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


function! s:suite.comment() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");'])
  call caw#set_context(deepcopy(s:NORMAL_MODE_CONTEXT))

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
  call caw#set_context(extend(deepcopy(s:VISUAL_MODE_CONTEXT),
  \ {'visualmode': 'V', 'firstline': 2, 'lastline': 2}))

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
  call caw#set_context(extend(deepcopy(s:VISUAL_MODE_CONTEXT),
  \ {'visualmode': 'V', 'firstline': 1, 'lastline': 3}))

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
  call caw#set_context(deepcopy(s:NORMAL_MODE_CONTEXT))

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_many_sp() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");                  // FIXME'])
  call caw#set_context(deepcopy(s:NORMAL_MODE_CONTEXT))

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_many_sp_blank() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");                  //'])
  call caw#set_context(deepcopy(s:NORMAL_MODE_CONTEXT))

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_no_spaces() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");// FIXME'])
  call caw#set_context(deepcopy(s:NORMAL_MODE_CONTEXT))

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_no_spaces_blank() abort
  " set up
  setlocal filetype=c
  call setline(1, ['printf("hello\n");//'])
  call caw#set_context(deepcopy(s:NORMAL_MODE_CONTEXT))

  " execute
  call s:dollarpos.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction
