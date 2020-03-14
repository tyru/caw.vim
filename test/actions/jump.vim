scriptencoding utf-8

let s:suite = themis#suite('actions.jump')
let s:assert = themis#helper('assert')

let s:NORMAL_MODE_CONTEXT = {
\   'mode': 'n',
\   'visualmode': '',
\   'firstline': 1,
\   'lastline': 1
\}

function! s:suite.before() abort
    " Load filetype=c comment strings.
    " setlocal filetype=c    " XXX: Why this isn't working?
    unlet! b:did_caw_ftplugin
    runtime! after/ftplugin/c/caw.vim
endfunction

function! s:suite.before_each() abort
    let s:jump = caw#new('actions.jump')
endfunction

function! s:suite.after_each() abort
    call vmock#verify()
    call vmock#clear()
    call caw#__clear_context__()
endfunction


function! s:suite.comment_next() abort
    " vmock
    call vmock#mock('caw#actions#jump#ex_opencmd').with(1, '// ')
    call vmock#mock('caw#cursor').with(2, vmock#any())
    call vmock#mock('caw#startinsert').with('A')

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_oneline_comment, '//')
    call s:jump.comment_next()
endfunction

function! s:suite.comment_prev() abort
    " vmock
    call vmock#mock('caw#actions#jump#ex_opencmd').with(0, '// ')
    call vmock#mock('caw#startinsert').with('A')

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_oneline_comment, '//')
    call s:jump.comment_prev()
endfunction
