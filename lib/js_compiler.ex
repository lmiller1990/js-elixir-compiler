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
    src
    |> tokenize()
    |> Enum.map(&match_token/1)
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
      String.match?(token, ~r/\s/) -> {:whitespace, token}
      String.match?(token, ~r/^function$/) -> {:function, token}
      String.match?(token, ~r/^return$/) -> {:return, token}
      String.match?(token, ~r/^\+$/) -> {:add, token}
      String.match?(token, ~r/^[0-9]$/) -> {:integer, token}
      String.match?(token, ~r/[A-Za-z]/) -> {:identifier, token}
      String.match?(token, ~r/\(/) -> {:open_paren, token}
      String.match?(token, ~r/\)/) -> {:close_paren, token}
      String.match?(token, ~r/\{/) -> {:open_curly, token}
      String.match?(token, ~r/\}/) -> {:close_curly, token}
      true -> {:unknown, "\"#{token}\""}
    end
  end

  def log_token_info({type, content}) do
    IO.puts("#{content} type => #{type}")
  end
end

tokens = Compiler.read_src() |> Tokenizer.run()
Enum.each(tokens, &Tokenizer.log_token_info/1)
