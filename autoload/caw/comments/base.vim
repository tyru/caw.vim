scriptencoding utf-8

function! caw#comments#base#new() abort
    return deepcopy(s:base)
endfunction


let s:base = {}

function! s:base._get_comment_vars(varname) abort
    let NONE = []
    let comments = []
    let current = caw#get_var(a:varname, NONE, [line('.')])
    if current isnot# NONE
        let comments += [current]
    endif
    let filetypes = caw#get_related_filetypes(&filetype)
    for ft in filetypes
        call s:load_ftplugin(ft)
        let cmt = caw#get_var(a:varname, NONE, [line('.')])
        if cmt isnot# NONE
            let comments += [cmt]
        endif
    endfor
    if !empty(filetypes)
        call s:load_ftplugin(&filetype)
    endif
    return comments
endfunction

function! s:load_ftplugin(ft) abort
    if exists('b:undo_ftplugin')
        execute b:undo_ftplugin
    endif
    unlet! b:did_caw_ftplugin
    execute 'runtime! after/ftplugin/' . a:ft . '/caw.vim'
endfunction
