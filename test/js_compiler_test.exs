defmodule JsCompilerTest do
  use ExUnit.Case

  def basic_app() do
    """
    function add(n) {
      return n + 1
    }

    add(4)
    """
  end

  test "runs" do
    tokens = Tokenizer.run(basic_app())

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
      {:close_paren, ")"}
    ]

    assert tokens == expected
  end
end
