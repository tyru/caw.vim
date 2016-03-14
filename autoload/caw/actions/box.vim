scriptencoding utf-8

function! caw#actions#box#new() abort
    let obj = deepcopy(s:box)
    let obj.comment_database = caw#new('comments.wrap_multiline')
    return obj
endfunction


" TODO:
" - s:caw_box_uncomment()

let s:box = {}

function! s:box.comment() dict
    " Get current filetype comments.
    " Use oneline comment for top/bottom comments.
    " Use wrap comment for left/right comments if possible.
    let cmt = self.comment_database.get_comment()
    if empty(cmt)
    \  || empty(cmt.left)
    \  || empty(cmt.right)
    \  || empty(cmt.top)
    \  || empty(cmt.bottom)
        return
    endif

    " Determine left/right col to box string.
    let top_lnum    = caw#context().firstline
    let bottom_lnum = caw#context().lastline
    let [left_col, right_col] =
    \   caw#get_both_sides_space_cols(1, top_lnum, bottom_lnum)
    call caw#assert(left_col > 0, 'left_col > 0')
    call caw#assert(right_col > 0, 'right_col > 0')

    " Box string!
    let reg = getreg('z', 1)
    let regtype = getregtype('z')
    try
        " Delete target lines.
        silent execute top_lnum.','.bottom_lnum.'delete z'
        let lines = split(@z, "\n")

        let width = right_col - left_col
        call caw#assert(width > 0, 'width > 0')
        let tops_and_bottoms = cmt.left . repeat(cmt.top, width + 2) . cmt.right

        let sp_left = caw#get_var("caw_box_sp_left")
        let sp_right = caw#get_var("caw_box_sp_right")
        call map(lines, 'caw#wrap_comment_align(v:val, cmt.left . sp_left, sp_right . cmt.right, left_col, right_col)')
        " Pad/Remove left/right whitespaces.
        call insert(lines,
        \   repeat((&expandtab ? ' ' : "\t"), left_col-1)
        \   . tops_and_bottoms)
        call add(lines,
        \   repeat((&expandtab ? ' ' : "\t"), left_col-1)
        \   . tops_and_bottoms)

        " Put modified lines.
        let @z = join(lines, "\n")
        " If top_lnum == line('.') + 1, `execute top_lnum.'put! z'` will cause an error.
        silent execute (top_lnum - 1).'put z'

    finally
        call setreg('z', reg, regtype)
    endtry
endfunction
