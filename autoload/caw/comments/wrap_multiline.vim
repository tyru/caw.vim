scriptencoding utf-8

function! caw#comments#wrap_multiline#new() abort
    return deepcopy(s:wrap_multiline)
endfunction


let s:wrap_multiline = {}
let s:METHODS = ['get_comment_vars']
lockvar! s:METHODS

function! s:wrap_multiline.get_comment() abort
    for method in s:METHODS
        let r = self[method]()
        if !empty(r)
            return r
        endif
    endfor
    return {}
endfunction

function! s:wrap_multiline.get_comments() abort
    let comments = []
    for method in s:METHODS
        let r = self[method]()
        if !empty(r)
            let comments += [r]
        endif
    endfor
    return comments
endfunction

function! s:wrap_multiline.get_comment_vars() abort
    return caw#get_var('caw_wrap_multiline_comment', '')
endfunction
