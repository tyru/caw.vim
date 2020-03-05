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

function! s:comment_detectable.search_synstack(lnum, cmt, pattern) abort
    let line = caw#getline(a:lnum)
    let cols = []
    let idx  = -1
    while 1
        let idx = stridx(line, a:cmt, (idx ==# -1 ? 0 : idx + 1))
        if idx == -1
            break
        endif
        call add(cols, idx + 1)
    endwhile

    if empty(cols)
        return -1
    endif

    for col in cols
        for id in caw#synstack(a:lnum, col)
            if caw#synIDattr(synIDtrans(id), 'name') =~# a:pattern
                return col
            endif
        endfor
    endfor
    return -1
endfunction
