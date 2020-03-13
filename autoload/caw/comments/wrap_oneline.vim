scriptencoding utf-8

function! caw#comments#wrap_oneline#new() abort
    let obj = caw#comments#base#new()
    return extend(obj, deepcopy(s:wrap_oneline))
endfunction


let s:wrap_oneline = {}
unlet! s:METHODS
let s:METHODS = ['get_comment_vars', 'get_comment_detect']
lockvar! s:METHODS

function! s:wrap_oneline.get_comments() abort
    let comments = []
    for method in s:METHODS
        let comments += self[method]()
    endfor
    return s:uniq(sort(comments, function('s:by_length')))
endfunction

if exists('*uniq')
    let s:uniq = function('uniq')
else
    function! s:uniq(list) abort
        let results = []
        let dup = {}
        for l:V in a:list
            let id = string(l:V)
            if !has_key(dup, id)
                let results += [l:V]
                let dup[id] = 1
            endif
        endfor
        return results
    endfunction
endif

function! s:by_length(c1, c2) abort
    let [l1, r1] = a:c1
    let [l2, r2] = a:c2
    let d = strlen(l2) - strlen(l1)
    if d !=# 0
        return d
    endif
    return strlen(r2) - strlen(r1)
endfunction

function! s:wrap_oneline.get_comment_vars() abort
    return self._get_comment_vars('caw_wrap_oneline_comment')
endfunction

function! s:wrap_oneline.get_comment_detect() abort
    let m = matchlist(&l:commentstring, '^\(.\{-}\)[ \t]*%s[ \t]*\(.*\)$')
    if !empty(m) && m[1] !=# '' && m[2] !=# ''
        return [m[1:2]]
    endif
    return []
endfunction
