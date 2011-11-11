" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


" All keymappings are bound to this function.
function! caw#keymapping_stub(mode, type, action) "{{{
    try
        return call(
        \   s:caw[a:type][a:action],
        \   [a:mode],
        \   s:caw[a:type]
        \)
    catch
        echohl ErrorMsg
        echomsg '[' . v:exception . ']::[' . v:throwpoint . ']'
        echohl None
    endtry
endfunction "}}}

" Misc. functions.
" Utilities {{{

function s:SID() "{{{
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction "}}}
let s:SID_PREFIX = s:SID()
delfunc s:SID

function! s:local_func(name) "{{{
    return function(
    \   '<SNR>' . s:SID_PREFIX . '_' . a:name
    \)
endfunction "}}}


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


function! s:assert(cond, msg) "{{{
    if !a:cond
        throw 'caw: assertion failure: ' . a:msg
    endif
endfunction "}}}

function! s:get_var(varname, ...) "{{{
    for ns in [b:, w:, t:, g:]
        if has_key(ns, a:varname)
            return ns[a:varname]
        endif
    endfor
    if a:0
        return a:1
    else
        call s:assert(0, "s:get_var(): this must be reached")
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

" }}}

" Comment string database.
" s:comments {{{
" TODO Multiline
let s:comments = {'oneline': {}, 'wrap_oneline': {}, 'wrap_multiline': {}}


function! s:comments_get_comment(filetype) dict "{{{
    for method in self.__get_comment_fn_list
        let r = self[method](a:filetype)
        if !empty(r)
            return r
        endif
        unlet r
    endfor
    return self.__get_comment_empty_value
endfunction "}}}
function! s:create_get_comment(fn_list, empty_value) "{{{
    return {
    \   '__get_comment_empty_value': a:empty_value,
    \   '__get_comment_fn_list': a:fn_list,
    \   'get_comment': s:local_func('comments_get_comment'),
    \}
endfunction "}}}

function! s:comments_get_comment_vars(filetype) dict "{{{
    return s:get_var(self.__get_comment_vars_varname, '')
endfunction "}}}
function! s:create_get_comment_vars(comment) "{{{
    return {
    \   '__get_comment_vars_varname': a:comment,
    \   'get_comment_vars': s:local_func('comments_get_comment_vars'),
    \}
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
    \   'pfmain': '#',
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

" Comment types (styles) and those actions.
" s:caw {{{
let s:caw = {}


function! s:caw_call_another_action(method, args) dict "{{{
    for c in sort(keys(self.__call_another_action_comment_vs_action))
        if !empty(s:comments[c].get_comment(&filetype))
            let action = self.__call_another_action_comment_vs_action[c]
            return call(s:caw[action][a:method], a:args, s:caw[action])
        endif
    endfor
endfunction "}}}
function! s:create_call_another_action(comment_vs_action) "{{{
    return {
    \   '__call_another_action_comment_vs_action': a:comment_vs_action,
    \   'call_another_action': s:local_func('caw_call_another_action'),
    \}
endfunction "}}}


" Readable inheritance wrapper functions for extend()
function! s:create_class_from(...) "{{{
    let class = {}
    for base in a:000
        call extend(class, base, 'error')
    endfor
    return class
endfunction "}}}
function! s:override_methods(class, methods) "{{{
    call extend(a:class, a:methods, 'force')
endfunction "}}}


" s:Commentable {{{
"
" These methods are missing.
" Derived object must implement those.
"
" s:Commentable_comment() requires:
" - Derived.comment_normal()

function! s:Commentable_comment(mode) dict "{{{
    if !has_key(self, 'comment_database')
    \   || empty(self.comment_database.get_comment(&filetype))
        if s:get_var('caw_find_another_action', 0)
            return self.call_another_action('comment', [a:mode])
        endif
        return
    endif

    if a:mode ==# 'n'
        call self.comment_normal(line('.'))
    else
        let wiseness = get({
        \   'v': 'characterwise',
        \   'V': 'linewise',
        \   "\<C-v>": 'blockwise',
        \}, visualmode(), '')
        if wiseness != '' && has_key(self, 'comment_visual_' . wiseness)
            call call(self['comment_visual_' . wiseness], [], self)
        else
            call self.comment_visual()
        endif
    endif
endfunction "}}}

function! s:Commentable_comment_visual() dict "{{{
    " Behave like linewise.
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum)
    endfor
endfunction "}}}

let s:Commentable = {
\   'comment': s:local_func('Commentable_comment'),
\   'comment_visual': s:local_func('Commentable_comment_visual'),
\}
" }}}
" s:Uncommentable {{{
"
" These methods are missing.
" Derived object must implement those.
"
" s:Uncommentable_uncomment() and s:Uncommentable_uncomment_visual() require:
" - Derived.uncomment_normal()


