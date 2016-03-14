scriptencoding utf-8

function! caw#actions#capital_i#new() abort
    let obj = deepcopy(s:capital_i)
    let obj = extend(obj, caw#new('actions.small_i'))
    return obj
endfunction


let s:capital_i = {}

function! s:capital_i.comment_normal(lnum, ...) abort
    let startinsert = get(a:000, 0, caw#get_var('caw_I_startinsert_at_blank_line')) && caw#context().mode ==# 'n'
    let line = getline(a:lnum)
    let caw_I_sp = line =~# '^\s*$' ?
    \               caw#get_var('caw_I_sp_blank') :
    \               caw#get_var('caw_I_sp')

    let cmt = self.comment_database.get_comment()
    call caw#assert(!empty(cmt), "`cmt` must not be empty.")

    if line =~# '^\s*$'
        if caw#get_var('caw_I_skip_blank_line')
            return
        endif
        call setline(a:lnum, cmt . caw_I_sp)
        if startinsert
            startinsert!
        endif
    else
        call setline(a:lnum, cmt . caw_I_sp . line)
    endif
endfunction
