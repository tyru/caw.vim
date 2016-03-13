scriptencoding utf-8

function! caw#actions#a#new() abort
    let commentable = caw#new('actions.traits.commentable')
    let uncommentable = caw#new('actions.traits.uncommentable')
    let togglable = caw#new('actions.traits.togglable')
    let comment_detectable = caw#new('actions.traits.comment_detectable')

    let obj = deepcopy(s:pos_a)
    " Implements methods.
    let obj.comment = commentable.comment
    let obj.comment_visual = commentable.comment_visual
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


let s:pos_a = {'fallback_types': ['wrap']}

function! s:pos_a.comment_normal(lnum, ...) dict
    let startinsert = a:0 ? a:1 : caw#get_var('caw_a_startinsert') && caw#context().mode ==# 'n'

    let cmt = self.comment_database.get_comment()
    call caw#assert(!empty(cmt), "`cmt` must not be empty.")

    call setline(
    \   a:lnum,
    \   getline(a:lnum)
    \       . caw#get_var('caw_a_sp_left')
    \       . cmt
    \       . caw#get_var('caw_a_sp_right')
    \)
    if startinsert
        startinsert!
    endif
endfunction

function! s:get_comment_col(lnum)
    let cmt = caw#new('comments.oneline').get_comment()
    if empty(cmt)
        return -1
    endif

    let line = getline(a:lnum)
    let cols = []
    while 1
        let idx = stridx(line, cmt, empty(cols) ? 0 : idx + 1)
        if idx == -1
            break
        endif
        call add(cols, idx + 1)
    endwhile

    if empty(cols)
        return -1
    endif

    for col in cols
        for id in synstack(a:lnum, col)
            if synIDattr(synIDtrans(id), 'name') ==# 'Comment'
                return col
            endif
        endfor
    endfor
    return -1
endfunction

function! s:pos_a.has_comment_normal(lnum) dict
    return s:get_comment_col(a:lnum) > 0
endfunction

function! s:pos_a.uncomment_normal(lnum) dict
    let cmt = self.comment_database.get_comment()
    call caw#assert(!empty(cmt), "`cmt` must not be empty.")

    if self.has_comment_normal(a:lnum)
        let col = s:get_comment_col(a:lnum)
        if col <= 0
            return
        endif
        let idx = col - 1

        let line = getline(a:lnum)
        let [l, r] = [line[idx : idx + strlen(cmt) - 1], cmt]
        call caw#assert(l ==# r, "s:caw.a.uncomment_normal(): ".string(l).' ==# '.string(r))

        let before = line[0 : idx - 1]
        " 'caw_a_sp_left'
        let before = substitute(before, '\s\+$', '', '')

        call setline(a:lnum, before)
    endif
endfunction
