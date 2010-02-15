scriptencoding utf-8

"-----------------------------------------------------------------
" DOCUMENT {{{1
"==================================================
" Name: CommentAnyWay.vim
" Version: 1.0.0
" Author: tyru <tyru.exe@gmail.com>
" Last Change: 2009-10-01.
"
" Change Log: {{{2
"   1.0.0: Initial upload.
"   1.0.1: Fix bug that CommentAnyWay.Base.GetIndent() can't get proper indent
"   num.
" }}}2
"
"
" Usage:
"
"   COMMANDS: {{{2
"     CAOnelineComment [comment]
"         (this takes arguments 0 or 1)
"         change current one-line comment.
"         but more smarter way is using |gcv|.
"
"     CARevertComment
"         (this takes no arguments)
"         revert comment.
"   }}}2
"
"   MAPPING: {{{2
"     In normal mode:
"       If you typed digits string([1-9]) before typing these mappings,
"       behave like in visual mode.
"       so you want to see when you gave digits string, see "In visual mode".
"
"       gcc
"           if default. this is the same as |gct|.
"       gcI
"           add one-line comment to the beginning of line.
"       gci
"           add one-line comment to the beginning of non-space string(\S).
"       gca
"           add one-line comment to the end of line.
"       gcu{type}
"           type is one of 'c I i a'.
"           remove one-line comment.
"       gcw
"           add one-line comment to wrap the line.
"       gct
"           toggle comment/uncomment.
"       gcv{wrap}{action}
"           add various comment.
"       gco
"           jump(o) before add comment.
"       gcO
"           jump(O) before add comment.
"       gcmm
"           add multi-comment.
"       gcmi
"           add if statement.
"       gcmw
"           add while statement.
"       gcmf
"           add for statement.
"       gcms
"           add switch statement.
"       gcmd
"           add do ~ while statement.
"       gcmt
"           add try ~ catch statement.
"
"
"     In visual mode:
"
"       gcc
"           if default. this is the same as |gct|.
"       gcI
"           add one-line comment to the beginning of line.
"       gci
"           add one-line comment to the beginning of non-space string(\S).
"       gca
"           add one-line comment to the end of line.
"       gcu{type}
"           type is one of 'I i a w'.
"           remove one-line comment.
"       gcw
"           add one-line comment to wrap the line.
"       gct
"           toggle comment/uncomment.
"       gcv{string}
"           add various comments.
"       gcmm
"           add multi-comment.
"       gcmi
"           add if statement.
"       gcmw
"           add while statement.
"       gcmf
"           add for statement.
"       gcms
"           add switch statement.
"       gcmd
"           add do ~ while statement.
"       gcmt
"           add try ~ catch statement.
"
"       And these are default mappings.
"       you can define all mappings what you want.
"
"   }}}2
"
"   EXAMPLES: {{{2
"     If global variables are all default value...
"
"     |gcI|
"       before:
"           '   testtesttest'
"       after:
"           '#    testtesttest'
"
"     |gci|
"       before:
"           '   <- inserted here'
"       after:
"           '   # <- inserted here'
"
"     |gca|
"       before:
"           'aaaaaaa'
"       after:
"           'aaaaaaa    # '
"
"     |gcw|
"       before:
"           'aaaaaaa'
"       after:
"           '/* aaaaaaa */'
"
"     |gcv|
"       before:
"           '   some code here'
"       after:
"           you type 'gcv', and '// XXX:<CR>i'
"           '   // XXX: some code here'
"
"     |gco|
"       before:
"           '   func1();'
"       after:
"           you type 'gco', and 'func2();'
"           '   func1()'
"           '   // func2();'
"
"     |gcO|
"       before:
"           '   func1();'
"       after:
"           you type 'gcO', and 'call func1()'
"           '   // call func1()'
"           '   func1();'
"
"      multiline mappings(gcm*) insert the comments or the statements.
"
"      global variables change detailed behavior.
"      and all these mappings are also available in visual mode.
"
"    }}}2
"
"   GLOBAL VARIABLES: {{{2
"       There are two type variables(b:*** and g:***)
"       except ca_filetype_support, ca_filetype_table, ca_mapping_table,
"       g:ca_prefix.
"
"       And 'ca_ff_space', 'ca_fb_space', 'ca_bf_space', 'ca_bb_space',
"       'ca_wrap_forward', 'ca_wrap_back' will be replaced with common pattern.
"         
"         multiline :
"           '%i%': indent space.(&tabstop)
"           '%o%': b:ca_oneline_comment or g:ca_oneline_comment
"           '%^%': the line which includes this is not inserted indent.
"       and ca_oneline_comment, are not
"       replaced with that patterns.
"
"       AND DON'T USE VARIABLE WITH TODO TAG.
"
"
"
"     g:ca_filetype_table (default:read below.)
"         this variable will be deleted after Vim load this script.
"         the default structure is:
"           let s:ca_filetype_table = {
"               \ 'oneline' : {
"                   \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : '//',
"                   \ 'asm.lisp.scheme' : ';',
"                   \ 'vb'           : "'",
"                   \ 'perl.python.ruby' : '#',
"                   \ 'vim.vimperator' : '"',
"                   \ 'dosbatch'     : 'rem',
"               \ },
"               \ 'wrapline' : {
"                   \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : ['/* '  , ' */'],
"                   \ 'html'         : [ "<!-- ", " -->" ],
"               \ },
"               \ 'multiline' : {
"                   \ 'comment' : {
"                       \ 'actionscript.c.cpp.cs.d.javascript.objc' : ['/*', ' * %c%', ' */'],
"                       \ 'java' : ['/**', ' * %c%', ' */'],
"                       \ 'scheme' : ['#|', '%c%', '|#'],
"                       \ 'perl.ruby' : ['%^%=pod', '%c%', '%^%=cut'],
"                       \ 'html' : ["<!--", '%c%', '-->'],
"                   \ },
"                   \ 'if': {
"                       \ 'actionscript.c.cpp.cs.d.java.javascript.objc.perl' : ['if (%c%) {', '}'],
"                       \ 'ruby' : ['if %c%', 'end'],
"                       \ 'python' : ['if %c%:'],
"                       \ 'vim' : ['if %c%', 'endif'],
"                       \ 'dosbatch' : ['if %c% (', ')'],
"                   \ },
"                   \ 'while' : {
"                       \ 'actionscript.c.cpp.cs.d.java.javascript.objc.perl' : ['while (%c%) {', '}'],
"                       \ 'ruby' : ['while %c%', 'end'],
"                       \ 'python' : ['while %c%:'],
"                       \ 'vim' : ['while %c%', 'endwhile'],
"                   \ },
"                   \ 'for': {
"                       \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : ['for (%c%; ;) {', '}'],
"                       \ 'perl' : ['for (%c%) {', '}'],
"                       \ 'ruby' : ['for %c% in ', 'end'],
"                       \ 'python' : ['for %c% in :'],
"                       \ 'vim' : ['for %c% in', 'endfor'],
"                       \ 'dosbatch' : ['for %c% in () do (', ')'],
"                   \ },
"                   \ 'switch': {
"                       \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : ['switch (%c%) {', '}'],
"                       \ 'perl' : ['given (%c%) {', '}'],
"                       \ 'ruby' : ['case %c%', 'end'],
"                   \ },
"                   \ 'try' : {
"                       \ 'actionscript.cpp.cs.d.java' : ['try {', '} catch (%c%) {', '}'],
"                       \ 'objc' : ['@try {', '} @catch (%c%) {', '}'],
"                       \ 'vim' : ['try', 'catch %c%', 'endtry']
"                   \ },
"                   \ 'do' : {
"                       \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : ['do {', '} while (%c%);'],
"                       \ 'perl' : ['do {', '%c%', '};'],
"                   \ },
"               \ },
"           \ }
"
"     g:ca_filetype_support (default:1)
"         if false, force some variables to be set
"           ca_oneline_priority   is [0]
"           ca_multiline_priority is [0]
"         (if you feel vim's response is slow while using my plugin,
"         make this true. but no filetype comment is supported.)
"
"     g:ca_mapping_table (default:read below.)
"         this variable will be deleted after Vim load this script.
"         each map is required 'pass' and 'mode' at least.
"         the default structure is:
"           let s:ca_mapping_table = {
"               \ 'c' : {
"                   \ 'pass' : 't',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ },
"               \ 'I' : {
"                   \ 'pass' : 'I',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'i' : {
"                   \ 'pass' : 'i',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'a' : {
"                   \ 'pass' : 'a',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'w' : {
"                   \ 'pass' : 'w',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 't' : {
"                   \ 'pass' : 't',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'u' : {
"                   \ 'pass' : 'u',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'o' : {
"                   \ 'pass' : 'o',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'n',
"               \ }, 
"               \ 'O' : {
"                   \ 'pass' : 'O',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'n',
"               \ },
"               \ 'v' : {
"                   \ 'pass' : 'v',
"                   \ 'mode' : 'nv',
"               \ },
"               \ 'mm' : {
"                   \ 'pass' : 'mc',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ },
"               \ 'mc' : {
"                   \ 'pass' : 'mc',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'mi' : {
"                   \ 'pass' : 'mi',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'mw' : {
"                   \ 'pass' : 'mw',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'mf' : {
"                   \ 'pass' : 'mf',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ }, 
"               \ 'ms' : {
"                   \ 'pass' : 'ms',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ },
"               \ 'md' : {
"                   \ 'pass' : 'md',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ },
"               \ 'mt' : {
"                   \ 'pass' : 'mt',
"                   \ 'silent' : 1,
"                   \ 'mode' : 'nv',
"               \ },
"           \}
"
"
"     g:ca_prefix (default:gc)
"         the prefix of mapping.
"         example, if you did
"             let g:ca_prefix = ',c'
"         so you can add comment at the beginning of line
"         by typing ',cI' or ',ci'
"
"         my favorite mapping is '<LocalLeader>c'.
"         my g:maplocalleader is ';'. so this is the same as ';c'.
"
"     ca_oneline_comment (default:"#")
"         if couldn't find one-line comment of current filetype.
"         use this as its comment.
"
"     ca_toggle_comment (default:'i')
"         this is used when |gct| comment(or uncomment) the line.
"         if this is default, |gct| would behave like |gci| and |gcui| each line.
"
"     ca_jump_comment (default:'i')
"         this is used when |gco| or |gcO|.
"         allowed 'i', 'I'.
"
"     ca_ff_space (default:'')
"         this is added before comment when |gcI|, |gci|.
"
"     ca_fb_space (default:' ')
"         this is added after comment when |gcI|, |gci|.
"
"     ca_bf_space (default: expandtab:'    ', noexpandtab:"\t")
"         this is added before comment when |gca|.
"
"     ca_bb_space (default:' ')
"         this is added after comment when |gca|.
"
"     ca_wrap_read_indent (default:1)
"         insert comment after indent space when |gcw|.
"
"     ca_wrap_forward (default:'%o%%o%%o% ')
"         if couldn't find wrap-line comment of current filetype.
"         use this as its comment.
"         this is added before the line when |gcw|.
"
"     ca_wrap_back (default:' %o%%o%%o%')
"         if couldn't find wrap-line comment of current filetype.
"         use this as its comment.
"         this is added after the line when |gcw|.
"
"     ca_I_enter_i_if_blank (default:1)
"         when |gcI|, if normal mode, and current line is blank line,
"         enter the insert mode after the comment.
"
"     ca_i_enter_i_if_blank (default:1)
"         when |gci|, if normal mode, and current line is blank line,
"         enter the insert mode after the comment.
"
"     ca_a_enter_i (default:1)
"         enter the insert mode after the comment.
"
"     ca_wrap_enter_i (default:1)
"         when |gcw|, if normal mode,
"         enter the insert mode after the comment.
"
"     ca_i_read_indent (default:1)
"         at blank line, and normal mode,
"         insert comment after indent space when |gci|.
"
"     ca_align_forward (default:1)
"         if true, align |gci| comment.
"
"     TODO: ca_align_back (default:1)
"         if true, align |gca| comment.
"
"     TODO: ca_align_wrap (default:1)
"         if true, align |gcw| comment.
"
"     ca_multiline_insert_pos (default:'o')
"         'O': insert multi-line comment at current line, like 'O'.
"         'o': insert multi-line comment at next line, like 'o'.
"
"     ca_multicomment_visual_insert (default:1)
"         NOTE: WRITE THIS LATER.
"
"     ca_oneline_priority (default:[1, 0])
"         define priorities of the order of one-line comment.
"         0 : vim's |comments| option definition.
"         1 : my comment definition.
"         NOTE: if you do not want to my definition... just do
"           let g:ca_oneline_priority = [0]
"         but parser of |comments| might get wrong definition.
"
"     ca_multiline_priority (default:[1, 0])
"         define priorities of the order of multi-line comment.
"         0 : vim's |comments| option definition.
"         1 : my comment definition.
"         NOTE: if you do not want to my definition... just do
"           let g:ca_oneline_priority = [0]
"         but parser of |comments| might get wrong definition.
"   }}}2
"
"
"   TODO:
"     * do TODO. fix FIXME. check XXX.
"     * support comments type of
"           multi-line : '#if 0' ~ '#endif'
"       and manage many types of comments.
"     * for |gcv|, add more patterns(s:ReplacePat.[Comment/UnComment])
"       and allow user to pre-define the patterns.
"       (this is similar to :s, but fast.)
"     * add fold function.(&commentstring)
"     * Muiltiline.UnComment()
"     * user defines template string.(or the function returning it)
"     * separate filetype definitions into ~/.vim/after/ftplugin directory.
"     * if the lines include both tab and space,
"     the lines should restore original tab or space indent when uncomment.
"     * show debug msg when loading. debug msg includes which setting is
"     loaded.
"     
"   FIXME:
"     * too OO-ish...
"     * won't load defs when html...
"
"
"==================================================
" }}}1
"-----------------------------------------------------------------
" INCLUDE GUARD {{{1
if exists( 'g:loaded_comment_anyway' ) && g:loaded_comment_anyway
    finish
