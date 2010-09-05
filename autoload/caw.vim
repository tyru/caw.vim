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
        echomsg v:exception
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
    if a:filetype =~# 'c\|cpp'
        return '//'
    elseif a:filetype =~# 'perl\|ruby\|python\|php'
        return '#'
    elseif a:filetype =~# 'vim'
        return '"'
    else
        return ''
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

" i {{{
let s:caw.i = {}

function! s:caw.i.comment(mode, ...) "{{{
    if a:mode ==# 'n'
        let lnum = a:0 ? a:1 : line('.')
        call self.comment_normal(lnum)
    else
        call self.comment_visual()
    endif
endfunction "}}}

function! s:caw.i.comment_normal(lnum) "{{{
    let cmt = s:get_comment_string(&filetype)
    if cmt != ''
        let m = matchlist(getline(a:lnum), '^\([ \t]*\)\(.*\)')
        if empty(m)
            throw 'caw: s:caw.i.comment(): internal error'
        endif
        call setline(a:lnum, m[1] . cmt . s:get_var('caw_sp_i') . m[2])
    endif
endfunction "}}}

function! s:caw.i.comment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum)
    endfor
endfunction "}}}

" }}}

" a {{{
let s:caw.a = {}

function! s:caw.a.comment(mode, ...) "{{{
    let lnum = a:0 ? a:1 : line('.')
    if a:mode ==# 'n'
        let cmt = s:get_comment_string(&filetype)
        if cmt != ''
            call setline(lnum, getline(lnum) . s:get_var('caw_sp_a_left') . cmt . s:get_var('caw_sp_a_right'))
            if s:get_var('caw_a_startinsert')
                call feedkeys('A', 'n')
            endif
        endif
    else
        for lnum in range(line("'<"), line("'>"))
            call self.comment('n', lnum)
        endfor
    endif
endfunction "}}}

" }}}

" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
