scriptencoding utf-8

function! caw#actions#traits#comment_detectable#new() abort
    return deepcopy(s:comment_detectable)
endfunction


let s:comment_detectable = {}

" Below methods are missing.
" Derived object must implement those.
"
" s:comment_detectable.has_comment(),
" s:comment_detectable.has_comment_visual() require:
" - Derived.has_comment_normal()

function! s:comment_detectable.has_comment() abort
    let context = caw#context()
    if context.mode ==# 'n'
        call self.has_comment_normal(context.firstline)
    else
        return self.has_comment_visual()
    endif
endfunction

function! s:comment_detectable.has_comment_visual() abort
    for lnum in range(
    \   caw#context().firstline,
    \   caw#context().lastline
    \)
        if self.has_comment_normal(lnum)
            return 1
        endif
    endfor
    return 0
endfunction

function! s:comment_detectable.has_all_comment() abort
    " CommentDetectable.has_all_comment() returns true
    " when all lines are consisted of commented lines and *blank lines*.
    for lnum in range(
    \   caw#context().firstline,
    \   caw#context().lastline
    \)
        if caw#getline(lnum) !~# '^\s*$' && !self.has_comment_normal(lnum)
            return 0
        endif
    endfor
    return 1
endfunction
