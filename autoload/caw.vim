" vim:foldmethod=marker:fen:
scriptencoding utf-8

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

function! s:get_caw_object() "{{{
    return exists('b:caw') ? b:caw : s:caw
endfunction "}}}


" i/a
function! caw#do_i_comment(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.i.comment, [a:mode], caw.i)
endfunction "}}}

function! caw#do_I_comment(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.I.comment, [a:mode], caw.I)
endfunction "}}}

function! caw#do_a_comment(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.a.comment, [a:mode], caw.a)
endfunction "}}}

function! caw#do_i_toggle(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.i.toggle, [a:mode], caw.i)
endfunction "}}}

function! caw#do_I_toggle(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.I.toggle, [a:mode], caw.I)
endfunction "}}}

function! caw#do_a_toggle(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.a.toggle, [a:mode], caw.a)
endfunction "}}}



" wrap
function! caw#do_wrap_comment(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.wrap.comment, [a:mode], caw.wrap)
endfunction "}}}

function! caw#do_wrap_toggle(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.wrap.toggle, [a:mode], caw.wrap)
endfunction "}}}



" jump
function! caw#do_jump_comment_next() "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.jump.comment, [1], caw.jump)
endfunction "}}}

function! caw#do_jump_comment_prev() "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.jump.comment, [0], caw.jump)
endfunction "}}}



" input
function! caw#do_input_comment(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.input.comment, [a:mode], caw.input)
endfunction "}}}



" uncomment
function! caw#do_uncomment(mode) "{{{
    let caw = s:get_caw_object()
    let action = caw.detect_operated_action(a:mode)
    if action != ''
        call caw[action].uncomment(a:mode)
    endif
endfunction "}}}


function! caw#do_uncomment_i(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.i.uncomment, [a:mode], caw.i)
endfunction "}}}

function! caw#do_uncomment_a(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.a.uncomment, [a:mode], caw.a)
endfunction "}}}


function! caw#do_uncomment_wrap(mode) "{{{
    let caw = s:get_caw_object()
    return s:sandbox_call(caw.wrap.uncomment, [a:mode], caw.wrap)
endfunction "}}}


function! caw#do_uncomment_input(mode) "{{{
    " TODO
endfunction "}}}

" }}}


" Implementation {{{

function! s:set_and_save_comment_string(comment_string) "{{{
    let stash = {}

    if !exists('b:caw_oneline_comment')
        function stash.restore()
            unlet b:caw_oneline_comment
        endfunction
    elseif type(b:caw_oneline_comment) != type("")
        let stash.org_value = copy(b:caw_oneline_comment)
        function stash.restore()
            unlet b:caw_oneline_comment
            let b:caw_oneline_comment = self.org_value
        endfunction
        unlet b:caw_oneline_comment    " to avoid type error at :let below
    else
        let stash.org_value = copy(b:caw_oneline_comment)
        function stash.restore()
            let b:caw_oneline_comment = self.org_value
        endfunction
    endif

    let b:caw_oneline_comment = a:comment_string

    return stash
endfunction "}}}

function! s:restore_comment_string(stash) "{{{
    call a:stash.restore()
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
    elseif &l:indentexpr != ''
        let save_view = winsaveview()
        let save_lnum = v:lnum
        let v:lnum = a:lnum
        try
            return eval(&l:indentexpr)
        finally
            let v:lnum = save_lnum
            " NOTE: GetPythonIndent() may move cursor. wtf?
            call winrestview(save_view)
        endtry
    else
        return indent(a:lnum)
    endif
endfunction "}}}

function! s:get_indent(lnum) "{{{
    let n = s:get_indent_num(a:lnum)
    if &expandtab
        return repeat(' ', n)
    else
        return repeat("\t", n / &tabstop) . repeat(' ', n % &tabstop)
    endif
endfunction "}}}

function! s:get_inserted_indent(lnum) "{{{
    return matchstr(getline(a:lnum), '^\s\+')
