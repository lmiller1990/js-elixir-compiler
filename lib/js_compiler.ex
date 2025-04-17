defmodule Compiler do
  def read_src do
    case File.read("app.js") do
      {:ok, file} -> file
      {:error, :enoent} -> IO.puts("Did not found it")
    end
  end
end

defmodule Tokenizer do
  def run(src) do
    tokens =
      src
      |> tokenize()
      |> Enum.map(&match_token/1)

    tokens ++ [{:eof}]
  end

  def tokenize(src) do
    src
    |> String.replace("(", " ( ")
    |> String.replace(")", " ) ")
    |> String.replace("{", " { ")
    |> String.replace("}", " } ")
    |> String.replace("+", " + ")
    |> String.replace(";", " ; ")
    |> String.replace("\n", " ")
    |> String.split(~r/\s+/, trim: true)
  end

  def match_token(token) do
    cond do
      token == "function" -> {:function, token}
      token == "return" -> {:return, token}
      token == "+" -> {:add, token}
      token == "(" -> {:open_paren, token}
      token == ")" -> {:close_paren, token}
      token == "{" -> {:open_curly, token}
      token == "}" -> {:close_curly, token}
      token == ";" -> {:semicolon, token}
      String.match?(token, ~r/^\d+$/) -> {:integer, token}
      String.match?(token, ~r/[A-Za-z]/) -> {:identifier, token}
      true -> {:unknown, "\"#{token}\""}
    end
  end

  def log_token_info({type, content}) do
    IO.puts("#{content} type => #{type}")
  end
end

defmodule Parser do
  def parse(nodes) do
    Enum.reverse(parse(nodes, []))
  end

  def parse([{:eof}], ast) do
    [{:py_eof} | ast]
  end

  def parse([{:function, _} | rest], ast) do
    ast = [{:py_function_def} | ast]
    parse(rest, ast)
  end

  def parse([{:return, _} | rest], ast) do
    ast = [{:py_return} | ast]
    parse(rest, ast)
  end

  def parse([{:add, _} | rest], ast) do
    ast = [{:py_add} | ast]
    parse(rest, ast)
  end

  def parse([{:integer, int} | rest], ast) do
    ast = [{:py_integer, int} | ast]
    parse(rest, ast)
  end

  def parse([{:semicolon, _} | rest], ast) do
    ast = [{:py_newline} | ast]
    parse(rest, ast)
  end

  def parse([{:identifier, label} | rest], ast) do
    ast = [{:py_identifier, label} | ast]
    parse(rest, ast)
  end

  def parse([{:open_paren, _} | rest], ast) do
    ast = [{:py_open_paren} | ast]
    parse(rest, ast)
  end

  def parse([{:close_paren, _} | rest], ast) do
    ast = [{:py_close_paren} | ast]
    parse(rest, ast)
  end

  def parse([{:open_curly, _} | rest], ast) do
    ast = [{:py_function_colon} | ast]
    parse(rest, ast)
  end

  def parse([{:close_curly, _} | rest], ast) do
    ast = [{:py_function_end} | ast]
    parse(rest, ast)
  end
end

defmodule Codegen do
  def generate([{:py_function_def} | rest], code) do
    code = code <> "def "
    generate(rest, code)
  end

  def generate([{:py_eof}], code) do
    code <> "\n"
  end

  def generate([{:py_identifier, label} | rest], code) do
    code = code <> label
    generate(rest, code)
  end

  def generate([{:py_open_paren} | rest], code) do
    code = code <> "("
    generate(rest, code)
  end

  def generate([{:py_close_paren} | rest], code) do
    code = code <> ")"
    generate(rest, code)
  end

  def generate([{:py_function_colon}, {:py_function_end} | rest], code) do
    code = code <> ":\n" <> String.duplicate(" ", 4) <> "pass"
    generate(rest, code)
  end

  def generate([{:py_function_colon} | rest], code) do
    code = code <> ":\n" <> String.duplicate(" ", 4)
    generate(rest, code)
  end

  def generate([{:py_function_end} | rest], code) do
    code = code <> "\n\n"
    generate(rest, code)
  end

  def generate([{:py_return} | rest], code) do
    code = code <> "return "
    generate(rest, code)
  end

  def generate([{:py_add} | rest], code) do
    code = code <> " + "
    generate(rest, code)
  end

  def generate([{:py_integer, int} | rest], code) do
    code = code <> "#{int}"
    generate(rest, code)
  end

  def generate([{:py_newline} | rest], code) do
    code = code <> "\n"
    generate(rest, code)
  end
end
