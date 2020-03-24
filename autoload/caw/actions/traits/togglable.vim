scriptencoding utf-8

function! caw#actions#traits#togglable#new() abort
  return deepcopy(s:togglable)
endfunction


let s:togglable = {}

" Below methods are missing.
" Derived object must implement them.
"
" Requires:
" - has_all_comment(start, end)
" - uncomment()
" - comment()


function! s:togglable.toggle() abort
  let context = caw#context()
  if context.mode ==# 'n'
    if self.has_all_comment(context.firstline, context.lastline)
      " The line has a comment string.
      call self.uncomment()
    else
      " The line doesn't have a comment string.
      call self.comment()
    endif
  else
    if self.has_all_comment(context.firstline, context.lastline)
      " All lines have comment strings.
      call self.uncomment()
    else
      " Some lines have comment strings, or no lines have comment strings.
      call self.comment()
    endif
  endif
endfunction
