scriptencoding utf-8

function! caw#actions#wrap#new() abort
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
  let obj.comment_database = caw#new('comments.wrap_oneline')

  return extend(obj, deepcopy(s:wrap))
endfunction


let s:wrap = {'fallback_types': ['hatpos']}

" vint: next-line -ProhibitUnusedVariable
function! s:wrap.startinsert(lnum) abort
  return ''
endfunction


function! s:wrap.get_comment_line(lnum, options) abort
  let left_col = get(a:options, 'left_col', -1)
  let right_col = get(a:options, 'right_col', -1)
  let line = getline(a:lnum)
  if caw#context().mode ==# 'n'
  \   && caw#get_var('caw_wrap_skip_blank_line')
  \   && line =~# '^\s*$'
    return line
  endif

  let comments = self.comment_database.get_comments()
  if empty(comments)
    return line
  endif
  let [left, right] = comments[0]
  if left_col > 0 && right_col > 0
    let line = caw#wrap_comment_align(
    \   line,
    \   left . caw#get_var('caw_wrap_sp_left'),
    \   caw#get_var('caw_wrap_sp_right') . right,
    \   left_col,
    \   right_col)
    return line
  endif
  let line = substitute(line, '^\s\+', '', '')
  if left !=# ''
    let line = left . caw#get_var('caw_wrap_sp_left') . line
  endif
  if right !=# ''
    let line = line . caw#get_var('caw_wrap_sp_right') . right
  endif
  let line = caw#get_inserted_indent(a:lnum) . line
  return line
endfunction

function! s:wrap.comment_visual() abort
  let context = caw#context()
  let wiseness = get({
  \   'v': 'characterwise',
  \   'V': 'linewise',
  \   "\<C-v>": 'blockwise',
  \}, context.visualmode, '')
  if wiseness !=# ''
  \   && has_key(self, 'comment_visual_' . wiseness)
    call call(self['comment_visual_' . wiseness], [], self)
    return
  endif

  let align = caw#get_var('caw_wrap_align')
  if align
    let [left_col, right_col] =
    \   caw#get_both_sides_space_cols(
    \       caw#get_var('caw_wrap_skip_blank_line'),
    \       context.firstline,
    \       context.lastline)
  endif

  let skip_blank_line = caw#get_var('caw_wrap_skip_blank_line')
  let lines = []
  for lnum in range(
  \   context.firstline,
  \   context.lastline
  \)
    let line = getline(lnum)
    if !skip_blank_line || line !~# '^\s*$'
      let options = align ? {'left_col': left_col, 'right_col': right_col} : {}
      let line = self.get_comment_line(lnum, options)
    endif
    let lines += [line]
  endfor

  call caw#replace_lines(context.firstline, context.lastline, lines)
endfunction

let s:op_self = {}

" vint: next-line -ProhibitUnusedVariable
function! s:comment_visual_characterwise_comment_out(text) abort
  let comments = s:op_self.comment_database.get_comments()
  if empty(comments)
    return a:text
  endif
  let [left, right] = comments[0]
  return left
  \   . caw#get_var('caw_wrap_sp_left')
  \   . a:text
  \   . caw#get_var('caw_wrap_sp_right')
  \   . right
endfunction

function! s:operate_on_word(funcname) abort
  normal! gv

  let reg_z_save     = getreg('z', 1)
  let regtype_z_save = getregtype('z')

  try
    " Filter selected range with `{a:funcname}(selected_text)`.
    let cut_with_reg_z = '"zc'
    execute printf("normal! %s\<C-r>\<C-o>=%s(@z)\<CR>",
    \       cut_with_reg_z, a:funcname)
  finally
    call setreg('z', reg_z_save, regtype_z_save)
  endtry
endfunction

function! s:wrap.comment_visual_characterwise() abort
  let s:op_self = self
  call s:operate_on_word('<SID>comment_visual_characterwise_comment_out')
endfunction

function! s:wrap.get_commented_range(lnum, comments) abort
  let line = caw#trim(getline(a:lnum))
  let ignore_syngroup = caw#get_var('caw_wrap_ignore_syngroup', 0, [a:lnum])
  for [left, right] in a:comments
    " if the line is surrounded with left and right, ignore Comment syntax group
    let surrounded = stridx(line, left) ==# 0
    \ && strlen(line) - strlen(right) >=# 0
    \ && strridx(line, right) ==# strlen(line) - strlen(right)
    let lcol = self.get_commented_col(a:lnum, left, ignore_syngroup || surrounded)
    if lcol ==# 0
      continue
    endif
    let rcol = self.get_commented_col(a:lnum, right, ignore_syngroup || surrounded)
    if rcol ==# 0
      continue
    endif
    if lcol < rcol
      return {'start': lcol, 'end': rcol, 'comment': [left, right]}
    endif
  endfor
  return {}
endfunction

" vint: next-line -ProhibitUnusedVariable
function! s:wrap.get_uncomment_line(lnum, options) abort
  let comments = self.comment_database.get_possible_comments(caw#context())
  let range = self.get_commented_range(a:lnum, comments)
  let line = getline(a:lnum)
  if empty(range)
    return line
  endif
  let [left, right] = range.comment
  let sp_len = strlen(caw#get_var('caw_wrap_sp_left'))
  let line = substitute(line, '\V' . left . '\v\s{0,' . sp_len . '}', '', '')
  let sp_len = strlen(caw#get_var('caw_wrap_sp_right'))
  let line = substitute(line, '\v\s{0,' . sp_len . '}\V' . right, '', '')
  " Trim only right because multiple aligned comment may leave more spaces
  " than caw_wrap_sp_right
  let line = caw#trim_right(line)
  return line
endfunction
