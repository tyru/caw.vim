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


" key: current action name, value: old action name
let s:deprecated = {
\   'tildepos': 'i',
\   'zeropos': 'I',
\   'dollarpos': 'a',
\}

" Global variables {{{
let g:caw_no_default_keymappings = get(g:, 'caw_no_default_keymappings', 0)
" If a old variable exists, show deprecation message
" and set the value to a new variable.
function! s:def_deprecated(name, value) abort
    let m = matchlist(a:name, '\v^caw_(tildepos|zeropos|dollarpos)')
    if !empty(m)
        let oldvarname = substitute(
        \   a:name, '^caw_' . m[1], 'caw_' . s:deprecated[m[1]], ''
        \)
        if has_key(g:, oldvarname)
            echohl WarningMsg
            echomsg printf('g:%s is deprecated. please use g:%s instead.', oldvarname, a:name)
            echohl None
            let g:[a:name] = g:[oldvarname]
        else
            let g:[a:name] = get(g:, a:name, a:value)
        endif
    else
        let g:[a:name] = get(g:, a:name, a:value)
    endif
endfunction

function! s:def(name, value) abort
    let g:[a:name] = get(g:, a:name, a:value)
endfunction

call s:def_deprecated('caw_tildepos_sp', ' ')
call s:def_deprecated('caw_tildepos_sp_blank', '')
call s:def_deprecated('caw_tildepos_startinsert_at_blank_line', 1)
call s:def_deprecated('caw_tildepos_skip_blank_line', 0)
call s:def_deprecated('caw_tildepos_align', 1)

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
function! s:define_prefix(lhs) abort
    let rhs = '<Plug>(caw:prefix)'
    if !hasmapto(rhs)
        execute 'silent! nmap <unique>' a:lhs rhs
        execute 'silent! xmap <unique>' a:lhs rhs
    endif
endfunction
call s:define_prefix('gc')


function! s:map_generic(action, method, ...) abort
    let has_deprecated_action = has_key(s:deprecated, a:action)
    let lhs = printf('<Plug>(caw:%s:%s)', a:action, a:method)
    let deprecated_lhs = printf('<Plug>(caw:%s:%s)',
    \                       get(s:deprecated, a:action, ''), a:method)
    let modes = get(a:000, 0, 'nx')
    for mode in split(modes, '\zs')
        execute
        \   mode . 'noremap'
        \   '<silent>'
        \   lhs
        \   printf(
        \       ':<C-u>call caw#keymapping_stub(%s, %s, %s)<CR>',
        \       string(mode),
        \       string(a:action),
        \       string(a:method))
        if has_deprecated_action
            execute
            \   mode . 'noremap'
            \   '<silent>'
            \   deprecated_lhs
            \   printf(
            \       ':<C-u>call caw#keymapping_stub_deprecated'
            \                       . '(%s, %s, %s, %s)<CR>',
            \       string(mode),
            \       string(a:action),
            \       string(a:method),
            \       string(s:deprecated[a:action]))
        endif
    endfor
endfunction

function! s:map_user(lhs, rhs) abort
    let lhs = '<Plug>(caw:prefix)' . a:lhs
    let rhs = printf('<Plug>(caw:%s)', a:rhs)
    for mode in ['n', 'x']
        if !hasmapto(rhs, mode)
            silent! execute
            \   mode.'map <unique>' lhs rhs
        endif
    endfor
endfunction



" tildepos {{{
call s:map_generic('tildepos', 'comment', 'nx')
call s:map_generic('tildepos', 'uncomment', 'nx')
call s:map_generic('tildepos', 'toggle', 'nx')

if !g:caw_no_default_keymappings
    call s:map_user('i', 'tildepos:comment')
    call s:map_user('ui', 'tildepos:uncomment')
    call s:map_user('c', 'tildepos:toggle')
endif
" }}}

" zeropos {{{
call s:map_generic('zeropos', 'comment', 'nx')
call s:map_generic('zeropos', 'uncomment', 'nx')
call s:map_generic('zeropos', 'toggle', 'nx')

if !g:caw_no_default_keymappings
    call s:map_user('I', 'zeropos:comment')
    call s:map_user('uI', 'zeropos:uncomment')
endif
" }}}

" dollarpos {{{
call s:map_generic('dollarpos', 'comment')
call s:map_generic('dollarpos', 'uncomment')
call s:map_generic('dollarpos', 'toggle')

if !g:caw_no_default_keymappings
    call s:map_user('a', 'dollarpos:comment')
    call s:map_user('ua', 'dollarpos:uncomment')
endif
" }}}

" wrap {{{
call s:map_generic('wrap', 'comment')
call s:map_generic('wrap', 'uncomment')
call s:map_generic('wrap', 'toggle')

if !g:caw_no_default_keymappings
    call s:map_user('w', 'wrap:comment')
    call s:map_user('uw', 'wrap:uncomment')
endif
" }}}

" box {{{
call s:map_generic('box', 'comment')

if !g:caw_no_default_keymappings
    call s:map_user('b', 'box:comment')
endif
" }}}

" jump {{{
call s:map_generic('jump', 'comment-next', 'n')
call s:map_generic('jump', 'comment-prev', 'n')

if !g:caw_no_default_keymappings
    call s:map_user('o', 'jump:comment-next')
    call s:map_user('O', 'jump:comment-prev')
endif
" }}}

" input {{{
call s:map_generic('input', 'comment')
call s:map_generic('input', 'uncomment')

if !g:caw_no_default_keymappings
    call s:map_user('v', 'input:comment')
    call s:map_user('uv', 'input:uncomment')
endif
" }}}

" operator {{{
try
    call operator#user#define('caw_wrap_toggle', 'caw#operator_wrap_toggle')
catch /^Vim\%((\a\+)\)\=:E117/
    " vim-operator-user is not installed
endtry
" }}}

" Cleanup {{{

unlet s:deprecated
delfunction s:define_prefix
delfunction s:map_generic
delfunction s:map_user

" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
