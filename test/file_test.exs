defmodule FileTest do
  use   ExUnit.Case
  alias Vimdoc.File, as: VF

  test "find existing path" do
    actual = VF.find("test")

    [
      ["test", "file_test.exs"],
      ["test", "files", "vimdoc.yml"],
    ] |> Enum.each(fn expected ->
      assert Path.join(expected) in actual
    end)
  end

  test "find not existing path" do
    assert VF.find("not_existing") == []
  end
end
