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
    let all_comment = self.has_all_comment()
    let mixed = !all_comment && self.has_comment()
    if caw#context().mode ==# 'n'
        if all_comment
            " The line is commented out.
            call self.uncomment()
        else
            " The line is not commented out.
            call self.comment()
        endif
    else
        if mixed
            " Some lines are commented out.
            call self.comment()
        elseif all_comment
            " All lines are commented out.
            call self.uncomment()
        else
            " All lines are not commented out.
            call self.comment()
        endif
    endif
endfunction
