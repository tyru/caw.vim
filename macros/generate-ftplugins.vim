" Run this script to generate after/ftplugin/*:
"   vim -u NONE -i NONE -N -S macros/generate-ftplugins.vim -c quit

" Please add oneline comments here
function! s:oneline() abort
  return {
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
  \   'arduino': '//',
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
  \   'cql': '--',
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
  \   'egison': ';',
  \   'eiffel': '--',
  \   'elf': "'",
  \   'elm': '--',
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
  \   'kotlin': '//',
  \   'kscript': '//',
  \   'lace': '--',
  \   'lean': '--',
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
  \   'mysql': '--',
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
  \   'octave': '%',
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
  \   'pug': '//-',
  \   'python': '#',
  \   'ql': '//',
  \   'qmake': '#',
  \   'r': '#',
  \   'racket': ';',
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
  \   'rust': '//',
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
  \   'stylus': '//',
  \   'swig': '//',
  \   'swift': '//',
  \   'systemd': '#',
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
  \   'toml': '#',
  \   'trasys': '$',
  \   'tsalt': '//',
  \   'tsscl': '#',
  \   'tssgm': "comment = '",
  \   'txt2tags': '%',
  \   'typescript': '//',
  \   'typescriptreact': '//',
  \   'uc': '//',
  \   'uil': '!',
  \   'vb': "'",
  \   'velocity': '##',
  \   'verilog': '//',
  \   'verilog_systemverilog': '//',
  \   'vgrindefs': '#',
  \   'vhdl': '--',
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
  \   'yaml': '#',
  \   'z8a': ';',
  \   'zimbu': '#',
  \   'zsh': '#',
  \}
endfunction

" Please wrap oneline comments here
function! s:wrap_oneline() abort
  return {
  \   'aap': ['/*', '*/'],
  \   'actionscript': ['/*', '*/'],
  \   'ahk': ['/*', '*/'],
  \   'applescript': ['(*', '*)'],
  \   'arduino': ['/*', '*/'],
  \   'c': ['/*', '*/'],
  \   'cg': ['/*', '*/'],
  \   'ch': ['/*', '*/'],
  \   'clean': ['/*', '*/'],
  \   'clipper': ['/*', '*/'],
  \   'coq': ['(*', '*)'],
  \   'cpp': ['/*', '*/'],
  \   'cql': ['/*', '*/'],
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
  \   'jsx': ['{/*', '*/}'],
  \   'julia': ['#=', '=#'],
  \   'kotlin': ['/*', '*/'],
  \   'kscript': ['/*', '*/'],
  \   'lean': ['/-', '-/'],
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
  \   'pandoc': ['<!--', '-->'],
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
  \   'ql': ['/*', '*/'],
  \   'racket': ['#|', '|#'],
  \   'rc': ['/*', '*/'],
  \   'rust': ['/*', '*/'],
  \   'scala': ['/*', '*/'],
  \   'sgmldecl': ['--', '--'],
  \   'sgmllnx': ['<!--', '-->'],
  \   'slice': ['/*', '*/'],
  \   'smarty': ['{*', '*}'],
  \   'smil': ['<!', '>'],
  \   'sml': ['(*', '*)'],
  \   'swig': ['/*', '*/'],
  \   'swift': ['/*', '*/'],
  \   'systemverilog': ['/*', '*/'],
  \   'tads': ['/*', '*/'],
  \   'tsalt': ['/*', '*/'],
  \   'tsx': ['{/*', '*/}'],
  \   'typescript': ['/*', '*/'],
  \   'typescriptreact': ['/*', '*/'],
  \   'uc': ['/*', '*/'],
  \   'velocity': ['#*', '*#'],
  \   'vera': ['/*', '*/'],
  \   'verilog': ['/*', '*/'],
  \   'verilog_systemverilog': ['/*', '*/'],
  \   'xquery': ['(:', ':)'],
  \}
endfunction

" Please wrap multiline comments here
function! s:wrap_multiline() abort
  return {
  \   'arduino': {'left': '/*', 'top': '*', 'bottom': '*', 'right': '*/'},
  \   'c': {'left': '/*', 'top': '*', 'bottom': '*', 'right': '*/'},
  \   'cpp': {'left': '/*', 'top': '*', 'bottom': '*', 'right': '*/'},
  \   'perl': {'left': '#', 'top': '#', 'bottom': '#', 'right': '#'},
  \   'racket': {'left': '#|', 'top': '#', 'bottom': '#', 'right': '|#'},
  \   'ruby': {'left': '#', 'top': '#', 'bottom': '#', 'right': '#'},
  \   'swig': {'left': '/*', 'top': '*', 'bottom': '*', 'right': '*/'},
  \}
