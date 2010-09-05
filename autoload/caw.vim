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
function! caw#do_wrap_comment() "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_one_comment() "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_multi_comment() "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_toggle() "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_one_toggle() "{{{
    " TODO
endfunction "}}}

function! caw#do_wrap_multi_toggle() "{{{
    " TODO
endfunction "}}}



" uncomment
function! caw#do_uncomment() "{{{
    " TODO
endfunction "}}}


function! caw#do_uncomment_i() "{{{
    " TODO
endfunction "}}}

function! caw#do_uncomment_a() "{{{
    " TODO
endfunction "}}}


function! caw#do_uncomment_wrap() "{{{
    " TODO
endfunction "}}}

function! caw#do_uncomment_wrap_one() "{{{
    " TODO
endfunction "}}}

function! caw#do_uncomment_wrap_multi() "{{{
    " TODO
endfunction "}}}


function! caw#do_uncomment_input() "{{{
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
    let lnum = a:0 ? a:1 : line('.')
    if a:mode ==# 'n'
        let cmt = s:get_comment_string(&filetype)
        if cmt != ''
            let m = matchlist(getline(lnum), '^\([ \t]*\)\(.*\)')
            if empty(m)
                throw 'caw: s:caw.i.comment(): internal error'
            endif
            call setline(lnum, m[1] . cmt . s:get_var('caw_sp_i') . m[2])
        endif
    else
        for lnum in range(line("'<"), line("'>"))
            call self.comment('n', lnum)
        endfor
    endif
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
