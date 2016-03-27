scriptencoding utf-8

function! caw#actions#input#new() abort
    return deepcopy(s:input)
endfunction


let s:input = {}

function! s:input.comment() abort
    try
        let [actname, method] = s:ask_action()
        if actname ==# '' || method ==# ''
            throw 'Invalid character is pressed.'
        endif
        let action = caw#new('actions.' . actname)
        if !has_key(action, method)
            throw "No '" . method . "' method for '" . actname . "'."
        endif
    catch
        echohl ErrorMsg
        echomsg 'caw:' v:exception
        echohl None
        return
    endtry

    let default_cmt = caw#new('comments.oneline').get_comment()
    let cmt = s:input('comment string?:', default_cmt)

    if !empty(default_cmt) && default_cmt !=# cmt
        let org_status = s:set_and_save_comment_string(cmt)
    endif
    try
        let context = caw#context()
        if context.mode ==# 'n'
            call action[method](context.firstline)
        else
            for lnum in range(context.firstline, context.lastline)
                call action[method](lnum)
            endfor
        endif
    finally
        if exists('org_status')
            call org_status.restore()
        endif
    endtry
endfunction

function! s:ask_action() abort
    let NONE = ['', '']

    let actname = get({
    \   'i': 'hatpos',
    \   'I': 'zeropos',
    \   'a': 'dollarpos',
    \   'j': 'jump',
    \   'w': 'wrap',
    \}, s:getchar(), '')

    if actname == ''
        return NONE
    elseif actname ==# 'jump'
        let next_or_prev = get({
        \   'o': 'comment_next',
        \   'O': 'comment_prev',
        \}, s:getchar(), '')
        if next_or_prev ==# ''
            return NONE
        else
            return [actname, next_or_prev]
        endif
    else
        return [actname, 'comment_normal']
    endif
endfunction

function! s:set_and_save_comment_string(comment_string) abort
    let stash = {}

    if !exists('b:caw_oneline_comment')
        function stash.restore() abort
            unlet b:caw_oneline_comment
        endfunction
    elseif type(b:caw_oneline_comment) != type("")
        let stash.org_value = copy(b:caw_oneline_comment)
        function stash.restore() abort
            unlet b:caw_oneline_comment
            let b:caw_oneline_comment = self.org_value
        endfunction
        unlet b:caw_oneline_comment    " to avoid type error at :let below
    else
        let stash.org_value = copy(b:caw_oneline_comment)
        function stash.restore() abort
            let b:caw_oneline_comment = self.org_value
        endfunction
    endif

    let b:caw_oneline_comment = a:comment_string

    return stash
endfunction

function! s:getchar(...) abort
    call inputsave()
    try
        let c = call('getchar', a:000)
        return type(c) == type("") ? c : nr2char(c)
    finally
        call inputrestore()
    endtry
endfunction

function! s:input(...) abort
    call inputsave()
    try
        return call('input', a:000)
    finally
        call inputrestore()
    endtry
endfunction

