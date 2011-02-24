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



function! s:map(lhs, rhs) "{{{
    if a:lhs == '' || a:rhs == ''
        echoerr 'internal error'
        return
    endif
    if !hasmapto(a:rhs)
        execute 'silent! nmap <unique>' a:lhs a:rhs
        execute 'silent! vmap <unique>' a:lhs a:rhs
    endif
endfunction "}}}


" prefix
call s:map('gc', '<Plug>(caw:prefix)')


" i/a
nnoremap <silent> <Plug>(caw:i:comment)  :<C-u>call caw#do_i_comment('n')<CR>
vnoremap <silent> <Plug>(caw:i:comment)  :<C-u>call caw#do_i_comment('v')<CR>

nnoremap <silent> <Plug>(caw:I:comment)  :<C-u>call caw#do_I_comment('n')<CR>
vnoremap <silent> <Plug>(caw:I:comment)  :<C-u>call caw#do_I_comment('v')<CR>

nnoremap <silent> <Plug>(caw:a:comment)  :<C-u>call caw#do_a_comment('n')<CR>
vnoremap <silent> <Plug>(caw:a:comment)  :<C-u>call caw#do_a_comment('v')<CR>

nnoremap <silent> <Plug>(caw:i:uncomment)    :<C-u>call caw#do_i_uncomment('n')<CR>
vnoremap <silent> <Plug>(caw:i:uncomment)    :<C-u>call caw#do_i_uncomment('v')<CR>

nnoremap <silent> <Plug>(caw:i:uncomment)    :<C-u>call caw#do_i_uncomment('n')<CR>
vnoremap <silent> <Plug>(caw:i:uncomment)    :<C-u>call caw#do_i_uncomment('v')<CR>

nnoremap <silent> <Plug>(caw:I:uncomment)    :<C-u>call caw#do_I_uncomment('n')<CR>
vnoremap <silent> <Plug>(caw:I:uncomment)    :<C-u>call caw#do_I_uncomment('v')<CR>

nnoremap <silent> <Plug>(caw:a:uncomment)    :<C-u>call caw#do_a_uncomment('n')<CR>
vnoremap <silent> <Plug>(caw:a:uncomment)    :<C-u>call caw#do_a_uncomment('v')<CR>

nnoremap <silent> <Plug>(caw:i:toggle)   :<C-u>call caw#do_i_toggle('n')<CR>
vnoremap <silent> <Plug>(caw:i:toggle)   :<C-u>call caw#do_i_toggle('v')<CR>

nnoremap <silent> <Plug>(caw:I:toggle)   :<C-u>call caw#do_I_toggle('n')<CR>
vnoremap <silent> <Plug>(caw:I:toggle)   :<C-u>call caw#do_I_toggle('v')<CR>

nnoremap <silent> <Plug>(caw:a:toggle)   :<C-u>call caw#do_a_toggle('n')<CR>
vnoremap <silent> <Plug>(caw:a:toggle)   :<C-u>call caw#do_a_toggle('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)i', '<Plug>(caw:i:comment)')
    call s:map('<Plug>(caw:prefix)I', '<Plug>(caw:I:comment)')
    call s:map('<Plug>(caw:prefix)a', '<Plug>(caw:a:comment)')
    call s:map('<Plug>(caw:prefix)ui', '<Plug>(caw:i:uncomment)')
    call s:map('<Plug>(caw:prefix)ua', '<Plug>(caw:a:uncomment)')
    call s:map('<Plug>(caw:prefix)c', '<Plug>(caw:i:toggle)')
endif


" wrap
nnoremap <silent> <Plug>(caw:wrap:comment)           :<C-u>call caw#do_wrap_comment('n')<CR>
vnoremap <silent> <Plug>(caw:wrap:comment)           :<C-u>call caw#do_wrap_comment('v')<CR>

nnoremap <silent> <Plug>(caw:wrap:uncomment)         :<C-u>call caw#do_wrap_uncomment('n')<CR>
vnoremap <silent> <Plug>(caw:wrap:uncomment)         :<C-u>call caw#do_wrap_uncomment('v')<CR>

nnoremap <silent> <Plug>(caw:wrap:toggle)            :<C-u>call caw#do_wrap_toggle('n')<CR>
vnoremap <silent> <Plug>(caw:wrap:toggle)            :<C-u>call caw#do_wrap_toggle('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)w', '<Plug>(caw:wrap:comment)')
    call s:map('<Plug>(caw:prefix)uw', '<Plug>(caw:wrap:uncomment)')
endif



" jump
nnoremap <silent> <Plug>(caw:jump:comment-next)  :<C-u>call caw#do_jump_comment_next()<CR>

nnoremap <silent> <Plug>(caw:jump:comment-prev)  :<C-u>call caw#do_jump_comment_prev()<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)o', '<Plug>(caw:jump:comment-next)')
    call s:map('<Plug>(caw:prefix)O', '<Plug>(caw:jump:comment-prev)')
endif



" input
nnoremap <silent> <Plug>(caw:input:comment)  :<C-u>call caw#do_input_comment('n')<CR>
vnoremap <silent> <Plug>(caw:input:comment)  :<C-u>call caw#do_input_comment('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)v', '<Plug>(caw:input:comment)')
endif


" uncomment: input
nnoremap <silent> <Plug>(caw:input:uncomment)    :<C-u>call caw#do_input_uncomment('n')<CR>
vnoremap <silent> <Plug>(caw:input:uncomment)    :<C-u>call caw#do_input_uncomment('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)uv', '<Plug>(caw:input:uncomment)')
endif


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
