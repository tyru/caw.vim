scriptencoding utf-8

let s:suite = themis#suite('actions.box')
let s:assert = themis#helper('assert')

let s:NORMAL_MODE_CONTEXT = {
\   'mode': 'n',
\   'visualmode': '',
\   'firstline': 1,
\   'lastline': 1
\}

function! s:suite.before_each() abort
  new
  let s:box = caw#new('actions.box')
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
  call s:box.comment()

  " assert
  call s:assert.equals(b:caw_wrap_multiline_comment,
  \       {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'})
  call s:assert.equals(getline(1, '$'), [
  \   '/**********************/',
  \   '/* printf("hello\n"); */',
  \   '/**********************/'
  \])
endfunction

function! s:suite.comment_indent_noexpandtab() abort
  " set up
  setlocal filetype=c
  setlocal noexpandtab
  call setline(1, ["\t" . 'printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:box.comment()

  " assert
  call s:assert.equals(b:caw_wrap_multiline_comment,
  \       {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'})
  call s:assert.equals(getline(1, '$'), [
  \   "\t" . '/**********************/',
  \   "\t" . '/* printf("hello\n"); */',
  \   "\t" . '/**********************/'
  \])
endfunction

function! s:suite.comment_indent_expandtab() abort
  " set up
  setlocal filetype=c
  setlocal expandtab
  call setline(1, ['  printf("hello\n");'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:box.comment()

  " assert
  call s:assert.equals(b:caw_wrap_multiline_comment,
  \       {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'})
  call s:assert.equals(getline(1, '$'), [
  \   '  /**********************/',
  \   '  /* printf("hello\n"); */',
  \   '  /**********************/'
  \])
endfunction

function! s:suite.comment_part() abort
  " set up
  setlocal filetype=c
  setlocal expandtab
  call setline(1, ['  if (stridx(s, "#") == 0) {', '    func();', '  }'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'firstline': 2,
  \ 'lastline': 2,
  \})
  call cursor(2, 1)

  " execute
  call s:box.comment()

  " assert
  call s:assert.equals(b:caw_wrap_multiline_comment,
  \       {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'})
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    /***********/',
  \ '    /* func(); */',
  \ '    /***********/',
  \ '  }'])
endfunction

function! s:suite.comment_part_2() abort
  " set up
  setlocal filetype=c
  setlocal expandtab
  call setline(1, ['  if (stridx(s, "#") == 0) {', '    func();', '  }'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'firstline': 1,
  \ 'lastline': 3
  \})

  " execute
  call s:box.comment()

  " assert
  call s:assert.equals(b:caw_wrap_multiline_comment,
  \       {'right': '*/', 'bottom': '*', 'left': '/*', 'top': '*'})
  call s:assert.equals(getline(1, '$'), ['  /******************************/',
  \ '  /* if (stridx(s, "#") == 0) { */',
  \ '  /*   func();                  */',
  \ '  /* }                          */',
  \ '  /******************************/',
  \ ])
endfunction
