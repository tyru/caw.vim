scriptencoding utf-8

function! caw#comments#wrap_oneline#new() abort
    return deepcopy(s:wrap_oneline)
endfunction


let s:wrap_oneline = {}
let s:METHODS = ['get_comment_vars', 'get_comment_detect']
lockvar! s:METHODS

function! s:wrap_oneline.get_comments() abort
    let comments = []
    for method in s:METHODS
        let r = self[method]()
        if !empty(r)
            let comments += [r]
        endif
    endfor
    return comments
endfunction

function! s:wrap_oneline.get_comment_vars() abort
    return caw#get_var('caw_wrap_oneline_comment', [], [line('.')])
endfunction

function! s:wrap_oneline.get_comment_detect() abort
    let m = matchlist(&l:commentstring, '^\(.\{-}\)[ \t]*%s[ \t]*\(.*\)$')
    if !empty(m) && m[1] !=# '' && m[2] !=# ''
        return m[1:2]
    endif
    return []
endfunction
