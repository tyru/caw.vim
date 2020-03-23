scriptencoding utf-8

function! caw#actions#zeropos#new() abort
  let obj = deepcopy(caw#new('actions.hatpos'))
  let obj = extend(obj, deepcopy(s:zeropos), 'force')
  return obj
endfunction


let s:zeropos = {}

function! s:zeropos.comment_normal(lnum, ...) abort
  let startinsert = get(a:000, 0, caw#get_var('caw_zeropos_startinsert_at_blank_line')) && caw#context().mode ==# 'n'
  let line = getline(a:lnum)
  let caw_zeropos_sp = line =~# '^\s*$' ?
  \               caw#get_var('caw_zeropos_sp_blank') :
  \               caw#get_var('caw_zeropos_sp', '', [a:lnum])

  let comments = self.comment_database.get_comments()
  if empty(comments)
    return
  endif
  let cmt = comments[0]

  if line =~# '^\s*$'
    if caw#get_var('caw_zeropos_skip_blank_line')
      return
    endif
    call setline(a:lnum, cmt . caw_zeropos_sp)
    if startinsert
      startinsert!
    endif
  else
    call setline(a:lnum, cmt . caw_zeropos_sp . line)
  endif
endfunction
