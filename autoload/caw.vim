" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


"caw#keymapping_stub(): All keymappings are bound to this function. {{{
function! caw#keymapping_stub(mode, type, action) "{{{
    let context = {}
    let context.mode = a:mode
    let context.visualmode = visualmode()
    if a:mode ==# 'n'
        let context.firstline = line('.')
        let context.lastline  = line('.')
    else
        let context.firstline = line("'<")
        let context.lastline  = line("'>")
    endif
    if exists('*context_filetype#get_filetype')
      let context.filetype = context_filetype#get_filetype()
    else
      let context.filetype = &filetype
    endif
    let context.count = v:count1
    call s:set_context(context)

    try
        " TODO:
        " - Deprecate g:caw_find_another_action and
        " Implement <Plug>(caw:dwim) like Emacs's dwim-comment
        " - Stop checking b:changedtick and
        " let s:caw[type][a:action] just return changed lines,
        " not modifying buffer.
        let types = [a:type]
        if s:get_var('caw_find_another_action')
            let types += get(s:caw[a:type], 'fallback_types', [])
        endif
        for type in types
            let old_changedtick = b:changedtick
            if has_key(s:caw[type], 'comment_database')
            \   && empty(s:caw[type].comment_database.get_comment())
                continue
            endif
            " echom 'calling s:caw['.string(type).']['.string(a:action).']() ...'
            call s:caw[type][a:action]()
            " echom 'calling s:caw['.string(type).']['.string(a:action).']() ... done.'
            if b:changedtick !=# old_changedtick
                break
            endif
        endfor
    catch
        echohl ErrorMsg
        echomsg '[' . v:exception . ']::[' . v:throwpoint . ']'
        echohl None
    finally
        call s:set_context({})    " free context.
    endtry
endfunction "}}}
" }}}

" Context: context while invoking keymapping. {{{
let s:context = {}
function! s:set_context(context) "{{{
    unlockvar! s:context
    let s:context = a:context
    lockvar! s:context
endfunction "}}}
function! s:get_context() "{{{
    return s:context
endfunction "}}}
" }}}

" Utilities: Misc. functions. {{{

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

function! s:make_indent_str(indent_byte_num)
    return repeat((&expandtab ? ' ' : "\t"), a:indent_byte_num)
endfunction


function! s:trim_whitespaces(str) "{{{
    let str = a:str
    let str = substitute(str, '^\s\+', '', '')
    let str = substitute(str, '\s\+$', '', '')
    return str
endfunction "}}}

function! s:get_min_indent_num(skip_blank_line, from_lnum, to_lnum) "{{{
    let min_indent_num = 1/0
    for lnum in range(a:from_lnum, a:to_lnum)
        if a:skip_blank_line && getline(lnum) =~ '^\s*$'
            continue    " Skip blank line.
        endif
        let n = s:get_inserted_indent_num(lnum)
        if n < min_indent_num
            let min_indent_num = n
        endif
    endfor
    return min_indent_num
endfunction "}}}

function! s:get_both_sides_space_cols(skip_blank_line, from_lnum, to_lnum) "{{{
    let left  = 1/0
    let right = 1
    for line in getline(a:from_lnum, a:to_lnum)
        if a:skip_blank_line && line =~ '^\s*$'
            continue    " Skip blank line.
        endif
        let l  = strlen(matchstr(line, '^\s*')) + 1
        let r = strlen(line) - strlen(matchstr(line, '\s*$')) + 1
        if l < left
            let left = l
        endif
        if r > right
            let right = r
        endif
    endfor
    return [left, right]
endfunction "}}}

