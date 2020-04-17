scriptencoding utf-8

let s:suite = themis#suite('actions.zeropos')
let s:assert = themis#helper('assert')

let s:NORMAL_MODE_CONTEXT = {
\   'mode': 'n',
\   'visualmode': '',
\   'firstline': 1,
\   'lastline': 1
\}

let s:VISUAL_MODE_CONTEXT = {
\   'mode': 'x',
\   'visualmode': 'V',
\   'firstline': 1,
\   'lastline': 1
\}

function! s:suite.before_each() abort
  new
  let s:zeropos = caw#new('actions.zeropos')
endfunction

function! s:suite.after_each() abort
  bw!
endfunction

function! s:set_context(base, ...) abort
  let context = extend(deepcopy(a:base), a:0 ? a:1 : {})
  call caw#set_context(context)
endfunction


function! s:suite.comment() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:zeropos.comment()

  " assert
  call s:assert.equals(getline(1, '$'), ['// printf("hello\n");'])
endfunction

function! s:suite.comment_indent() abort
  " set up
  setlocal filetype=c
  call setline(1, ['  printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:zeropos.comment()

  " assert
  call s:assert.equals(getline(1, '$'), ['//   printf("hello\n");'])
endfunction

function! s:suite.comment_normal() abort
  " set up
  setlocal filetype=c
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
  call s:zeropos.comment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '//     func();',
  \ '  }'
  \])
endfunction

function! s:suite.comment_visual_oneline() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:VISUAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'visualmode': 'V',
  \ 'firstline': 2,
  \ 'lastline': 2,
  \})
  call cursor(2, 1)

  " execute
  call s:zeropos.comment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '//     func();',
  \ '  }'
  \])
endfunction

function! s:suite.comment_visual_multiline_hatpos_align() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:VISUAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'visualmode': 'v',
  \ 'firstline': 1,
  \ 'lastline': 3,
  \})
  let old = g:caw_hatpos_align
  let g:caw_hatpos_align = 1

  try
    " execute
    call s:zeropos.comment()

    " assert
    call s:assert.equals(getline(1, '$'), [
    \ '//   if (stridx(s, "#") == 0) {',
    \ '//     func();',
    \ '//   }'
    \])
  finally
    " finalize
    let g:caw_hatpos_align = old
  endtry
endfunction

function! s:suite.comment_visual_multiline_no_hatpos_align() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:VISUAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'visualmode': 'v',
  \ 'firstline': 1,
  \ 'lastline': 3,
  \})
  let old = g:caw_hatpos_align
  let g:caw_hatpos_align = 0

  try
    " execute
    call s:zeropos.comment()

    " assert
    call s:assert.equals(getline(1, '$'), [
    \ '//   if (stridx(s, "#") == 0) {',
    \ '//     func();',
    \ '//   }'
    \])
  finally
    " finalize
    let g:caw_hatpos_align = old
  endtry
endfunction

function! s:suite.comment_vim() abort
  " set up
  setlocal filetype=vim
  call setline(1, [
  \ 'let dict = {',
  \ '  \ ''key'': ''value'',',
  \ '  \}'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'vim',
  \ 'context_filetype': 'vim',
  \ 'firstline': 2,
  \ 'lastline': 2,
  \})
  call cursor(2, 1)

  " execute
  call s:zeropos.comment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'let dict = {',
  \ '"  \ ''key'': ''value'',',
  \ '  \}'
  \])
endfunction

function! s:suite.uncomment() abort
  " set up
  setlocal filetype=c
  call setline(1, ['// printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_vim() abort
  " set up
  setlocal filetype=vim
  call setline(1, [
  \ 'let dict = {',
  \ '"   \ ''key'': ''value'',',
  \ '  \}'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'vim',
  \ 'context_filetype': 'vim',
  \ 'firstline': 2,
  \ 'lastline': 2,
  \})
  call cursor(2, 1)

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'let dict = {',
  \ '  \ ''key'': ''value'',',
  \ '  \}'
  \])
endfunction

function! s:suite.uncomment_vim_hatpos() abort
  " set up
  setlocal filetype=vim
  call setline(1, [
  \ 'let dict = {',
  \ '  "\ ''key'': ''value'',',
  \ '  \}'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'vim',
  \ 'context_filetype': 'vim',
  \ 'firstline': 2,
  \ 'lastline': 2,
  \})
  call cursor(2, 1)

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'let dict = {',
  \ '  \ ''key'': ''value'',',
  \ '  \}'
  \])
endfunction

function! s:suite.uncomment_indent() abort
  " set up
  setlocal filetype=c
  call setline(1, ['  // printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['  printf("hello\n");'])
endfunction

function! s:suite.uncomment_no_spaces() abort
  " set up
  setlocal filetype=c
  call setline(1, ['//printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_no_spaces_indent() abort
  " set up
  setlocal filetype=c
  call setline(1, ['  //printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['  printf("hello\n");'])
endfunction

function! s:suite.uncomment_visual_oneline() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    // func();',
  \ '  }'
  \])
  call s:set_context(s:VISUAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'visualmode': 'V',
  \ 'firstline': 2,
  \ 'lastline': 2,
  \})
  call cursor(2, 1)

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
endfunction

function! s:suite.uncomment_visual_multiline() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ '//   if (stridx(s, "#") == 0) {',
  \ '//     func();',
  \ '//   }'
  \])
  call s:set_context(s:VISUAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'visualmode': 'v',
  \ 'firstline': 1,
  \ 'lastline': 3,
  \})

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
endfunction

function! s:suite.uncomment_visual_multiline_hatpos() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ '  // if (stridx(s, "#") == 0) {',
  \ '  //   func();',
  \ '  // }'
  \])
  call s:set_context(s:VISUAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'visualmode': 'v',
  \ 'firstline': 1,
  \ 'lastline': 3,
  \})

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
endfunction

function! s:suite.dont_uncomment_trailing_comment() abort
  " set up
  setlocal filetype=c
  call setline(1, ['func(); // hello'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:zeropos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['func(); // hello'])
endfunction

function! s:suite.toggle_comment_at_line_with_trailing_comment() abort
  " set up
  setlocal filetype=c
  call setline(1, ['  func(); // hello'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:zeropos.toggle()

  " assert
  call s:assert.equals(getline(1, '$'), ['//   func(); // hello'])
endfunction
