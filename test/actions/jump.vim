scriptencoding utf-8

let s:suite = themis#suite('actions.jump')
let s:assert = themis#helper('assert')

let s:NORMAL_MODE_CONTEXT = {
\   'mode': 'n',
\   'visualmode': '',
\   'firstline': 1,
\   'lastline': 1
\}

function! s:suite.before_each() abort
  new
  let s:jump = caw#new('actions.jump')
endfunction

function! s:suite.after_each() abort
  bw!
endfunction

function! s:set_context(base, ...) abort
  let context = extend(deepcopy(a:base), a:0 ? a:1 : {})
  call caw#set_context(context)
endfunction


function! s:suite.comment_next() abort
  " set up
  setlocal filetype=c
  setlocal expandtab cindent tabstop=2 shiftwidth=2
  call setline(1, ['printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:jump.comment_next()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");', '// '])
endfunction

function! s:suite.comment_next_indent() abort
  " set up
  setlocal filetype=c
  setlocal expandtab cindent tabstop=2 shiftwidth=2
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:jump.comment_next()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    // ',
  \ '    func();',
  \ '  }'
  \])
endfunction

function! s:suite.comment_next_indent_2() abort
  " set up
  setlocal filetype=c
  setlocal expandtab cindent tabstop=2 shiftwidth=2
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'firstline': 2,
  \ 'lastline': 2,
  \})
  call cursor(2, 1)

  " execute
  call s:jump.comment_next()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '    // ',
  \ '  }'
  \])
endfunction

function! s:suite.comment_next_indent_3() abort
  " set up
  setlocal filetype=c
  setlocal expandtab cindent tabstop=2 shiftwidth=2
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'firstline': 3,
  \ 'lastline': 3,
  \})
  call cursor(3, 1)

  " execute
  call s:jump.comment_next()

  " assert
  " XXX: This result is caused by $VIMRUNTIME/indent/c.vim .
  " Because original input is not normal C code.
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }',
  \ '// ',
  \])
endfunction

function! s:suite.comment_prev() abort
  " set up
  setlocal filetype=c
  setlocal expandtab cindent tabstop=2 shiftwidth=2
  call setline(1, ['printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:jump.comment_prev()

  " assert
  call s:assert.equals(getline(1, '$'), ['// ', 'printf("hello\n");'])
endfunction

function! s:suite.comment_prev_indent() abort
  " set up
  setlocal filetype=c
  setlocal expandtab cindent tabstop=2 shiftwidth=2
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:jump.comment_prev()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '// ',
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
endfunction

function! s:suite.comment_prev_indent_2() abort
  " set up
  setlocal filetype=c
  setlocal expandtab cindent tabstop=2 shiftwidth=2
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'firstline': 2,
  \ 'lastline': 2,
  \})
  call cursor(2, 1)

  " execute
  call s:jump.comment_prev()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    // ',
  \ '    func();',
  \ '  }'
  \])
endfunction

function! s:suite.comment_prev_indent_3() abort
  " set up
  setlocal filetype=c
  setlocal expandtab cindent tabstop=2 shiftwidth=2
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'firstline': 3,
  \ 'lastline': 3,
  \})
  call cursor(3, 1)

  " execute
  call s:jump.comment_prev()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '    // ',
  \ '  }',
  \])
endfunction