endfunction "}}}

function! s:get_inserted_indent_num(lnum) "{{{
    return strlen(s:get_inserted_indent(a:lnum))
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


function! s:create_get_comment(fn_list, empty_value) "{{{
    let o = {'__get_comment_empty_value': a:empty_value, '__get_comment_fn_list': a:fn_list}
    function! o.get_comment(filetype)
        for method in self.__get_comment_fn_list
            let r = self[method](a:filetype)
            if !empty(r)
                return r
            endif
            unlet r
        endfor
        return self.__get_comment_empty_value
    endfunction

    return o
endfunction "}}}

function! s:create_get_comment_vars(comment) "{{{
    let o = {'__get_comment_vars_varname': a:comment}
    function! o.get_comment_vars(filetype)
        for ns in [b:, w:, t:, g:]
            if has_key(ns, self.__get_comment_vars_varname)
                return ns[self.__get_comment_vars_varname]
            endif
        endfor
        return ''
    endfunction

    return o
endfunction "}}}


" oneline {{{
call extend(s:comments.oneline, s:create_get_comment(['get_comment_vars', 'get_comment_detect', 'get_comment_builtin'], ''), 'error')
call extend(s:comments.oneline, s:create_get_comment_vars('caw_oneline_comment'), 'error')

function! s:comments.oneline.get_comment_detect(filetype) "{{{
    let comments_default = "s1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-"
    if &l:comments ==# comments_default
        return ''
    endif

    " TODO

    return ''
endfunction "}}}

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
    \   'scheme': ';',
    \   'scilab': '//',
    \   'scsh': ';',
    \   'sed': '#',
    \   'sh': '#',
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
call extend(s:comments.wrap_oneline, s:create_get_comment(['get_comment_vars', 'get_comment_detect', 'get_comment_builtin'], []), 'error')
call extend(s:comments.wrap_oneline, s:create_get_comment_vars('caw_wrap_oneline_comment'), 'error')

function! s:comments.wrap_oneline.get_comment_detect(filetype) "{{{
    let m = matchlist(&l:commentstring, '^\(.\{-}\)[ \t]*%s[ \t]*\(.*\)$')
    if empty(m)
        return []
    endif
    return m[1:2]
endfunction "}}}

