" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_caw') && g:loaded_caw
    finish
endif
let g:loaded_caw = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


let s:plug = {}

" key: current action name, value: old action name
let s:plug.deprecated = {
\   'hatpos': ['i', 'tildepos'],
\   'zeropos': ['I'],
\   'dollarpos': ['a'],
\}

" Global variables {{{

let g:caw_no_default_keymappings = get(g:, 'caw_no_default_keymappings', 0)
let g:caw_operator_keymappings = get(g:, 'caw_operator_keymappings', 0)
if globpath(&rtp, 'autoload/operator/user.vim') !=# ''
    let s:operator_user_installed = 1
else
    let s:operator_user_installed = 0
    let g:caw_operator_keymappings = 0
endif

" If any of old variables exists, show deprecation message
" and set the value to a new variable.
function! s:def_deprecated(name, value) abort
    let m = matchlist(a:name, '\v^caw_(hatpos|zeropos|dollarpos)')
    if !empty(m)
        let found = 0
        for d in s:plug.deprecated[m[1]]
            let oldvarname = substitute(
            \   a:name, '^caw_' . m[1], 'caw_' . d, ''
            \)
            if has_key(g:, oldvarname)
                echohl WarningMsg
                echomsg printf('g:%s is deprecated. please use g:%s instead.', oldvarname, a:name)
                echohl None
                let g:[a:name] = g:[oldvarname]
                let found = 1
            endif
        endfor
        if !found
            let g:[a:name] = get(g:, a:name, a:value)
        endif
    else
        let g:[a:name] = get(g:, a:name, a:value)
    endif
endfunction

function! s:def(name, value) abort
    let g:[a:name] = get(g:, a:name, a:value)
endfunction

call s:def_deprecated('caw_hatpos_sp', ' ')
call s:def_deprecated('caw_hatpos_sp_blank', '')
call s:def_deprecated('caw_hatpos_startinsert_at_blank_line', 1)
call s:def_deprecated('caw_hatpos_skip_blank_line', 0)
call s:def_deprecated('caw_hatpos_align', 1)

call s:def_deprecated('caw_zeropos_sp', ' ')
call s:def_deprecated('caw_zeropos_sp_blank', '')
call s:def_deprecated('caw_zeropos_startinsert_at_blank_line', 1)
call s:def_deprecated('caw_zeropos_skip_blank_line', 0)

call s:def_deprecated('caw_dollarpos_sp_left', repeat(' ', 4))
call s:def_deprecated('caw_dollarpos_sp_right', ' ')
call s:def_deprecated('caw_dollarpos_startinsert', 1)

call s:def('caw_wrap_sp_left', ' ')
call s:def('caw_wrap_sp_right', ' ')
call s:def('caw_wrap_skip_blank_line', 1)
call s:def('caw_wrap_align', 1)

call s:def('caw_jump_sp', ' ')

call s:def('caw_box_sp_left', ' ')
call s:def('caw_box_sp_right', ' ')

call s:def('caw_find_another_action', 1)

delfunction s:def_deprecated
delfunction s:def
" }}}

" Define default keymappings and <Plug> keymappings. {{{

" NOTE: You can change <Plug>(caw:prefix) to change prefix.
function! s:plug.define_prefix(lhs) abort
    let rhs = '<Plug>(caw:prefix)'
    if !hasmapto(rhs)
        execute 'silent! nmap <unique>' a:lhs rhs
        execute 'silent! xmap <unique>' a:lhs rhs
    endif
endfunction
call s:plug.define_prefix('gc')

function! s:plug.map(action, method, ...) abort
    let modes = get(a:000, 0, 'nx')
    call s:plug.map_plug(a:action, a:method, modes)
    if s:operator_user_installed
        call s:plug.map_operator(a:action, a:method)
    endif
endfunction

function! s:plug.map_operator(action, method) abort
    let name = 'caw-' . a:action . '-' . a:method
    let excmd = printf('call caw#__operator_init__(%s, %s)',
    \                   string(a:action), string(a:method))
    call operator#user#define(name, 'caw#__do_operator__', excmd)
    " For forward compatibility, do not let users map keymappings directly
    " which operator-user provides.
    for mode in ['n', 'x', 'o']
        execute mode . 'map'
        \   printf('<Plug>(caw:%s:%s:operator)', a:action, a:method)
        \   printf('<Plug>(operator-caw-%s-%s)', a:action, a:method)
    endfor
