" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}

function! s:is_jsxtag(lnum) abort
  for id in synstack(a:lnum, caw#context().col)
    if synIDattr(id, 'name') =~# '^jsx'
      return 1
    endif
  endfor
  return 0
endfunction

function! caw#ft#jsx#wrap_comment(lnum) abort
  return s:is_jsxtag(a:lnum) ? ['{/*', '*/},'] : ['/*', '*/']
endfunction

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
