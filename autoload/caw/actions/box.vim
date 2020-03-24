scriptencoding utf-8

function! caw#actions#box#new() abort
  let obj = deepcopy(s:box)
  let obj.comment_database = caw#new('comments.wrap_multiline')
  return obj
endfunction


let s:box = {}

function! s:box.comment() abort
  " Get current filetype comments.
  " Use oneline comment for top/bottom comments.
  " Use wrap comment for left/right comments if possible.
  let comments = self.comment_database.get_comments()
  if empty(comments)
    return
  endif
  let cmt = comments[0]

  " Determine left/right col to box string.
  let top_lnum    = caw#context().firstline
  let bottom_lnum = caw#context().lastline
  let [left_col, right_col] =
  \   caw#get_both_sides_space_cols(1, top_lnum, bottom_lnum)
  call caw#assert(left_col > 0, 'left_col > 0')
  call caw#assert(right_col > 0, 'right_col > 0')

  " Get and delete target lines.
  let lines = getline(top_lnum, bottom_lnum)
  silent execute top_lnum.','.bottom_lnum.'delete _'

  let width = right_col - left_col
  call caw#assert(width > 0, 'width > 0')

  let sp_left = caw#get_var('caw_box_sp_left')
  let sp_right = caw#get_var('caw_box_sp_right')
  call map(lines, 'caw#wrap_comment_align(v:val, cmt.left . sp_left, sp_right . cmt.right, left_col, right_col)')
  " Pad/Remove left/right whitespaces.
  let tops_and_bottoms = caw#make_indent_str(left_col-1)
  \                   . (cmt.left . repeat(cmt.top, width + 2) . cmt.right)
  let lines = [tops_and_bottoms] + lines + [tops_and_bottoms]

  " Put modified lines.
  if top_lnum ==# 1 && getline(1) ==# ''
    call setline(1, lines)
  else
    call append(top_lnum - 1, lines)
  endif
endfunction
