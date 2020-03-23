scriptencoding utf-8

function! caw#actions#dollarpos#new() abort
  let commentable = caw#new('actions.traits.commentable')
  let uncommentable = caw#new('actions.traits.uncommentable')
  let togglable = caw#new('actions.traits.togglable')
  let comment_detectable = caw#new('actions.traits.comment_detectable')

  let obj = {}
  " Implements methods.
  call extend(obj, commentable)
  call extend(obj, uncommentable)
  call extend(obj, comment_detectable)
  call extend(obj, togglable)
  " Import comment database.
  let obj.comment_database = caw#new('comments.oneline')

  return extend(obj, deepcopy(s:dollarpos))
endfunction


let s:dollarpos = {'fallback_types': ['wrap']}

function! s:dollarpos.comment_normal(lnum, ...) abort
  let startinsert = a:0 ? a:1 : caw#get_var('caw_dollarpos_startinsert') && caw#context().mode ==# 'n'

  let comments = self.comment_database.get_comments()
  if empty(comments)
    return
  endif
  let cmt = comments[0]

  call caw#setline(
  \   a:lnum,
  \   caw#getline(a:lnum)
  \       . caw#get_var('caw_dollarpos_sp_left')
  \       . cmt
  \       . caw#get_var('caw_dollarpos_sp_right')
  \)
  if startinsert
    call caw#startinsert('A')
  endif
endfunction

function! s:dollarpos.get_commented_range(lnum, comments) abort
  for cmt in a:comments
    let lcol = self.get_commented_col(a:lnum, cmt)
    if lcol ==# 0
      continue
    endif
    return {'start': lcol, 'end': lcol, 'comment': cmt}
  endfor
  return {}
endfunction

function! s:dollarpos.uncomment_normal(lnum) abort
  let comments = self.comment_database.sorted_comments_by_length_desc()
  let range = self.get_commented_range(a:lnum, comments)
  if empty(range)
    return
  endif
  let line = caw#getline(a:lnum)
  let left = range.start - 2 < 0 ? '' : line[: range.start - 2]
  let left = caw#trim_right(left)
  call caw#setline(a:lnum, left)
endfunction
