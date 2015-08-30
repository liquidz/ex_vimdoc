defmodule DictTest do
  use   ExUnit.Case
  alias Vimdoc.Dict, as: VD

  test "aa" do
    expected = %{
      hello: "world",
      foo:   "bar",
      nest:  %{bar: "baz"},
      list:  [%{one: 1}, %{two: 2}]
    }

    actual   = VD.keyDict %{
      "hello" => "world",
      "list" =>  [%{"one" => 1}, %{two: 2}],
      foo:       "bar",
      nest:      %{"bar" => "baz"},
    }

    assert actual == expected
  end

end
