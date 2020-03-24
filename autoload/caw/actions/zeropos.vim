scriptencoding utf-8

function! caw#actions#zeropos#new() abort
  let obj = deepcopy(caw#new('actions.hatpos'))
  let obj = extend(obj, deepcopy(s:zeropos), 'force')
  return obj
endfunction


let s:zeropos = {}

function! s:zeropos.get_var(varname, ...) abort
  return call('caw#get_var', ['caw_zeropos_' . a:varname] + a:000)
endfunction

function! s:zeropos.startinsert(lnum) abort
  if self.get_var('startinsert_at_blank_line') && getline(a:lnum) =~# '^\s*$'
  \ && caw#context().mode ==# 'n'
    return 'startinsert!'
  endif
  return ''
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:zeropos.get_comment_line(lnum, options) abort
  let line = getline(a:lnum)
  let caw_zeropos_sp = self.get_var('sp', '', [a:lnum])

  let comments = self.comment_database.get_comments()
  if empty(comments)
    return line
  endif
  let cmt = comments[0]

  if line =~# '^\s*$'
    if self.get_var('skip_blank_line')
      return line
    endif
    return cmt . caw_zeropos_sp
  endif
  return cmt . caw_zeropos_sp . line
endfunction
