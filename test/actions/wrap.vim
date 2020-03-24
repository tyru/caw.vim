scriptencoding utf-8

let s:suite = themis#suite('actions.wrap')
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
  let s:wrap = caw#new('actions.wrap')
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
  call s:wrap.comment()

  " assert
  call s:assert.equals(getline(1, '$'), ['/* printf("hello\n"); */'])
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
  call s:wrap.comment()

  " assert
  call s:assert.equals(getline(1, '$'), ['  /* printf("hello\n"); */'])
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
  \ 'lastline': 2
  \})

  " execute
  call s:wrap.comment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    /* func(); */',
  \ '  }'
  \])
endfunction

function! s:suite.comment_visual_multiline_align() abort
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
  \ 'firstline': 1,
  \ 'lastline': 3
  \})
  let old = g:caw_wrap_align
  let g:caw_wrap_align = 1

  try
    " execute
    call s:wrap.comment()

    " assert
    call s:assert.equals(getline(1, '$'), [
    \ '  /* if (stridx(s, "#") == 0) { */',
    \ '  /*   func();                  */',
    \ '  /* }                          */'
    \])
  finally
    " finalize
    let g:caw_wrap_align = old
  endtry
endfunction

function! s:suite.comment_visual_multiline_no_align() abort
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
  \ 'firstline': 1,
  \ 'lastline': 3
  \})
  let old = g:caw_wrap_align
  let g:caw_wrap_align = 0

  try
    " execute
    call s:wrap.comment()

    " assert
    call s:assert.equals(getline(1, '$'), [
    \ '  /* if (stridx(s, "#") == 0) { */',
    \ '    /* func(); */',
    \ '  /* } */'
    \])
  finally
    " finalize
    let g:caw_wrap_align = old
  endtry
endfunction

function! s:suite.uncomment() abort
  " set up
  setlocal filetype=c
  call setline(1, ['/* printf("hello\n"); */'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:wrap.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_indent() abort
  " set up
  setlocal filetype=c
  call setline(1, ['  /* printf("hello\n"); */'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:wrap.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['  printf("hello\n");'])
endfunction

function! s:suite.uncomment_no_spaces() abort
  " set up
  setlocal filetype=c
  call setline(1, ['/*printf("hello\n");*/'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:wrap.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['printf("hello\n");'])
endfunction

function! s:suite.uncomment_no_spaces_indent() abort
  " set up
  setlocal filetype=c
  call setline(1, ['  /*printf("hello\n");*/'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:wrap.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), ['  printf("hello\n");'])
endfunction

function! s:suite.uncomment_visual_multiline() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ '  /* if (stridx(s, "#") == 0) { */',
  \ '  /*   func();                  */',
  \ '  /* }                          */'
  \])
  call s:set_context(s:VISUAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \ 'visualmode': 'V',
  \ 'firstline': 1,
  \ 'lastline': 3
  \})

  " execute
  call s:wrap.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  if (stridx(s, "#") == 0) {',
  \ '    func();',
  \ '  }'
  \])
endfunction

function! s:suite.toggle_ignore_comment_inside_string_literal() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ '  if (stridx("/* hello */", s) != -1) {',
  \ '    func();',
  \ '  }'
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:wrap.toggle()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '  /* if (stridx("/* hello */", s) != -1) { */',
  \ '    func();',
  \ '  }'
  \])
endfunction

function! s:suite.uncomment_portion_of_line() abort
  " set up
  setlocal filetype=c
  call setline(1, [
  \ 'int i = /* 1 ? 2 : */ 0;',
  \])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': 'c',
  \ 'context_filetype': 'c',
  \})

  " execute
  call s:wrap.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'int i = 1 ? 2 : 0;',
  \])
endfunction

function! s:suite.uncomment_doesnt_lose_indent() abort
  " set up
  setlocal filetype=jsp
  call setline(1, [
  \ '<%-- <div>                                               --%>',
  \ '<%--   <picture>                                         --%>',
  \ '<%--     <source                                         --%>',
  \ '<%--       media="(min-width: 1200px)"                   --%>',
  \ '<%--       srcset="img.png, img.png@2x 2x"               --%>',
  \ '<%--     />                                              --%>',
  \ '<%--     <img src="img.png" alt="image" class="image" /> --%>',
  \ '<%--   </picture>                                        --%>',
  \ '<%-- </div>                                              --%>',
  \])
  call s:set_context(s:VISUAL_MODE_CONTEXT, {
  \ 'filetype': 'jsp',
  \ 'context_filetype': 'jsp',
  \ 'visualmode': 'V',
  \ 'firstline': 1,
  \ 'lastline': 9
  \})

  " execute
  call s:wrap.uncomment()

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '<div>',
  \ '  <picture>',
  \ '    <source',
  \ '      media="(min-width: 1200px)"',
  \ '      srcset="img.png, img.png@2x 2x"',
  \ '    />',
  \ '    <img src="img.png" alt="image" class="image" />',
  \ '  </picture>',
  \ '</div>',
  \])
endfunction

function! s:suite.comment_jsx_and_tsx_1() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])

  " execute
  call caw#keymapping_stub('n', 'wrap', 'comment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ '/* const foo = ''this is js style''; */',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
endfunction

function! s:suite.comment_jsx_and_tsx_2() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
  call cursor(3, 1)

  " execute
  call caw#keymapping_stub('n', 'wrap', 'comment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ '/* const bar = ( */',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
endfunction

function! s:suite.comment_jsx_and_tsx_3() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
  call cursor(4, 1)

  " execute
  call caw#keymapping_stub('n', 'wrap', 'comment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    {/* <h1>this is jsx style</h1> */}',
  \ ');',
  \])
endfunction

function! s:suite.comment_jsx_and_tsx_4() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
  call cursor(4, 5)

  " execute
  call caw#keymapping_stub('n', 'wrap', 'comment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    {/* <h1>this is jsx style</h1> */}',
  \ ');',
  \])
endfunction

function! s:suite.comment_jsx_and_tsx_5() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
  call cursor(5, 1)

  " execute
  call caw#keymapping_stub('n', 'wrap', 'comment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ '/* ); */',
  \])
endfunction

function! s:suite.uncomment_jsx_and_tsx_1() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ '/* const foo = ''this is js style''; */',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])

  " execute
  call caw#keymapping_stub('n', 'wrap', 'uncomment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
endfunction

function! s:suite.uncomment_jsx_and_tsx_2() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ '/* const bar = ( */',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
  call cursor(3, 1)

  " execute
  call caw#keymapping_stub('n', 'wrap', 'uncomment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
endfunction

function! s:suite.uncomment_jsx_and_tsx_3() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    {/* <h1>this is jsx style</h1> */}',
  \ ');',
  \])
  call cursor(4, 1)

  " execute
  call caw#keymapping_stub('n', 'wrap', 'uncomment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
endfunction

function! s:suite.uncomment_jsx_and_tsx_4() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    {/* <h1>this is jsx style</h1> */}',
  \ ');',
  \])
  call cursor(4, 5)

  " execute
  call caw#keymapping_stub('n', 'wrap', 'uncomment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
endfunction

function! s:suite.uncomment_jsx_and_tsx_5() abort
  " set up
  setlocal filetype=javascript
  call setline(1, [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ '/* ); */',
  \])
  call cursor(5, 1)

  " execute
  call caw#keymapping_stub('n', 'wrap', 'uncomment')

  " assert
  call s:assert.equals(getline(1, '$'), [
  \ 'const foo = ''this is js style'';',
  \ '',
  \ 'const bar = (',
  \ '    <h1>this is jsx style</h1>',
  \ ');',
  \])
endfunction
