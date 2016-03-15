scriptencoding utf-8

function! caw#actions#small_i#new() abort
    let commentable = caw#new('actions.traits.commentable')
    let uncommentable = caw#new('actions.traits.uncommentable')
    let togglable = caw#new('actions.traits.togglable')
    let comment_detectable = caw#new('actions.traits.comment_detectable')

    let obj = deepcopy(s:small_i)
    " Implements methods.
    let obj.comment = commentable.comment
    let obj.uncomment = uncommentable.uncomment
    let obj.uncomment_visual = uncommentable.uncomment_visual
    let obj.has_comment = comment_detectable.has_comment
    let obj.has_comment_visual = comment_detectable.has_comment_visual
    let obj.has_all_comment = comment_detectable.has_all_comment
    let obj.toggle = togglable.toggle
    " Import comment database.
    let obj.comment_database = caw#new('comments.oneline')

    return obj
endfunction


let s:small_i = {'fallback_types': ['wrap']}

function! s:small_i.comment_normal(lnum, ...) abort
    " NOTE: min_indent_num is byte length. not display width.

    let startinsert = get(a:000, 0, caw#get_var('caw_i_startinsert_at_blank_line'))
    let min_indent_num = get(a:000, 1, -1)
    let line = getline(a:lnum)
    let caw_i_sp = line =~# '^\s*$' ?
    \               caw#get_var('caw_i_sp_blank') :
    \               caw#get_var('caw_i_sp')

    let cmt = self.comment_database.get_comment()
    call caw#assert(!empty(cmt), "`cmt` must not be empty.")

    if min_indent_num >= 0
        if min_indent_num > strlen(line)
            call caw#setline(a:lnum, s:make_indent_str(min_indent_num))
            let line = getline(a:lnum)
        endif
        call caw#assert(min_indent_num <= strlen(line), min_indent_num.' is accessible to '.string(line).'.')
        let before = min_indent_num ==# 0 ? '' : line[: min_indent_num - 1]
        let after  = min_indent_num ==# 0 ? line : line[min_indent_num :]
        call caw#setline(a:lnum, before . cmt . caw_i_sp . after)
    elseif line =~# '^\s*$'
        execute 'normal! '.a:lnum.'G"_cc' . cmt . caw_i_sp
        if startinsert && caw#context().mode ==# 'n'
            call caw#startinsert('A')
        endif
    else
        let indent = caw#get_inserted_indent(a:lnum)
        let line = substitute(getline(a:lnum), '^[ \t]\+', '', '')
        call caw#setline(a:lnum, indent . cmt . caw_i_sp . line)
    endif
endfunction

function! s:small_i.comment_visual() abort
    if caw#get_var('caw_i_align')
        let min_indent_num =
        \   caw#get_min_indent_num(
        \       1,
        \       caw#context().firstline,
        \       caw#context().lastline)
    endif

    for lnum in range(
    \   caw#context().firstline,
    \   caw#context().lastline
    \)
        if caw#get_var('caw_i_skip_blank_line') && getline(lnum) =~ '^\s*$'
            continue    " Skip blank line.
        endif
        if exists('min_indent_num')
            call self.comment_normal(lnum, 0, min_indent_num)
        else
            call self.comment_normal(lnum, 0)
        endif
    endfor
endfunction

function! s:small_i.has_comment_normal(lnum) abort
    let line_without_indent = substitute(getline(a:lnum), '^[ \t]\+', '', '')
    let cmt = caw#new('comments.oneline').get_comment()
    return !empty(cmt) && stridx(line_without_indent, cmt) == 0
endfunction

function! s:small_i.uncomment_normal(lnum) abort
    let cmt = self.comment_database.get_comment()
    call caw#assert(!empty(cmt), "`cmt` must not be empty.")

    if self.has_comment_normal(a:lnum)
        let indent = caw#get_inserted_indent(a:lnum)
        let line   = substitute(getline(a:lnum), '^[ \t]\+', '', '')
        if stridx(line, cmt) == 0
            " Remove comment.
            let line = line[strlen(cmt) :]
            " 'caw_i_sp'
            if stridx(line, caw#get_var('caw_i_sp')) ==# 0
                let line = line[strlen(caw#get_var('caw_i_sp')) :]
            endif
            call caw#setline(a:lnum, indent . line)
        endif
    endif
endfunction
