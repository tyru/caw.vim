scriptencoding utf-8

function! caw#comments#wrap_multiline#new() abort
    let obj = caw#comments#base#new()
    return extend(obj, deepcopy(s:wrap_multiline))
endfunction


let s:wrap_multiline = {}
unlet! s:METHODS
let s:METHODS = ['get_comment_vars']
lockvar! s:METHODS

function! s:wrap_multiline.get_comments() abort
    let comments = []
    for method in s:METHODS
        let comments += self[method]()
    endfor
    return comments
endfunction

function! s:wrap_multiline.get_comment_vars() abort
    return self._get_comment_vars('caw_wrap_multiline_comment')
endfunction
