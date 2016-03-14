scriptencoding utf-8

function! caw#actions#jump#new() abort
    return deepcopy(s:jump)
endfunction


let s:jump = {}

function! s:jump.comment_next() dict
    return call('s:caw_jump_comment', [1], self)
endfunction
let s:jump['comment-next'] = s:jump.comment_next

function! s:jump.comment_prev() dict
    return call('s:caw_jump_comment', [0], self)
endfunction
let s:jump['comment-prev'] = s:jump.comment_prev

function! s:caw_jump_comment(next) dict
    let cmt = caw#new('comments.oneline').get_comment()
    if empty(cmt)
        return
    endif

    let lnum = line('.')
    if a:next
        " Begin a new line and insert
        " the online comment leader with whitespaces.
        execute 'normal! o' . cmt .  caw#get_var('caw_jump_sp')
        " Start Insert mode at the end of the inserted line.
        call cursor(lnum + 1, 1)
        startinsert!
    else
        " NOTE: `lnum` is target lnum.
        " because new line was inserted just now.
        execute 'normal! O' . cmt . caw#get_var('caw_jump_sp')
        " Start Insert mode at the end of the inserted line.
        call cursor(lnum, 1)
        startinsert!
    endif
endfunction
