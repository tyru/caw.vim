scriptencoding utf-8

let s:suite = themis#suite('comments.wrap_oneline')
let s:assert = themis#helper('assert')

function! s:suite.get_comment() abort
    let wrap_oneline = caw#new('comments.wrap_oneline')
    call s:test_get_comment(wrap_oneline, ['L', 'R'], ['L', 'R'], 'get_comment')
endfunction

function! s:suite.get_comment_vars() abort
    let wrap_oneline = caw#new('comments.wrap_oneline')
    call s:test_get_comment(wrap_oneline, ['L2', 'R2'], ['L2', 'R2'], 'get_comment_vars')
endfunction

function! s:suite.get_comment_vars_empty() abort
    let wrap_oneline = caw#new('comments.wrap_oneline')
    call s:test_get_comment(wrap_oneline, [], [], 'get_comment_vars')
endfunction

function! s:suite.get_comment_detect() abort
    let wrap_oneline = caw#new('comments.wrap_oneline')
    call s:test_get_comment_detect(wrap_oneline, '/*%s*/', ['/*', '*/'])
endfunction

function! s:suite.get_comment_detect_spaces() abort
    let wrap_oneline = caw#new('comments.wrap_oneline')
    call s:test_get_comment_detect(wrap_oneline, '/* %s */', ['/*', '*/'])
endfunction

function! s:suite.get_comment_detect_empty() abort
    let wrap_oneline = caw#new('comments.wrap_oneline')
    call s:test_get_comment_detect(wrap_oneline, '', [])
endfunction


" Helper functions

function! s:test_get_comment(module, value, expected, func) abort
    let b:caw_wrap_oneline_comment = a:value
    try
        let R = call(a:module[a:func], [], a:module)
        call s:assert.equals(R, a:expected)
    finally
        unlet b:caw_wrap_oneline_comment
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
