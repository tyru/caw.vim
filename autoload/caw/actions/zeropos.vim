scriptencoding utf-8

function! caw#actions#zeropos#new() abort
    let obj = deepcopy(caw#new('actions.hatpos'))
    let obj = extend(obj, deepcopy(s:zeropos), 'force')
    return obj
endfunction


let s:zeropos = {}

function! s:zeropos.comment_normal(lnum, ...) abort
    let startinsert = get(a:000, 0, caw#get_var('caw_zeropos_startinsert_at_blank_line')) && caw#context().mode ==# 'n'
    let line = caw#getline(a:lnum)
    let caw_zeropos_sp = line =~# '^\s*$' ?
    \               caw#get_var('caw_zeropos_sp_blank') :
    \               caw#get_var('caw_zeropos_sp')

    let cmt = self.comment_database.get_comment()
    call caw#assert(!empty(cmt), "`cmt` must not be empty.")

    if line =~# '^\s*$'
        if caw#get_var('caw_zeropos_skip_blank_line')
            return
        endif
        call caw#setline(a:lnum, cmt . caw_zeropos_sp)
        if startinsert
            call caw#startinsert('A')
        endif
    else
        call caw#setline(a:lnum, cmt . caw_zeropos_sp . line)
    endif
endfunction
