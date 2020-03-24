scriptencoding utf-8

let s:suite = themis#suite('comments.wrap_multiline')
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
  let wrap_multiline = caw#new('comments.wrap_multiline')
  let value = {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'}
  let expected = copy(value)
  call s:test_get_comment(wrap_multiline, value, [expected], 'get_comments')
endfunction

function! s:suite.get_possible_comments() abort
  setlocal filetype=
  let wrap_multiline = caw#new('comments.wrap_multiline')
  let value = {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'}
  let expected = copy(value)
  call s:test_get_comment(wrap_multiline, value, [expected], 'get_possible_comments', [deepcopy(s:NORMAL_MODE_CONTEXT)])
endfunction

function! s:suite.get_comment_vars() abort
  setlocal filetype=
  let wrap_multiline = caw#new('comments.wrap_multiline')
  let value = {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'}
  let expected = copy(value)
  call s:test_get_comment(wrap_multiline, value, [expected], 'get_comment_vars')
endfunction

function! s:suite.get_comment_vars_empty() abort
  setlocal filetype=
  let wrap_multiline = caw#new('comments.wrap_multiline')
  let value = {}
  call s:test_get_comment(wrap_multiline, value, [], 'get_comment_vars')
endfunction


" Helper functions

function! s:test_get_comment(module, value, expected, func, ...) abort
  let additional_args = a:0 ? a:1 : []
  let b:caw_wrap_multiline_comment = a:value
  try
    let R = call(a:module[a:func], [] + additional_args, a:module)
    call s:assert.equals(R, a:expected)
  finally
    unlet b:caw_wrap_multiline_comment
  endtry
endfunction
