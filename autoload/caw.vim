" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" Interface {{{

function! s:sandbox_call(Fn, args, ...) "{{{
    try
        return a:0 ? call(a:Fn, a:args, a:1) : call(a:Fn, a:args)
    catch
        echohl ErrorMsg
        echomsg '[' . v:exception . ']::[' . v:throwpoint . ']'
        echohl None
    endtry
endfunction "}}}



" i/a
function! caw#do_i_comment(mode) "{{{
    return s:sandbox_call(s:caw.i.comment, [a:mode], s:caw.i)
endfunction "}}}

function! caw#do_a_comment(mode) "{{{
    return s:sandbox_call(s:caw.a.comment, [a:mode], s:caw.a)
endfunction "}}}

function! caw#do_i_toggle(mode) "{{{
    return s:sandbox_call(s:caw.i.toggle, [a:mode], s:caw.i)
endfunction "}}}

function! caw#do_a_toggle(mode) "{{{
    return s:sandbox_call(s:caw.a.toggle, [a:mode], s:caw.a)
endfunction "}}}



" wrap
function! caw#do_wrap_comment(mode) "{{{
    return s:sandbox_call(s:caw.wrap.comment, [a:mode], s:caw.wrap)
endfunction "}}}

function! caw#do_wrap_toggle(mode) "{{{
    return s:sandbox_call(s:caw.wrap.toggle, [a:mode], s:caw.wrap)
endfunction "}}}



" jump
function! caw#do_jump_comment_next() "{{{
    return s:sandbox_call(s:caw.jump.comment, [1], s:caw.jump)
endfunction "}}}

function! caw#do_jump_comment_prev() "{{{
    return s:sandbox_call(s:caw.jump.comment, [0], s:caw.jump)
endfunction "}}}



" input
function! caw#do_input_comment(mode) "{{{
    return s:sandbox_call(s:caw.input.comment, [a:mode], s:caw.input)
endfunction "}}}



" uncomment
function! caw#do_uncomment(mode) "{{{
    " TODO
endfunction "}}}


function! caw#do_uncomment_i(mode) "{{{
    return s:sandbox_call(s:caw.i.uncomment, [a:mode], s:caw.i)
endfunction "}}}

function! caw#do_uncomment_a(mode) "{{{
    return s:sandbox_call(s:caw.a.uncomment, [a:mode], s:caw.a)
endfunction "}}}


function! caw#do_uncomment_wrap(mode) "{{{
    return s:sandbox_call(s:caw.wrap.uncomment, [a:mode], s:caw.wrap)
endfunction "}}}


function! caw#do_uncomment_input(mode) "{{{
    " TODO
endfunction "}}}

" }}}


" Implementation {{{

function! s:set_and_save_comment_string(filetype, comment_string) "{{{
    let stash = {}

    let NONEXISTS = 0
    let INVALID = 1
    let EXISTS = 2
    let EMPTY = 0

    if !exists('b:caw_oneline_comment')
        let stash.status = NONEXISTS
        let cmt = EMPTY
    elseif type(b:caw_oneline_comment) != type({})
        let stash.status = INVALID
        let stash.org_value = copy(b:caw_oneline_comment)
        let cmt = EMPTY
    else
        let stash.status = EXISTS
        let stash.org_value = copy(b:caw_oneline_comment)
        let cmt = get(b:caw_oneline_comment, a:filetype, EMPTY)
    endif

    let b:caw_oneline_comment = extend(
    \   (cmt is EMPTY ? {} : b:caw_oneline_comment),
    \   {a:filetype : a:comment_string},
    \   'force'
    \)

    return stash
endfunction "}}}

function! s:restore_comment_string(stash) "{{{
    let NONEXISTS = 0
    let INVALID = 1
    let EXISTS = 2

    if a:stash.status ==# NONEXISTS
        unlet b:caw_oneline_comment
    elseif a:stash.status ==# INVALID
        let b:caw_oneline_comment = a:stash.org_value
    elseif a:stash.status ==# EXISTS
        let b:caw_oneline_comment = a:stash.org_value
    endif
endfunction "}}}


function! s:assert(cond, msg) "{{{
    if !a:cond
        throw 'caw: assertion failure: ' . a:msg
    endif
endfunction "}}}

function! s:get_var(varname) "{{{
    for ns in [b:, w:, t:, g:]
        if has_key(ns, a:varname)
            return ns[a:varname]
        endif
    endfor
    call s:assert(0, "s:get_var(): this must be reached")
endfunction "}}}


function! s:get_indent_num(lnum) "{{{
    if has('cindent') && &syntax =~# '\<c\|cpp\>'
        return cindent(a:lnum)
    elseif has('lispindent') && &syntax =~# '\<lisp\|scheme\>'
        return lispindent(a:lnum)
    elseif exists('*GetVimIndent') && &syntax ==# 'vim'
        let v:lnum = a:lnum
        return GetVimIndent()
    else
        return indent(a:lnum)
    endif
endfunction "}}}

function! s:get_indent(lnum) "{{{
    if &expandtab
        return repeat(' ', s:get_indent_num(a:lnum))
    else
        return repeat("\t", s:get_indent_num(a:lnum) / &tabstop)
    endif
endfunction "}}}

function! s:get_inserted_indent(lnum) "{{{
    return matchstr(getline(a:lnum), '^\s\+')
endfunction "}}}


function! s:trim_whitespaces(str) "{{{
    let str = a:str
    let str = substitute(str, '^\s\+', '', '')
    let str = substitute(str, '\s\+$', '', '')
    return str
endfunction "}}}



" s:comments {{{
" TODO Multiline
let s:comments = {'oneline': {}, 'wrap_oneline': {}, 'wrap_multiline': {}}


function! s:create_get_comment(default_value, fn_list) "{{{
    let o = {'__get_comment_default_value': a:default_value, '__get_comment_fn_list': a:fn_list}
    function! o.get_comment(filetype)
        for method in self.__get_comment_fn_list
            let r = self[method](a:filetype)
            if !empty(r)
                return r
            endif
            unlet r
        endfor
        return self.__get_comment_default_value
    endfunction

    return o
endfunction "}}}

function! s:create_get_comment_vars(comment) "{{{
    let o = {'__get_comment_vars_varname': a:comment}
    function! o.get_comment_vars(filetype)
        for ns in [b:, w:, t:, g:]
            if has_key(ns, self.__get_comment_vars_varname)
            \   && has_key(ns[self.__get_comment_vars_varname], a:filetype)
                return ns[self.__get_comment_vars_varname][a:filetype]
            endif
        endfor
        return ''
    endfunction

    return o
endfunction "}}}

function! s:create_get_comment_detect() "{{{
    let o = {}
    function! o.get_comment_detect(filetype)
        let comments_default = "s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-"
        if &comments ==# comments_default
            return ''
        endif

        " TODO

        return ''
    endfunction

    return o
endfunction "}}}


" oneline {{{
call extend(s:comments.oneline, s:create_get_comment(g:caw_default_oneline_comment, ['get_comment_vars', 'get_comment_detect', 'get_comment_builtin']), 'error')
call extend(s:comments.oneline, s:create_get_comment_vars('caw_oneline_comment'), 'error')
call extend(s:comments.oneline, s:create_get_comment_detect(), 'error')

" TODO Remove builtin
function! s:comments.oneline.get_comment_builtin(filetype) "{{{
    " TODO: compound filetypes
    return get({
    \   'aap': '#',
    \   'abc': '%',
    \   'acedb': '//',
    \   'actionscript': '//',
    \   'ada': '--',
    \   'ahdl': '--',
    \   'ahk': ';',
    \   'amiga': ';',
    \   'aml': '/*',
    \   'ampl': '#',
    \   'apache': '#',
    \   'apachestyle': '#',
    \   'applescript': '--',
    \   'asciidoc': '//',
    \   'asm': ';',
    \   'asm68k': ';',
    \   'asn': '--',
    \   'aspvbs': "'",
    \   'asterisk': ';',
    \   'asy': '//',
    \   'atlas': 'C',
    \   'autohotkey': ';',
    \   'autoit': ';',
    \   'ave': "'",
    \   'awk': '#',
    \   'basic': "'",
    \   'bbx': '%',
    \   'bc': '#',
    \   'bib': '%',
    \   'bindzone': ';',
    \   'bst': '%',
    \   'btm': '::',
    \   'c': '//',
    \   'calibre': '//',
    \   'caos': '*',
    \   'catalog': '--',
    \   'cfg': '#',
    \   'cg': '//',
    \   'ch': '//',
    \   'cl': '#',
    \   'clean': '//',
    \   'clipper': '//',
    \   'clojure': ';',
    \   'cmake': '#',
    \   'conf': '#',
    \   'config': '#',
    \   'conkyrc': '#',
    \   'cpp': '//',
    \   'crontab': '#',
    \   'cs': '//',
    \   'csp': '--',
    \   'cterm': '*',
    \   'cucumber': '#',
    \   'cvs': 'CVS:',
    \   'd': '//',
    \   'dakota': '#',
    \   'dcl': '$!',
    \   'debcontrol': '#',
    \   'debsources': '#',
    \   'def': ';',
    \   'desktop': '#',
    \   'dhcpd': '#',
    \   'diff': '#',
    \   'dns': ';',
    \   'dosbatch': 'REM',
    \   'dosini': ';',
    \   'dot': '//',
    \   'dracula': ';',
    \   'dsl': ';',
    \   'dylan': '//',
    \   'ebuild': '#',
    \   'ecd': '#',
    \   'eclass': '#',
    \   'eiffel': '--',
    \   'elf': "'",
    \   'elmfilt': '#',
    \   'erlang': '%',
    \   'expect': '#',
    \   'exports': '#',
    \   'factor': '!',
    \   'fgl': '#',
    \   'focexec': '-*',
    \   'form': '*',
    \   'foxpro': '*',
    \   'fstab': '#',
    \   'fvwm': '#',
    \   'fx': '//',
    \   'gams': '*',
    \   'gdb': '#',
    \   'gdmo': '--',
    \   'gentoo-conf-d': '#',
    \   'gentoo-env-d': '#',
    \   'gentoo-init-d': '#',
    \   'gentoo-make-conf': '#',
    \   'gentoo-package-keywords': '#',
    \   'gentoo-package-mask': '#',
    \   'gentoo-package-use': '#',
    \   'gitcommit': '#',
    \   'gitconfig': '#',
    \   'gitrebase': '#',
    \   'gnuplot': '#',
    \   'groovy': '//',
    \   'gtkrc': '#',
    \   'h': '//',
    \   'haml': '-#',
    \   'hb': '#',
    \   'hercules': '//',
    \   'hog': '#',
    \   'hostsaccess': '#',
    \   'htmlcheetah': '##',
    \   'htmlos': '#',
    \   'ia64': '#',
    \   'icon': '#',
    \   'idl': '//',
    \   'idlang': ';',
    \   'inform': '!',
    \   'inittab': '#',
    \   'ishd': '//',
    \   'iss': ';',
    \   'ist': '%',
    \   'java': '//',
    \   'javacc': '//',
    \   'javascript': '//',
    \   'jess': ';',
    \   'jproperties': '#',
    \   'kix': ';',
    \   'kscript': '//',
    \   'lace': '--',
    \   'ldif': '#',
    \   'lilo': '#',
    \   'lilypond': '%',
    \   'lisp': ';',
    \   'llvm': ';',
    \   'lout': '#',
    \   'lprolog': '%',
    \   'lscript': "'",
    \   'lss': '#',
    \   'lua': '--',
    \   'lynx': '#',
    \   'lytex': '%',
    \   'mail': '>',
    \   'mako': '##',
    \   'man': '."',
    \   'map': '%',
    \   'maple': '#',
    \   'masm': ';',
    \   'master': '$',
    \   'matlab': '%',
    \   'mel': '//',
    \   'mib': '--',
    \   'mkd': '>',
    \   'model': '$',
    \   'monk': ';',
    \   'mush': '#',
    \   'named': '//',
    \   'nasm': ';',
    \   'nastran': '$',
    \   'natural': '/*',
    \   'ncf': ';',
    \   'newlisp': ';',
    \   'nroff': '\"',
    \   'nsis': '#',
    \   'ntp': '#',
    \   'objc': '//',
    \   'objcpp': '//',
    \   'objj': '//',
    \   'occam': '--',
    \   'omnimark': ';',
    \   'openroad': '//',
    \   'opl': 'REM',
    \   'ora': '#',
    \   'ox': '//',
    \   'patran': '$',
    \   'pcap': '#',
    \   'pccts': '//',
    \   'pdf': '%',
    \   'perl': '#',
    \   'pfmain': '//',
    \   'php': '//',
    \   'pic': ';',
    \   'pike': '//',
    \   'pilrc': '//',
    \   'pine': '#',
    \   'plm': '//',
    \   'plsql': '--',
    \   'po': '#',
    \   'postscr': '%',
    \   'pov': '//',
    \   'povini': ';',
    \   'ppd': '%',
    \   'ppwiz': '%',
    \   'processing': '//',
    \   'prolog': '%',
    \   'ps1': '#',
    \   'psf': '#',
    \   'ptcap': '#',
    \   'python': '#',
    \   'r': '#',
    \   'radiance': '#',
    \   'ratpoison': '#',
    \   'rc': '//',
    \   'rebol': ';',
    \   'registry': ';',
    \   'remind': '#',
    \   'resolv': '#',
    \   'rgb': '!',
    \   'rib': '#',
    \   'robots': '#',
    \   'ruby': '#',
    \   'sa': '--',
    \   'samba': '#',
    \   'sass': '//',
    \   'sather': '--',
    \   'scala': '//',
    \   'scilab': '//',
    \   'scsh': ';',
    \   'sed': '#',
    \   'sicad': '*',
    \   'simula': '%',
    \   'sinda': '$',
    \   'skill': ';',
    \   'slang': '%',
    \   'slice': '//',
    \   'slrnrc': '%',
    \   'sm': '#',
    \   'smith': ';',
    \   'snnsnet': '#',
    \   'snnspat': '#',
    \   'snnsres': '#',
    \   'snobol4': '*',
    \   'spec': '#',
    \   'specman': '//',
    \   'spectre': '//',
    \   'spice': '$',
    \   'sql': '--',
    \   'sqlforms': '--',
    \   'sqlj': '--',
    \   'sqr': '!',
    \   'squid': '#',
    \   'st': '"',
    \   'stp': '--',
    \   'systemverilog': '//',
    \   'tads': '//',
    \   'tags': ';',
    \   'tak': '$',
    \   'tasm': ';',
    \   'tcl': '#',
    \   'texinfo': '@c',
    \   'texmf': '%',
    \   'tf': ';',
    \   'tidy': '#',
    \   'tli': '#',
    \   'trasys': '$',
    \   'tsalt': '//',
    \   'tsscl': '#',
    \   'tssgm': "comment = '",
    \   'txt2tags': '%',
    \   'uc': '//',
    \   'uil': '!',
    \   'vb': "'",
    \   'velocity': '##',
    \   'verilog': '//',
    \   'verilog_systemverilog': '//',
    \   'vgrindefs': '#',
    \   'vhdl': '--',
    \   'vim': '"',
    \   'vimperator': '"',
    \   'virata': '%',
    \   'vrml': '#',
    \   'vsejcl': '/*',
    \   'webmacro': '##',
    \   'wget': '#',
    \   'winbatch': ';',
    \   'wml': '#',
    \   'wvdial': ';',
    \   'xdefaults': '!',
    \   'xkb': '//',
    \   'xmath': '#',
    \   'xpm2': '!',
    \   'z8a': ';',
    \}, a:filetype, '')
endfunction "}}}
" }}}

" wrap_oneline "{{{
call extend(s:comments.wrap_oneline, s:create_get_comment(g:caw_default_wrap_oneline_comment, ['get_comment_vars', 'get_comment_detect', 'get_comment_builtin']), 'error')
call extend(s:comments.wrap_oneline, s:create_get_comment_vars('caw_wrap_oneline_comment'), 'error')
call extend(s:comments.wrap_oneline, s:create_get_comment_detect(), 'error')

" TODO Remove builtin
function! s:comments.wrap_oneline.get_comment_builtin(filetype) "{{{
    if a:filetype =~# '\<c\|cpp\>'
        return ['/*', '*/']
    elseif a:filetype ==# 'vim'
        return ['"""', '"""']
    endif
    return []
endfunction "}}}
" }}}

" wrap_multiline {{{
call extend(s:comments.wrap_multiline, s:create_get_comment(g:caw_default_wrap_multiline_comment, ['get_comment_vars', 'get_comment_detect', 'get_comment_builtin']), 'error')
call extend(s:comments.wrap_multiline, s:create_get_comment_vars('caw_wrap_multiline_comment'), 'error')
call extend(s:comments.wrap_multiline, s:create_get_comment_detect(), 'error')

" TODO Remove builtin
function! s:comments.wrap_multiline.get_comment_builtin(filetype) "{{{
    if a:filetype =~# '\<c\|cpp\>'
        " TODO
        " return {'top': '#if 0', 'bottom': '#endif'}
        return {'begin_left': '/*', 'middle_left': '*', 'end_left': '*/'}
    elseif a:filetype =~# '\<perl\>'
        return {'top': '=pod', 'bottom': '=cut'}
    endif
    return {}
endfunction "}}}
" }}}

" }}}

" s:caw {{{
let s:caw = {}

" s:base {{{
let s:base = {}

" NOTE:
" These methods are missing in s:base.
" Derived object must implement those.
"
" s:base.comment() requires:
" - s:base.comment_normal()
"
" s:base.commented() and s:base.commented_visual() requires:
" - s:base.commented_normal()
"
" s:base.uncomment() and s:base.uncomment_visual() requires:
" - s:base.uncomment_normal()


function! s:base.comment(mode) "{{{
    if a:mode ==# 'n'
        call self.comment_normal(line('.'))
    else
        call self.comment_visual()
    endif
endfunction "}}}

function! s:base.comment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum)
    endfor
endfunction "}}}


function! s:base.toggle(mode) "{{{
    if self.commented(a:mode)
        call self.uncomment(a:mode)
    else
        call self.comment(a:mode)
    endif
endfunction "}}}


function! s:base.commented(mode) "{{{
    if a:mode ==# 'n'
        return self.commented_normal(line('.'))
    else
        return self.commented_visual()
    endif
endfunction "}}}

function! s:base.commented_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        if self.commented_normal(lnum)
            return 1
        endif
    endfor
    return 0
endfunction "}}}


function! s:base.uncomment(mode) "{{{
    if a:mode ==# 'n'
        call self.uncomment_normal(line('.'))
    else
        call self.uncomment_visual()
    endif
endfunction "}}}

function! s:base.uncomment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.uncomment_normal(lnum)
    endfor
endfunction "}}}

" }}}


" i {{{
let s:caw.i = deepcopy(s:base)

function! s:caw.i.comment_normal(lnum, ...) "{{{
    let startinsert = get(a:000, 0, s:get_var('caw_i_startinsert_at_blank_line'))
    let comment_col = get(a:000, 1, -1)

    let cmt = s:comments.oneline.get_comment(&filetype)
    if !empty(cmt)
        let line = getline(a:lnum)
        if line =~# '^\s*$'
            let indent = s:get_indent(a:lnum)
            call setline(a:lnum, indent . cmt . s:get_var('caw_sp_i'))
            if startinsert
                call feedkeys('A', 'n')
            endif
        elseif comment_col > 0
            let idx = comment_col - 1
            call s:assert(idx < strlen(line), idx.' is accessible to '.string(line).'.')
            let before = idx ==# 0 ? '' : line[: idx]
            let after  = idx ==# 0 ? line : line[idx + 1 :]
            call setline(a:lnum, before . cmt . s:get_var('caw_sp_i') . after)
        else
            let indent = s:get_inserted_indent(a:lnum)
            let line = substitute(getline(a:lnum), '^[ \t]\+', '', '')
            call setline(a:lnum, indent . cmt . s:get_var('caw_sp_i') . line)
        endif
    endif
endfunction "}}}

function! s:caw.i.comment_visual() "{{{
    let min_indent_num = 1/0
    if g:caw_i_align
        for lnum in range(line("'<"), line("'>"))
            let n = strlen(matchstr(getline(lnum), '^\s\+'))
            if n < min_indent_num
                let min_indent_num = n
            endif
        endfor
    endif

    for lnum in range(line("'<"), line("'>"))
        call call(
        \   self.comment_normal,
        \   [lnum, 0] + (min_indent_num > 0 ? [min_indent_num] : []),
        \   self
        \)
    endfor
endfunction "}}}


function! s:caw.i.commented_normal(lnum) "{{{
    let line_without_indent = substitute(getline(a:lnum), '^[ \t]\+', '', '')
    let cmt = s:comments.oneline.get_comment(&filetype)
    return !empty(cmt) && stridx(line_without_indent, cmt) == 0
endfunction "}}}



function! s:caw.i.uncomment_normal(lnum) "{{{
    let cmt = s:comments.oneline.get_comment(&filetype)
    if !empty(cmt) && self.commented_normal(a:lnum)
        let indent = s:get_inserted_indent(a:lnum)
        let line   = substitute(getline(a:lnum), '^[ \t]\+', '', '')
        if stridx(line, cmt) == 0
            " Remove comment.
            let line = line[strlen(cmt) :]
            " 'caw_sp_i'
            if stridx(line, s:get_var('caw_sp_i')) ==# 0
                let line = line[strlen(s:get_var('caw_sp_i')) :]
            endif
            call setline(a:lnum, indent . line)
        endif
    endif
endfunction "}}}

" }}}

" a {{{
let s:caw.a = deepcopy(s:base)

function! s:caw.a.comment_normal(lnum, ...) "{{{
    let startinsert = a:0 ? a:1 : s:get_var('caw_a_startinsert')

    let cmt = s:comments.oneline.get_comment(&filetype)
    if !empty(cmt)
        call setline(
        \   a:lnum,
        \   getline(a:lnum)
        \       . s:get_var('caw_sp_a_left')
        \       . cmt
        \       . s:get_var('caw_sp_a_right')
        \)
        if startinsert
            call feedkeys('A', 'n')
        endif
    endif
endfunction "}}}

function! s:caw.a.comment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum, 0)
    endfor
endfunction "}}}


function! s:caw_a_get_commented_col(lnum) "{{{
    let cmt = s:comments.oneline.get_comment(&filetype)
    if empty(cmt)
        return -1
    endif

    let line = getline(a:lnum)
    let cols = []
    while 1
        let idx = stridx(line, cmt, empty(cols) ? 0 : idx + 1)
        if idx == -1
            break
        endif
        call add(cols, idx + 1)
    endwhile

    if empty(cols)
        return -1
    endif

    for col in cols
        for id in synstack(a:lnum, col)
            if synIDattr(synIDtrans(id), 'name') ==# 'Comment'
                return col
            endif
        endfor
    endfor
    return -1
endfunction "}}}

function! s:caw.a.commented_normal(lnum) "{{{
    return s:caw_a_get_commented_col(a:lnum) > 0
endfunction "}}}


function! s:caw.a.uncomment_normal(lnum) "{{{
    let cmt = s:comments.oneline.get_comment(&filetype)
    if !empty(cmt) && self.commented_normal(a:lnum)
        let col = s:caw_a_get_commented_col(a:lnum)
        if col <= 0
            return
        endif
        let idx = col - 1

        let line = getline(a:lnum)
        let [l, r] = [line[idx : idx + strlen(cmt) - 1], cmt]
        call s:assert(l ==# r, "s:caw.a.uncomment_normal(): ".string(l).' ==# '.string(r))

        let before = line[0 : idx - 1]
        " 'caw_sp_a_left'
        let before = substitute(before, '\s\+$', '', '')

        call setline(a:lnum, before)
    endif
endfunction "}}}

" }}}

" wrap {{{
let s:caw.wrap = deepcopy(s:base)

function! s:caw.wrap.comment_normal(lnum) "{{{
    let cmt = s:comments.wrap_oneline.get_comment(&filetype)
    if !empty(cmt)
        let [left, right] = cmt
        let line_without_indent = substitute(getline(a:lnum), '^\s\+', '', '')
        call setline(
        \   a:lnum,
        \   s:get_inserted_indent(a:lnum)
        \       . left
        \       . s:get_var('caw_sp_wrap_left')
        \       . line_without_indent
        \       . s:get_var('caw_sp_wrap_right')
        \       . right
        \)
    endif
endfunction "}}}

function! s:caw.wrap.comment_visual() "{{{
    " TODO:
    "
    " Not:
    " /* line1 */
    " /* line2 */
    " /* line3 */
    "
    " Doit:
    " /*********
    "  * line1 *
    "  * line2 *
    "  * line3 *
    "  *********/

    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum, 0)
    endfor
endfunction "}}}


function! s:caw.wrap.commented_normal(lnum) "{{{
    let cmt = s:comments.wrap_oneline.get_comment(&filetype)
    if empty(cmt)
        return 0
    endif

    let line = s:trim_whitespaces(getline(a:lnum))

    " line begins with left, ends with right.
    let [left, right] = cmt
    return
    \   line[: strlen(left) - 1] ==# left
    \   && line[strlen(line) - strlen(right) :] ==# right
endfunction "}}}


function! s:caw.wrap.uncomment_normal(lnum) "{{{
    let cmt = s:comments.wrap_oneline.get_comment(&filetype)
    if !empty(cmt) && self.commented_normal(a:lnum)
        let [left, right] = cmt

        let line = s:trim_whitespaces(getline(a:lnum))

        let [left, right] = cmt

        let [l, r] = [line[: strlen(left) - 1], left]
        call s:assert(l ==# r, string(l).' ==# '.string(r))
        let [l, r] = [line[strlen(line) - strlen(right) :], right]
        call s:assert(l ==# r, string(l).' ==# '.string(r))

        let body = line[strlen(left) : -strlen(right) - 1]
        let body = s:trim_whitespaces(body)
        call setline(a:lnum, s:get_inserted_indent(a:lnum) . body)
    endif
endfunction "}}}

" }}}

" jump {{{
let s:caw.jump = deepcopy(s:base)

function! s:caw.jump.comment(next) "{{{
    let cmt = s:comments.oneline.get_comment(&filetype)
    if empty(cmt)
        return
    endif

    let lnum = line('.')
    if a:next
        call append(lnum, '')
        let indent = s:get_indent(lnum + 1)

        call setline(lnum + 1, indent . cmt . g:caw_sp_jump)
        call cursor(lnum + 1, 1)
        startinsert!
    else
        call append(lnum - 1, '')
        " NOTE: `lnum` is target lnum.
        " because new line was inserted just now.
        let indent = s:get_indent(lnum)

        call setline(lnum, indent . cmt . g:caw_sp_jump)
        call cursor(lnum, 1)
        startinsert!
    endif
endfunction "}}}

" }}}

" input {{{
let s:caw.input = deepcopy(s:base)

function! s:caw.input.comment(mode) "{{{
    let [pos, pos_opt] = s:caw_input_get_pos()
    if !has_key(s:caw, pos) || !has_key(s:caw[pos], 'comment')
        echohl WarningMsg
        echomsg pos . ': Invalid pos.'
        echohl None
        return
    endif

    let default_cmt = s:comments.oneline.get_comment(&filetype)
    let cmt = s:caw_input_get_comment_string(default_cmt)

    if !empty(default_cmt) && default_cmt !=# cmt
        let org_status = s:set_and_save_comment_string(&filetype, cmt)
    endif
    try
        if a:mode ==# 'n'
            call self.comment_normal(line('.'), pos)
        else
            call self.comment_visual(pos)
        endif
    finally
        if !empty(default_cmt) && default_cmt !=# cmt
            call s:restore_comment_string(org_status)
        endif
    endtry
endfunction "}}}

function! s:caw.input.comment_normal(lnum, pos) "{{{
    call s:caw[a:pos].comment_normal(a:lnum)
endfunction "}}}

function! s:caw.input.comment_visual(pos) "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum, a:pos)
    endfor
endfunction "}}}

function! s:caw_input_get_pos() "{{{
    let NONE = ['', '']

    let pos = get({
    \   'i': 'i',
    \   'a': 'a',
    \   'j': 'jump',
    \   'w': 'wrap',
    \}, s:getchar(), '')

    if pos == ''
        return NONE
    elseif pos ==# 'jump'
        let next_or_prev = get({
        \   'o': 'next',
        \   'O': 'prev',
        \}, s:getchar(), '')
        if next_or_prev == ''
            return NONE
        else
            return [pos, next_or_prev]
        endif
    else
        return [pos, '']
    endif
endfunction "}}}

function! s:getchar(...) "{{{
    call inputsave()
    try
        let c = call('getchar', a:000)
        return type(c) == type("") ? c : nr2char(c)
    finally
        call inputrestore()
    endtry
endfunction "}}}

function! s:caw_input_get_comment_string(default_cmt) "{{{
    return s:input('any comment?:', a:default_cmt)
endfunction "}}}

function! s:input(...) "{{{
    call inputsave()
    try
        return call('input', a:000)
    finally
        call inputrestore()
    endtry
endfunction "}}}

" }}}

" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