endif
let g:loaded_comment_anyway = 1
" }}}1
" SAVE CPO {{{1
let s:save_cpo = &cpo
set cpo&vim
" }}}1
"-----------------------------------------------------------------
" SOME UTILITY FUNCTIONS {{{1

" s:Warn( msg, ... ) {{{2
func! s:Warn( msg, ... )
    if a:0 ==# 0
        call s:EchoWith( a:msg, 'WarningMsg' )
    else
        let [msg, errID] = [a:msg, a:1]
        call s:EchoWith( 'Sorry, internal error.', 'WarningMsg' )
        call s:EchoWith( printf( "errID:%s\nmsg:%s", errID, msg ), 'WarningMsg' )
    endif
endfunc
" }}}2

" s:EchoWith( msg, hi ) {{{2
func! s:EchoWith( msg, hi )
    execute 'echohl '. a:hi
    echo a:msg
    echohl None
endfunc
" }}}2

" s:ExtendUserSetting( global_var, template ) {{{2
"   extend a:global_var if it doesn't have.
"
"   type( {} ):
"       if a:global_var has a key of template:
"           let a:global_var[key]
"               \ = s:ExtendUserSetting( g:global_var[key], a:template[key] )
"       else:
"           assign.
"   type( 0 ) or type( "" ):
"       * return a:global_var, not consider if a:global_var equals a:template.
func! s:ExtendUserSetting( global_var, template )
    if type( a:global_var ) != type( a:template )
        call s:Warn( 'type( a:global_var ) != type( a:template )', 'E001' )
        throw 'type error'
    endif

    let var = a:global_var
    if type( var ) ==# type( {} )
        " consider nests
        for i in keys( a:template )
            if has_key( var, i )
                let var[i] = s:ExtendUserSetting( var[i], a:template[i] )
            else
                let var[i] = a:template[i]
            endif
        endfor
    endif

    return var