endfunction

function! s:additional_vars_begin() abort
  return {
  \ 'vim': join([
  \   'function! s:is_vim9line(lnum) abort',
  \   '  return search(''\C\m^\s*vim9s\%[cript]\>'', ''bnWz'') >= 1',
  \   'endfunction',
  \   'let b:caw_oneline_comment = { lnum -> s:is_vim9line(lnum) ? ''#'' : ''"'' }',
  \ ], "\n"),
  \}
endfunction

function! s:additional_vars_end() abort
  return {
  \ 'vim': join([
  \   'function! s:linecont_sp(lnum) abort',
  \   '  return getline(a:lnum) =~# ''^\s*\\'' ? '''' : '' ''',
  \   'endfunction',
  \   'let b:caw_hatpos_sp = function(''s:linecont_sp'')',
  \   'let b:caw_zeropos_sp = b:caw_hatpos_sp',
  \   'let b:caw_hatpos_ignore_syngroup = 1',
  \   'let b:caw_zeropos_ignore_syngroup = 1',
  \ ], "\n"),
  \ 'javascript': join([
  \   'let b:caw_search_possible_comments = 1',
  \ ], "\n"),
  \ 'typescript': join([
  \   'let b:caw_search_possible_comments = 1',
  \ ], "\n"),
  \ 'typescriptreact': join([
  \   'let b:caw_search_possible_comments = 1',
  \ ], "\n"),
  \}
endfunction


let s:root_dir = expand('<sfile>:h:h')

function! s:run() abort
  let swapfile = &swapfile
  set noswapfile
  try
    call s:write_all()
  finally
    let &swapfile = swapfile
  endtry
endfunction

function! s:sort_unique(list) abort
  let result = []
  let set = {}
  for el in sort(copy(a:list))
    if !has_key(set, el)
      let result += [el]
    endif
  endfor
  return result
endfunction

function! s:write_all() abort
  let oneline = s:oneline()
  let wrap_oneline = s:wrap_oneline()
  let wrap_multiline = s:wrap_multiline()
  let additional_vars_begin = s:additional_vars_begin()
  let additional_vars_end = s:additional_vars_end()
  let all_keys = s:sort_unique(
  \   keys(oneline) + keys(wrap_oneline) + keys(wrap_multiline)
  \     + keys(additional_vars_begin) + keys(additional_vars_end)
  \)
  for filetype in all_keys
    " Create /after/ftplugin/{filetype}/caw.vim
    let dir = s:root_dir . '/after/ftplugin/'.filetype
    silent! call mkdir(dir, 'p')
    silent edit `=dir.'/caw.vim'`
    silent %delete _
    silent read macros/after-ftplugin-template.vim
    silent 1g/^$/delete _

    " vint: -ProhibitCommandRelyOnUser
    " vint: -ProhibitCommandWithUnintendedSideEffect

    " b:caw_oneline_comment
    if has_key(oneline, filetype)
      %s@<ONELINE>@\='let b:caw_oneline_comment = '.string(oneline[filetype])@
    else
      g/<ONELINE>/d
    endif

    " b:caw_wrap_oneline_comment
    if has_key(wrap_oneline, filetype)
      %s@<WRAP_ONELINE>@\='let b:caw_wrap_oneline_comment = '.string(wrap_oneline[filetype])@
    else
      g/<WRAP_ONELINE>/d
    endif

    " b:caw_wrap_multiline_comment
    if has_key(wrap_multiline, filetype)
      %s@<WRAP_MULTILINE>@\='let b:caw_wrap_multiline_comment = '.string(wrap_multiline[filetype])@
    else
      g/<WRAP_MULTILINE>/d
    endif

    " More additional variables
    if has_key(additional_vars_begin, filetype)
      %s@<ADDITIONAL_VARS_BEGIN>@\=additional_vars_begin[filetype]@
    else
      g/<ADDITIONAL_VARS_BEGIN>/d
    endif

    " More additional variables
    if has_key(additional_vars_end, filetype)
      %s@<ADDITIONAL_VARS_END>@\=additional_vars_end[filetype]@
    else
      g/<ADDITIONAL_VARS_END>/d
    endif

    " vint: +ProhibitCommandRelyOnUser
    " vint: +ProhibitCommandWithUnintendedSideEffect

    write
  endfor
endfunction

call s:run()
