scriptencoding utf-8

function! caw#actions#wrap#new() abort
    let commentable = caw#new('actions.traits.commentable')
    let uncommentable = caw#new('actions.traits.uncommentable')
    let togglable = caw#new('actions.traits.togglable')
    let comment_detectable = caw#new('actions.traits.comment_detectable')

    let obj = deepcopy(s:wrap)
    " Implements methods.
    let obj.comment = commentable.comment
    let obj.uncomment = uncommentable.uncomment
    let obj.uncomment_visual = uncommentable.uncomment_visual
    let obj.has_comment = comment_detectable.has_comment
    let obj.has_comment_visual = comment_detectable.has_comment_visual
    let obj.has_all_comment = comment_detectable.has_all_comment
    let obj.toggle = togglable.toggle
    " Import comment database.
    let obj.comment_database = caw#new('comments.wrap_oneline')

    return obj
endfunction


let s:wrap = {'fallback_types': ['hatpos']}

function! s:wrap.comment_normal(lnum, ...) abort
    let left_col = get(a:000, 0, -1)
    let right_col = get(a:000, 1, -1)

    let cmt = self.comment_database.get_comment()
    call caw#assert(!empty(cmt), "`cmt` must not be empty.")
    if caw#context().mode ==# 'n'
    \   && caw#get_var('caw_wrap_skip_blank_line')
    \   && caw#getline(a:lnum) =~# '^\s*$'
        return
    endif

    let line = caw#getline(a:lnum)
    let [left_cmt, right_cmt] = cmt
    if left_col > 0 && right_col > 0
        let line = caw#wrap_comment_align(
        \   line,
        \   left_cmt . caw#get_var("caw_wrap_sp_left"),
        \   caw#get_var("caw_wrap_sp_right") . right_cmt,
        \   left_col,
        \   right_col)
        call caw#setline(a:lnum, line)
    else
        let line = substitute(line, '^\s\+', '', '')
        if left_cmt != ''
            let line = left_cmt . caw#get_var('caw_wrap_sp_left') . line
        endif
        if right_cmt != ''
            let line = line . caw#get_var('caw_wrap_sp_right') . right_cmt
        endif
        let line = caw#get_inserted_indent(a:lnum) . line
        call caw#setline(a:lnum, line)
    endif
endfunction

function! s:wrap.comment_visual() abort
    let wiseness = get({
    \   'v': 'characterwise',
    \   'V': 'linewise',
    \   "\<C-v>": 'blockwise',
    \}, caw#context().visualmode, '')
    if wiseness != ''
    \   && has_key(self, 'comment_visual_' . wiseness)
        call call(self['comment_visual_' . wiseness], [], self)
        return
    endif

    if caw#get_var('caw_wrap_align')
        let [left_col, right_col] =
        \   caw#get_both_sides_space_cols(
        \       caw#get_var('caw_wrap_skip_blank_line'),
        \       caw#context().firstline,
        \       caw#context().lastline)
    endif

    let skip_blank_line = caw#get_var('caw_wrap_skip_blank_line')
    for lnum in range(
    \   caw#context().firstline,
    \   caw#context().lastline
    \)
        if skip_blank_line && caw#getline(lnum) =~ '^\s*$'
            continue    " Skip blank line.
        endif
        if exists('left_col') && exists('right_col')
            call self.comment_normal(lnum, left_col, right_col)
        else
            call self.comment_normal(lnum)
        endif
    endfor
endfunction

function! s:comment_visual_characterwise_comment_out(text) abort
    let cmt = caw#new('comments.wrap_oneline').get_comment()
    if empty(cmt)
        return a:text
    else
        return cmt[0]
        \   . caw#get_var('caw_wrap_sp_left')
        \   . a:text
        \   . caw#get_var('caw_wrap_sp_right')
        \   . cmt[1]
    endif
endfunction

function! s:operate_on_word(funcname) abort
    normal! gv

    let reg_z_save     = getreg('z', 1)
    let regtype_z_save = getregtype('z')

    try
        " Filter selected range with `{a:funcname}(selected_text)`.
        let cut_with_reg_z = '"zc'
        execute printf("normal! %s\<C-r>\<C-o>=%s(@z)\<CR>", cut_with_reg_z, a:funcname)
    finally
        call setreg('z', reg_z_save, regtype_z_save)
    endtry
endfunction

function! s:wrap.comment_visual_characterwise() abort
    let cmt = self.comment_database.get_comment()
    call caw#assert(!empty(cmt), "`cmt` must not be empty.")
    call s:operate_on_word('<SID>comment_visual_characterwise_comment_out')
endfunction

function! s:wrap.has_comment_normal(lnum) abort
    let cmt = caw#new('comments.wrap_oneline').get_comment()
    if empty(cmt)
        return 0
    endif

    let line = caw#trim_whitespaces(caw#getline(a:lnum))

    " line begins with left, ends with right.
    let [left, right] = cmt
    return
    \   (left == '' || line[: strlen(left) - 1] ==# left)
    \   && (right == '' || line[strlen(line) - strlen(right) :] ==# right)
endfunction

function! s:wrap.uncomment_normal(lnum) abort
    let cmt = caw#new('comments.wrap_oneline').get_comment()
    if !empty(cmt) && self.has_comment_normal(a:lnum)
        let [left, right] = cmt
        let line = caw#trim_whitespaces(caw#getline(a:lnum))

        if left != '' && line[: strlen(left) - 1] ==# left
            let line = line[strlen(left) :]
        endif
        if right != '' && line[strlen(line) - strlen(right) :] ==# right
            let line = line[: -strlen(right) - 1]
        endif

        let indent = caw#get_inserted_indent(a:lnum)
        let line = caw#trim_whitespaces(line)
        call caw#setline(a:lnum, indent . line)
    endif
endfunction
