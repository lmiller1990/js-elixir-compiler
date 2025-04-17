defmodule JsCompilerTest do
  use ExUnit.Case

  def read_fixture(fixture) do
    base = Path.join(__DIR__, "fixtures/#{fixture}")
    js_task = Task.async(fn -> File.read(Path.join(base, "code.js")) end)
    py_task = Task.async(fn -> File.read(Path.join(base, "code.py")) end)
    {:ok, js} = Task.await(js_task)
    {:ok, py} = Task.await(py_task)
    [js, py]
  end

  def basic_app_js() do
    """
    function add(n) {
      return n + 1
    }

    add(4)
    """
  end

  def basic_app_py() do
    """
    def add(n):
      return n + 1

    add(4)
    """
  end

  test "tokenizer" do
    tokens = Tokenizer.run(basic_app_js())

    expected = [
      {:function, "function"},
      {:identifier, "add"},
      {:open_paren, "("},
      {:identifier, "n"},
      {:close_paren, ")"},
      {:open_curly, "{"},
      {:return, "return"},
      {:identifier, "n"},
      {:add, "+"},
      {:integer, "1"},
      {:close_curly, "}"},
      {:identifier, "add"},
      {:open_paren, "("},
      {:integer, "4"},
      {:close_paren, ")"},
      {:eof}
    ]

    assert tokens == expected
  end

  test "parser: function with no body" do
    tokens = [
      {:function, "function"},
      {:identifier, "foo"},
      {:open_paren, "("},
      {:close_paren, ")"},
      {:open_curly, "{"},
      {:close_curly, "}"},
      {:eof}
    ]

    ast = Parser.parse(tokens)

    expected = [
      {:py_function_def},
      {:py_identifier, "foo"},
      {:py_open_paren},
      {:py_close_paren},
      {:py_function_colon},
      {:py_function_end},
      {:py_eof}
    ]

    assert ast == expected
  end

  test "parser: function with body" do
    [js, _py] = read_fixture("function_with_body")
    tokens = Tokenizer.run(js)

    assert tokens == [
             {:function, "function"},
             {:identifier, "foo"},
             {:open_paren, "("},
             {:identifier, "n"},
             {:close_paren, ")"},
             {:open_curly, "{"},
             {:return, "return"},
             {:identifier, "n"},
             {:add, "+"},
             {:integer, "1"},
             {:semicolon, ";"},
             {:close_curly, "}"},
             {:identifier, "print"},
             {:open_paren, "("},
             {:identifier, "foo"},
             {:open_paren, "("},
             {:integer, "5"},
             {:close_paren, ")"},
             {:close_paren, ")"},
             {:semicolon, ";"},
             {:eof}
           ]

    ast = Parser.parse(tokens)

    assert ast == [
             {:py_function_def},
             {:py_identifier, "foo"},
             {:py_open_paren},
             {:py_identifier, "n"},
             {:py_close_paren},
             {:py_function_colon},
             {:py_return},
             {:py_identifier, "n"},
             {:py_add},
             {:py_integer, "1"},
             {:py_newline},
             {:py_function_end},
             {:py_identifier, "print"},
             {:py_open_paren},
             {:py_identifier, "foo"},
             {:py_open_paren},
             {:py_integer, "5"},
             {:py_close_paren},
             {:py_close_paren},
             {:py_newline},
             {:py_eof}
           ]
  end

  test "generator: function with no body" do
    ast = [
      {:py_function_def},
      {:py_identifier, "foo"},
      {:py_open_paren},
      {:py_close_paren},
      {:py_function_colon},
      {:py_function_end},
      {:py_eof}
    ]

    code = Codegen.generate(ast, "")

    [_, py] = read_fixture("function_no_body")

    assert code == py
  end

  test "generator: function with body" do
    ast = [
      {:py_function_def},
      {:py_identifier, "foo"},
      {:py_open_paren},
      {:py_identifier, "n"},
      {:py_close_paren},
      {:py_function_colon},
      {:py_return},
      {:py_identifier, "n"},
      {:py_add},
      {:py_integer, "1"},
      {:py_newline},
      {:py_function_end},
      {:py_identifier, "print"},
      {:py_open_paren},
      {:py_identifier, "foo"},
      {:py_open_paren},
      {:py_integer, "5"},
      {:py_close_paren},
      {:py_close_paren},
      {:py_newline},
      {:py_eof}
    ]

    code = Codegen.generate(ast, "")

    [_, py] = read_fixture("function_with_body")

    assert String.trim_trailing(code) == String.trim_trailing(py)
    IO.puts(code)

    {output, 0} = System.cmd("python", ["-c", code])
    assert String.trim_trailing(output) == "6"
  end
end
