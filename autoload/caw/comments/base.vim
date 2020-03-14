scriptencoding utf-8

function! caw#comments#base#new() abort
    return deepcopy(s:base)
endfunction


let s:base = {}

function! s:base._sorted_comments_by_length_desc(by_length) abort
    let comments = self.get_comments()
    return caw#uniq(sort(comments, a:by_length))
endfunction

function! s:base._get_comment_vars(varname) abort
    let NONE = []
    let comments = []
    let current = caw#get_var(a:varname, NONE, [line('.')])
    if current isnot# NONE && !empty(current)
        let comments += [current]
    endif
    let filetypes = caw#get_related_filetypes(&filetype)
    for ft in filetypes
        call caw#load_ftplugin(ft)
        let cmt = caw#get_var(a:varname, NONE, [line('.')])
        if cmt isnot# NONE && !empty(current)
            let comments += [cmt]
        endif
    endfor
    if !empty(filetypes)
        call caw#load_ftplugin(&filetype)
    endif
    return comments
endfunction
