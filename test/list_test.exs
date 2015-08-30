defmodule ListTest do
  use   ExUnit.Case
  alias Vimdoc.List, as: VL

  test "strip" do
    data = ["", "foo", "", "bar", "", ""]
    assert VL.strip(data) == ["foo", "", "bar"]
  end
end
