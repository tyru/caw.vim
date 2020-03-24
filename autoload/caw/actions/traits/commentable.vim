scriptencoding utf-8

function! caw#actions#traits#commentable#new() abort
  return deepcopy(s:commentable)
endfunction


let s:commentable = {}

" Below methods are missing.
" Derived object must implement them.
"
" Requires:
" - get_comment_line(lnum, options)
" - startinsert(lnum)

function! s:commentable.comment() abort
  let context = caw#context()
  if context.mode ==# 'n'
    let cmd = self.startinsert(context.firstline)
    call self.comment_normal(context.firstline)
    if cmd !=# ''
      execute cmd
    endif
  else
    call self.comment_visual()
  endif
endfunction

function! s:commentable.comment_visual() abort
  let context = caw#context()
  let lines = []
  for lnum in range(context.firstline, context.lastline)
    let lines += [self.get_comment_line(lnum, {})]
  endfor
  call caw#replace_lines(context.firstline, context.lastline, lines)
endfunction

function! s:commentable.comment_normal(lnum) abort
  call caw#replace_line(a:lnum, self.get_comment_line(a:lnum, {}))
endfunction
