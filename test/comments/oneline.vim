scriptencoding utf-8

let s:suite = themis#suite('comments.oneline')
let s:assert = themis#helper('assert')

let s:NORMAL_MODE_CONTEXT = {
\   'mode': 'n',
\   'visualmode': '',
\   'filetype': '',
\   'context_filetype': '',
\   'firstline': 1,
\   'lastline': 1,
\}

function! s:suite.can_load_c_ftplugin() abort
  setlocal filetype=c
  call s:assert.equals(b:caw_oneline_comment, '//')
endfunction

function! s:suite.can_load_vim_ftplugin() abort
  setlocal filetype=vim
  call s:assert.is_function(b:caw_oneline_comment)
endfunction

function! s:suite.get_comments() abort
  setlocal filetype=
  let oneline = caw#new('comments.oneline')
  call s:test_get_comment(oneline, 'COMMENT1', '//%s', ['COMMENT1', '//'], 'get_comments')
endfunction

function! s:suite.get_possible_comments() abort
  setlocal filetype=
  let oneline = caw#new('comments.oneline')
  call s:test_get_comment(oneline, '#', '//%s', ['//', '#'], 'get_possible_comments', [deepcopy(s:NORMAL_MODE_CONTEXT)])
endfunction

function! s:suite.get_comment_vars() abort
  setlocal filetype=
  let oneline = caw#new('comments.oneline')
  call s:test_get_comment(oneline, 'COMMENT2', '', ['COMMENT2'], 'get_comment_vars')
endfunction

function! s:suite.get_comment_vars_empty() abort
  setlocal filetype=
  let oneline = caw#new('comments.oneline')
  call s:test_get_comment(oneline, '', '', [], 'get_comment_vars')
endfunction

function! s:suite.get_comment_detect() abort
  setlocal filetype=
  let oneline = caw#new('comments.oneline')
  call s:test_get_comment_detect(oneline, '//%s', ['//'])
endfunction

function! s:suite.get_comment_detect_spaces() abort
  setlocal filetype=
  let oneline = caw#new('comments.oneline')
  call s:test_get_comment_detect(oneline, '// %s', ['//'])
endfunction

function! s:suite.get_comment_detect_empty() abort
  setlocal filetype=
  let oneline = caw#new('comments.oneline')
  call s:test_get_comment_detect(oneline, '', [])
endfunction


" Helper functions

function! s:test_get_comment(module, var_value, cms_value, expected, func, ...) abort
  let additional_args = a:0 ? a:1 : []
  let old_commentstring = &l:commentstring
  let &l:commentstring = a:cms_value
  let b:caw_oneline_comment = a:var_value
  try
    let R = call(a:module[a:func], [] + additional_args, a:module)
    call s:assert.equals(R, a:expected)
  finally
    unlet b:caw_oneline_comment
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
