" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


"caw#keymapping_stub(): All keymappings are bound to this function. {{{
function! caw#keymapping_stub(mode, action, method)
    let context = {}
    let context.mode = a:mode
    let context.visualmode = visualmode()
    if a:mode ==# 'n'
        let context.firstline = line('.')
        let context.lastline  = line('.')
    else
        let context.firstline = line("'<")
        let context.lastline  = line("'>")
    endif
    if exists('*context_filetype#get_filetype')
        let context.filetype = context_filetype#get_filetype()
    else
        let context.filetype = &filetype
    endif
    let context.count = v:count1
    call s:set_context(context)

    try
        " TODO: Check the action exists.
        let actions = [caw#new('actions.' . a:action)]

        " TODO:
        " - Deprecate g:caw_find_another_action and
        " Implement <Plug>(caw:dwim) like Emacs's dwim-comment
        " - Stop checking b:changedtick and
        " let act[a:method] just return changed lines,
        " not modifying buffer.
        if caw#get_var('caw_find_another_action')
            let actions += map(
            \   copy(get(actions[0], 'fallback_types', [])),
            \   'caw#new("actions." . v:val)')
        endif

        for act in actions
            let old_changedtick = b:changedtick
            if has_key(act, 'comment_database')
            \   && empty(act.comment_database.get_comment())
                continue
            endif

            call act[a:method]()

            " FIXME: Should check by return value of `act[a:method]()`
            if b:changedtick !=# old_changedtick
                break
            endif
        endfor
    catch
        echohl ErrorMsg
        echomsg '[' . v:exception . ']::[' . v:throwpoint . ']'
        echohl None
    finally
        call s:set_context({})    " free context.
    endtry
endfunction
" }}}

" Context: context while invoking keymapping. {{{
let s:context = {}
function! s:set_context(context)
    unlockvar! s:context
    let s:context = a:context
    lockvar! s:context
endfunction
function! caw#context()
    return s:context
endfunction
" }}}

" Utilities: Misc. functions. {{{

function s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction
let s:SNR_PREFIX = '<SNR>' . s:SID() . '_'
delfunc s:SID

function! s:local_func(name)
    return function(s:SNR_PREFIX . a:name)
endfunction



function! caw#assert(cond, msg)
    if !a:cond
        throw 'caw: assertion failure: ' . a:msg
    endif
endfunction

function! caw#get_var(varname, ...)
    for ns in [b:, w:, t:, g:]
        if has_key(ns, a:varname)
            return ns[a:varname]
        endif
    endfor
    if a:0
        return a:1
    else
        call caw#assert(0, "caw#get_var(): this must be reached")
    endif
endfunction


function! caw#get_inserted_indent(lnum)
    return matchstr(getline(a:lnum), '^\s\+')
endfunction

function! s:get_inserted_indent_num(lnum)
    return strlen(caw#get_inserted_indent(a:lnum))
endfunction

function! s:make_indent_str(indent_byte_num)
    return repeat((&expandtab ? ' ' : "\t"), a:indent_byte_num)
endfunction


function! caw#trim_whitespaces(str)
    let str = a:str
    let str = substitute(str, '^\s\+', '', '')
    let str = substitute(str, '\s\+$', '', '')
    return str
endfunction

function! caw#get_min_indent_num(skip_blank_line, from_lnum, to_lnum)
    let min_indent_num = 1/0
    for lnum in range(a:from_lnum, a:to_lnum)
        if a:skip_blank_line && getline(lnum) =~ '^\s*$'
            continue    " Skip blank line.
        endif
        let n = s:get_inserted_indent_num(lnum)
        if n < min_indent_num
            let min_indent_num = n
        endif
    endfor
    return min_indent_num
endfunction

function! caw#get_both_sides_space_cols(skip_blank_line, from_lnum, to_lnum)
    let left  = 1/0
    let right = 1
    for line in getline(a:from_lnum, a:to_lnum)
        if a:skip_blank_line && line =~ '^\s*$'
            continue    " Skip blank line.
        endif
        let l  = strlen(matchstr(line, '^\s*')) + 1
        let r = strlen(line) - strlen(matchstr(line, '\s*$')) + 1
        if l < left
            let left = l
        endif
        if r > right
            let right = r
        endif
    endfor
    return [left, right]
endfunction

function! caw#wrap_comment_align(line, left_cmt, right_cmt, left_col, right_col)
    let l = a:line
    " Save indent.
    let indent = a:left_col >=# 2 ? l[: a:left_col-2] : ''
    let indent = indent =~# '^\s*$' ? indent : ''
    " Pad tail whitespaces.
    if strlen(l) < a:right_col-1
        let l .= repeat(' ', (a:right_col-1) - strlen(l))
    endif
    " Trim left/right whitespaces.
    let l = l[a:left_col-1 : a:right_col-1]
    " Add left/right comment and whitespaces.
    if a:left_cmt !=# ''
        let l = a:left_cmt . l
    endif
    if a:right_cmt !=# ''
        let l = l . a:right_cmt
    endif
    " Restore indent.
    return indent . l
endfunction


" TODO: newer globpath() can return List.
function! s:globpath(path, expr) abort
    return split(globpath(a:path, a:expr, 1), '\n')
endfunction


" '.../autoload/caw'
let s:root_dir = expand('<sfile>:h') . '/caw'
" s:modules[module_name][cache_key]
" cache_key = string(a:000)
let s:modules = {}

function! caw#load(name) abort
    " If the module is already loaded, return it.
    if has_key(s:modules, a:name)
        return
    endif
    " Load script file.
    let file = tr(a:name, '.', '/') . '.vim'
    source `=s:root_dir.'/'.file`
    " Call depends() function.
    let depends = 'caw#' . tr(a:name, '.', '#') . '#depends'
    if exists('*'.depends)
        for module in call(depends, [])
            call caw#load(module)
        endfor
    endif
    let s:modules[a:name] = {}
endfunction

function! caw#new(name, ...) abort
    let id = string(a:000)
    if has_key(s:modules, a:name) && has_key(s:modules[a:name], id)
        return copy(s:modules[a:name][id])
    endif
    call caw#load(a:name)
    " Call new() function.
    let constructor = 'caw#' . tr(a:name, '.', '#') . '#new'
    let s:modules[a:name][id] = call(constructor, a:000)
    return copy(s:modules[a:name][id])
endfunction

function! caw#__inject_for_test__(name, mock, ...) abort
    let id = string(a:000)
    let s:modules[a:name][id] = copy(a:mock)
endfunction

" }}}

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
