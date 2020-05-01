scriptencoding utf-8

function! caw#comments#base#new() abort
  return deepcopy(s:base)
endfunction


let s:base = {}

function! s:base._get_possible_comments(context, varname, by_length) abort
  if caw#get_var('caw_search_possible_comments', 0)
    let related = self._get_related_ft_comments(a:context, a:varname)
  else
    let related = []
  endif
  let comments = self.get_comments()
  return caw#uniq(sort(related + comments, a:by_length))
endfunction

function! s:base._get_comment_vars(varname) abort
  let NONE = []
  let comments = []
  let current = caw#get_var(a:varname, NONE, [line('.')])
  if current isnot# NONE && !empty(current)
    let comments += [current]
  endif
  return comments
endfunction

function! s:base._get_related_ft_comments(context, varname) abort
  let NONE = []
  let comments = []
  let filetypes = caw#get_related_filetypes(a:context.filetype)
  for ft in filetypes
    call caw#load_ftplugin(ft)
    let cmt = caw#get_var(a:varname, NONE, [line('.')])
    if cmt isnot# NONE && !empty(cmt)
      let comments += [cmt]
    endif
  endfor
  if !empty(filetypes)
    call caw#load_ftplugin(a:context.filetype)
  endif
  return comments
endfunction
