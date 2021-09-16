" vim:foldmethod=marker:fen:
scriptencoding utf-8

function! s:is_vim9line(lnum) abort
  return search('\C\m^\s*vim9s\%[cript]\>', 'bnWz') >= 1
endfunction
let b:caw_oneline_comment = { lnum -> s:is_vim9line(lnum) ? '#' : '"' }
function! s:linecont_sp(lnum) abort
  return getline(a:lnum) =~# '^\s*\\' ? '' : ' '
endfunction
let b:caw_hatpos_sp = function('s:linecont_sp')
let b:caw_zeropos_sp = b:caw_hatpos_sp
let b:caw_hatpos_ignore_syngroup = 1
let b:caw_zeropos_ignore_syngroup = 1

if !exists('b:did_caw_ftplugin')
  if exists('b:undo_ftplugin')
    let b:undo_ftplugin .= ' | '
  else
    let b:undo_ftplugin = ''
  endif
  let b:undo_ftplugin .= 'unlet! b:caw_oneline_comment b:caw_wrap_oneline_comment b:caw_wrap_multiline_comment b:did_caw_ftplugin'
  let b:did_caw_ftplugin = 1
endif