function! s:wrap_comment_align(line, left_cmt, right_cmt, left_col, right_col) "{{{
    let l = a:line
    " Save indent.
    let indent = a:left_col >=# 2 ? l[: a:left_col-2] : ''
    let indent = indent =~# '^\s*$' ? indent : ''
    " Pad tail whitespaces.
    if strlen(l) < a:right_col-1
        let l .= repeat(' ', (a:right_col-1) - strlen(l))
    endif
    " Trim left/right whitespaces.
    let l = l[a:left_col-1 : a:right_col-1]
    " Add left/right comment and whitespaces.
    if a:left_cmt !=# ''
        let l = a:left_cmt . l
    endif
    if a:right_cmt !=# ''
        let l = l . a:right_cmt
    endif
    " Restore indent.
    return indent . l
endfunction "}}}

" }}}

" s:comments: Comment string database. {{{
let s:comments = {'oneline': {}, 'wrap_oneline': {}, 'wrap_multiline': {}}


function! s:comments_get_comment() dict "{{{
    for method in self.__get_comment_fn_list
        let r = self[method]()
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

function! s:comments_get_comment_vars() dict "{{{
    return s:get_var(self.__get_comment_vars_varname, '')
endfunction "}}}
function! s:create_get_comment_vars(comment) "{{{
    return {
    \   '__get_comment_vars_varname': a:comment,
    \   'get_comment_vars': s:local_func('comments_get_comment_vars'),
    \}
endfunction "}}}


" oneline {{{
call extend(s:comments.oneline, s:create_get_comment(['get_comment_vars', 'get_comment_builtin', 'get_comment_detect'], ''), 'error')
call extend(s:comments.oneline, s:create_get_comment_vars('caw_oneline_comment'), 'error')

function! s:comments.oneline.get_comment_detect() "{{{
    let m = matchlist(&l:commentstring, '^\(.\{-}\)[ \t]*%s[ \t]*\(.*\)$')
    if !empty(m) && m[1] !=# '' && m[2] ==# ''
        return m[1]
    endif
    return ''
endfunction "}}}

function! s:comments.oneline.get_comment_builtin() "{{{
    " TODO: compound filetypes
    return repeat(get({
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
    \   'elm': "--",
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
    \   'go': '//',
    \   'groovy': '//',
    \   'gtkrc': '#',
    \   'h': '//',
    \   'haml': '-#',
    \   'haskell': '--',
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
    \   'julia': '#',
    \   'kirikiri': ';',
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
    \   'nginx': '#',
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
    \   'slim': '/',
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
    \   'tmux': '#',
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
    \   'zimbu': '#',
    \   'zsh': '#',
    \}, s:get_context().filetype, ''), s:get_context().count)
endfunction "}}}
" }}}

