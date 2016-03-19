scriptencoding utf-8

function! caw#actions#traits#commentable#new() abort
    return deepcopy(s:commentable)
endfunction


let s:commentable = {}

" Below methods are missing.
" Derived object must implement those.
"
" s:commentable.comment() requires:
" - Derived.comment_normal()

function! s:commentable.comment() abort
    let context = caw#context()
    if context.mode ==# 'n'
        call self.comment_normal(context.firstline)
    else
        call self.comment_visual()
    endif
endfunction

function! s:commentable.comment_visual() abort
    " Behave linewisely.
    for lnum in range(
    \   caw#context().firstline,
    \   caw#context().lastline
    \)
        call self.comment_normal(lnum)
    endfor
endfunction

