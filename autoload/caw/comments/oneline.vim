scriptencoding utf-8

function! caw#comments#oneline#new() abort
    let obj = caw#comments#base#new()
    return extend(obj, deepcopy(s:oneline))
endfunction


let s:oneline = {}
unlet! s:METHODS
let s:METHODS = ['get_comment_vars', 'get_comment_detect']
lockvar! s:METHODS

function! s:oneline.get_comments() abort
    let comments = []
    for method in s:METHODS
        let comments += self[method]()
    endfor
    return comments
endfunction

function! s:oneline.get_comment_vars() abort
    return self._get_comment_vars('caw_oneline_comment')
endfunction

function! s:oneline.get_comment_detect() abort
    let m = matchlist(&l:commentstring, '^\(.\{-}\)[ \t]*%s[ \t]*\(.*\)$')
    if !empty(m) && m[1] !=# '' && m[2] ==# ''
        return [m[1]]
    endif
    return []
endfunction
