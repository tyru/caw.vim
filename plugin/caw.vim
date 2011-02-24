" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_CommentAnyWay') && g:loaded_CommentAnyWay
    finish
endif
let g:loaded_CommentAnyWay = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


if !exists('g:caw_no_default_keymappings')
    let g:caw_no_default_keymappings = 0
endif

if !exists('g:caw_sp_i')
    let g:caw_sp_i = ' '
endif
if !exists('g:caw_i_startinsert_at_blank_line')
    let g:caw_i_startinsert_at_blank_line = 1
endif
if !exists('g:caw_i_align')
    let g:caw_i_align = 1
endif

if !exists('g:caw_sp_a_left')
    let g:caw_sp_a_left = repeat(' ', 4)
endif
if !exists('g:caw_sp_a_right')
    let g:caw_sp_a_right = ' '
endif
if !exists('g:caw_a_startinsert')
    let g:caw_a_startinsert = 1
endif

if !exists('g:caw_sp_wrap_left')
    let g:caw_sp_wrap_left = ' '
endif
if !exists('g:caw_sp_wrap_right')
    let g:caw_sp_wrap_right = ' '
endif

if !exists('g:caw_sp_jump')
    let g:caw_sp_jump = ' '
endif

if !exists('g:caw_find_another_action')
    let g:caw_find_another_action = 1
endif



function! s:map_user(lhs, rhs) "{{{
    if a:lhs == '' || a:rhs == ''
        echoerr 'internal error'
        return
    endif
    if !hasmapto(a:rhs)
        execute 'silent! nmap <unique>' a:lhs a:rhs
        execute 'silent! vmap <unique>' a:lhs a:rhs
    endif
endfunction "}}}
function! s:map_plug(lhs, fn, ...) "{{{
    if a:lhs == '' || a:fn == ''
        echoerr 'internal error'
        return
    endif
    let lhs = printf('<Plug>(caw:%s)', a:lhs)
    for mode in a:0 ? a:1 : ['n', 'v']
        execute
        \   mode . 'noremap'
        \   '<silent>'
        \   lhs
        \   ':<C-u>call '
        \   . substitute(a:fn, '<mode>', string(mode), 'g')
        \   . '<CR>'
    endfor
endfunction "}}}


" prefix
call s:map_user('gc', '<Plug>(caw:prefix)')


" i/a
call s:map_plug('i:comment', 'caw#do_i_comment(<mode>)')
call s:map_plug('I:comment', 'caw#do_I_comment(<mode>)')
call s:map_plug('a:comment', 'caw#do_a_comment(<mode>)')

call s:map_plug('i:uncomment', 'caw#do_i_uncomment(<mode>)')
call s:map_plug('I:uncomment', 'caw#do_I_uncomment(<mode>)')
call s:map_plug('a:uncomment', 'caw#do_a_uncomment(<mode>)')

call s:map_plug('i:toggle', 'caw#do_i_toggle(<mode>)')
call s:map_plug('I:toggle', 'caw#do_I_toggle(<mode>)')
call s:map_plug('a:toggle', 'caw#do_a_toggle(<mode>)')

if !g:caw_no_default_keymappings
    call s:map_user('<Plug>(caw:prefix)i', '<Plug>(caw:i:comment)')
    call s:map_user('<Plug>(caw:prefix)I', '<Plug>(caw:I:comment)')
    call s:map_user('<Plug>(caw:prefix)a', '<Plug>(caw:a:comment)')
    call s:map_user('<Plug>(caw:prefix)ui', '<Plug>(caw:i:uncomment)')
    call s:map_user('<Plug>(caw:prefix)ua', '<Plug>(caw:a:uncomment)')
    call s:map_user('<Plug>(caw:prefix)c', '<Plug>(caw:i:toggle)')
endif


" wrap
call s:map_plug('wrap:comment', 'caw#do_wrap_comment(<mode>)')
call s:map_plug('wrap:uncomment', 'caw#do_wrap_uncomment(<mode>)')
call s:map_plug('wrap:toggle', 'caw#do_wrap_toggle(<mode>)')

if !g:caw_no_default_keymappings
    call s:map_user('<Plug>(caw:prefix)w', '<Plug>(caw:wrap:comment)')
    call s:map_user('<Plug>(caw:prefix)uw', '<Plug>(caw:wrap:uncomment)')
endif



" jump
call s:map_plug('jump:comment-next', 'caw#do_jump_comment_next()', ['n'])
call s:map_plug('jump:comment-prev', 'caw#do_jump_comment_prev()', ['n'])

if !g:caw_no_default_keymappings
    call s:map_user('<Plug>(caw:prefix)o', '<Plug>(caw:jump:comment-next)')
    call s:map_user('<Plug>(caw:prefix)O', '<Plug>(caw:jump:comment-prev)')
endif



" input
call s:map_plug('input:comment', 'caw#do_input_comment(<mode>)')

if !g:caw_no_default_keymappings
    call s:map_user('<Plug>(caw:prefix)v', '<Plug>(caw:input:comment)')
endif


" uncomment: input
call s:map_plug('input:uncomment', 'caw#do_input_uncomment(<mode>)')

if !g:caw_no_default_keymappings
    call s:map_user('<Plug>(caw:prefix)uv', '<Plug>(caw:input:uncomment)')
endif



delfunc s:map_user
delfunc s:map_plug


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
