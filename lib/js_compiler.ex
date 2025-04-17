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
  def parse([{:eof}], ast) do
    ast ++ [{:py_eof}]
  end

  def parse([{:function, _} | rest], ast) do
    ast = ast ++ [{:py_function_def}]
    parse(rest, ast)
  end

  def parse([{:identifier, label} | rest], ast) do
    ast = ast ++ [{:py_identifier, label}]
    parse(rest, ast)
  end

  def parse([{:open_paren, _} | rest], ast) do
    ast = ast ++ [{:py_open_paren}]
    parse(rest, ast)
  end

  def parse([{:close_paren, _} | rest], ast) do
    ast = ast ++ [{:py_close_paren}]
    parse(rest, ast)
  end

  def parse([{:open_curly, _} | rest], ast) do
    ast = ast ++ [{:py_function_colon}]
    parse(rest, ast)
  end

  def parse([{:close_curly, _} | rest], ast) do
    ast = ast ++ [{:py_function_end}]
    parse(rest, ast)
  end
end