endfunc
" }}}2

" s:GetVar( varname ) {{{2
func! s:GetVar( varname )
    for i in ['b', 'g']
        let var = i .':'. a:varname
        if exists( var )
            return deepcopy( eval( var ) )
        endif
    endfor

    let v:errmsg = printf( "Can't get variable '%s'", a:varname )
    throw 'variable error'
endfunc
" }}}2

" TODO: cache
" s:GetFileTypeDef( dict, ... ) {{{2
func! s:GetFileTypeDef( dict, ... )
    let retval = a:0 == 0 ? '' : a:1
    if &ft ==# '' | return retval | endif
    " NOTE: compound filetype is ignored.
    let cur_ftype = get( split( &ft, '\.' ), 0 )

    for key in keys( a:dict )
        for ftype in split( key, '\.' )
            if cur_ftype ==# ftype
                return deepcopy( a:dict[key] )
            endif
        endfor
    endfor
    return retval
endfunc
" }}}2

" s:FilterFileType( dict, template ) {{{2
func! s:FilterFileType( dict, template )
    let template = deepcopy( a:template )
    for key in keys( a:dict )
        " get rid of ftype(all key's filetype) from keys of a:template,
        for ftype in split( key, '\.' )
            " rename key if found ftype.
            for templ_key in keys( template )
                if index( split( templ_key, '\.' ), ftype ) != -1
                    " rename
                    let lis = filter( split( templ_key, '\.' ), 'v:val !=# ftype' )
                    if ! empty( lis )
                        let new_key_name = join( lis, '.' )
                        let template[new_key_name] = template[templ_key]
                    endif
                    unlet template[templ_key]
                endif
            endfor
        endfor
    " add key to template
    let template[key] = deepcopy( a:dict[key] )
    endfor
    return template
endfunc
" }}}2

" s:EscapeRegexp( regexp ) {{{2
func! s:EscapeRegexp( regexp )
    let regexp = a:regexp
    " escape '-' between '[' and ']'.
    let regexp = substitute( regexp, '\[[^\]]*\(-\)[^\]]*\]', '', 'g' )

    " In Perl: escape( a:regexp, '\*+.?{}()[]^$|/' )
    if &magic
        return escape( a:regexp, '\*.{[]^$|/' )
    else
        return escape( a:regexp, '\*[]^$/' )
    endif
endfunc
" }}}2
" }}}2

" s:RegisterOptions( name, type ) {{{2
func! s:RegisterOptions( name, type )
    for opt in s:Options
        if opt['name'] ==# a:name    " already registered.
            return
        endif
    endfor

    let value = eval( '&'. a:name )
    let s:Options += [ { 'name' : a:name, 'type' : a:type, 'value' : value } ]
endfunc
" }}}2

" s:RestoreOptions() {{{2
func! s:RestoreOptions()
    if ! empty( s:Options )
        for opt in s:Options
            if opt.type == 'string'
                execute printf( 'setlocal %s=%s', opt.name, opt.value )
            else
                execute printf( 'let &%s = %s', opt.name, opt.value )
            endif
        endfor
        let s:Options = []
    endif
endfunc
" }}}2

" s:InsertCommentFromMap( flag ) {{{2
func! s:InsertCommentFromMap( flag )
    let [fcomment, bcomment, wrap_forward, wrap_back]
            \ = s:CommentAnyWay.Oneline.GetOneLineComment()
    let str = ''

    if a:flag =~? 'i'  | let str .= fcomment     | endif
    if a:flag =~# 'a'  | let str .= bcomment     | endif
    if a:flag =~# 'wf' | let str .= wrap_forward | endif
    if a:flag =~# 'wb' | let str .= wrap_back    | endif

    return str
endfunc
" }}}2

func! s:ExpandTab( sp_num )
    return &expandtab ? 
        \ repeat( ' ', a:sp_num )
        \ : repeat( "\t", a:sp_num / &tabstop )
endfunc
" }}}1
"-----------------------------------------------------------------
" GLOBAL VARIABLES {{{1
" g:ca_ff_space
if ! exists( 'g:ca_ff_space' )
    let g:ca_ff_space = ''
endif
" g:ca_fb_space
if ! exists( 'g:ca_fb_space' )
    let g:ca_fb_space = ' '
endif
" g:ca_bf_space
if ! exists( 'g:ca_bf_space' )
    if &expandtab
        let g:ca_bf_space = '    '
    else
        let g:ca_bf_space = "\t"
    endif
endif
" g:ca_bb_space
if ! exists( 'g:ca_bb_space' )
    let g:ca_bb_space = ' '
endif
" g:ca_oneline_comment
if ! exists( 'g:ca_oneline_comment' )
    let g:ca_oneline_comment = "#"
endif
" g:ca_I_enter_i_if_blank
if ! exists( 'g:ca_I_enter_i_if_blank' )
    let g:ca_I_enter_i_if_blank = 1
endif
" g:ca_i_enter_i_if_blank
if ! exists( 'g:ca_i_enter_i_if_blank' )
    let g:ca_i_enter_i_if_blank = 1
endif
" g:ca_a_enter_i
if ! exists( 'g:ca_a_enter_i' )
    let g:ca_a_enter_i = 1
endif
" g:ca_wrap_enter_i
if ! exists( 'g:ca_wrap_enter_i' )
    let g:ca_wrap_enter_i = 1
endif
" g:ca_align_forward
if ! exists( 'g:ca_align_forward' )
    let g:ca_align_forward = 1
endif
" g:ca_align_back
if ! exists( 'g:ca_align_back' )
    let g:ca_align_back = 1
endif
" g:ca_align_wrap
if ! exists( 'g:ca_align_wrap' )
    let g:ca_align_wrap = 1
endif
" g:ca_verbose
if ! exists( 'g:ca_verbose' )
    let g:ca_verbose = 0
endif
" g:ca_prefix
if ! exists( 'g:ca_prefix' )
    let g:ca_prefix = 'gc'
endif
" g:ca_wrap_forward
if ! exists( 'g:ca_wrap_forward' )
    let g:ca_wrap_forward = '%o%%o%%o% '
endif
" g:ca_wrap_back
if ! exists( 'g:ca_wrap_back' )
    let g:ca_wrap_back = ' %o%%o%%o%'
endif
" g:ca_i_read_indent
if ! exists( 'g:ca_i_read_indent' )
    let g:ca_i_read_indent = 1
endif
" g:ca_wrap_read_indent
if ! exists( 'g:ca_wrap_read_indent' )
    let g:ca_wrap_read_indent = 1
endif
" ca_filetype_support
if ! exists( 'g:ca_filetype_support' )
    let g:ca_filetype_support = 1
endif
" ca_multicomment_visual_insert
if ! exists( 'g:ca_multicomment_visual_insert' )
    let g:ca_multicomment_visual_insert = 1
endif

" ca_multiline_insert_pos {{{2
if exists( 'g:ca_multiline_insert_pos' )
    if g:ca_multiline_insert_pos ==? 'o'
        call s:Warn( 'g:ca_multiline_insert_pos is allowed one of "o O".' )
        let g:ca_multiline_insert_pos = 'o'
    endif
else
    let g:ca_multiline_insert_pos = 'o'
endif
" }}}2

" g:ca_toggle_comment {{{2
if exists( 'g:ca_toggle_comment' )
    if g:ca_toggle_comment !~# '^[Iiaw]$'
        let msg = 'g:ca_toggle_comment is allowed one of "I i a w".'
        call s:Warn( msg )
        let g:ca_toggle_comment = 'i'
    endif
else
    let g:ca_toggle_comment = 'i'
endif
" }}}2