function! s:Uncommentable_uncomment(mode) dict "{{{
    if !has_key(self, 'comment_database')
    \   || empty(self.comment_database.get_comment(&filetype))
        if s:get_var('caw_find_another_action', 0)
            return self.call_another_action('uncomment', [a:mode])
        endif
        return
    endif

    if a:mode ==# 'n'
        call self.uncomment_normal(line('.'))
    else
        call self.uncomment_visual()
    endif
endfunction "}}}

function! s:Uncommentable_uncomment_visual() dict "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.uncomment_normal(lnum)
    endfor
endfunction "}}}


let s:Uncommentable = {
\   'uncomment': s:local_func('Uncommentable_uncomment'),
\   'uncomment_visual': s:local_func('Uncommentable_uncomment_visual'),
\}
" }}}
" s:CommentDetectable {{{
"
" These methods are missing.
" Derived object must implement those.
"
" s:CommentDetectable_has_comment() and s:CommentDetectable_has_comment_visual() require:
" - Derived.has_comment_normal()


function! s:CommentDetectable_has_comment(mode) dict "{{{
    if a:mode ==# 'n'
        return self.has_comment_normal(line('.'))
    else
        return self.has_comment_visual()
    endif
endfunction "}}}

function! s:CommentDetectable_has_comment_visual() dict "{{{
    for lnum in range(line("'<"), line("'>"))
        if self.has_comment_normal(lnum)
            return 1
        endif
    endfor
    return 0
endfunction "}}}

function! s:CommentDetectable_has_all_comment() dict "{{{
    for lnum in range(line("'<"), line("'>"))
        if !self.has_comment_normal(lnum)
            return 0
        endif
    endfor
    return 1
endfunction "}}}


let s:CommentDetectable = {
\   'has_comment': s:local_func('CommentDetectable_has_comment'),
\   'has_comment_visual': s:local_func('CommentDetectable_has_comment_visual'),
\   'has_all_comment': s:local_func('CommentDetectable_has_all_comment'),
\}
" }}}
" s:Togglable {{{
"
" These methods are missing.
" Derived object must implement those.
"
" s:Togglable_toggle requires:
" - Derived.uncomment()
" - Derived.comment()


function! s:Togglable_toggle(mode) dict "{{{
    if !has_key(self, 'comment_database')
    \   || empty(self.comment_database.get_comment(&filetype))
        if s:get_var('caw_find_another_action', 0)
            return self.call_another_action('toggle', [a:mode])
        endif
        return
    endif

    let all_comment = self.has_all_comment()
    let mixed = !all_comment && self.has_comment(a:mode)
    if mixed
        " Some lines are commented out.
        call self.comment(a:mode)
    elseif all_comment
        " All lines are commented out.
        call self.uncomment(a:mode)
    else
        " All lines are not commented out.
        call self.comment(a:mode)
    endif
endfunction "}}}


let s:Togglable = {
\   'toggle': s:local_func('Togglable_toggle'),
\}
" }}}


" i {{{

function! s:caw_i_comment_normal(lnum, ...) dict "{{{
    let startinsert = get(a:000, 0, s:get_var('caw_i_startinsert_at_blank_line'))
    let min_indent_num = get(a:000, 1, -1)

    let cmt = self.comment_database.get_comment(&filetype)
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    let line = getline(a:lnum)
    if min_indent_num >= 0
        call s:assert(min_indent_num <= strlen(line), min_indent_num.' is accessible to '.string(line).'.')
        let before = min_indent_num ==# 0 ? '' : line[: min_indent_num - 1]
        let after  = min_indent_num ==# 0 ? line : line[min_indent_num :]
        call setline(a:lnum, before . cmt . s:get_var('caw_sp_i') . after)
    elseif line =~# '^\s*$'
        " Delete the current line and then do "gcO".
        silent delete _
        call s:caw.jump.comment_prev('n')
    else
        let indent = s:get_inserted_indent(a:lnum)
        let line = substitute(getline(a:lnum), '^[ \t]\+', '', '')
        call setline(a:lnum, indent . cmt . s:get_var('caw_sp_i') . line)
    endif
endfunction "}}}

function! s:caw_i_comment_visual() dict "{{{
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

function! s:caw_i_has_comment_normal(lnum) dict "{{{
    let line_without_indent = substitute(getline(a:lnum), '^[ \t]\+', '', '')
    let cmt = s:comments.oneline.get_comment(&filetype)
    return !empty(cmt) && stridx(line_without_indent, cmt) == 0
