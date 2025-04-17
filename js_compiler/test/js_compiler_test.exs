defmodule JsCompilerTest do
  use ExUnit.Case
  doctest JsCompiler

  test "greets the world" do
    assert JsCompiler.hello() == :world
  end
end
