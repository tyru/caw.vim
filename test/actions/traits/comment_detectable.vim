scriptencoding utf-8

let s:suite = themis#suite('actions.traits.comment_detectable')
let s:assert = themis#helper('assert')

let s:NORMAL_MODE_CONTEXT = {
\   'mode': 'n',
\   'visualmode': '',
\   'firstline': 1,
\   'lastline': 1
\}

function! s:suite.before_each() abort
  new
  let s:comment_detectable= caw#new('actions.traits.comment_detectable')
endfunction

function! s:suite.after_each() abort
  bw!
endfunction

function! s:set_context(base, ...) abort
  let context = extend(deepcopy(a:base), a:0 ? a:1 : {})
  call caw#set_context(context)
endfunction

" ft_for_test_Comment -> value
function! s:suite.has_syntax_when_highlight_direct_value() abort
  " set up
  setlocal filetype=ft_for_test
  call setline(1, ['# printf("")'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': &filetype,
  \ 'context_filetype': &filetype,
  \})

  syntax match ft_for_test_Comment +^#.*$+
  hi! ft_for_test_Comment ctermfg=8

  " assert
  call s:assert.equals(s:comment_detectable.has_syntax('Comment$', 1, 1), 1)
endfunction

" ft_for_test_Comment -> ft_for_test_Color1 -> value
function! s:suite.has_syntax_when_highlight_link() abort
  " set up
  setlocal filetype=ft_for_test
  call setline(1, ['# printf("")'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': &filetype,
  \ 'context_filetype': &filetype,
  \})

  syntax match ft_for_test_Comment +^#.*$+
  hi! link ft_for_test_Color1 ctermfg=8
  hi! link ft_for_test_Comment ft_for_test_Color1

  " assert
  call s:assert.equals(s:comment_detectable.has_syntax('Comment$', 1, 1), 1)
endfunction

" ft_for_test_Comment → ft_for_test_Color1 → ft_for_test_Color2 → value
function! s:suite.has_syntax_when_highlight_nested_link() abort
  " set up
  setlocal filetype=ft_for_test
  call setline(1, ['# printf("")'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': &filetype,
  \ 'context_filetype': &filetype,
  \})

  syntax match ft_for_test_Comment +^#.*$+
  hi! ft_for_test_Color2 ctermfg=8
  hi! link ft_for_test_Color1 ft_for_test_Color2
  hi! link ft_for_test_Comment ft_for_test_Color1

  " assert
  call s:assert.equals(s:comment_detectable.has_syntax('Comment$', 1, 1), 1)
endfunction

function! s:suite.has_syntax_when_highlight_not_match() abort
  " set up
  setlocal filetype=ft_for_test
  call setline(1, ['printf("")'])
  call s:set_context(s:NORMAL_MODE_CONTEXT, {
  \ 'filetype': &filetype,
  \ 'context_filetype': &filetype,
  \})

  syntax match ft_for_test_Comment +^#.*$+
  hi! ft_for_test_Comment ctermfg=8

  " assert
  call s:assert.equals(s:comment_detectable.has_syntax('Comment$', 1, 1), 0)
endfunction