endfunction "}}}

function! s:caw_i_uncomment_normal(lnum) dict "{{{
    let cmt = self.comment_database.get_comment(&filetype)
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    if self.has_comment_normal(a:lnum)
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


let s:caw.i = s:create_class_from(
\   {
\       'comment_normal': s:local_func('caw_i_comment_normal'),
\       'uncomment_normal': s:local_func('caw_i_uncomment_normal'),
\       'has_comment_normal': s:local_func('caw_i_has_comment_normal'),
\       'comment_database': s:comments.oneline,
\   },
\   s:create_call_another_action({'wrap_oneline': 'wrap'}),
\   s:Commentable,
\   s:Uncommentable,
\   s:CommentDetectable,
\   s:Togglable,
\)
call s:override_methods(s:caw.i, {
\   'comment_visual': s:local_func('caw_i_comment_visual'),
\})
" }}}

" I {{{

function! s:caw_I_comment_normal(lnum, ...) dict "{{{
    let startinsert = get(a:000, 0, s:get_var('caw_I_startinsert_at_blank_line'))

    let cmt = self.comment_database.get_comment(&filetype)
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    let line = getline(a:lnum)
    if line =~# '^\s*$'
        call setline(a:lnum, cmt . s:get_var('caw_sp_I'))
        if startinsert
            startinsert!
        endif
    else
        call setline(a:lnum, cmt . s:get_var('caw_sp_I') . line)
    endif
endfunction "}}}


let s:caw.I = s:create_class_from(s:caw.i)
call s:override_methods(s:caw.I, {
\   'comment_normal': s:local_func('caw_I_comment_normal'),
\})
" }}}

" a {{{

function! s:caw_a_comment_normal(lnum, ...) dict "{{{
    let startinsert = a:0 ? a:1 : s:get_var('caw_a_startinsert')

    let cmt = self.comment_database.get_comment(&filetype)
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    call setline(
    \   a:lnum,
    \   getline(a:lnum)
    \       . s:get_var('caw_sp_a_left')
    \       . cmt
    \       . s:get_var('caw_sp_a_right')
    \)
    if startinsert
        startinsert!
    endif
endfunction "}}}

function! s:caw_a_comment_visual() dict "{{{
    for lnum in range(line("'<"), line("'>"))
        call self.comment_normal(lnum)
    endfor
endfunction "}}}

function! s:caw_a_get_comment_col(lnum) "{{{
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

function! s:caw_a_has_comment_normal(lnum) dict "{{{
    return s:caw_a_get_comment_col(a:lnum) > 0
endfunction "}}}

function! s:caw_a_uncomment_normal(lnum) dict "{{{
    let cmt = self.comment_database.get_comment(&filetype)
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    if self.has_comment_normal(a:lnum)
        let col = s:caw_a_get_comment_col(a:lnum)
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


let s:caw.a = s:create_class_from(
\   {
\       'comment_normal': s:local_func('caw_a_comment_normal'),
\       'uncomment_normal': s:local_func('caw_a_uncomment_normal'),
\       'has_comment_normal': s:local_func('caw_a_has_comment_normal'),
\       'comment_database': s:comments.oneline,
\   },
\   s:create_call_another_action({'wrap_oneline': 'wrap'}),
\   s:Commentable,
\   s:Uncommentable,
\   s:CommentDetectable,
\   s:Togglable,
\)
call s:override_methods(s:caw.I, {
\   'comment_visual': s:local_func('caw_a_comment_visual'),
\})
" }}}

" wrap {{{

