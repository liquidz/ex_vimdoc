""
" Execute |foo#plus|
command! Foo call foo#plus(1, 2)

""
" @name :BarN
" Execute |foo#plus|(3, n)
command! -nargs=1 Bar call foo#plus(3, <args>)