" wrap_oneline "{{{
call extend(s:comments.wrap_oneline, s:create_get_comment(['get_comment_vars', 'get_comment_builtin', 'get_comment_detect'], []), 'error')
call extend(s:comments.wrap_oneline, s:create_get_comment_vars('caw_wrap_oneline_comment'), 'error')

function! s:comments.wrap_oneline.get_comment_detect() "{{{
    let m = matchlist(&l:commentstring, '^\(.\{-}\)[ \t]*%s[ \t]*\(.*\)$')
    if !empty(m) && m[1] !=# '' && m[2] !=# ''
        return m[1:2]
    endif
    return []
endfunction "}}}

function! s:comments.wrap_oneline.get_comment_builtin() "{{{
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
    \   'elm': ['{-', '-}'],
    \   'eruby': ['<%#', '%>'],
    \   'fx': ['/*', '*/'],
    \   'genshi': ['<!--', '-->'],
    \   'go': ['/*', '*/'],
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
    \   'julia': ['#=', '=#'],
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
    \}, s:get_context().filetype, [])
endfunction "}}}
" }}}

" wrap_multiline {{{
call extend(s:comments.wrap_multiline, s:create_get_comment(['get_comment_vars', 'get_comment_builtin'], {}), 'error')
call extend(s:comments.wrap_multiline, s:create_get_comment_vars('caw_wrap_multiline_comment'), 'error')

function! s:comments.wrap_multiline.get_comment_builtin() "{{{
    " TODO: compound filetypes
    " TODO: More filetypes
    return get({
    \   'perl': {'left': '#', 'top': '#', 'bottom': '#', 'right': '#'},
    \   'ruby': {'left': '#', 'top': '#', 'bottom': '#', 'right': '#'},
    \   'c': {'left': '/*', 'top': '*', 'bottom': '*', 'right': '*/'},
    \   'cpp': {'left': '/*', 'top': '*', 'bottom': '*', 'right': '*/'},
    \}, s:get_context().filetype, {})
endfunction "}}}
" }}}

lockvar! s:comments
" }}}

" s:caw: Comment types (styles) and those actions. {{{
let s:caw = {}


" s:Commentable {{{
"
" These methods are missing.
" Derived object must implement those.
"
" s:Commentable_comment() requires:
" - Derived.comment_normal()

function! s:Commentable_comment() dict "{{{
    if s:get_context().mode ==# 'n'
        call self.comment_normal(line('.'))
    else
        call self.comment_visual()
    endif
endfunction "}}}

function! s:Commentable_comment_visual() dict "{{{
    " Behave linewisely.
    for lnum in range(
    \   s:get_context().firstline,
    \   s:get_context().lastline
    \)
        call self.comment_normal(lnum)
    endfor
endfunction "}}}

" }}}
" s:Uncommentable {{{
"
" These methods are missing.
" Derived object must implement those.
"
" s:Uncommentable_uncomment() and s:Uncommentable_uncomment_visual() require:
" - Derived.uncomment_normal()


function! s:Uncommentable_uncomment() dict "{{{
    if s:get_context().mode ==# 'n'
        call self.uncomment_normal(line('.'))
    else
        call self.uncomment_visual()
    endif
endfunction "}}}

function! s:Uncommentable_uncomment_visual() dict "{{{
    for lnum in range(
    \   s:get_context().firstline,
    \   s:get_context().lastline
    \)
        call self.uncomment_normal(lnum)
    endfor
endfunction "}}}

" }}}
" s:CommentDetectable {{{
"
" These methods are missing.
" Derived object must implement those.
"
" s:CommentDetectable_has_comment() and s:CommentDetectable_has_comment_visual() require:
" - Derived.has_comment_normal()


function! s:CommentDetectable_has_comment() dict "{{{
    if s:get_context().mode ==# 'n'
        return self.has_comment_normal(line('.'))
    else
        return self.has_comment_visual()
    endif
endfunction "}}}

function! s:CommentDetectable_has_comment_visual() dict "{{{
    for lnum in range(
    \   s:get_context().firstline,
    \   s:get_context().lastline
    \)
        if self.has_comment_normal(lnum)
            return 1
        endif
    endfor
    return 0
endfunction "}}}

function! s:CommentDetectable_has_all_comment() dict "{{{
    " CommentDetectable.has_all_comment() returns true
    " when all lines are consisted of commented lines and *blank lines*.
    for lnum in range(
    \   s:get_context().firstline,
    \   s:get_context().lastline
    \)
        if getline(lnum) !~# '^\s*$' && !self.has_comment_normal(lnum)
            return 0
        endif
    endfor
    return 1
endfunction "}}}

" }}}
" s:Togglable {{{
"
" These methods are missing.
" Derived object must implement those.
"
" s:Togglable_toggle requires:
" - Derived.uncomment()
" - Derived.comment()


function! s:Togglable_toggle() dict "{{{
    let all_comment = self.has_all_comment()
    let mixed = !all_comment && self.has_comment()
    if s:get_context().mode ==# 'n'
        if all_comment
            " The line is commented out.
            call self.uncomment()
        else
            " The line is not commented out.
            call self.comment()
        endif
    else
        if mixed
            " Some lines are commented out.
            call self.comment()
        elseif all_comment
            " All lines are commented out.
            call self.uncomment()
        else
            " All lines are not commented out.
            call self.comment()
        endif
    endif
endfunction "}}}

" }}}


" i {{{

function! s:caw_i_comment_normal(lnum, ...) dict "{{{
    " NOTE: min_indent_num is byte length. not display width.

    let startinsert = get(a:000, 0, s:get_var('caw_i_startinsert_at_blank_line'))
    let min_indent_num = get(a:000, 1, -1)
    let line = getline(a:lnum)
    let caw_i_sp = line =~# '^\s*$' ?
    \               s:get_var('caw_i_sp_blank') :
    \               s:get_var('caw_i_sp')

    let cmt = self.comment_database.get_comment()
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    if min_indent_num >= 0
        if min_indent_num > strlen(line)
            call setline(a:lnum, s:make_indent_str(min_indent_num))
            let line = getline(a:lnum)
        endif
        call s:assert(min_indent_num <= strlen(line), min_indent_num.' is accessible to '.string(line).'.')
        let before = min_indent_num ==# 0 ? '' : line[: min_indent_num - 1]
        let after  = min_indent_num ==# 0 ? line : line[min_indent_num :]
        call setline(a:lnum, before . cmt . caw_i_sp . after)
    elseif line =~# '^\s*$'
        execute 'normal! '.a:lnum.'G"_cc' . cmt . caw_i_sp
        if startinsert && s:get_context().mode ==# 'n'
            startinsert!
        endif
    else
        let indent = s:get_inserted_indent(a:lnum)
        let line = substitute(getline(a:lnum), '^[ \t]\+', '', '')
        call setline(a:lnum, indent . cmt . caw_i_sp . line)
    endif
endfunction "}}}

function! s:caw_i_comment_visual() dict "{{{
    if s:get_var('caw_i_align')
        let min_indent_num =
        \   s:get_min_indent_num(
        \       1,
        \       s:get_context().firstline,
        \       s:get_context().lastline)
    endif

    for lnum in range(
    \   s:get_context().firstline,
    \   s:get_context().lastline
    \)
        if s:get_var('caw_i_skip_blank_line') && getline(lnum) =~ '^\s*$'
            continue    " Skip blank line.
        endif
        if s:get_var('caw_i_align')
            call self.comment_normal(lnum, 0, min_indent_num)
        else
            call self.comment_normal(lnum, 0)
        endif
    endfor
endfunction "}}}

function! s:caw_i_has_comment_normal(lnum) dict "{{{
    let line_without_indent = substitute(getline(a:lnum), '^[ \t]\+', '', '')
    let cmt = s:comments.oneline.get_comment()
    return !empty(cmt) && stridx(line_without_indent, cmt) == 0
endfunction "}}}

function! s:caw_i_uncomment_normal(lnum) dict "{{{
    let cmt = self.comment_database.get_comment()
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    if self.has_comment_normal(a:lnum)
        let indent = s:get_inserted_indent(a:lnum)
        let line   = substitute(getline(a:lnum), '^[ \t]\+', '', '')
        if stridx(line, cmt) == 0
            " Remove comment.
            let line = line[strlen(cmt) :]
            " 'caw_i_sp'
            if stridx(line, s:get_var('caw_i_sp')) ==# 0
                let line = line[strlen(s:get_var('caw_i_sp')) :]
            endif
            call setline(a:lnum, indent . line)
        endif
    endif
endfunction "}}}


let s:caw.i = {
\   'comment': s:local_func('Commentable_comment'),
\   'comment_normal': s:local_func('caw_i_comment_normal'),
\   'comment_visual': s:local_func('caw_i_comment_visual'),
\   'uncomment': s:local_func('Uncommentable_uncomment'),
\   'uncomment_normal': s:local_func('caw_i_uncomment_normal'),
\   'uncomment_visual': s:local_func('Uncommentable_uncomment_visual'),
\   'has_comment': s:local_func('CommentDetectable_has_comment'),
\   'has_comment_visual': s:local_func('CommentDetectable_has_comment_visual'),
\   'has_all_comment': s:local_func('CommentDetectable_has_all_comment'),
\   'has_comment_normal': s:local_func('caw_i_has_comment_normal'),
\   'toggle': s:local_func('Togglable_toggle'),
\
\   'comment_database': s:comments.oneline,
\   'fallback_types': ['wrap'],
\}
" }}}

" I {{{

function! s:caw_I_comment_normal(lnum, ...) dict "{{{
    let startinsert = get(a:000, 0, s:get_var('caw_I_startinsert_at_blank_line')) && s:get_context().mode ==# 'n'
    let line = getline(a:lnum)
    let caw_I_sp = line =~# '^\s*$' ?
    \               s:get_var('caw_I_sp_blank') :
    \               s:get_var('caw_I_sp')

    let cmt = self.comment_database.get_comment()
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    if line =~# '^\s*$'
        if s:get_var('caw_I_skip_blank_line')
            return
        endif
        call setline(a:lnum, cmt . caw_I_sp)
        if startinsert
            startinsert!
        endif
    else
        call setline(a:lnum, cmt . caw_I_sp . line)
    endif
endfunction "}}}


let s:caw.I = deepcopy(s:caw.i)
let s:caw.I.comment_normal = s:local_func('caw_I_comment_normal')
" }}}

" a {{{

function! s:caw_a_comment_normal(lnum, ...) dict "{{{
    let startinsert = a:0 ? a:1 : s:get_var('caw_a_startinsert') && s:get_context().mode ==# 'n'

    let cmt = self.comment_database.get_comment()
    call s:assert(!empty(cmt), "`cmt` must not be empty.")

    call setline(
    \   a:lnum,
    \   getline(a:lnum)
    \       . s:get_var('caw_a_sp_left')
    \       . cmt
    \       . s:get_var('caw_a_sp_right')
    \)
    if startinsert
        startinsert!
    endif
endfunction "}}}

function! s:caw_a_get_comment_col(lnum) "{{{
    let cmt = s:comments.oneline.get_comment()
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
    let cmt = self.comment_database.get_comment()
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
        " 'caw_a_sp_left'
        let before = substitute(before, '\s\+$', '', '')

        call setline(a:lnum, before)
    endif
endfunction "}}}


let s:caw.a = {
\   'comment': s:local_func('Commentable_comment'),
\   'comment_normal': s:local_func('caw_a_comment_normal'),
\   'comment_visual': s:local_func('Commentable_comment_visual'),
\   'uncomment': s:local_func('Uncommentable_uncomment'),
\   'uncomment_normal': s:local_func('caw_a_uncomment_normal'),
\   'uncomment_visual': s:local_func('Uncommentable_uncomment_visual'),
\   'has_comment': s:local_func('CommentDetectable_has_comment'),
\   'has_comment_normal': s:local_func('caw_a_has_comment_normal'),
\   'has_comment_visual': s:local_func('CommentDetectable_has_comment_visual'),
\   'has_all_comment': s:local_func('CommentDetectable_has_all_comment'),
\   'toggle': s:local_func('Togglable_toggle'),
\
\   'comment_database': s:comments.oneline,
\   'fallback_types': ['wrap'],
\}
" }}}

" wrap {{{

function! s:caw_wrap_comment_normal(lnum, ...) dict "{{{
    let left_col = get(a:000, 0, -1)
    let right_col = get(a:000, 1, -1)

    let cmt = self.comment_database.get_comment()
    call s:assert(!empty(cmt), "`cmt` must not be empty.")
    if s:get_context().mode ==# 'n'
    \   && s:get_var('caw_wrap_skip_blank_line')
    \   && getline(a:lnum) =~# '^\s*$'
        return
    endif

    let line = getline(a:lnum)
    let [left_cmt, right_cmt] = cmt
    if left_col > 0 && right_col > 0
        let line = s:wrap_comment_align(
        \   line,
        \   left_cmt . s:get_var("caw_wrap_sp_left"),
        \   s:get_var("caw_wrap_sp_right") . right_cmt,
        \   left_col,
        \   right_col)
        call setline(a:lnum, line)
    else
        let line = substitute(line, '^\s\+', '', '')
        if left_cmt != ''
            let line = left_cmt . s:get_var('caw_wrap_sp_left') . line
        endif
        if right_cmt != ''
            let line = line . s:get_var('caw_wrap_sp_right') . right_cmt
        endif
        let line = s:get_inserted_indent(a:lnum) . line
        call setline(a:lnum, line)
    endif
endfunction "}}}

function! s:caw_wrap_comment_visual() dict "{{{
    let wiseness = get({
    \   'v': 'characterwise',
    \   'V': 'linewise',
    \   "\<C-v>": 'blockwise',
    \}, s:get_context().visualmode, '')
    if wiseness != ''
    \   && has_key(self, 'comment_visual_' . wiseness)
        call call(self['comment_visual_' . wiseness], [], self)
        return
    endif

    if s:get_var('caw_wrap_align')
        let [left_col, right_col] =
        \   s:get_both_sides_space_cols(
        \       s:get_var('caw_wrap_skip_blank_line'),
        \       s:get_context().firstline,
        \       s:get_context().lastline)
    endif

    for lnum in range(
    \   s:get_context().firstline,
    \   s:get_context().lastline
    \)
        if s:get_var('caw_wrap_skip_blank_line') && getline(lnum) =~ '^\s*$'
            continue    " Skip blank line.
        endif
        if s:get_var('caw_wrap_align')
            call self.comment_normal(lnum, left_col, right_col)
        else
            call self.comment_normal(lnum)
        endif
    endfor
endfunction "}}}

function! s:comment_visual_characterwise_comment_out(text) "{{{
    let cmt = s:comments.wrap_oneline.get_comment()
    if empty(cmt)
        return a:text
    else
        return cmt[0]
        \   . s:get_var('caw_wrap_sp_left')
        \   . a:text
        \   . s:get_var('caw_wrap_sp_right')
        \   . cmt[1]
    endif
endfunction "}}}
function! s:operate_on_word(funcname) "{{{
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
    let cmt = self.comment_database.get_comment()
    call s:assert(!empty(cmt), "`cmt` must not be empty.")
    call s:operate_on_word('<SID>comment_visual_characterwise_comment_out')
endfunction "}}}

function! s:caw_wrap_has_comment_normal(lnum) dict "{{{
    let cmt = s:comments.wrap_oneline.get_comment()
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
    let cmt = s:comments.wrap_oneline.get_comment()
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


let s:caw.wrap = {
\   'comment': s:local_func('Commentable_comment'),
\   'comment_normal': s:local_func('caw_wrap_comment_normal'),
\   'comment_visual': s:local_func('caw_wrap_comment_visual'),
\   'comment_visual_characterwise': s:local_func('caw_wrap_comment_visual_characterwise'),
\   'uncomment': s:local_func('Uncommentable_uncomment'),
\   'uncomment_normal': s:local_func('caw_wrap_uncomment_normal'),
\   'uncomment_visual': s:local_func('Uncommentable_uncomment_visual'),
\   'has_comment': s:local_func('CommentDetectable_has_comment'),
\   'has_comment_normal': s:local_func('caw_wrap_has_comment_normal'),
\   'has_comment_visual': s:local_func('CommentDetectable_has_comment_visual'),
\   'has_all_comment': s:local_func('CommentDetectable_has_all_comment'),
\   'toggle': s:local_func('Togglable_toggle'),
\
\   'comment_database': s:comments.wrap_oneline,
\   'fallback_types': ['i'],
\}
" }}}

" box {{{

" TODO:
" - s:caw_box_uncomment()


function! s:caw_box_comment() dict "{{{
    " Get current filetype comments.
    " Use oneline comment for top/bottom comments.
    " Use wrap comment for left/right comments if possible.
    let cmt = self.comment_database.get_comment()
    if empty(cmt)
    \  || empty(cmt.left)
    \  || empty(cmt.right)
    \  || empty(cmt.top)
    \  || empty(cmt.bottom)
        return
    endif

    " Determine left/right col to box string.
    let top_lnum    = s:get_context().firstline
    let bottom_lnum = s:get_context().lastline
    let [left_col, right_col] =
    \   s:get_both_sides_space_cols(1, top_lnum, bottom_lnum)
    call s:assert(left_col > 0, 'left_col > 0')
    call s:assert(right_col > 0, 'right_col > 0')

    " Box string!
    let reg = getreg('z', 1)
    let regtype = getregtype('z')
    try
        " Delete target lines.
        silent execute top_lnum.','.bottom_lnum.'delete z'
        let lines = split(@z, "\n")

        let width = right_col - left_col
        call s:assert(width > 0, 'width > 0')
        let tops_and_bottoms = cmt.left . repeat(cmt.top, width + 2) . cmt.right

        let sp_left = s:get_var("caw_box_sp_left")
        let sp_right = s:get_var("caw_box_sp_right")
        call map(lines, 's:wrap_comment_align(v:val, cmt.left . sp_left, sp_right . cmt.right, left_col, right_col)')
        " Pad/Remove left/right whitespaces.
        call insert(lines,
        \   repeat((&expandtab ? ' ' : "\t"), left_col-1)
        \   . tops_and_bottoms)
        call add(lines,
        \   repeat((&expandtab ? ' ' : "\t"), left_col-1)
        \   . tops_and_bottoms)

        " Put modified lines.
        let @z = join(lines, "\n")
        " If top_lnum == line('.') + 1, `execute top_lnum.'put! z'` will cause an error.
        silent execute (top_lnum - 1).'put z'

    finally
        call setreg('z', reg, regtype)
    endtry
endfunction "}}}

let s:caw.box = {
\   'comment': s:local_func('caw_box_comment'),
\   'comment_database': s:comments.wrap_multiline,
\}
" }}}

" jump {{{

function! s:caw_jump_comment_next() dict "{{{
    return call('s:caw_jump_comment', [1], self)
endfunction "}}}

function! s:caw_jump_comment_prev() dict "{{{
    return call('s:caw_jump_comment', [0], self)
endfunction "}}}

function! s:caw_jump_comment(next) dict "{{{
    let cmt = s:comments.oneline.get_comment()
    if empty(cmt)
        return
    endif

    let lnum = line('.')
    if a:next
        " Begin a new line and insert
        " the online comment leader with whitespaces.
        execute 'normal! o' . cmt .  s:get_var('caw_jump_sp')
        " Start Insert mode at the end of the inserted line.
        call cursor(lnum + 1, 1)
        startinsert!
    else
        " NOTE: `lnum` is target lnum.
        " because new line was inserted just now.
        execute 'normal! O' . cmt . s:get_var('caw_jump_sp')
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

function! s:caw_input_comment() dict "{{{
    let [pos, pos_opt] = s:caw_input_get_pos()
    if !has_key(s:caw, pos) || !has_key(s:caw[pos], 'comment')
        echohl WarningMsg
        echomsg pos . ': Invalid pos.'
        echohl None
        return
    endif

    let default_cmt = s:comments.oneline.get_comment()
    let cmt = s:input('any comment?:', default_cmt)

    if !empty(default_cmt) && default_cmt !=# cmt
        let org_status = s:set_and_save_comment_string(cmt)
    endif
    try
        if s:get_context().mode ==# 'n'
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
    for lnum in range(
    \   s:get_context().firstline,
    \   s:get_context().lastline
    \)
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

" s:caw is not changed.
" no changing script-local variable but only buffer is changed.
lockvar! s:caw

" }}}


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
