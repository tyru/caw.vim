scriptencoding utf-8

let s:suite = themis#suite('actions.dollarpos')
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
  let s:dollarpos = caw#new('actions.dollarpos')
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
  call s:dollarpos.comment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");    // '])
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
  \ 'firstline': 2,
  \ 'lastline': 2
  \})
  call cursor(2, 1)

  " execute
  call s:dollarpos.comment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();    // ',
  \ '  }'
  \])
endfunction

function! s:suite.comment_visual_multiline() abort
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
  \ 'firstline': 1,
  \ 'lastline': 3
  \})

  " execute
  call s:dollarpos.comment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {    // ',
  \ '    func();    // ',
  \ '  }    // '
  \])
endfunction

function! s:suite.uncomment() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");     // FIXME'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_many_sp() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");                  // FIXME'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_many_sp_whitespaces() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");                  //'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_no_spaces() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");// FIXME'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_no_spaces_blank() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");//'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

" context_filetype.vim related problem
function! s:suite.vim_uncomment_doesnt_remove_hash() abort
  " set up
  setlocal filetype=vim
  call setline(1, ['" call foo#bar()'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'vim',
  \ 'context_filetype': 'vim',
  \})

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [''])
endfunction

function! s:suite.c_uncomment_doesnt_remove_hash() abort
  " set up
  setlocal filetype=c
  call setline(1, ['// foo() # bar()'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [''])
endfunction
