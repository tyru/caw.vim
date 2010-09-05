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



" input
function! caw#do_input_comment(mode) "{{{
    return s:sandbox_call(s:caw.input.comment, [a:mode], s:caw.input)
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

function! s:set_and_save_comment_string(filetype, comment_string) "{{{
    let stash = {}

    let NONEXISTS = 0
    let INVALID = 1
    let EXISTS = 2
    let EMPTY = 0

    if !exists('b:caw_oneline_comment_string')
        let stash.status = NONEXISTS
        let cmt = EMPTY
    elseif type(b:caw_oneline_comment_string) != type({})
        let stash.status = INVALID
        let stash.org_value = copy(b:caw_oneline_comment_string)
        let cmt = EMPTY
    else
        let stash.status = EXISTS
        let stash.org_value = copy(b:caw_oneline_comment_string)
        let cmt = get(b:caw_oneline_comment_string, a:filetype, EMPTY)
    endif

    let b:caw_oneline_comment_string = extend(
    \   (cmt is EMPTY ? {} : b:caw_oneline_comment_string),
    \   {a:filetype : a:comment_string},
    \   'force'
    \)

    return stash
endfunction "}}}

function! s:restore_comment_string(stash) "{{{
    let NONEXISTS = 0
    let INVALID = 1
    let EXISTS = 2

    if a:stash.status ==# NONEXISTS
        unlet b:caw_oneline_comment_string
    elseif a:stash.status ==# INVALID
        let b:caw_oneline_comment_string = a:stash.org_value
    elseif a:stash.status ==# EXISTS
        let b:caw_oneline_comment_string = a:stash.org_value
    endif
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
" s:base.commented() and s:base.commented_visual() requires:
" - s:base.commented_normal()
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

function! s:base.commented_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        if self.commented_normal(lnum)
            return 1
        endif
    endfor
    return 0
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
    let startinsert = a:0 ? a:1 : s:get_var('caw_a_startinsert')
    let cmt = s:get_comment_string(&filetype)
    if cmt != ''
        let line = getline(a:lnum) . s:get_var('caw_sp_a_left') . cmt . s:get_var('caw_sp_a_right')
        call setline(a:lnum, line)
        if startinsert
            call feedkeys('A', 'n')
        endif
    endif
endfunction "}}}

function! s:caw.a.comment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum, 0)
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

" input {{{
let s:caw.input = {}

function! s:caw.input.comment(mode) "{{{
    let [pos, pos_opt] = s:caw_input_get_pos()
    if !has_key(s:caw, pos) || !has_key(s:caw[pos], 'comment')
        echohl WarningMsg
        echomsg pos . ': Invalid pos.'
        echohl None
        return
    endif

    let default_cmt = s:get_comment_string(&filetype)
    let cmt = s:caw_input_get_comment_string(default_cmt)

    if default_cmt !=# cmt
        let org_status = s:set_and_save_comment_string(&filetype, cmt)
    endif
    try
        if a:mode ==# 'n'
            call self.comment_normal(line('.'), pos)
        else
            call self.comment_visual(pos)
        endif
    finally
        if default_cmt !=# cmt
            call s:restore_comment_string(org_status)
        endif
    endtry
endfunction "}}}

function! s:caw.input.comment_normal(lnum, pos) "{{{
    call s:caw[a:pos].comment_normal(a:lnum)
endfunction "}}}

function! s:caw.input.comment_visual(pos) "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum, a:pos)
    endfor
endfunction "}}}

function! s:caw_input_get_pos() "{{{
    let NONE = ['', '']

    let pos = get({
    \   'i': 'i',
    \   'a': 'a',
    \   'j': 'jump',
    \   'w': 'wrap',
    \}, s:getchar(), '')

    if pos == ''
        return NONE
    elseif pos ==# 'jump'
        let next_or_prev = get({
        \   'o': 'next',
        \   'O': 'prev',
        \}, s:getchar(), '')
        if next_or_prev == ''
            return NONE
        else
            return [pos, next_or_prev]
        endif
    else
        return [pos, '']
    endif
endfunction "}}}

function! s:getchar(...) "{{{
    call inputsave()
    try
        let c = call('getchar', a:000)
        return type(c) == type("") ? c : nr2char(c)
    finally
        call inputrestore()
    endtry
endfunction "}}}

function! s:caw_input_get_comment_string(default_cmt) "{{{
    return s:input('any comment?:', a:default_cmt)
endfunction "}}}

function! s:input(...) "{{{
    call inputsave()
    try
        return call('input', a:000)
    finally
        call inputrestore()
    endtry
endfunction "}}}

" }}}

" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
