defmodule VimdocTest do
  use ExUnit.Case

  test "read_config" do
    conf = Path.join("test", "files") |> Vimdoc.read_config
    assert conf == %{foo: "bar", exclude: [".*baz.*"]}
  end

  test "plugin_files" do
    res = ["test", "files", "test_plugin"]
    |> Path.join
    |> Vimdoc.plugin_files

    assert res != []
  end

  test "exclude_files" do
    res = ["a", "ab", "b", "c", "d"]
    |> Vimdoc.exclude_files(["a.*", "[cd]"])

    assert res == ["b"]
  end

  test "main" do
    path   = ["test", "files", "test_plugin"] |> Path.join
    status = Vimdoc.main(path)
    assert status == :ok

    generated = [path, "doc", "foo.txt"] |> Path.join |> File.read!
    expected  = [path, "expected_helpfile.txt"] |> Path.join |> File.read!
    assert generated == expected
  end

end
