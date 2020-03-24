scriptencoding utf-8

let s:suite = themis#suite('comments.wrap_oneline')
let s:assert = themis#helper('assert')

let s:NORMAL_MODE_CONTEXT = {
\   'mode': 'n',
\   'visualmode': '',
\   'filetype': '',
\   'context_filetype': '',
\   'firstline': 1,
\   'lastline': 1,
\}

function! s:suite.get_comments() abort
  setlocal filetype=
  let wrap_oneline = caw#new('comments.wrap_oneline')
  call s:test_get_comment(wrap_oneline, ['L', 'R'], '/*%s*/', [['L', 'R'], ['/*', '*/']], 'get_comments')
endfunction

function! s:suite.get_possible_comments() abort
  setlocal filetype=
  let wrap_oneline = caw#new('comments.wrap_oneline')
  call s:test_get_comment(wrap_oneline, ['L', 'R'], '/*%s*/', [['/*', '*/'], ['L', 'R']], 'get_possible_comments', [deepcopy(s:NORMAL_MODE_CONTEXT)])
endfunction

function! s:suite.get_comment_vars() abort
  setlocal filetype=
  let wrap_oneline = caw#new('comments.wrap_oneline')
  call s:test_get_comment(wrap_oneline, ['L2', 'R2'], '/*%s*/', [['L2', 'R2']], 'get_comment_vars')
endfunction

function! s:suite.get_comment_vars_empty() abort
  setlocal filetype=
  let wrap_oneline = caw#new('comments.wrap_oneline')
  call s:test_get_comment(wrap_oneline, [], '/*%s*/', [], 'get_comment_vars')
endfunction

function! s:suite.get_comment_detect() abort
  setlocal filetype=
  let wrap_oneline = caw#new('comments.wrap_oneline')
  call s:test_get_comment_detect(wrap_oneline, '/*%s*/', [['/*', '*/']])
endfunction

function! s:suite.get_comment_detect_spaces() abort
  setlocal filetype=
  let wrap_oneline = caw#new('comments.wrap_oneline')
  call s:test_get_comment_detect(wrap_oneline, '/* %s */', [['/*', '*/']])
endfunction

function! s:suite.get_comment_detect_empty() abort
  setlocal filetype=
  let wrap_oneline = caw#new('comments.wrap_oneline')
  call s:test_get_comment_detect(wrap_oneline, '', [])
endfunction


" Helper functions

function! s:test_get_comment(module, var_value, cms_value, expected, func, ...) abort
  let additional_args = a:0 ? a:1 : []
  let old_commentstring = &l:commentstring
  let &l:commentstring = a:cms_value
  let b:caw_wrap_oneline_comment = a:var_value
  try
    let R = call(a:module[a:func], [] + additional_args, a:module)
    call s:assert.equals(R, a:expected)
  finally
    unlet b:caw_wrap_oneline_comment
    let &l:commentstring = old_commentstring
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
