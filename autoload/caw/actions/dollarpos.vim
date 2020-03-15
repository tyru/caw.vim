scriptencoding utf-8

function! caw#actions#dollarpos#new() abort
    let commentable = caw#new('actions.traits.commentable')
    let uncommentable = caw#new('actions.traits.uncommentable')
    let togglable = caw#new('actions.traits.togglable')
    let comment_detectable = caw#new('actions.traits.comment_detectable')

    let obj = deepcopy(s:dollarpos)
    " Implements methods.
    let obj.comment = commentable.comment
    let obj.comment_visual = commentable.comment_visual
    let obj.uncomment = uncommentable.uncomment
    let obj.uncomment_visual = uncommentable.uncomment_visual
    let obj.has_comment = comment_detectable.has_comment
    let obj.has_comment_visual = comment_detectable.has_comment_visual
    let obj.has_all_comment = comment_detectable.has_all_comment
    let obj.search_synstack = comment_detectable.search_synstack
    let obj.has_syntax = comment_detectable.has_syntax
    let obj.toggle = togglable.toggle
    " Import comment database.
    let obj.comment_database = caw#new('comments.oneline')

    return obj
endfunction


let s:dollarpos = {'fallback_types': ['wrap']}

function! s:dollarpos.comment_normal(lnum, ...) abort
    let startinsert = a:0 ? a:1 : caw#get_var('caw_dollarpos_startinsert') && caw#context().mode ==# 'n'

    let comments = self.comment_database.get_comments()
    call caw#assert(!empty(comments), '`comments` must not be empty.')
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

function! s:dollarpos.has_comment_normal(lnum) abort
    for cmt in self.comment_database.get_comments()
        if self.search_synstack(a:lnum, cmt, '^Comment$') > 0
            return 1
        endif
    endfor
    return 0
endfunction

function! s:dollarpos.uncomment_normal(lnum) abort
    for cmt in self.comment_database.get_comments()
        let col = self.search_synstack(a:lnum, cmt, '^Comment$')
        if col <= 0
            continue
        endif
        let idx = col - 1
        let line = caw#getline(a:lnum)
        let [l, r] = [line[idx : idx + strlen(cmt) - 1], cmt]
        call caw#assert(l ==# r, 's:caw.a.uncomment_normal(): '.string(l).' ==# '.string(r))

        let before = line[0 : idx - 1]
        " 'caw_dollarpos_sp_left'
        let before = substitute(before, '\s\+$', '', '')

        call caw#setline(a:lnum, before)
        break
    endfor
endfunction