" g:ca_jump_comment {{{2
if exists( 'g:ca_jump_comment' )
    if g:ca_jump_comment !=? 'i'
        call s:Warn( 'g:ca_jump_comment is allowed "o O".' )
        let g:ca_jump_comment = 'i'
    endif
else
    let g:ca_jump_comment = 'i'
endif
" }}}2

" ca_oneline_priority {{{2
if exists( 'g:ca_oneline_priority' )
    if type( g:ca_oneline_priority ) != type( [] )
    \ || empty( g:ca_oneline_priority )
        call s:Warn( 'your g:ca_oneline_priority is not valid value. use default.' )
        let g:ca_oneline_priority = [1, 0]
    endif
else
    let g:ca_oneline_priority = [1, 0]
endif
" }}}2

" ca_multiline_priority {{{2
if exists( 'g:ca_multiline_priority' )
    if type( g:ca_multiline_priority ) != type( [] )
    \ || empty( g:ca_multiline_priority )
        call s:Warn( 'your g:ca_multiline_priority is not valid value. use default.' )
        let g:ca_multiline_priority = [1, 0]
    endif
else
    let g:ca_multiline_priority = [1, 0]
endif
" }}}2

" ca_filetype_table {{{2
" NOTE: THIS IS NOT A GLOBAL VARIABLE!!
let s:ca_filetype_table = {
    \ 'oneline' : {
        \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : '//',
        \ 'asm.lisp.scheme' : ';',
        \ 'vb'           : "'",
        \ 'perl.python.ruby' : '#',
        \ 'vim.vimperator' : '"',
        \ 'dosbatch'     : 'rem',
    \ },
    \ 'wrapline' : {
        \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : ['/* '  , ' */'],
        \ 'html'         : [ "<!-- ", " -->" ],
    \ },
    \ 'multiline' : {
        \ 'comment' : {
            \ 'actionscript.c.cpp.cs.d.javascript.objc' : ['/*', ' * %c%', ' */'],
            \ 'java' : ['/**', ' * %c%', ' */'],
            \ 'scheme' : ['#|', '%c%', '|#'],
            \ 'perl.ruby' : ['%^%=pod', '%c%', '%^%=cut'],
            \ 'html' : ["<!--", '%c%', '-->'],
        \ },
        \ 'if': {
            \ 'actionscript.c.cpp.cs.d.java.javascript.objc.perl' : ['if (%c%) {', '}'],
            \ 'ruby' : ['if %c%', 'end'],
            \ 'python' : ['if %c%:'],
            \ 'vim' : ['if %c%', 'endif'],
            \ 'dosbatch' : ['if %c% (', ')'],
        \ },
        \ 'while' : {
            \ 'actionscript.c.cpp.cs.d.java.javascript.objc.perl' : ['while (%c%) {', '}'],
            \ 'ruby' : ['while %c%', 'end'],
            \ 'python' : ['while %c%:'],
            \ 'vim' : ['while %c%', 'endwhile'],
        \ },
        \ 'for': {
            \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : ['for (%c%; ;) {', '}'],
            \ 'perl' : ['for (%c%) {', '}'],
            \ 'ruby' : ['for %c% in ', 'end'],
            \ 'python' : ['for %c% in :'],
            \ 'vim' : ['for %c% in', 'endfor'],
            \ 'dosbatch' : ['for %c% in () do (', ')'],
        \ },
        \ 'switch': {
            \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : ['switch (%c%) {', '}'],
            \ 'perl' : ['given (%c%) {', '}'],
            \ 'ruby' : ['case %c%', 'end'],
        \ },
        \ 'try' : {
            \ 'actionscript.cpp.cs.d.java' : ['try {', '} catch (%c%) {', '}'],
            \ 'objc' : ['@try {', '} @catch (%c%) {', '}'],
            \ 'vim' : ['try', 'catch %c%', 'endtry']
        \ },
        \ 'do' : {
            \ 'actionscript.c.cpp.cs.d.java.javascript.objc' : ['do {', '} while (%c%);'],
            \ 'perl' : ['do {', '%c%', '};'],
        \ },
    \ },
\ }
if exists( 'g:ca_filetype_table' )
    if g:ca_filetype_support
        try
            for [key, val] in items( g:ca_filetype_table )
                " key: 'oneline', 'wrapline', ...
                if key ==# 'multiline'
                    " val: 'comment', 'if', 'while', ...
                    for i in keys( val )
                        let g:ca_filetype_table[key][i]
                            \ = s:FilterFileType( val[i], s:ca_filetype_table[key][i])
                    endfor
                else
                    " val: 'actionscript.c.cpp ...'
                    let g:ca_filetype_table[key]
                        \ = s:FilterFileType( val, s:ca_filetype_table[key] )
                endif
            endfor
        catch /^type error$/
            call s:Warn( 'type error: g:ca_filetype_table is Dictionary. use default.' )
            let g:ca_filetype_table = s:ca_filetype_table
        endtry
    else
        " even if no support is needed,
        " user's g:ca_filetype_table remains.
        " but my definitions are not loaded.
    endif
else
    let g:ca_filetype_table = s:ca_filetype_table
endif
unlet s:ca_filetype_table

if ! g:ca_filetype_support
    let g:ca_oneline_priority   = [0]
    let g:ca_multiline_priority = [0]
endif
" }}}2