function! s:comments.wrap_oneline.get_comment_builtin(filetype) "{{{
    " TODO: compound filetypes
    return get({
    \   'aap': ['/*', '*/'],
    \   'actionscript': ['/*', '*/'],
    \   'ahk': ['/*', '*/'],
    \   'applescript': ['(*', '*)'],
    \   'c': ['/*', '*/'],
    \   'cg': ['/*', '*/'],
    \   'ch': ['/*', '*/'],
    \   'clean': ['/*', '*/'],
    \   'clipper': ['/*', '*/'],
    \   'cpp': ['/*', '*/'],
    \   'cs': ['/*', '*/'],
    \   'd': ['/*', '*/'],
    \   'django': ['<!--', '-->'],
    \   'docbk': ['<!--', '-->'],
    \   'dot': ['/*', '*/'],
    \   'dtml': ['<dtml-comment>', '</dtml-comment>'],
    \   'dylan': ['/*', '*/'],
    \   'eruby': ['<!--', '-->'],
    \   'fx': ['/*', '*/'],
    \   'genshi': ['<!--', '-->'],
    \   'groovy': ['/*', '*/'],
    \   'h': ['/*', '*/'],
    \   'hercules': ['/*', '*/'],
    \   'html': ['<!--', '-->'],
    \   'htmldjango': ['<!--', '-->'],
    \   'idl': ['/*', '*/'],
    \   'ishd': ['/*', '*/'],
    \   'java': ['/*', '*/'],
    \   'javacc': ['/*', '*/'],
    \   'javascript': ['/*', '*/'],
    \   'jgraph': ['(*', '*)'],
    \   'jsp': ['<%--', '--%>'],
    \   'kscript': ['/*', '*/'],
    \   'liquid': ['{%', '%}'],
    \   'lisp': ['#|', '|#'],
    \   'lotos': ['(*', '*)'],
    \   'lua': ['--[[', ']]'],
    \   'markdown': ['<!--', '-->'],
    \   'mason': ['<% #', '%>'],
    \   'mel': ['/*', '*/'],
    \   'mma': ['(*', '*)'],
    \   'model': ['$', '$'],
    \   'moduala': ['(*', '*)'],
    \   'modula2': ['(*', '*)'],
    \   'modula3': ['(*', '*)'],
    \   'named': ['/*', '*/'],
    \   'objc': ['/*', '*/'],
    \   'objcpp': ['/*', '*/'],
    \   'objj': ['/*', '*/'],
    \   'ocaml': ['(*', '*)'],
    \   'omlet': ['(*', '*)'],
    \   'pascal': ['(*', '*)'],
    \   'patran': ['/*', '*/'],
    \   'pccts': ['/*', '*/'],
    \   'php': ['/*', '*/'],
    \   'pike': ['/*', '*/'],
    \   'pilrc': ['/*', '*/'],
    \   'plm': ['/*', '*/'],
    \   'plsql': ['/*', '*/'],
    \   'pov': ['/*', '*/'],
    \   'processing': ['/*', '*/'],
    \   'prolog': ['/*', '*/'],
    \   'rc': ['/*', '*/'],
    \   'scala': ['/*', '*/'],
    \   'sgmldecl': ['--', '--'],
    \   'sgmllnx': ['<!--', '-->'],
    \   'slice': ['/*', '*/'],
    \   'smarty': ['{*', '*}'],
    \   'smil': ['<!', '>'],
    \   'sml': ['(*', '*)'],
    \   'systemverilog': ['/*', '*/'],
    \   'tads': ['/*', '*/'],
    \   'tsalt': ['/*', '*/'],
    \   'uc': ['/*', '*/'],
    \   'velocity': ['#*', '*#'],
    \   'vera': ['/*', '*/'],
    \   'verilog': ['/*', '*/'],
    \   'verilog_systemverilog': ['/*', '*/'],
    \   'xquery': ['(:', ':)'],
    \}, a:filetype, [])
endfunction "}}}
" }}}

" wrap_multiline {{{
call extend(s:comments.wrap_multiline, s:create_get_comment(['get_comment_vars', 'get_comment_builtin'], {}), 'error')
call extend(s:comments.wrap_multiline, s:create_get_comment_vars('caw_wrap_multiline_comment'), 'error')

function! s:comments.wrap_multiline.get_comment_builtin(filetype) "{{{
    " TODO: compound filetypes
    return get({
    \   'perl': {'top': '=pod', 'bottom': '=cut'},
    \   'ruby': {'top': '=pod', 'bottom': '=cut'},
    \   'c': {'begin_left': '/*', 'middle_left': '*', 'end_left': '*/'},
    \   'cpp': {'begin_left': '/*', 'middle_left': '*', 'end_left': '*/'},
    \}, a:filetype, {})
endfunction "}}}
" }}}

" }}}

" s:caw {{{
let s:caw = {}


function! s:create_call_another_action(comment_vs_action) "{{{
    let o = {'__call_another_action_comment_vs_action': a:comment_vs_action}
    function! o.call_another_action(method, args)
        for c in sort(keys(self.__call_another_action_comment_vs_action))
            if !empty(s:comments[c].get_comment(&filetype))
                let action = self.__call_another_action_comment_vs_action[c]
                return call(s:caw[action][a:method], a:args, s:caw[action])
            endif
        endfor
    endfunction
    return o
endfunction "}}}


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
        let wiseness = get({
        \   'v': 'characterwise',
        \   'V': 'linewise',
        \   "\<C-v>": 'blockwise',
        \}, visualmode(), '')
        if wiseness != '' && has_key(self, 'comment_visual_' . wiseness)
            call self['comment_visual_' . wiseness]()
        else
            call self.comment_visual()
        endif
    endif
endfunction "}}}

function! s:base.comment_visual() "{{{
    " Behave like linewise.
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
call extend(s:caw.i, s:create_call_another_action({'wrap_oneline': 'wrap'}), 'error')

function! s:caw.i.comment_normal(lnum, ...) "{{{
    let startinsert = get(a:000, 0, s:get_var('caw_i_startinsert_at_blank_line'))
    let min_indent_num = get(a:000, 1, -1)

    let cmt = s:comments.oneline.get_comment(&filetype)
    if empty(cmt)
        if s:get_var('caw_find_another_action')
            call self.call_another_action('comment_normal', [a:lnum])
        endif
        return
    endif

    let line = getline(a:lnum)
    if min_indent_num >= 0
        call s:assert(min_indent_num <= strlen(line), min_indent_num.' is accessible to '.string(line).'.')
        let before = min_indent_num ==# 0 ? '' : line[: min_indent_num - 1]
        let after  = min_indent_num ==# 0 ? line : line[min_indent_num :]
        call setline(a:lnum, before . cmt . s:get_var('caw_sp_i') . after)
    elseif line =~# '^\s*$'
        let indent = s:get_indent(a:lnum)
        call setline(a:lnum, indent . cmt . s:get_var('caw_sp_i'))
        if startinsert
            call feedkeys('A', 'n')
        endif
    else
        let indent = s:get_inserted_indent(a:lnum)
        let line = substitute(getline(a:lnum), '^[ \t]\+', '', '')
        call setline(a:lnum, indent . cmt . s:get_var('caw_sp_i') . line)
    endif
endfunction "}}}

function! s:caw.i.comment_visual() "{{{
    let min_indent_num = 1/0
    if s:get_var('caw_i_align')
        for lnum in range(line("'<"), line("'>"))
            if getline(lnum) =~ '^\s*$'
                continue    " Skip blank line.
            endif
            let n = s:get_inserted_indent_num(lnum)
            if n < min_indent_num
                let min_indent_num = n
            endif
        endfor
    endif

    for lnum in range(line("'<"), line("'>"))
        if getline(lnum) =~ '^\s*$'
            continue    " Skip blank line.
        endif
        call self.comment_normal(lnum, 0, min_indent_num)
    endfor
endfunction "}}}


function! s:caw.i.commented_normal(lnum) "{{{
    let line_without_indent = substitute(getline(a:lnum), '^[ \t]\+', '', '')
    let cmt = s:comments.oneline.get_comment(&filetype)
    return !empty(cmt) && stridx(line_without_indent, cmt) == 0
endfunction "}}}



function! s:caw.i.uncomment_normal(lnum) "{{{
    let cmt = s:comments.oneline.get_comment(&filetype)
    if empty(cmt)
        if s:get_var('caw_find_another_action')
            call self.call_another_action('uncomment_normal', [a:lnum])
        endif
        return
    endif

    if self.commented_normal(a:lnum)
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

" I {{{
let s:caw.I = deepcopy(s:base)
call extend(s:caw.I, s:create_call_another_action({'wrap_oneline': 'wrap'}), 'error')

let s:caw.I.comment_normal = s:caw.i.comment_normal
let s:caw.I.comment_visual = s:caw.i.comment_visual
let s:caw.I.commented_normal = s:caw.i.commented_normal
let s:caw.I.uncomment_normal = s:caw.i.uncomment_normal

function! s:caw.I.comment_normal(lnum, ...) "{{{
    let startinsert = get(a:000, 0, s:get_var('caw_i_startinsert_at_blank_line'))

    let cmt = s:comments.oneline.get_comment(&filetype)
    if empty(cmt)
        if s:get_var('caw_find_another_action')
            call self.call_another_action('comment_normal', [a:lnum])
        endif
        return
    endif

    let line = getline(a:lnum)
    if line =~# '^\s*$'
        call setline(a:lnum, cmt . s:get_var('caw_sp_i'))
        if startinsert
            call feedkeys('A', 'n')
        endif
    else
        call setline(a:lnum, cmt . s:get_var('caw_sp_i') . line)
    endif
endfunction "}}}

" }}}

" a {{{
let s:caw.a = deepcopy(s:base)
call extend(s:caw.a, s:create_call_another_action({'wrap_oneline': 'wrap'}), 'error')

function! s:caw.a.comment_normal(lnum, ...) "{{{
    let startinsert = a:0 ? a:1 : s:get_var('caw_a_startinsert')

    let cmt = s:comments.oneline.get_comment(&filetype)
    if empty(cmt)
        if s:get_var('caw_find_another_action')
            call self.call_another_action('comment_normal', [a:lnum])
        endif
        return
    endif

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
endfunction "}}}

function! s:caw.a.comment_visual() "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum)
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
    if empty(cmt)
        if s:get_var('caw_find_another_action')
            call self.call_another_action('uncomment_normal', [a:lnum])
        endif
        return
    endif

    if self.commented_normal(a:lnum)
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
call extend(s:caw.wrap, s:create_call_another_action({'oneline': 'i'}), 'error')

function! s:caw.wrap.comment_normal(lnum, ...) "{{{
    let cmt = s:comments.wrap_oneline.get_comment(&filetype)
    if empty(cmt)
        if s:get_var('caw_find_another_action')
            call self.call_another_action('comment_normal', [a:lnum])
        endif
        return
    endif

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
endfunction "}}}


function! s:comment_visual_characterwise_comment_out(text) "{{{
    let cmt = s:comments.wrap_oneline.get_comment(&filetype)
    if empty(cmt)
        return a:text
    else
        return cmt[0]
        \   . s:get_var('caw_sp_wrap_left')
        \   . a:text
        \   . s:get_var('caw_sp_wrap_right')
        \   . cmt[1]
    endif
endfunction "}}}
function! s:caw.wrap.__operate_on_word(funcname) "{{{
    normal! gv

    let reg_z_save     = getreg('z', 1)
    let regtype_z_save = getregtype('z')

    try
        " Filter selected range with `{a:funcname}(selected_text)`.
        let cut_with_reg_z = '"zc'
        execute printf("normal! %s\<C-r>\<C-o>=%s(@z)\<CR>", cut_with_reg_z, a:funcname)
    finally
        call setreg('z', reg_z_save, regtype_z_save)
    endtry
endfunction "}}}
function! s:caw.wrap.comment_visual_characterwise() "{{{
    let cmt = s:comments.wrap_oneline.get_comment(&filetype)
    if empty(cmt)
        if s:get_var('caw_find_another_action')
            let [begin_lnum, end_lnum] = [getpos("'<")[1], getpos("'>")[1]]
            call s:assert(begin_lnum <= end_lnum, "begin_lnum <= end_lnum")
            for lnum in range(begin_lnum, end_lnum)
                call self.call_another_action('comment_normal', [lnum])
            endfor
        endif
        return
    endif
    call self.__operate_on_word('<SID>comment_visual_characterwise_comment_out')
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

        call setline(lnum + 1, indent . cmt . s:get_var('caw_sp_jump'))
        call cursor(lnum + 1, 1)
        startinsert!
    else
        call append(lnum - 1, '')
        " NOTE: `lnum` is target lnum.
        " because new line was inserted just now.
        let indent = s:get_indent(lnum)

        call setline(lnum, indent . cmt . s:get_var('caw_sp_jump'))
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
        let org_status = s:set_and_save_comment_string(cmt)
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
    \   'I': 'I',
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


function! s:caw.detect_operated_action(mode) "{{{
    " TODO
    return ''
endfunction "}}}

" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
