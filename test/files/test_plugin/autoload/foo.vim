""
" hello
" world
"

""
" @variable
" enabling flag
"
if !exists('g:foo#enable')
  let g:foo#enable = 0
endif

""
" Return (x + y)
" this is test function
" Example: >
"   foo#plus(10, 20)
" <
function! foo#plus(x, y) abort
  return a:x + a:y
endfunction
