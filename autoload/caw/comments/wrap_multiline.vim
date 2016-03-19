scriptencoding utf-8

function! caw#comments#wrap_multiline#new() abort
    return deepcopy(s:wrap_multiline)
endfunction


let s:wrap_multiline = {}

function! s:wrap_multiline.get_comment() abort
    for method in ['get_comment_vars']
        let r = self[method]()
        if !empty(r)
            return r
        endif
        unlet r
    endfor
    return {}
endfunction

function! s:wrap_multiline.get_comment_vars() abort
    return caw#get_var('caw_wrap_multiline_comment', '')
endfunction