" ca_mapping_table {{{2
" NOTE: this will be unlet in s:Init().
" NOTE: THIS IS NOT A GLOBAL VARIABLE!!
let s:ca_mapping_table = {
    \ 'c' : {
        \ 'pass' : 't',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ },
    \ 'I' : {
        \ 'pass' : 'I',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'i' : {
        \ 'pass' : 'i',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'a' : {
        \ 'pass' : 'a',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'w' : {
        \ 'pass' : 'w',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 't' : {
        \ 'pass' : 't',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'u' : {
        \ 'pass' : 'u',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'o' : {
        \ 'pass' : 'o',
        \ 'silent' : 1,
        \ 'mode' : 'n',
    \ }, 
    \ 'O' : {
        \ 'pass' : 'O',
        \ 'silent' : 1,
        \ 'mode' : 'n',
    \ },
    \ 'v' : {
        \ 'pass' : 'v',
        \ 'mode' : 'nv',
    \ },
    \ 'mm' : {
        \ 'pass' : 'mc',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ },
    \ 'mc' : {
        \ 'pass' : 'mc',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'mi' : {
        \ 'pass' : 'mi',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'mw' : {
        \ 'pass' : 'mw',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'mf' : {
        \ 'pass' : 'mf',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ }, 
    \ 'ms' : {
        \ 'pass' : 'ms',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ },
    \ 'md' : {
        \ 'pass' : 'md',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ },
    \ 'mt' : {
        \ 'pass' : 'mt',
        \ 'silent' : 1,
        \ 'mode' : 'nv',
    \ },
\}
if exists( 'g:ca_mapping_table' )
    try
        let g:ca_mapping_table =
            \ s:ExtendUserSetting( g:ca_mapping_table, s:ca_mapping_table )
    catch /^type error$/
        let msg = 'type error: g:ca_mapping_table is Dictionary. use default.' 
        call s:Warn( msg )
        let g:ca_mapping_table = s:ca_mapping_table
    endtry
else
    let g:ca_mapping_table = s:ca_mapping_table
endif
unlet s:ca_mapping_table
" }}}2
" }}}1
" SCOPED VARIABLES {{{1

" NOTE: don't add these variables to s:CommentAnyWay,
" structures get so huge.(deepcopy Base to Oneline, Muiltiline)
" NOTE:
" these keys are used when looking up which class(Oneline, Muiltiline) is called.
" and values are used by Oneline.Slurp() and Muiltiline.Run().
let s:Mappings = {
    \ 'I' : ['Oneline', { 'func' : 'Comment'       , 'slurp' : 1 } ],
    \ 'i' : ['Oneline', { 'func' : 'Comment'       , 'slurp' : 1 } ],
    \ 'a' : ['Oneline', { 'func' : 'Comment'       , 'slurp' : 1 } ],
    \ 'w' : ['Oneline', { 'func' : 'Comment'       , 'slurp' : 1 } ],
    \ 't' : ['Oneline', { 'func' : 'ToggleComment' , 'slurp' : 1 } ],
    \ 'u' : ['Oneline', { 'func' : 'UnComment'     , 'slurp' : 1 } ],
    \ 'v' : ['Oneline', { 'func' : 'VariousComment' } ],
    \ 'o' : ['Oneline', { 'func' : 'JumpComment' } ],
    \ 'O' : ['Oneline', { 'func' : 'JumpComment' } ],
    \ 'mc' : [ 'Muiltiline', { 'func' : 'BuildString' } ], 
    \ 'mi' : [ 'Muiltiline', { 'func' : 'BuildString' } ], 
    \ 'mw' : [ 'Muiltiline', { 'func' : 'BuildString' } ], 
    \ 'mf' : [ 'Muiltiline', { 'func' : 'BuildString' } ], 
    \ 'ms' : [ 'Muiltiline', { 'func' : 'BuildString' } ], 
    \ 'md' : [ 'Muiltiline', { 'func' : 'BuildString' } ], 
    \ 'mt' : [ 'Muiltiline', { 'func' : 'BuildString' } ], 
\ }
let s:ReplacePat = { 'Comment': {}, 'UnComment': {} }
let s:FileType = {
    \ 'prev_filetype'   : '',
    \ 'priorities_table' : ['option', 'setting'],
    \ 'OnelineString'   : { 'setting' : {}, 'option' : {} },
    \ 'WrapString'      : { 'setting' : {} },
    \ 'MultilineString' : { 'setting' : {}, 'option' : {} },
\ }
let s:Options = []
" }}}1
"-----------------------------------------------------------------
" DEFINE DEBUG FUNC/COM IF g:ca_verbose {{{1
if g:ca_verbose
    func! s:Debug( ... )
        if a:0 ==# 0 | return | endif
        if a:1 ==? 'on'
            let g:ca_verbose = 1
        elseif a:1 ==? 'off'
            let g:ca_verbose = 0
        else
            echo eval( join( a:000, ' ' ) )
        endif
    endfunc
    command! -nargs=* CADebug   call s:Debug( <f-args> )
endif
" }}}1
"-----------------------------------------------------------------
" FUNCTION DEFINITIONS {{{1
" s:RunWithPos( pos ) range {{{2
func! s:RunWithPos( pos ) range
    if a:pos =~ '\.'
        let pos = get( split( a:pos, '\.' ), 0 )
    else
        let pos = a:pos
    endif

    let z_str  = getreg( 'z', 1 )
    let z_type = getregtype( 'z' )
    let srch_str = getreg( '/', 1 )
    let srch_type = getregtype( '/' )
    call s:RegisterOptions( 'lazyredraw', 'bool' )
    call s:RegisterOptions( 'hlsearch', 'bool' )
    setl lazyredraw
    setl nohlsearch

    let mapping = s:CommentAnyWay.Base.FindMapping( pos )
    if mapping !=# ''
        call s:CommentAnyWay[mapping].Init()
        let s:CommentAnyWay[mapping].pos       = pos
        let s:CommentAnyWay[mapping].has_range = a:firstline != a:lastline
        let s:CommentAnyWay[mapping].range     = [a:firstline, a:lastline]
        call s:CommentAnyWay[mapping].Run()
    else
        if g:ca_verbose
            call s:Warn( printf( 'no key for %s.', pos ) )
            call s:Warn( printf( 'mapping:%s', mapping ) )
        endif
    endif

    call s:RestoreOptions()
    call setreg( 'z', z_str, z_type )
    call setreg( '/', srch_str, srch_type )
endfunc
" }}}2

" BASE {{{2
let s:CommentAnyWay = {
    \ 'Base'      : { 'mappings' : {} },
    \ 'Oneline'   : {},
    \ 'Muiltiline' : {},
\ }


" s:CommentAnyWay.Base.LoadVimComments() {{{3
func! s:CommentAnyWay.Base.LoadVimComments()
    if &ft ==# '' || &comments ==# 's1:/*,mb:*,ex:*/,://,b:#,:%,:XCOMM,n:>,fb:-'
        return
    endif
    let head_sp = '0'
    let cmts_def_m = s:FileType.MultilineString.option
    let cmts_def_o = s:FileType.OnelineString.option
    let cur_ftype  = get( split( &ft, '\.' ), 0 )
    if has_key( cmts_def_m, 'comment' )
     \ && ! empty( s:GetFileTypeDef( cmts_def_m.comment, [] ) )
        " has current filetype's definition.
        " so no need to load.(cache)
        return
    else
        " make a key
        let cmts_def_m = { 'comment' : { cur_ftype : [] } }
        let cmts_def_m_templ = { cur_ftype : {} }
    endif

    " load multi comment and oneline comment
    for i in split( &comments, ',' )
        let keep_empty    = 1
        let [flags; vals] = split( i, ':', keep_empty )
        " &comments =~# '0' is 0...
        if index( split( &comments, '\zs' ), '0' ) != -1 | continue | endif

        " for dosbatch
        call filter( vals, "v:val != ''" )
        if empty( vals ) | continue | endif
        let val = vals[0]

        " for one-line comment.
        if flags == ''
            if ! has_key( cmts_def_o, cur_ftype )
                let cmts_def_o[cur_ftype] = val
            endif
        endif

        let matched = matchstr( flags, '[sme]' )
        if matched ==# '' | continue | endif

        if matched ==# 's' && flags =~# '0'
            if has_key( cmts_def_m_templ[cur_ftype], 's' )
                unlet cmts_def_m_templ[cur_ftype]['s']
            endif
            continue
        elseif matched ==# 's' && flags =~# '[1-9][0-9]*'
            let head_sp = matchstr( flags, '[1-9][0-9]*' )
        elseif matched ==# 'm' || matched ==# 'e'
            let val = repeat( ' ', head_sp ) . val
        endif
        call extend( cmts_def_m_templ[cur_ftype], { matched : val }, 'force' )
    endfor

    " set multi-comment
    for i in ['s', 'm', 'e']
        if has_key( cmts_def_m_templ[cur_ftype], i )
            let cmts_def_m.comment[cur_ftype] += [ cmts_def_m_templ[cur_ftype][i] ]
        endif
    endfor
    " cmts_def_m is not same dict as s:FileType.***.option. (Why?)
    let s:FileType.MultilineString.option = cmts_def_m
    " because the cache would work wrongly next BufEnter.
    if empty( cmts_def_m.comment[cur_ftype] ) | unlet cmts_def_m.comment | endif
endfunc
" }}}3

" s:CommentAnyWay.Base.LoadWhenBufEnter() {{{3
"   NOTE: don't return even when &ft is empty.
func! s:CommentAnyWay.Base.LoadWhenBufEnter()
    if &ft == ''
        let b:ca_oneline_comment = g:ca_oneline_comment
        let s:FileType.prev_filetype = ''
    else
        let cur_ftype = get( split( &ft, '\.' ), 0 )
        if cur_ftype !=# '' && cur_ftype ==# s:FileType.prev_filetype
            " cache
            return
        endif
        let s:FileType.prev_filetype = cur_ftype
    endif

    call s:CommentAnyWay.Base.LoadVimComments()    " load vim's 'comments' option.(for one or multi)
    for type in ['Oneline', 'Muiltiline']
        call s:CommentAnyWay[type].LoadDefinitions()    " rebuild replace regexp.
    endfor
endfunc
" }}}3

" s:CommentAnyWay.Base.FindMapping( mapkey ) {{{3
func! s:CommentAnyWay.Base.FindMapping( mapkey )
    for type in ['Oneline', 'Muiltiline']
        if has_key( s:CommentAnyWay[type], 'mappings' )
        \ && has_key( s:CommentAnyWay[type].mappings, a:mapkey )
            return type
        endif
    endfor

    return ''
endfunc
" }}}3

" s:CommentAnyWay.Base.EnterInsertMode( prev_line ) dict {{{3
func! s:CommentAnyWay.Base.EnterInsertMode( prev_line ) dict
    let is_blankline = a:prev_line =~# '^\s*$'

    " insert at tail of current line when calling CommentOneLine()
    if self.pos ==# 'I'
        if is_blankline && s:GetVar( 'ca_I_enter_i_if_blank' )
            startinsert!
        endif
    elseif self.pos ==# 'i'
        if is_blankline && s:GetVar( 'ca_i_enter_i_if_blank' )
            startinsert!
        endif
    elseif self.pos ==# 'a'
        if s:GetVar( 'ca_a_enter_i' )
            startinsert!
        endif
    elseif self.pos ==# 'w' && is_blankline
        if s:GetVar( 'ca_wrap_enter_i' )
            let exec = '^'
            let len = strlen( s:CommentAnyWay.Oneline.GetOneLineComment()[2] )    " wrap_forward
            let exec .= len == 0    ? '' : len .'l'
            let exec .= 'i'
            call feedkeys( exec, 'n' )
        endif
    elseif self.pos =~# '^m'    " multi-comment
        normal! j
        if search( '%c%', 'Wbc' )
            " normal! v2l"_d
            " call feedkeys( 'a', 'n' )
            call feedkeys( 'v2l"_c', 'n' )
        endif
    endif
endfunc
" }}}3

" s:CommentAnyWay.Base.GetIndent( lnum ) dict {{{3
func! s:CommentAnyWay.Base.GetIndent( lnum ) dict
    let ftypes = split( &filetype, '\.' )

    if ! empty( filter( ftypes, 'v:val ==# "c" || v:val ==# "cpp"' ) )
        let indent = cindent( a:lnum )
    elseif ! empty( filter( ftypes, 'v:val ==# "lisp" || v:val ==# "scheme"' ) )
        " NOTE: DON'T CALL ME AFTER INSERTING SOME STRINGS.
        " THIS UNDOES THAT BEHAVIOR.
        call s:RegisterOptions( 'autoindent', 'bool' )
        execute "normal! o \<Esc>x"
        let indent = indent( a:lnum )
        silent undo
    else
        let indent = cindent( a:lnum )
        if indent != indent( a:lnum ) && getline( a:lnum ) !~ '^\s*$' 
            let indent = indent( a:lnum )
        endif
    endif

    return indent
endfunc
" }}}3
" }}}2

" ONELINE COMMENT {{{2
let s:CommentAnyWay.Oneline = copy( s:CommentAnyWay.Base )


" s:CommentAnyWay.Oneline.Init() dict {{{3
func! s:CommentAnyWay.Oneline.Init() dict
    let self.pos            = ''
    let self.lnum           = 0
    let self.range          = []
    let self.head_space     = ''
    let self.MAX_SRCH_LINES = 100
    let self.has_range      = 0

    let self.uncomment_pos  = ''
endfunc
" }}}3

" s:CommentAnyWay.Oneline.Run() dict {{{3
func! s:CommentAnyWay.Oneline.Run() dict
    " save current line status.
    let prev_line = getline( self.range[0] )
    " get ca_align_forward
    " align comment position when 'gci'.
    if self.pos ==# 'i' && ( s:GetVar( 'ca_align_forward' ) || ! self.has_range && s:GetVar( 'ca_i_read_indent' ) )
        let self.head_space = s:ExpandTab( self.GetIndent( self.range[0] ) )
    elseif self.pos ==# 'w' && s:GetVar( 'ca_wrap_read_indent' )
        let self.head_space = s:ExpandTab( self.GetIndent( self.range[0] ) )
    else
        let self.head_space = ''
    endif

    " check uncomment pos.
    if self.pos ==# 'u'
        let self.uncomment_pos = nr2char( getchar() )    " get pos.
        if ! has_key( s:ReplacePat.UnComment, self.uncomment_pos )
            return
        endif
    " check comment pos.
    elseif ! has_key( self.mappings, self.pos )
        let errmsg = "s:Comment(): Unknown comment position '". self['pos'] ."'."
        call s:Warn( errmsg, 'E002' )
        return
    endif

    let map = self.mappings[self.pos]
    if has_key( map, 'slurp' ) && map.slurp
        " process all the lines.
        call self.Slurp()
    else
        " for JumpComment(), VariousComment().
        let func = self.mappings[self.pos].func
        if type( func ) == type( "" )
            call self[func]()
        elseif type( func ) == type( function( 'tr' ) )
            call func( self )    " XXX: work?
        endif
    endif

    if ! self.has_range
        call self.EnterInsertMode( prev_line )
    endif
endfunc
" }}}3

" s:CommentAnyWay.Oneline.Slurp() dict {{{3
func! s:CommentAnyWay.Oneline.Slurp() dict
    let func = self.mappings[self.pos].func

    for self.lnum in range( self.range[0], self.range[1] )
        let line     = getline( self.lnum )
        if type( func ) == type( "" )
            let replaced = self[func]()
        elseif type( func ) == type( function( 'tr' ) )
            let replaced = func( deepcopy( self ) )    " XXX
        endif
        if line != replaced | call setline( self.lnum, replaced ) | endif
    endfor
endfunc
" }}}3

" TODO: Align comment in case 'a'
" s:CommentAnyWay.Oneline.Comment() dict {{{3
func! s:CommentAnyWay.Oneline.Comment() dict
    let comment        = s:ReplacePat.Comment
    let line           = getline( self.lnum )
    let is_blankline   = line =~# '^\s*$'
    let is_i_align_cmt = self.pos ==# 'i' && ( s:GetVar( 'ca_align_forward' ) || ( ! self.has_range && s:GetVar( 'ca_i_read_indent' ) ) )

    if is_i_align_cmt
        let line = substitute( line, '^'. self.head_space, '', '')
        let line = substitute( line, comment['I'][0], comment['I'][1], '' )
        let line = self.head_space . line
    elseif self.pos ==# 'w' && s:GetVar( 'ca_wrap_read_indent' )
        let line = substitute( line, comment[self.pos][0], comment[self.pos][1], '' )
        if is_blankline
            let line = self.head_space . line
        endif
    else
        let line = substitute( line, comment[self.pos][0], comment[self.pos][1], '' )
    endif

    return line
endfunc
" }}}3

" s:CommentAnyWay.Oneline.UnComment() dict {{{3
func! s:CommentAnyWay.Oneline.UnComment() dict
    if ! has_key( s:ReplacePat.UnComment, self.uncomment_pos )
        call s:Warn( self.uncomment_pos ."Can't uncomment.", 'E003' )
    endif
    let uncomment = s:ReplacePat.UnComment[self.uncomment_pos]
    return substitute( getline( self.lnum ), uncomment[0], uncomment[1], '' )
endfunc
" }}}3

" s:CommentAnyWay.Oneline.ToggleComment() dict {{{3
func! s:CommentAnyWay.Oneline.ToggleComment() dict
    let self.pos           = s:GetVar( 'ca_toggle_comment' )
    let self.uncomment_pos = s:GetVar( 'ca_toggle_comment' )
    let self.head_space    = s:ExpandTab( self.GetIndent( self.lnum ) )

    if self.IsCommentedLine()
        return self.UnComment()
    else
        return self.Comment()
    endif
endfunc
" }}}3

" s:CommentAnyWay.Oneline.IsCommentedLine() dict {{{3
func! s:CommentAnyWay.Oneline.IsCommentedLine() dict
    let line = getline( self.lnum )
    let uncomment = s:ReplacePat.UnComment

    for i in ['I', 'i', 'a', 'w']
        if ! has_key( uncomment, i ) | continue | endif
        if matchstr( line, uncomment[i][0] ) !=# ''
            return 1
        endif
    endfor
    return 0
endfunc
" }}}3

" TODO: add more action (XXX:current support 'I', 'i')
" s:CommentAnyWay.Oneline.JumpComment() dict {{{3
func! s:CommentAnyWay.Oneline.JumpComment() dict
    let vect = self.pos

    " get comment pos.
    let pos = s:GetVar( 'ca_jump_comment' )


    call s:RegisterOptions( 'autoindent', 'bool' )
    setl ai

    call feedkeys( vect, 'n' )    " jump.
    if pos !=# 'i' || ! s:GetVar( 'ca_align_forward' )
        call feedkeys( "\<Esc>0C", 'n' )
    endif

    call feedkeys( "\<Plug>InsertComment_i", 'm' )    " call s:InsertCommentFromMap( 'i' )
endfunc
" }}}3

" s:CommentAnyWay.Oneline.VariousComment() dict {{{3
func! s:CommentAnyWay.Oneline.VariousComment() dict
    " save values.
    call inputsave()
    let def = s:GetVar( 'ca_oneline_comment' )
    call s:RegisterOptions( 'eventignore', 'string' )
    call s:RegisterOptions( 'filetype', 'string' )
    setl eventignore=all
    " LoadDefinitions() don't load any filetype definition.
    setl ft=

    " input comment string.
    let input_str = input( 'set definition:' )
    if input_str ==# '' | return | endif
    let b:ca_oneline_comment = input_str
    call self.LoadDefinitions()

    " input comment type.
    echon 'comment type:'
    let key = nr2char( getchar() )
    if key ==# "\<CR>" || key ==# "\<Esc>"
        return
    endif
    if self.FindMapping( key ) !=# 'Oneline' || key ==# 'v'
        return
    endif
    let self.pos = key
    call self.Run()

    " restore
    let b:ca_oneline_comment = def

    " reload filetype definition.
    call s:RestoreOptions()    " for loading definition.
    call self.LoadDefinitions()
    call inputrestore()
endfunc
" }}}3

" s:CommentAnyWay.Oneline.GetOneLineComment() {{{3
func! s:CommentAnyWay.Oneline.GetOneLineComment()
    let ff_space        = s:GetVar( 'ca_ff_space' )
    let fb_space        = s:GetVar( 'ca_fb_space' )
    let bf_space        = s:GetVar( 'ca_bf_space' )
    let bb_space        = s:GetVar( 'ca_bb_space' )
    let wrap_forward    = s:GetVar( 'ca_wrap_forward' )
    let wrap_back       = s:GetVar( 'ca_wrap_back' )
    let oneline_comment = s:GetVar( 'ca_oneline_comment' )

    " set filetype comment if exists.
    if &ft != ''
        """ NOTE: if no comment definition, just use upper value.
        " set one-line comment string.(e.g.: '"' when filetype is 'vim')
        let table = s:FileType.priorities_table
        for order in s:GetVar( 'ca_oneline_priority' )
            let cmts_def = s:FileType.OnelineString[ table[order] ]
            if s:GetFileTypeDef( cmts_def, '' ) != ''
                let oneline_comment = s:GetFileTypeDef( cmts_def )
                " IMPORTANT.
                break
            endif
        endfor
        " set wrap-line comment string.
        let cmts_def = s:FileType.WrapString.setting
        let def = s:GetFileTypeDef( cmts_def, [] )
        if ! empty( def )
            let [wrap_forward, wrap_back] = def
        endif
    endif

    " build commented string for searching its commented line.
    let fcomment = ff_space . oneline_comment . fb_space
    let bcomment = bf_space . oneline_comment . bb_space

    for i in ['fcomment', 'bcomment', 'wrap_forward', 'wrap_back']
        " %o% -> oneline_comment
        let fmt = 'let %s = substitute( %s, "%%o%%", oneline_comment, "g" )'
        execute printf( fmt, i, i )
    endfor

    return [fcomment, bcomment, wrap_forward, wrap_back]
endfunc
" }}}3

" s:CommentAnyWay.Oneline.LoadDefinitions() {{{3
func! s:CommentAnyWay.Oneline.LoadDefinitions()
    let oneline_comment = s:GetVar( 'ca_oneline_comment' )
    let [fcomment, bcomment, wrap_forward, wrap_back] = self.GetOneLineComment()
    let fescaped     = s:EscapeRegexp( fcomment )
    let bescaped     = s:EscapeRegexp( bcomment )

    let s:ReplacePat.Comment['I']
                \ = [ '^',
                \     fescaped ]
    let s:ReplacePat.UnComment['I']
                \ = [ '^'. fescaped,
                \     '' ]
    let s:ReplacePat.Comment['i']
                \ = [ '^\(\s*\)',
                \     '\1'. fescaped ]
    let s:ReplacePat.UnComment['i']
                \ = [ '^\(\s\{-}\)'. fescaped,
                \     '\1' ]
    let s:ReplacePat.Comment['a']
                \ = [ '$',
                \      bescaped ]
    let s:ReplacePat.UnComment['a']
                \ = [ bescaped .'[^'. oneline_comment .']*$',
                \     '' ]
    let fescaped = s:EscapeRegexp( wrap_forward )
    let bescaped = s:EscapeRegexp( wrap_back )
    let s:ReplacePat.Comment['w']
                \ = [ '^\(\s*\)\(.*\)$',
                \     '\1'. fescaped .'\2'. bescaped ]
    let s:ReplacePat.UnComment['w']
                \ = [ fescaped .'\(.*\)'. bescaped,
                \     '\1' ]
endfunc
" }}}3

" s:CommentAnyWay.Oneline.ChangeOnelineComment( ... ) {{{3
func! s:CommentAnyWay.Oneline.ChangeOnelineComment( ... )
    if a:0 ==# 1
        let b:ca_oneline_comment = a:1
    else
        let oneline_comment = input( 'oneline comment:' )
        if oneline_comment !=# ''
            let b:ca_oneline_comment = oneline_comment
        else
            call s:EchoWith( 'not changed.', 'MoreMsg' )
            return
        endif
    endif

    let save_ft = &ft
    setl ft=
    call s:CommentAnyWay.Oneline.LoadDefinitions()    " rebuild comment string.
    let &ft = save_ft

    if b:ca_oneline_comment ==# '"'
        call s:EchoWith( "changed to '". b:ca_oneline_comment ."'.", 'ModeMsg' )
    else
        call s:EchoWith( 'changed to "'. b:ca_oneline_comment .'".', 'ModeMsg' )
    endif
endfunc
" }}}3
" }}}2

" MULTI COMMENT {{{2
let s:CommentAnyWay.Muiltiline = copy( s:CommentAnyWay.Base )


" s:CommentAnyWay.Muiltiline.Init() dict {{{3
func! s:CommentAnyWay.Muiltiline.Init() dict
    let self.pos            = ''
    let self.lnum           = 0
    let self.range          = []
    let self.head_space     = ''
    let self.MAX_SRCH_LINES = 100
    let self.has_range      = 0

    let self.range_buffer   = ''
endfunc
" }}}3

" s:CommentAnyWay.Muiltiline.LoadDefinitions() dict {{{3
func! s:CommentAnyWay.Muiltiline.LoadDefinitions() dict
    " Nop.
endfunc
" }}}3

" s:CommentAnyWay.Muiltiline.Run() dict {{{3
func! s:CommentAnyWay.Muiltiline.Run() dict
    let func = self.mappings[self.pos].func
    if type( func ) == type( "" ) && ! has_key( self, self.mappings[self.pos].func )
        let fmt = "not implemented yet '%s'..."
        call s:Warn( printf( fmt, self.pos ) )
        return
    endif

    " range
    if self.has_range
        for lnum in range( self.range[0], self.range[1] )
            if self.range_buffer ==# ''
                let self.range_buffer = getline( lnum )
            else
                let self.range_buffer .= "\n". getline( lnum )
            endif
        endfor
    endif

    if type( func ) == type( "" )
        let cmt_lis = self[func]()
    elseif type( func ) == type( function( 'tr' ) )
        let cmt_lis = func( self )    " XXX: work?
    endif
    if empty( cmt_lis )
        call s:Warn( 'no definition found...' )
        return
    endif

    let ins_pos = s:GetVar( 'ca_multiline_insert_pos' )
    if self.has_range
        let sp_num = self.GetIndent( line( '.' ) )
    elseif ins_pos ==# 'o'
        let sp_num = self.GetIndent( line( '.' ) + 1 )
    elseif ins_pos ==# 'O'
        let sp_num = self.GetIndent( line( '.' ) )
    endif
    let indent_space = s:ExpandTab( sp_num )


    if ! self.has_range
        call self.InsertString( cmt_lis, ins_pos, indent_space )
        call self.EnterInsertMode( "" )
    else

        " delete selected lines and copy into register.
        let diff = self.range[1] - self.range[0]
        execute printf( 'normal! `<V'.'%s'.'"zd', diff == 0 ? '' : diff .'j' )

        " delete the minimum indent space of the lines.
        let ins_lines =
            \ map( split( @z, "\n" ), 'substitute( v:val, indent_space, "", "" )' )
        " add 1-indent space.
        let ins_sp = s:ExpandTab( &tabstop )
        call map( ins_lines, 'ins_sp . v:val' )

        " build and insert comment string.
        let cmt_lis = [ cmt_lis[0] ] + ins_lines + cmt_lis[1:]
        if s:GetVar( 'ca_multicomment_visual_insert' )
            " do not insert the line including '%c%'.
            call filter( ins_lines, 'v:val !~# "%c%"' )
        endif
        call self.InsertString( cmt_lis, 'O', indent_space )

        call self.EnterInsertMode( "" )
    endif
endfunc
" }}}3

" s:CommentAnyWay.Muiltiline.InsertString( str_lines, pos, ins_space ) dict {{{3
func! s:CommentAnyWay.Muiltiline.InsertString( str_lines, pos, ins_space ) dict
    " get rid of %^%. and flag turns off if found %^%.
    let insert_indent = 1
    let lines = []
    for line in deepcopy( a:str_lines )
        if line =~# '%^%'
            let line = substitute( line, '%^%', '', 'g' )
            let insert_indent = 0
        endif
        if line =~ "\n"
            let lines += split( line, "\n", 1 )
        else
            let lines += [ line ]
        endif
    endfor

    " build inserted string
    let ins_space = insert_indent ? a:ins_space : ''
    let lines  = map( lines, 'ins_space . v:val' )

    let @z         = join( lines, "\n" )
    call s:RegisterOptions( 'paste', 'bool' )
    setl paste

    " insert
    if exists( ':AutoComplPopLock' )   | AutoComplPopLock   | endif
    if a:pos ==# 'o'
        silent put z
    else
        silent put! z
    endif
    if exists( ':AutoComplPopUnLock' ) | AutoComplPopUnlock | endif

    " restore
endfunc
" }}}3

" s:CommentAnyWay.Muiltiline.BuildString() {{{3
func! s:CommentAnyWay.Muiltiline.BuildString()
    let table       = s:FileType.priorities_table
    let result_lis  = []
    let debug       = []

    " set type of inserted string.
    " TODO: user defines template freely.
    " (make g:***_table and its structure
    " is { 'mc' : 'comment', 'mi' : 'if', ... })
    if self.pos ==# 'mc'
        let type = 'comment'
    elseif self.pos ==# 'mi'
        let type = 'if'
    elseif self.pos ==# 'mw'
        let type = 'while'
    elseif self.pos ==# 'mf'
        let type = 'for'
    elseif self.pos ==# 'ms'
        let type = 'switch'
    elseif self.pos ==# 'md'
        let type = 'do'
    elseif self.pos ==# 'mt'
        let type = 'try'
    endif


    for order in s:GetVar( 'ca_multiline_priority' )
        " cmts_def:
        " e.g.: { 'cpp': { 'comment' : [ '/*', ' * %c%', ' */' ], ... }, ... }
        let cmts_def = s:FileType.MultilineString[ table[order] ]
        if has_key( cmts_def, type ) && ! empty( s:GetFileTypeDef( cmts_def[type], [] ) )
            " not deepcopy(or copy), indent increasing each time.
            let lines = s:GetFileTypeDef( cmts_def[type] )

            " %i% -> indent space
            let i = 0
            let space = s:ExpandTab( &tabstop )
            while i < len( lines )
                let fmt = 'let %s = substitute( %s, "%%i%%", space, "g" )'
                execute printf( fmt, 'lines[i]', 'lines[i]' )
                let i = i + 1
            endwhile

            return lines 
        endif
    endfor
endfunc
" }}}3
" }}}2
" }}}1
"-----------------------------------------------------------------
" AUTOCOMMAND {{{1
augroup CSBufEnter
    autocmd!
    autocmd BufEnter,FileType *   call s:CommentAnyWay.Base.LoadWhenBufEnter()
augroup END
" }}}1
"-----------------------------------------------------------------
" COMMANDS {{{1
command! -nargs=?           CAOnelineComment
            \ call s:CommentAnyWay.Oneline.ChangeOnelineComment( <f-args> )
command!                    CARevertComment
            \ if exists( 'b:ca_oneline_comment' ) |
            \     unlet b:ca_oneline_comment |
            \ endif |
            \ call s:CommentAnyWay.Oneline.LoadDefinitions()
" }}}1
"-----------------------------------------------------------------
" MAPPINGS {{{1
" see s:Init().
" }}}1
"-----------------------------------------------------------------
" INITIALIZE {{{1
func! s:Init()
    " user's(and my) settings of filetype.
    if has_key( g:ca_filetype_table, 'oneline' )
        let s:FileType.OnelineString.setting
                    \ = deepcopy( g:ca_filetype_table.oneline )
    endif
    if has_key( g:ca_filetype_table, 'wrapline' )
        let s:FileType.WrapString.setting
                    \ = deepcopy( g:ca_filetype_table.wrapline )
    endif
    if has_key( g:ca_filetype_table, 'multiline' )
        let s:FileType.MultilineString.setting
                    \ = deepcopy( g:ca_filetype_table.multiline )
    endif
    unlet g:ca_filetype_table

    " mappings
    for [mapkey, map] in items( g:ca_mapping_table )
        if ! has_key( map, 'pass' ) || ! has_key( map, 'mode' )
            call s:Warn( 'missing a few keys in g:ca_mapping_table["'. mapkey .'"]' )
            continue
        endif
        if ! has_key( s:Mappings, map.pass )
            call s:Warn( 'no function found for mapping %s.' )
            continue
        endif

        " map each mode.
        for mode in split( map.mode, '\zs' )
            if has_key( map, 'silent' ) && map.silent
                let silent = '<silent>'
            else
                let silent = ''
            endif
            execute printf( '%snoremap <unique>%s %s :call <SID>RunWithPos( "%s" )<CR>', mode, silent, g:ca_prefix . mapkey, map.pass .'.'. mode )
        endfor

        let [class, mappings] = s:Mappings[map.pass]
        let dest_obj = s:CommentAnyWay[class]
        let dest_obj.mappings[map.pass] = mappings
    endfor
    unlet s:Mappings
    unlet g:ca_mapping_table

    " map no mapped the map to <Plug>***.
    " (to check indent num of current line)
    inoremap <silent><expr>
        \ <Plug>InsertComment_i    <SID>InsertCommentFromMap( "i" )

    " set comment string.
    call s:CommentAnyWay.Base.LoadWhenBufEnter()
endfunc

call s:Init()
" }}}1
"-----------------------------------------------------------------
" RESTORE CPO {{{1
let &cpo = s:save_cpo
" }}}1
"-----------------------------------------------------------------
" vim:fdm=marker:fen:
