scriptencoding utf-8

function! caw#actions#traits#uncommentable#new() abort
  return deepcopy(s:uncommentable)
endfunction


let s:uncommentable = {}

" Below methods are missing.
" Derived object must implement them.
"
" Requires:
" - get_uncomment_line(lnum, options)


function! s:uncommentable.uncomment() abort
  let context = caw#context()
  if context.mode ==# 'n'
    call self.uncomment_normal(context.firstline)
  else
    call self.uncomment_visual()
  endif
endfunction

function! s:uncommentable.uncomment_visual() abort
  let context = caw#context()
  let lines = []
  for lnum in range(context.firstline, context.lastline)
    let lines += [self.get_uncomment_line(lnum, {})]
  endfor
  call caw#replace_lines(context.firstline, context.lastline, lines)
endfunction

function! s:uncommentable.uncomment_normal(lnum) abort
  call caw#replace_line(a:lnum, self.get_uncomment_line(a:lnum, {}))
endfunction
