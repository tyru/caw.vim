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

" vint: next-line -ProhibitUnusedVariable
function! s:dollarpos.startinsert(lnum) abort
  if caw#get_var('caw_dollarpos_startinsert') && caw#context().mode ==# 'n'
    return 'startinsert!'
  endif
  return ''
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:dollarpos.get_comment_line(lnum, options) abort
  let comments = self.comment_database.get_comments()
  let line = getline(a:lnum)
  if empty(comments)
    return line
  endif
  let cmt = comments[0]

  return line
  \       . caw#get_var('caw_dollarpos_sp_left')
  \       . cmt
  \       . caw#get_var('caw_dollarpos_sp_right')
endfunction

function! s:dollarpos.get_commented_range(lnum, comments) abort
  let ignore_syngroup = caw#get_var('caw_dollarpos_ignore_syngroup', 0, [a:lnum])
  for cmt in a:comments
    let lcol = self.get_commented_col(a:lnum, cmt, ignore_syngroup)
    if lcol ==# 0
      continue
    endif
    return {'start': lcol, 'end': lcol, 'comment': cmt}
  endfor
  return {}
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:dollarpos.get_uncomment_line(lnum, options) abort
  let comments = self.comment_database.get_possible_comments(caw#context())
  let range = self.get_commented_range(a:lnum, comments)
  let line = getline(a:lnum)
  if empty(range)
    return line
  endif
  let left = range.start - 2 < 0 ? '' : line[: range.start - 2]
  let left = caw#trim_right(left)
  return left
endfunction
