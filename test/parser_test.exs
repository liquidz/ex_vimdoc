defmodule ParserTest do
  use   ExUnit.Case
  alias Vimdoc.Parser, as: VP

  test "tokenize" do
    result = """
    aaa
    ""
    " foo
    "
    bbb

    " bar
    ccc

    ""
    " baz
    "   bazz
    ddd
    eee

    ""
    " empty line start
    "
    " end
    fff
    """
    |> String.split(~r"\r?\n")
    |> VP.tokenize([], [], false)

    assert result == [
      {["foo"], "bbb"},
      {["baz", "  bazz"], "ddd"},
      {["empty line start", "", "end"], "fff"},
    ]
  end

  test "analyze introduction" do
    expected = %{type: "introduction", lines: ["help"]}
    [
      {["help"], ""},
    ]
    |> VP.analyze
    |> Enum.each(&(assert &1 == expected))
  end

  test "analyze variables" do
    expected = %{type: "variable", lines: ["help"], name: "g:foo"}
    [
      {["help"], "let g:foo = 1"},
      {["@type variable", "help"], "let g:foo = 1"},
      {["@name g:foo", "help"], "let g:bar = 1"},
    ]
    |> VP.analyze
    |> Enum.each(&(assert &1 == expected))
  end

  test "analyze annotations" do
    expected = %{type: "variable", name: "hello", foo: "bar"}
    data = ["@type variable", "@name  hello", "@foo bar  "]

    assert VP.analyze_annotation(data) == expected
  end

  test "analyze invalid annotation" do
    data = ["", " ", "@foo"]
    assert VP.analyze_annotation(data) == %{}
  end

  test "analyze functions" do
    expected = %{type: "function", lines: ["help"], name: "foo#bar", param: "(a1, a2)"}
    [
      {["help"], "function foo#bar(a1, a2)"},
      {["help"], "function foo#bar(a1, a2) abort"},
      {["help"], "function! foo#bar(a1, a2) abort"},
      {["@name foo#bar", "help"], "function! neko#nyan(a1, a2) abort"},
    ]
    |> VP.analyze
    |> Enum.each(&(assert &1 == expected))
  end

  test "analyze no param functions" do
    expected = %{type: "function", lines: ["help"], name: "foo#bar", param: "()"}
    [
      {["help"], "function foo#bar()"},
      {["help"], "function foo#bar() abort"},
      {["help"], "function! foo#bar() abort"},
      {["@name foo#bar", "help"], "function! neko#nyan() abort"},
    ]
    |> VP.analyze
    |> Enum.each(&(assert &1 == expected))
  end

  test "analyze commands" do
    expected = %{type: "command", lines: ["help"], name: ":FooBar"}
    [
      {["help"], "command FooBar call foo#bar()"},
      {["help"], "command! FooBar call foo#bar()"},
      {["help"], "command! -option FooBar call foo#bar()"},
    ]
    |> VP.analyze
    |> Enum.each(&(assert &1 == expected))
  end

  test "analyze mappings" do
    expected = %{type: "mapping", lines: ["help"], name: "<Plug>(foo_bar)"}
    [
      {["help"], "nmap <Plug>(foo_bar) :<C-u>FooBar<CR>"},
      {["help"], "nmap <silent> <Plug>(foo_bar) :<C-u>FooBar<CR>"},
      {["help"], "nnoremap <Plug>(foo_bar) :<C-u>FooBar<CR>"},
      {["help"], "nnoremap <silent> <Plug>(foo_bar) :<C-u>FooBar<CR>"},
    ]
    |> VP.analyze
    |> Enum.each(&(assert &1 == expected))
  end

  test "parse" do
    expected = [
      %{type: "introduction", lines: ["intro1", "intro2"]},
      %{type: "variable", lines: ["help1"], name: "g:aa#bb"},
      %{type: "function", lines: ["help2"], name: "dd#ee", param: "(ff)"},
    ]

    result = VP.parse("""
    ""
    " intro1
    " intro2

    ""
    " help1
    let g:aa#bb = "cc"

    ""
    " help2
    function! dd#ee(ff) abort
      return 'gg'
    endfunction
    """)

    assert result == expected
  end
end
