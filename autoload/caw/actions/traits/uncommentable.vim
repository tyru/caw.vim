scriptencoding utf-8

function! caw#actions#traits#uncommentable#new() abort
    return deepcopy(s:uncommentable)
endfunction


let s:uncommentable = {}

" Below methods are missing.
" Derived object must implement those.
"
" s:uncommentable.uncomment(),
" s:uncommentable.uncomment_visual() require:
" - Derived.uncomment_normal()


function! s:uncommentable.uncomment() abort
    let context = caw#context()
    if context.mode ==# 'n'
        call self.uncomment_normal(context.firstline)
    else
        call self.uncomment_visual()
    endif
endfunction

function! s:uncommentable.uncomment_visual() abort
    for lnum in range(
    \   caw#context().firstline,
    \   caw#context().lastline
    \)
        call self.uncomment_normal(lnum)
    endfor
endfunction
