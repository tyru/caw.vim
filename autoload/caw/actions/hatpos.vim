scriptencoding utf-8

function! caw#actions#hatpos#new() abort
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

  return extend(obj, deepcopy(s:hatpos))
endfunction


let s:hatpos = {'fallback_types': ['wrap']}

function! s:hatpos.get_var(varname, ...) abort
  return call('caw#get_var', ['caw_hatpos_' . a:varname] + a:000)
endfunction

function! s:hatpos.startinsert(lnum) abort
  if self.get_var('startinsert_at_blank_line') && getline(a:lnum) =~# '^\s*$'
  \ && caw#context().mode ==# 'n'
    return 'startinsert!'
  endif
  return ''
endfunction

function! s:hatpos.get_comment_line(lnum, options) abort
  " NOTE: min_indent_num is byte length. not display width.
  let min_indent_num = get(a:options, 'min_indent_num', -1)
  let line = getline(a:lnum)
  let sp = self.get_var('sp', '', [a:lnum])

  let comments = self.comment_database.get_comments()
  if empty(comments)
    return line
  endif
  let cmt = comments[0]

  if min_indent_num >= 0
    if min_indent_num > strlen(line)
      let line = caw#make_indent_str(min_indent_num)
    endif
    call caw#assert(min_indent_num <= strlen(line), min_indent_num.' is accessible to '.string(line).'.')
    let before = min_indent_num ==# 0 ? '' : line[: min_indent_num - 1]
    let after  = min_indent_num ==# 0 ? line : line[min_indent_num :]
    return before . cmt . sp . after
  elseif line =~# '^\s*$'
    " FIXME: write without :normal! and undo
    execute 'normal! '.a:lnum.'G"_cc' . cmt . sp
    let indent = caw#get_inserted_indent(a:lnum)
    undo
    return indent . cmt . sp . line
  else
    let indent = caw#get_inserted_indent(a:lnum)
    let line = substitute(getline(a:lnum), '^[ \t]\+', '', '')
    return indent . cmt . sp . line
  endif
endfunction

function! s:hatpos.comment_visual() abort
  let context = caw#context()
  let align = self.get_var('align')
  if align
    let min_indent_num =
    \   caw#get_min_indent_num(
    \       1,
    \       context.firstline,
    \       context.lastline)
  endif

  let lines = []
  let skip_blank_line = self.get_var('skip_blank_line')
  for lnum in range(
  \   context.firstline,
  \   context.lastline
  \)
    let line = getline(lnum)
    if !skip_blank_line || line !~# '^\s*$'
      let options = align ? {'min_indent_num': min_indent_num} : {}
      let line = self.get_comment_line(lnum, options)
    endif
    let lines += [line]
  endfor

  call caw#replace_lines(context.firstline, context.lastline, lines)
endfunction

function! s:hatpos.get_commented_range(lnum, comments) abort
  let ignore_syngroup = self.get_var('ignore_syngroup', 0, [a:lnum])
  let begin_col = matchend(getline(a:lnum), '^\s*.')
  for cmt in a:comments
    let lcol = self.get_commented_col(a:lnum, cmt, ignore_syngroup)
    if lcol ==# begin_col
      return {'start': lcol, 'end': lcol, 'comment': cmt}
    endif
  endfor
  return {}
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:hatpos.get_uncomment_line(lnum, options) abort
  let comments = self.comment_database.get_possible_comments(caw#context())
  let range = self.get_commented_range(a:lnum, comments)
  let line = getline(a:lnum)
  if empty(range)
    return line
  endif
  let left = range.start - 2 < 0 ? '' : line[: range.start - 2]
  let right = line[range.start - 1 + strlen(range.comment) :]
  let sp = self.get_var('sp', '', [a:lnum])
  if sp !=# '' && stridx(right, sp) ==# 0
    let right = right[strlen(sp) :]
  endif
  if caw#trim(left . right) ==# ''
    return ''
  else
    return left . right
  endif
endfunction
