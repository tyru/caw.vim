" vim:foldmethod=marker:fen:
scriptencoding utf-8

let s:installed_repeat_vim = (globpath(&runtimepath, 'autoload/repeat.vim') !=# '')
let s:installed_context_filetype = (globpath(&runtimepath, 'autoload/context_filetype.vim') !=# '')
let s:installed_ts_context_commentstring = (globpath(&runtimepath, 'plugin/ts_context_commentstring.vim') !=# '')
let s:op_args = ''
let s:op_doing = 0


"caw#keymapping_stub(): All keymappings are bound to this function. {{{
" Call actions' methods until it succeeded
" (currently seeing b:changedtick but it is bad idea)
function! caw#keymapping_stub(mode, action, method) abort
  " Skip indent.
  " Because some filetypes detect commented/uncommented on current line's syntax group.
  if col('.') < indent('.') + 1
    normal! ^
  endif

  " When integration == 'context_filetype'
  "   Load comment string from the context filetype
  " When integration == 'ts_context_commentstring'
  "   Load comment string from ts_context_commentstring plugin
  " When integration == ''
  "   No additional setup will be done
  let integration = s:get_integrated_plugin()

  " Context filetype support.
  " https://github.com/Shougo/context_filetype.vim
  if integration ==# 'context_filetype'
    let conft = context_filetype#get_filetype()
  else
    let conft = &l:filetype
  endif

  " Set up context.
  let context = {}
  let context.filetype = &l:filetype
  let context.context_filetype = conft
  let context.mode = a:mode
  let context.visualmode = visualmode()
  if a:mode ==# 'n'
    if v:count ==# 0
      let context.firstline = line('.')
      let context.lastline  = line('.')
    else
      let context.firstline = line('.')
      let context.lastline  = line('.') + v:count - 1
      let context.mode = 'x'
      let context.visualmode = 'V'
    endif
  else
    let context.firstline = line("'<")
    let context.lastline  = line("'>")
  endif
  call caw#set_context(context)

  if integration ==# 'ts_context_commentstring'
    let ts_cms = luaeval('require("ts_context_commentstring.internal").calculate_commentstring()')
    if ts_cms !=# &l:commentstring
      let l:UndoVariables = caw#update_comments_from_commentstring(ts_cms)
    else
      let l:UndoVariables = {-> 'nop'}
    endif
  elseif conft !=# &l:filetype
    call caw#load_ftplugin(conft)
  endif

  try
    let actions = [caw#new('actions.' . a:action)]

    " TODO:
    " - Deprecate g:caw_find_another_action and
    " Implement <Plug>(caw:dwim) like Emacs's dwim-comment
    " - Stop checking b:changedtick and
    " let act[a:method] just return changed lines,
    " not modifying buffer.
    if caw#get_var('caw_find_another_action')
      let actions += map(
      \   copy(get(actions[0], 'fallback_types', [])),
      \   'caw#new("actions." . v:val)')
    endif

    for act in actions
      let old_changedtick = b:changedtick
      if has_key(act, 'comment_database')
      \   && empty(act.comment_database.get_comments())
        continue
      endif

      call act[a:method]()

      " FIXME: Should check by return value of `act[a:method]()`
      if b:changedtick !=# old_changedtick
        break
      endif
    endfor
  catch
    echohl ErrorMsg
    echomsg '[' . v:exception . ']::[' . v:throwpoint . ']'
    echohl None
  finally
    if integration ==# 'ts_context_commentstring'
      call l:UndoVariables()
    elseif conft !=# &l:filetype
      call caw#load_ftplugin(&l:filetype)
    endif
    " Free context.
    call caw#set_context({})
    " repeat.vim support
    if s:installed_repeat_vim && !s:op_doing
      let lines = context.lastline - context.firstline
      execute 'nnoremap <Plug>(caw:__op_select__)'
      \       (lines > 0 ? 'V' . lines . 'j' : '<Nop>')
      let lastmap = printf(
      \   "\<Plug>(caw:__op_select__)\<Plug>(caw:%s:%s)",
      \   a:action, a:method
      \)
      call repeat#set(lastmap)
    endif
  endtry
endfunction

" Returns "context_filetype" or "ts_context_commentstring" or ""
function! s:get_integrated_plugin() abort
  let integration = caw#get_var('caw_integrated_plugin')
  if integration ==# 'context_filetype'
    if !s:installed_context_filetype
      echohl ErrorMsg
      echomsg 'Shougo/context_filetype.vim is not installed!'
      echohl None
      return ''
    endif
    return 'context_filetype'
  elseif integration ==# 'ts_context_commentstring'
    if !s:installed_ts_context_commentstring
      echohl ErrorMsg
      echomsg 'JoosepAlviste/nvim-ts-context-commentstring is not installed!'
      echohl None
      return ''
    endif
    return 'ts_context_commentstring'
  elseif s:installed_context_filetype
    return 'context_filetype'
  elseif s:installed_ts_context_commentstring
    return 'ts_context_commentstring'
  else
    return ''
  endif
endfunction

function! caw#keymapping_stub_deprecated(mode, action, method, old_action) abort
  let oldmap = printf('<Plug>(caw:%s:%s)', a:old_action, a:method)
  let newmap = printf('<Plug>(caw:%s:%s)', a:action, a:method)
  echohl WarningMsg
  echomsg oldmap . ' was deprecated. please use ' . newmap . ' instead.'
  echohl None

  return caw#keymapping_stub(a:mode, a:action, a:method)
endfunction


function! caw#__operator_init__(action, method) abort
  let s:op_args = a:action . ':' . a:method
endfunction

function! caw#__do_operator__(motion_wise) abort
  let s:op_doing = 1
  try
    if a:motion_wise ==# 'char'
      execute "normal `[v`]\<Plug>(caw:" . s:op_args . ')'
    else
      execute "normal `[V`]\<Plug>(caw:" . s:op_args . ')'
    endif
  finally
    let s:op_doing = 0
  endtry
endfunction

" }}}

" Context: context while invoking keymapping. {{{
let s:context = {}

function! caw#set_context(context) abort
  unlockvar! s:context
  let s:context = a:context
  lockvar! s:context
endfunction

function! caw#context() abort
  return copy(s:context)
endfunction
" }}}

" Utilities: Misc. functions. {{{

function! caw#get_related_filetypes(ft) abort
  if s:get_integrated_plugin() !=# 'context_filetype'
    return []
  endif
  let filetypes = get(context_filetype#filetypes(), a:ft, [])
  let dup = {a:ft : 1}
  let related = []
  for ft in map(copy(filetypes), 'v:val.filetype')
    if !has_key(dup, ft)
      let related += [ft]
      let dup[ft] = 1
    endif
  endfor
  return related
endfunction

function! caw#assert(cond, msg) abort
  if !a:cond
    throw 'caw: assertion failure: ' . a:msg
  endif
endfunction

function! caw#get_var(varname, ...) abort
  for ns in [b:, w:, t:, g:]
    if has_key(ns, a:varname)
      if a:0 > 1 && type(ns[a:varname]) is# type(function('function'))
        return call(ns[a:varname], a:2)
      endif
      return ns[a:varname]
    endif
  endfor
  if a:0
    return a:1
  else
    call caw#assert(0, 'caw#get_var(' . string(a:varname) . '):'
    \                . ' this must be reached!')
  endif
endfunction


function! caw#get_inserted_indent(lnum) abort
  return matchstr(getline(a:lnum), '^\s\+')
endfunction

function! s:get_inserted_indent_num(lnum) abort
  return strlen(caw#get_inserted_indent(a:lnum))
endfunction

function! caw#make_indent_str(indent_byte_num) abort
  return repeat((&expandtab ? ' ' : "\t"), a:indent_byte_num)
endfunction


if exists('*uniq')
  function! caw#uniq(list) abort
    return uniq(a:list)
  endfunction
else
  function! caw#uniq(list) abort
    if len(a:list) <=# 1
      return a:list
    endif
    let results = [a:list[0]]
    for l:V in a:list[1:]
      if string(results[-1]) !=# string(l:V)
        let results += [l:V]
      endif
    endfor
    return results
  endfunction
endif

function! caw#uniq_keep_order(list) abort
  if len(a:list) <=# 1
    return a:list
  endif
  let dup = {}
  let results = [a:list[0]]
  for l:V in a:list[1:]
    let id = string(l:V)
    if !has_key(dup, id)
      let results += [l:V]
      let dup[id] = 1
    endif
  endfor
  return results
endfunction

if exists('*trim')
  function! caw#trim(str) abort
    return trim(a:str)
  endfunction
else
  function! caw#trim(str) abort
    let str = a:str
    let str = substitute(str, '^\s\+', '', '')
    let str = substitute(str, '\s\+$', '', '')
    return str
  endfunction
endif

function! caw#trim_left(str) abort
  return substitute(a:str, '^\s\+', '', '')
endfunction

function! caw#trim_right(str) abort
  return substitute(a:str, '\s\+$', '', '')
endfunction


function! caw#replace_line(lnum, line) abort
  if a:line !=# getline(a:lnum)
    call setline(a:lnum, a:line)
  endif
endfunction

function! caw#replace_lines(start, end, lines) abort
  if a:lines !=# getline(a:start, a:end)
    call setline(a:start, a:lines)
  endif
endfunction

function! caw#get_min_indent_num(skip_blank_line, from_lnum, to_lnum) abort
  let min_indent_num = 1/0
  for lnum in range(a:from_lnum, a:to_lnum)
    if a:skip_blank_line && getline(lnum) =~# '^\s*$'
      continue    " Skip blank line.
    endif
    let n = s:get_inserted_indent_num(lnum)
    if n < min_indent_num
      let min_indent_num = n
    endif
  endfor
  return min_indent_num
endfunction

function! caw#get_both_sides_space_cols(skip_blank_line, from_lnum, to_lnum) abort
  let left  = 1/0
  let right = 1
  for line in getline(a:from_lnum, a:to_lnum)
    if a:skip_blank_line && line =~# '^\s*$'
      continue    " Skip blank line.
    endif
    let l = strlen(matchstr(line, '^\s*')) + 1
    let r = strlen(line) + 1
    if l < left
      let left = l
    endif
    if r > right
      let right = r
    endif
  endfor
  return [left, right]
endfunction

function! caw#wrap_comment_align(line, left_cmt, right_cmt, left_col, right_col) abort
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
endfunction

function! caw#load_ftplugin(ft) abort
  if exists('b:undo_ftplugin')
    execute b:undo_ftplugin
  endif
  unlet! b:did_caw_ftplugin
  execute 'runtime! after/ftplugin/' . a:ft . '/caw.vim'
endfunction

function! caw#update_comments_from_commentstring(cms) abort
  let parsed = caw#comments#parse_commentstring(a:cms)
  let variables = []

  if exists('b:caw_oneline_comment')
    let variables += ['let b:caw_oneline_comment = ' . string(b:caw_oneline_comment)]
  else
    let variables += ['unlet! b:caw_oneline_comment']
  endif
  if has_key(parsed, 'oneline')
    let b:caw_oneline_comment = parsed.oneline
  else
    unlet! b:caw_oneline_comment
  endif

  if exists('b:caw_wrap_oneline_comment')
    let variables += ['let b:caw_wrap_oneline_comment = ' . string(b:caw_wrap_oneline_comment)]
  else
    let variables += ['unlet! b:caw_wrap_oneline_comment']
  endif
  if has_key(parsed, 'wrap_oneline')
    let b:caw_wrap_oneline_comment = parsed.wrap_oneline
  else
    unlet! b:caw_wrap_oneline_comment
  endif

  if exists('b:caw_wrap_multiline_comment')
    let variables += ['let b:caw_wrap_multiline_comment = ' . string(b:caw_wrap_multiline_comment)]
  else
    let variables += ['unlet! b:caw_wrap_multiline_comment']
  endif
  if has_key(parsed, 'wrap_multiline')
    let b:caw_wrap_multiline_comment = parsed.wrap_multiline
  else
    unlet! b:caw_wrap_multiline_comment
  endif

  function! s:undo_variables() abort closure
    for undo in variables
      execute undo
    endfor
  endfunction

  return funcref('s:undo_variables')
endfunction


" '.../autoload/caw'
" vint: next-line -ProhibitUnusedVariable
let s:root_dir = expand('<sfile>:h') . '/caw'
" s:modules[module_name][cache_key]
" cache_key = string(a:000)
let s:modules = {}

function! caw#load(name) abort
  " If the module is already loaded, return it.
  if has_key(s:modules, a:name)
    return
  endif
  " Load script file.
  " vint: next-line -ProhibitUnusedVariable
  let file = tr(a:name, '.', '/') . '.vim'
  source `=s:root_dir.'/'.file`
  " Call depends() function.
  let depends = 'caw#' . tr(a:name, '.', '#') . '#depends'
  if exists('*'.depends)
    for module in call(depends, [])
      call caw#load(module)
    endfor
  endif
  let s:modules[a:name] = {}
endfunction

function! caw#new(name, ...) abort
  let id = string(a:000)
  if has_key(s:modules, a:name) && has_key(s:modules[a:name], id)
    return copy(s:modules[a:name][id])
  endif
  call caw#load(a:name)
  " Call new() function.
  let constructor = 'caw#' . tr(a:name, '.', '#') . '#new'
  let s:modules[a:name][id] = call(constructor, a:000)
  return copy(s:modules[a:name][id])
endfunction

" }}}
