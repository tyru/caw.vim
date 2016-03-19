scriptencoding utf-8

let s:suite = themis#suite('basic')
let s:assert = themis#helper('assert')

let s:NORMAL_MODE_CONTEXT = {
\   'mode': 'n',
\   'visualmode': '',
\   'firstline': 1,
\   'lastline': 1
\}

function! s:suite.before() abort
    " Load filetype=vim comment strings.
    " setlocal filetype=vim    " TODO
    runtime! after/ftplugin/vim/caw.vim
endfunction

function! s:suite.before_each() abort
    let s:tildepos = caw#new('actions.tildepos')
endfunction

function! s:suite.after_each() abort
    call vmock#verify()
    call vmock#clear()
    call caw#__clear_context__()
endfunction


function! s:suite.comment() abort
    " vmock
    call vmock#mock('caw#getline').return('let foo = "foo"')
    call vmock#mock('caw#setline').with(1, '" let foo = "foo"')

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_oneline_comment, '"')
    call s:tildepos.comment()
endfunction

function! s:suite.comment_indent() abort
    " vmock
    call vmock#mock('caw#getline').return('  let foo = "foo"')
    call vmock#mock('caw#setline').with(1, '  " let foo = "foo"')

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_oneline_comment, '"')
    call s:tildepos.comment()
endfunction

function! s:suite.uncomment() abort
    " vmock
    call vmock#mock('caw#getline').return('" let foo = "foo"')
    call vmock#mock('caw#setline').with(1, 'let foo = "foo"')

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_oneline_comment, '"')
    call s:tildepos.uncomment()
endfunction

function! s:suite.uncomment_indent() abort
    " vmock
    call vmock#mock('caw#getline').return('  " let foo = "foo"')
    call vmock#mock('caw#setline').with(1, '  let foo = "foo"')

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_oneline_comment, '"')
    call s:tildepos.uncomment()
endfunction