endfunction

function! s:plug.map_plug(action, method, modes) abort
    let lhs = printf('<Plug>(caw:%s:%s)', a:action, a:method)
    for mode in split(a:modes, '\zs')
        execute
        \   mode . 'noremap'
        \   '<silent>'
        \   lhs
        \   printf(
        \       ':<C-u>call caw#keymapping_stub(%s, %s, %s)<CR>',
        \       string(mode),
        \       string(a:action),
        \       string(a:method))
        for deprecated_action in get(s:plug.deprecated, a:action, [])
            execute
            \   mode . 'noremap'
            \   '<silent>'
            \   printf('<Plug>(caw:%s:%s)', deprecated_action, a:method)
            \   printf(
            \       ':<C-u>call caw#keymapping_stub_deprecated'
            \                       . '(%s, %s, %s, %s)<CR>',
            \       string(mode),
            \       string(a:action),
            \       string(a:method),
            \       string(deprecated_action))
        endfor
    endfor
endfunction

function! s:plug.map_user(lhs, action, method) abort
    if g:caw_operator_keymappings && a:action ==# 'jump'
        " jump action does not support operator
        return
    endif
    let lhs = '<Plug>(caw:prefix)' . a:lhs
    let rhs = g:caw_operator_keymappings ?
    \           printf('<Plug>(caw:%s:%s:operator)', a:action, a:method) :
    \           printf('<Plug>(caw:%s:%s)', a:action, a:method)
    for mode in ['n', 'x']
        if !hasmapto(rhs, mode)
            silent! execute
            \   mode.'map <unique>' lhs rhs
        endif
    endfor
endfunction



" hatpos {{{
call s:plug.map('hatpos', 'comment', 'nx')
call s:plug.map('hatpos', 'uncomment', 'nx')
call s:plug.map('hatpos', 'toggle', 'nx')

if !g:caw_no_default_keymappings
    call s:plug.map_user('i', 'hatpos', 'comment')
    call s:plug.map_user('ui', 'hatpos', 'uncomment')
    call s:plug.map_user('c', 'hatpos', 'toggle')
endif
" }}}

" zeropos {{{
call s:plug.map('zeropos', 'comment', 'nx')
call s:plug.map('zeropos', 'uncomment', 'nx')
call s:plug.map('zeropos', 'toggle', 'nx')

if !g:caw_no_default_keymappings
    call s:plug.map_user('I', 'zeropos', 'comment')
    call s:plug.map_user('uI', 'zeropos', 'uncomment')
endif
" }}}

" dollarpos {{{
call s:plug.map('dollarpos', 'comment')
call s:plug.map('dollarpos', 'uncomment')
call s:plug.map('dollarpos', 'toggle')

if !g:caw_no_default_keymappings
    call s:plug.map_user('a', 'dollarpos', 'comment')
    call s:plug.map_user('ua', 'dollarpos', 'uncomment')
endif
" }}}

" wrap {{{
call s:plug.map('wrap', 'comment')
call s:plug.map('wrap', 'uncomment')
call s:plug.map('wrap', 'toggle')

if !g:caw_no_default_keymappings
    call s:plug.map_user('w', 'wrap', 'comment')
    call s:plug.map_user('uw', 'wrap', 'uncomment')
endif
" }}}

" box {{{
call s:plug.map('box', 'comment')

if !g:caw_no_default_keymappings
    call s:plug.map_user('b', 'box', 'comment')
endif
" }}}

" jump {{{
call s:plug.map('jump', 'comment-next', 'n')
call s:plug.map('jump', 'comment-prev', 'n')

if !g:caw_no_default_keymappings
    call s:plug.map_user('o', 'jump', 'comment-next')
    call s:plug.map_user('O', 'jump', 'comment-prev')
endif
" }}}

" }}}

unlet s:plug


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
