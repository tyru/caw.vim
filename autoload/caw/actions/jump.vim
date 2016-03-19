scriptencoding utf-8

function! caw#actions#jump#new() abort
    return deepcopy(s:jump)
endfunction


let s:jump = {}

function! s:jump.comment_next() abort
    return call('s:caw_jump_comment', [1], self)
endfunction
let s:jump['comment-next'] = s:jump.comment_next

function! s:jump.comment_prev() abort
    return call('s:caw_jump_comment', [0], self)
endfunction
let s:jump['comment-prev'] = s:jump.comment_prev

function! s:caw_jump_comment(next) abort
    let cmt = caw#new('comments.oneline').get_comment()
    if empty(cmt)
        return
    endif

    " Begin a new line and insert
    " the online comment leader with whitespaces.
    " And start Insert mode at the end of the inserted line.
    let lnum = caw#context().firstline
    if a:next
        let save_fo = &l:formatoptions
        setlocal formatoptions-=o
        try
            execute 'normal! o' . cmt .  caw#get_var('caw_jump_sp')
        finally
            let &l:formatoptions = save_fo
        endtry
        call cursor(lnum + 1, 1)
        call caw#startinsert('A')
    else
        let save_fo = &l:formatoptions
        setlocal formatoptions-=o
        try
            execute 'normal! O' . cmt .  caw#get_var('caw_jump_sp')
        finally
            let &l:formatoptions = save_fo
        endtry
        call cursor(lnum, 1)
        call caw#startinsert('A')
    endif
endfunction
