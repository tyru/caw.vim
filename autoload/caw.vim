" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" Interface {{{

function! s:sandbox_call(Fn, args, ...) "{{{
    try
        return a:0 ? call(a:Fn, a:args, a:1) : call(a:Fn, a:args)
    catch
        echohl ErrorMsg
        echomsg '[' . v:exception . ']::[' . v:throwpoint . ']'
        echohl None
    endtry
endfunction "}}}



" i/a
function! caw#do_i_comment(mode) "{{{
    return s:sandbox_call(s:caw.i.comment, [a:mode], s:caw.i)
endfunction "}}}

function! caw#do_a_comment(mode) "{{{
    return s:sandbox_call(s:caw.a.comment, [a:mode], s:caw.a)
endfunction "}}}

function! caw#do_i_toggle(mode) "{{{
    return s:sandbox_call(s:caw.i.toggle, [a:mode], s:caw.i)
endfunction "}}}

function! caw#do_a_toggle(mode) "{{{
    return s:sandbox_call(s:caw.a.toggle, [a:mode], s:caw.a)
endfunction "}}}



" wrap
function! caw#do_wrap_comment(mode) "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_one_comment(mode) "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_multi_comment(mode) "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_toggle(mode) "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_one_toggle(mode) "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_multi_toggle(mode) "{{{
    " TODO
endfunction "}}}



" jump
function! caw#do_jump_comment_next() "{{{
    return s:sandbox_call(s:caw.jump.comment, [1], s:caw.jump)
endfunction "}}}

function! caw#do_jump_comment_prev() "{{{
    return s:sandbox_call(s:caw.jump.comment, [0], s:caw.jump)
endfunction "}}}



" uncomment
function! caw#do_uncomment(mode) "{{{
    " TODO
endfunction "}}}


function! caw#do_uncomment_i(mode) "{{{
    return s:sandbox_call(s:caw.i.uncomment, [a:mode], s:caw.i)
endfunction "}}}

function! caw#do_uncomment_a(mode) "{{{
    return s:sandbox_call(s:caw.a.uncomment, [a:mode], s:caw.a)
endfunction "}}}


function! caw#do_uncomment_wrap(mode) "{{{
    " TODO
endfunction "}}}

function! caw#do_uncomment_wrap_one(mode) "{{{
    " TODO
endfunction "}}}

function! caw#do_uncomment_wrap_multi(mode) "{{{
    " TODO
endfunction "}}}


function! caw#do_uncomment_input(mode) "{{{
    " TODO
endfunction "}}}

" }}}


" Implementation {{{

function! s:get_comment_string(filetype) "{{{
    for fn in [
    \   's:get_comment_string_vars',
    \   's:get_comment_string_builtin',
    \]
        let r = call(fn, [a:filetype])
        if r != ''
            return r
        endif
    endfor
endfunction "}}}

function! s:get_comment_string_vars(filetype) "{{{
    for ns in [b:, w:, t:, g:]
        if has_key(ns, 'caw_oneline_comment_string')
        \   && has_key(ns.caw_oneline_comment_string, a:filetype)
            return ns.caw_oneline_comment_string[a:filetype]
        endif
    endfor
    return ''
endfunction "}}}

function! s:get_comment_string_builtin(filetype) "{{{
    if a:filetype =~# 'c\|cpp'
        return '//'
    elseif a:filetype =~# 'perl\|ruby\|python\|php'
        return '#'
    elseif a:filetype =~# 'vim'
        return '"'
    endif
    return ''
endfunction "}}}

function! s:assert(cond, msg) "{{{
    if !a:cond
        throw 'caw: assertion failure: ' . a:msg
    endif
endfunction "}}}

function! s:get_var(varname) "{{{
    for ns in [b:, w:, t:, g:]
        if has_key(ns, a:varname)
            return ns[a:varname]
        endif
    endfor
    call s:assert(0, "s:get_var(): this must be reached")
endfunction "}}}


" s:caw {{{
let s:caw = {}

" s:base {{{
let s:base = {}

" NOTE:
" These methods are missing in s:base.
" Derived object must implement those.
"
" s:base.comment() requires:
" - s:base.comment_normal()
"
" s:base.commented() requires:
" - s:base.commented_normal()
" - s:base.commented_visual()
"
" s:base.uncomment() requires:
" - s:base.uncomment_normal()
" - s:base.uncomment_visual()


function! s:base.comment(mode) "{{{
    if a:mode ==# 'n'
        call self.comment_normal(line('.'))
    else
        call self.comment_visual()
    endif
endfunction "}}}

function! s:base.comment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum)
    endfor
endfunction "}}}


function! s:base.toggle(mode) "{{{
    if self.commented(a:mode)
        call self.uncomment(a:mode)
    else
        call self.comment(a:mode)
    endif
endfunction "}}}


function! s:base.commented(mode) "{{{
    if a:mode ==# 'n'
        return self.commented_normal(line('.'))
    else
        return self.commented_visual()
    endif
endfunction "}}}


function! s:base.uncomment(mode) "{{{
    if a:mode ==# 'n'
        call self.uncomment_normal(line('.'))
    else
        call self.uncomment_visual()
    endif
endfunction "}}}

" }}}


" i {{{
let s:caw.i = deepcopy(s:base)

function! s:caw.i.comment_normal(lnum) "{{{
    let cmt = s:get_comment_string(&filetype)
    if cmt != ''
        let m = matchlist(getline(a:lnum), '^\([ \t]*\)\(.*\)')
        if empty(m)
            throw 'caw: s:caw.i.comment_normal(): internal error'
        endif
        call setline(a:lnum, m[1] . cmt . s:get_var('caw_sp_i') . m[2])
    endif
endfunction "}}}


function! s:caw.i.commented_normal(lnum) "{{{
    let line_without_indent = substitute(getline(a:lnum), '^\s\+', '', '')
    let cmt = s:get_comment_string(&filetype)
    return stridx(line_without_indent, cmt) == 0
endfunction "}}}

function! s:caw.i.commented_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        if self.commented_normal(lnum)
            return 1
        endif
    endfor
    return 0
endfunction "}}}



function! s:caw.i.uncomment_normal(lnum) "{{{
    let cmt = s:get_comment_string(&filetype)
    if cmt != ''
        let m = matchlist(getline(a:lnum), '^\([ \t]*\)\(.*\)')
        if empty(m)
            throw 'caw: s:caw.i.uncomment_normal(): internal error'
        endif
        let [indent, line] = m[1:2]
        if stridx(line, cmt) == 0
            " Remove comment.
            let line = line[strlen(cmt) :]
            " 'caw_sp_i'
            let line = substitute(line, '^[ \t]\+', '', '')
            call setline(a:lnum, indent . line)
        endif
    endif
endfunction "}}}

function! s:caw.i.uncomment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.uncomment_normal(lnum)
    endfor
endfunction "}}}

" }}}

" a {{{
let s:caw.a = deepcopy(s:base)

function! s:caw.a.comment_normal(lnum, ...) "{{{
    let do_feedkeys = a:0 ? a:1 : s:get_var('caw_a_startinsert')
    let cmt = s:get_comment_string(&filetype)
    if cmt != ''
        let line = getline(a:lnum) . s:get_var('caw_sp_a_left') . cmt . s:get_var('caw_sp_a_right')
        call setline(a:lnum, line)
        if do_feedkeys
            call feedkeys('A', 'n')
        endif
    endif
endfunction "}}}

function! s:caw.a.comment_visual() "{{{
    let do_feedkeys = 1
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum, do_feedkeys)
        let do_feedkeys = 0
    endfor
endfunction "}}}


function! s:caw_a_get_commented_col(lnum) "{{{
    let cmt = s:get_comment_string(&filetype)
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
endfunction "}}}

function! s:caw.a.commented_normal(lnum) "{{{
    return s:caw_a_get_commented_col(a:lnum) > 0
endfunction "}}}

function! s:caw.a.commented_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        if self.commented_normal(lnum)
            return 1
        endif
    endfor
    return 0
endfunction "}}}


function! s:caw.a.uncomment_normal(lnum) "{{{
    let cmt = s:get_comment_string(&filetype)
    if cmt != ''
        let col = s:caw_a_get_commented_col(a:lnum)
        if col <= 0
            return
        endif
        let idx = col - 1

        let line = getline(a:lnum)
        let [l, r] = [line[idx : idx + strlen(cmt) - 1], cmt]
        call s:assert(l ==# r, "s:caw.a.uncomment_normal(): ".string(l).' ==# '.string(r))

        let before = line[0 : idx - 1]
        " 'caw_sp_a_left'
        let before = substitute(before, '\s\+$', '', '')

        call setline(a:lnum, before)
    endif
endfunction "}}}

function! s:caw.a.uncomment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.uncomment_normal(lnum)
    endfor
endfunction "}}}

" }}}

" jump {{{
let s:caw.jump = deepcopy(s:base)

function! s:caw.jump.comment(next) "{{{
    let cmt = s:get_comment_string(&filetype)
    if cmt == ''
        return
    endif

    if a:next
        let indent = matchstr(getline('.'), '^\s\+')
        call append(line('.'), indent . cmt . g:caw_sp_jump)
        call cursor(line('.') + 1, 1)
        startinsert!
    else
        let indent = matchstr(getline('.'), '^\s\+')
        call append(line('.') - 1, indent . cmt . g:caw_sp_jump)
        call cursor(line('.') - 1, 1)
        startinsert!
    endif
endfunction "}}}

" }}}

" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
