scriptencoding utf-8

let s:suite = themis#suite('comments.oneline')
let s:assert = themis#helper('assert')

function! s:suite.get_comment() abort
    let oneline = caw#new('comments.oneline')
    call s:test_get_comment(oneline, 'COMMENT1', 'COMMENT1', 'get_comment')
endfunction

function! s:suite.get_comment_vars() abort
    let oneline = caw#new('comments.oneline')
    call s:test_get_comment(oneline, 'COMMENT2', 'COMMENT2', 'get_comment_vars')
endfunction

function! s:suite.get_comment_vars_empty() abort
    let oneline = caw#new('comments.oneline')
    call s:test_get_comment(oneline, '', '', 'get_comment_vars')
endfunction

function! s:suite.get_comment_detect() abort
    let oneline = caw#new('comments.oneline')
    call s:test_get_comment_detect(oneline, '//%s', '//')
endfunction

function! s:suite.get_comment_detect_spaces() abort
    let oneline = caw#new('comments.oneline')
    call s:test_get_comment_detect(oneline, '// %s', '//')
endfunction

function! s:suite.get_comment_detect_empty() abort
    let oneline = caw#new('comments.oneline')
    call s:test_get_comment_detect(oneline, '', '')
endfunction


" Helper functions

function! s:test_get_comment(module, value, expected, func) abort
    let b:caw_oneline_comment = a:value
    try
        let R = call(a:module[a:func], [], a:module)
        call s:assert.equals(R, a:expected)
    finally
        unlet b:caw_oneline_comment
    endtry
endfunction

function! s:test_get_comment_detect(module, value, expected) abort
    let old_commentstring = &l:commentstring
    let &l:commentstring = a:value
    try
        call s:assert.equals(a:module.get_comment_detect(), a:expected)
    finally
        let &l:commentstring = old_commentstring
    endtry
endfunction
