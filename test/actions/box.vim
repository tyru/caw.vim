scriptencoding utf-8

let s:suite = themis#suite('actions.box')
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
    let s:box = caw#new('actions.box')
endfunction

function! s:suite.after_each() abort
    call vmock#verify()
    call vmock#clear()
    call caw#__clear_context__()
endfunction


function! s:suite.comment() abort
    " vmock
    call vmock#mock('caw#getline').with(1, 1).return([
    \   'printf("hello\n");'
    \])
    call vmock#mock('caw#append').with(0, [
    \   '/**********************/',
    \   '/* printf("hello\n"); */',
    \   '/**********************/'
    \])

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_wrap_multiline_comment,
    \       {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'})
    call s:box.comment()
endfunction

function! s:suite.comment_indent_noexpandtab() abort
    " vmock
    call vmock#mock('caw#getline').with(1, 1).return([
    \   "\t" . 'printf("hello\n");'
    \])
    call vmock#mock('caw#make_indent_str').with(1).return(
    \   "\t"
    \)
    call vmock#mock('caw#append').with(0, [
    \   "\t" . '/**********************/',
    \   "\t" . '/* printf("hello\n"); */',
    \   "\t" . '/**********************/'
    \])

    " options
    setlocal noexpandtab

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_wrap_multiline_comment,
    \       {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'})
    call s:box.comment()
endfunction

function! s:suite.comment_indent_expandtab() abort
    " vmock
    call vmock#mock('caw#getline').with(1, 1).return([
    \   '  printf("hello\n");'
    \])
    call vmock#mock('caw#make_indent_str').with(2).return(
    \   '  '
    \)
    call vmock#mock('caw#append').with(0, [
    \   '  /**********************/',
    \   '  /* printf("hello\n"); */',
    \   '  /**********************/'
    \])

    " options
    " (actions.box doesn't see 'tabstop',
    " it sees current line's indent string)
    setlocal expandtab

    " context
    call caw#__set_context__(deepcopy(s:NORMAL_MODE_CONTEXT))

    call s:assert.equals(b:caw_wrap_multiline_comment,
    \       {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'})
    call s:box.comment()
endfunction
