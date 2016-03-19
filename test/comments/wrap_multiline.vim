scriptencoding utf-8

let s:suite = themis#suite('comments.wrap_multiline')
let s:assert = themis#helper('assert')

function! s:suite.get_comment() abort
    let wrap_multiline = caw#new('comments.wrap_multiline')
    let value = {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'}
    let expected = copy(value)
    call s:test_get_comment(wrap_multiline, value, expected, 'get_comment')
endfunction

function! s:suite.get_comment_vars() abort
    let wrap_multiline = caw#new('comments.wrap_multiline')
    let value = {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'}
    let expected = copy(value)
    call s:test_get_comment(wrap_multiline, value, expected, 'get_comment_vars')
endfunction

function! s:suite.get_comment_vars_empty() abort
    let wrap_multiline = caw#new('comments.wrap_multiline')
    let value = {}
    let expected = {}
    call s:test_get_comment(wrap_multiline, value, expected, 'get_comment_vars')
endfunction


" Helper functions

function! s:test_get_comment(module, value, expected, func) abort
    let b:caw_wrap_multiline_comment = a:value
    try
        let R = call(a:module[a:func], [], a:module)
        call s:assert.equals(R, a:expected)
    finally
        unlet b:caw_wrap_multiline_comment
    endtry
endfunction
