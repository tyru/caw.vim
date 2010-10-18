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

nnoremap <silent> <Plug>(caw:a:comment)  :<C-u>call caw#do_a_comment('n')<CR>
vnoremap <silent> <Plug>(caw:a:comment)  :<C-u>call caw#do_a_comment('v')<CR>

nnoremap <silent> <Plug>(caw:i:toggle)   :<C-u>call caw#do_i_toggle('n')<CR>
vnoremap <silent> <Plug>(caw:i:toggle)   :<C-u>call caw#do_i_toggle('v')<CR>

nnoremap <silent> <Plug>(caw:a:toggle)   :<C-u>call caw#do_a_toggle('n')<CR>
vnoremap <silent> <Plug>(caw:a:toggle)   :<C-u>call caw#do_a_toggle('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)c', '<Plug>(caw:i:toggle)')
    call s:map('<Plug>(caw:prefix)i', '<Plug>(caw:i:comment)')
    call s:map('<Plug>(caw:prefix)a', '<Plug>(caw:a:comment)')
endif


" wrap
nnoremap <silent> <Plug>(caw:wrap:comment)           :<C-u>call caw#do_wrap_comment('n')<CR>
vnoremap <silent> <Plug>(caw:wrap:comment)           :<C-u>call caw#do_wrap_comment('v')<CR>

nnoremap <silent> <Plug>(caw:wrap:toggle)            :<C-u>call caw#do_wrap_toggle('n')<CR>
vnoremap <silent> <Plug>(caw:wrap:toggle)            :<C-u>call caw#do_wrap_toggle('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)w', '<Plug>(caw:wrap:comment)')
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



" uncomment
nnoremap <silent> <Plug>(caw:uncomment)  :<C-u>call caw#do_uncomment('n')<CR>
vnoremap <silent> <Plug>(caw:uncomment)  :<C-u>call caw#do_uncomment('n')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)uu', '<Plug>(caw:uncomment)')
endif

" uncomment: i/a
nnoremap <silent> <Plug>(caw:uncomment:i)    :<C-u>call caw#do_uncomment_i('n')<CR>
vnoremap <silent> <Plug>(caw:uncomment:i)    :<C-u>call caw#do_uncomment_i('v')<CR>

nnoremap <silent> <Plug>(caw:uncomment:a)    :<C-u>call caw#do_uncomment_a('n')<CR>
vnoremap <silent> <Plug>(caw:uncomment:a)    :<C-u>call caw#do_uncomment_a('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)ui', '<Plug>(caw:uncomment:i)')
    call s:map('<Plug>(caw:prefix)ua', '<Plug>(caw:uncomment:a)')
endif

" uncomment: wrap
nnoremap <silent> <Plug>(caw:uncomment:wrap)         :<C-u>call caw#do_uncomment_wrap('n')<CR>
vnoremap <silent> <Plug>(caw:uncomment:wrap)         :<C-u>call caw#do_uncomment_wrap('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)uw', '<Plug>(caw:uncomment:wrap)')
endif

" uncomment: input
nnoremap <silent> <Plug>(caw:uncomment:input)    :<C-u>call caw#do_uncomment_input('n')<CR>
vnoremap <silent> <Plug>(caw:uncomment:input)    :<C-u>call caw#do_uncomment_input('v')<CR>

if !g:caw_no_default_keymappings
    call s:map('<Plug>(caw:prefix)uv', '<Plug>(caw:uncomment:input)')
endif


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