function! s:caw_wrap_comment_normal(lnum) dict "{{{
    let cmt = self.comment_database.get_comment(&filetype)
    call s:assert(!empty(cmt), "`cmt` must not be empty.")
    if getline(a:lnum) =~# '^\s*$'
        return
    endif

    let [left, right] = cmt
    let line = substitute(getline(a:lnum), '^\s\+', '', '')
    if left != ''
        let line = left . s:get_var('caw_sp_wrap_left') . line
    endif
    if right != ''
        let line = line . s:get_var('caw_sp_wrap_right') . right
    endif
    call setline(
    \   a:lnum,
    \   s:get_inserted_indent(a:lnum) . line
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
function! s:caw_wrap___operate_on_word(funcname) "{{{
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
function! s:caw_wrap_comment_visual_characterwise() dict "{{{
    let cmt = self.comment_database.get_comment(&filetype)
    call s:assert(!empty(cmt), "`cmt` must not be empty.")
    call self.__operate_on_word('<SID>comment_visual_characterwise_comment_out')
endfunction "}}}

function! s:caw_wrap_has_comment_normal(lnum) dict "{{{
    let cmt = s:comments.wrap_oneline.get_comment(&filetype)
    if empty(cmt)
        return 0
    endif

    let line = s:trim_whitespaces(getline(a:lnum))

    " line begins with left, ends with right.
    let [left, right] = cmt
    return
    \   (left == '' || line[: strlen(left) - 1] ==# left)
    \   && (right == '' || line[strlen(line) - strlen(right) :] ==# right)
endfunction "}}}

function! s:caw_wrap_uncomment_normal(lnum) dict "{{{
    let cmt = s:comments.wrap_oneline.get_comment(&filetype)
    if !empty(cmt) && self.has_comment_normal(a:lnum)
        let [left, right] = cmt
        let line = s:trim_whitespaces(getline(a:lnum))

        if left != '' && line[: strlen(left) - 1] ==# left
            let line = line[strlen(left) :]
        endif
        if right != '' && line[strlen(line) - strlen(right) :] ==# right
            let line = line[: -strlen(right) - 1]
        endif

        let indent = s:get_inserted_indent(a:lnum)
        let line = s:trim_whitespaces(line)
        call setline(a:lnum, indent . line)
    endif
endfunction "}}}


let s:caw.wrap = s:create_class_from(
\   {
\       'comment_normal': s:local_func('caw_wrap_comment_normal'),
\       'uncomment_normal': s:local_func('caw_wrap_uncomment_normal'),
\       'has_comment_normal': s:local_func('caw_wrap_has_comment_normal'),
\       'comment_database': s:comments.wrap_oneline,
\   },
\   s:create_call_another_action({'oneline': 'i'}),
\   s:Commentable,
\   s:Uncommentable,
\   s:CommentDetectable,
\   s:Togglable,
\)
" }}}

" jump {{{

function! s:caw_jump_comment_next(mode) dict "{{{
    return call('s:caw_jump_comment', [1], self)
endfunction "}}}

function! s:caw_jump_comment_prev(mode) dict "{{{
    return call('s:caw_jump_comment', [0], self)
endfunction "}}}

function! s:caw_jump_comment(next) dict "{{{
    let cmt = s:comments.oneline.get_comment(&filetype)
    if empty(cmt)
        return
    endif

    let lnum = line('.')
    if a:next
        " Begin a new line and insert
        " the online comment leader with whitespaces.
        execute 'normal! o' . cmt .  s:get_var('caw_sp_jump')
        " Start Insert mode at the end of the inserted line.
        call cursor(lnum + 1, 1)
        startinsert!
    else
        " NOTE: `lnum` is target lnum.
        " because new line was inserted just now.
        execute 'normal! O' . cmt . s:get_var('caw_sp_jump')
        " Start Insert mode at the end of the inserted line.
        call cursor(lnum, 1)
        startinsert!
    endif
endfunction "}}}


let s:caw.jump = {
\   'comment-next': s:local_func('caw_jump_comment_next'),
\   'comment_next': s:local_func('caw_jump_comment_next'),
\   'comment-prev': s:local_func('caw_jump_comment_prev'),
\   'comment_prev': s:local_func('caw_jump_comment_prev'),
\}
" }}}

" input {{{

function! s:caw_input_comment(mode) dict "{{{
    let [pos, pos_opt] = s:caw_input_get_pos()
    if !has_key(s:caw, pos) || !has_key(s:caw[pos], 'comment')
        echohl WarningMsg
        echomsg pos . ': Invalid pos.'
        echohl None
        return
    endif

    let default_cmt = s:comments.oneline.get_comment(&filetype)
    let cmt = s:input('any comment?:', default_cmt)

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
            call org_status.restore()
        endif
    endtry
endfunction "}}}

function! s:caw_input_comment_normal(lnum, pos) dict "{{{
    call s:caw[a:pos].comment_normal(a:lnum)
endfunction "}}}

function! s:caw_input_comment_visual(pos) dict "{{{
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

function! s:input(...) "{{{
    call inputsave()
    try
        return call('input', a:000)
    finally
        call inputrestore()
    endtry
endfunction "}}}


let s:caw.input = {
\   'comment': s:local_func('caw_input_comment'),
\   'comment_normal': s:local_func('caw_input_comment_normal'),
\   'comment_visual': s:local_func('caw_input_comment_visual'),
\}
" }}}


function! s:caw.detect_operated_action(mode) "{{{
    " TODO
    return ''
endfunction "}}}

" Remove unnecessary objects for memory... {{{
" Those objects were used to build objects under s:caw.
" now no need to hold the objects so remove them.

unlet s:Commentable s:Uncommentable s:CommentDetectable s:Togglable
" }}}

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
