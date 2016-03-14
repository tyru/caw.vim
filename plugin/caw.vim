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


" Global variables {{{
if !exists('g:caw_no_default_keymappings')
    let g:caw_no_default_keymappings = 0
endif

if !exists('g:caw_i_sp')
    let g:caw_i_sp = ' '
endif
if !exists('g:caw_i_sp_blank')
    let g:caw_i_sp_blank = ''
endif
if !exists('g:caw_i_startinsert_at_blank_line')
    let g:caw_i_startinsert_at_blank_line = 1
endif
if !exists('g:caw_i_skip_blank_line')
    let g:caw_i_skip_blank_line = 0
endif
if !exists('g:caw_i_align')
    let g:caw_i_align = 1
endif

if !exists('g:caw_I_sp')
    let g:caw_I_sp = ' '
endif
if !exists('g:caw_I_sp_blank')
    let g:caw_I_sp_blank = ''
endif
if !exists('g:caw_I_startinsert_at_blank_line')
    let g:caw_I_startinsert_at_blank_line = 1
endif
if !exists('g:caw_I_skip_blank_line')
    let g:caw_I_skip_blank_line = 0
endif

if !exists('g:caw_a_sp_left')
    let g:caw_a_sp_left = repeat(' ', 4)
endif
if !exists('g:caw_a_sp_right')
    let g:caw_a_sp_right = ' '
endif
if !exists('g:caw_a_startinsert')
    let g:caw_a_startinsert = 1
endif

if !exists('g:caw_wrap_sp_left')
    let g:caw_wrap_sp_left = ' '
endif
if !exists('g:caw_wrap_sp_right')
    let g:caw_wrap_sp_right = ' '
endif
if !exists('g:caw_wrap_skip_blank_line')
    let g:caw_wrap_skip_blank_line = 1
endif
if !exists('g:caw_wrap_align')
    let g:caw_wrap_align = 1
endif

if !exists('g:caw_jump_sp')
    let g:caw_jump_sp = ' '
endif

if !exists('g:caw_box_sp_left')
    let g:caw_box_sp_left = ' '
endif
if !exists('g:caw_box_sp_right')
    let g:caw_box_sp_right = ' '
endif

if !exists('g:caw_find_another_action')
    let g:caw_find_another_action = 1
endif
" }}}


" Define default <Plug> keymapping. {{{

" NOTE: You can change <Plug>(caw:prefix) to change prefix.
function! s:define_prefix(lhs) "{{{
    let rhs = '<Plug>(caw:prefix)'
    if !hasmapto(rhs)
        execute 'silent! nmap <unique>' a:lhs rhs
        execute 'silent! xmap <unique>' a:lhs rhs
    endif
endfunction "}}}
call s:define_prefix('gc')


function! s:map_generic(action, method, ...) "{{{
    let lhs = printf('<Plug>(caw:%s:%s)', a:action, a:method)
    let modes = get(a:000, 0, 'nx')
    let sent_action = get(a:000, 1, a:action)
    for mode in split(modes, '\zs')
        execute
        \   mode . 'noremap'
        \   '<silent>'
        \   lhs
        \   printf(
        \       ':<C-u>call caw#keymapping_stub(%s, %s, %s)<CR>',
        \       string(mode),
        \       string(sent_action),
        \       string(a:method))
    endfor
endfunction "}}}
function! s:map_user(lhs, rhs) "{{{
    let lhs = '<Plug>(caw:prefix)' . a:lhs
    let rhs = printf('<Plug>(caw:%s)', a:rhs)
    for mode in ['n', 'x']
        if !hasmapto(rhs, mode)
            silent! execute
            \   mode.'map <unique>' lhs rhs
        endif
    endfor
endfunction "}}}



" i {{{
call s:map_generic('i', 'comment', 'nx', 'small_i')
call s:map_generic('i', 'uncomment', 'nx', 'small_i')
call s:map_generic('i', 'toggle', 'nx', 'small_i')

if !g:caw_no_default_keymappings
    call s:map_user('i', 'i:comment')
    call s:map_user('ui', 'i:uncomment')
    call s:map_user('c', 'i:toggle')
endif
" }}}

" I {{{
call s:map_generic('I', 'comment', 'nx', 'capital_i')
call s:map_generic('I', 'uncomment', 'nx', 'capital_i')
call s:map_generic('I', 'toggle', 'nx', 'capital_i')

if !g:caw_no_default_keymappings
    call s:map_user('I', 'I:comment')
    call s:map_user('uI', 'I:uncomment')
endif
" }}}

" a {{{
call s:map_generic('a', 'comment')
call s:map_generic('a', 'uncomment')
call s:map_generic('a', 'toggle')

if !g:caw_no_default_keymappings
    call s:map_user('a', 'a:comment')
    call s:map_user('ua', 'a:uncomment')
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


" Cleanup {{{

delfunction s:define_prefix
delfunction s:map_generic
delfunction s:map_user

" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
