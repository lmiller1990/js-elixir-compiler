defmodule JsCompilerTest do
  use ExUnit.Case

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

  test "parser" do
    tokens = [
      {:function, "function"},
      {:identifier, "foo"},
      {:open_paren, "("},
      {:close_paren, ")"},
      {:open_curly, "{"},
      {:close_curly, "}"},
      {:eof}
    ]

    ast = Parser.parse(tokens, [])

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
end
