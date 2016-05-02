scriptencoding utf-8

function! caw#actions#traits#togglable#new() abort
    return deepcopy(s:togglable)
endfunction


let s:togglable = {}

" Below methods are missing.
" Derived object must implement those.
"
" s:togglable.toggle requires:
" - Derived.uncomment()
" - Derived.comment()


function! s:togglable.toggle() abort
    if caw#context().mode ==# 'n'
        if self.has_all_comment()
            " The line has a comment string.
            call self.uncomment()
        else
            " The line doesn't have a comment string.
            call self.comment()
        endif
    else
        if self.has_all_comment()
            " All lines have comment strings.
            call self.uncomment()
        else
            " Some lines have comment strings, or no lines have comment strings.
            call self.comment()
        endif
    endif
endfunction
