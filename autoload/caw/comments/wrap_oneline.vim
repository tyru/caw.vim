scriptencoding utf-8

function! caw#comments#wrap_oneline#new() abort
    return deepcopy(s:wrap_oneline)
endfunction


let s:wrap_oneline = {}

function! s:wrap_oneline.get_comment() abort
    for method in ['get_comment_vars', 'get_comment_detect']
        let r = self[method]()
        if !empty(r)
            return r
        endif
        unlet r
    endfor
    return []
endfunction

function! s:wrap_oneline.get_comment_vars() abort
    return caw#get_var('caw_wrap_oneline_comment', [])
endfunction

function! s:wrap_oneline.get_comment_detect() abort
    let m = matchlist(&l:commentstring, '^\(.\{-}\)[ \t]*%s[ \t]*\(.*\)$')
    if !empty(m) && m[1] !=# '' && m[2] !=# ''
        return m[1:2]
    endif
    return []
endfunction
