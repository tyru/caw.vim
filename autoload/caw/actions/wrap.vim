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
    let line = caw#getline(a:lnum)
    if caw#context().mode ==# 'n'
    \   && caw#get_var('caw_wrap_skip_blank_line')
    \   && line =~# '^\s*$'
        return
    endif

    let comments = self.comment_database.get_comments()
    if empty(comments)
        return
    endif
    let [left, right] = comments[0]
    if left_col > 0 && right_col > 0
        let line = caw#wrap_comment_align(
        \   line,
        \   left . caw#get_var('caw_wrap_sp_left'),
        \   caw#get_var('caw_wrap_sp_right') . right,
        \   left_col,
        \   right_col)
        call caw#setline(a:lnum, line)
    else
        let line = substitute(line, '^\s\+', '', '')
        if left !=# ''
            let line = left . caw#get_var('caw_wrap_sp_left') . line
        endif
        if right !=# ''
            let line = line . caw#get_var('caw_wrap_sp_right') . right
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
    \}, caw#context().mode, '')
    if wiseness !=# ''
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
        if skip_blank_line && caw#getline(lnum) =~# '^\s*$'
            continue    " Skip blank line.
        endif
        if exists('left_col') && exists('right_col')
            call self.comment_normal(lnum, left_col, right_col)
        else
            call self.comment_normal(lnum)
        endif
    endfor
endfunction

function! s:comment_visual_characterwise_comment_out(text, comment_database) abort
    let comments = a:comment_database.get_comments()
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

function! s:operate_on_word(funcname, args) abort
    normal! gv

    let reg_z_save     = getreg('z', 1)
    let regtype_z_save = getregtype('z')

    try
        " Filter selected range with `{a:funcname}(selected_text)`.
        let cut_with_reg_z = '"zc'
        execute printf("normal! %s\<C-r>\<C-o>=call(%s, [@z] + %s)\<CR>",
        \       cut_with_reg_z, string(a:funcname), string(a:args))
    finally
        call setreg('z', reg_z_save, regtype_z_save)
    endtry
endfunction

function! s:wrap.comment_visual_characterwise() abort
    call s:operate_on_word('<SID>comment_visual_characterwise_comment_out', [self.comment_database])
endfunction

function! s:wrap.has_comment_normal(lnum) abort
    let comments = self.comment_database.get_comments()
    if empty(comments)
        return 0
    endif
    " line begins with left, ends with right.
    let line = caw#trim_whitespaces(caw#getline(a:lnum))
    for [left, right] in comments
        if (left ==# '' || line[: strlen(left) - 1] ==# left)
        \ && (right ==# '' || line[strlen(line) - strlen(right) :] ==# right)
            return 1
        endif
    endfor
    return 0
endfunction

function! s:wrap.uncomment_normal(lnum) abort
    let comments = self.comment_database.sorted_comments_by_length_desc()
    if empty(comments) || !self.has_comment_normal(a:lnum)
        return
    endif
    let line_without_indent = caw#trim_whitespaces(caw#getline(a:lnum))
    for [left, right] in comments
        let line = line_without_indent
        let fixed = 0
        if left !=# '' && line[: strlen(left) - 1] ==# left
            let line = line[strlen(left) :]
            let fixed = 1
        endif
        if right !=# '' && line[strlen(line) - strlen(right) :] ==# right
            let line = line[: -strlen(right) - 1]
            let fixed = 1
        endif
        let indent = caw#get_inserted_indent(a:lnum)
        let line = caw#trim_whitespaces(line)
        if fixed
            call caw#setline(a:lnum, indent . line)
            break
        endif
    endfor
endfunction
