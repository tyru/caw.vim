scriptencoding utf-8

let s:has_vim8_prop = exists('*prop_list') && exists('*prop_find')

function! caw#actions#traits#comment_detectable#new() abort
  return deepcopy(s:comment_detectable)
endfunction


let s:comment_detectable = {}

" Below methods are missing.
" Derived object must implement them.
"
" Requires:
" - comment_database.get_comments()
" - get_commented_range(lnum, comments)

function! s:comment_detectable.has_comment() abort
  let context = caw#context()
  if context.mode ==# 'n'
    call self.has_comment_normal(context.firstline)
  else
    return self.has_any_comment(context.firstline, context.lastline)
  endif
endfunction

function! s:comment_detectable.has_comment_normal(lnum) abort
  let comments = self.comment_database.get_comments()
  return !empty(self.get_commented_range(a:lnum, comments))
endfunction

function! s:comment_detectable.get_commented_col(lnum, needle, ignore_syngroup) abort
  let line = getline(a:lnum)
  let idx = -1
  let start = 0
  while 1
    let idx = stridx(line, a:needle, start)
    if idx ==# -1
      break
    endif
    if a:ignore_syngroup || self.has_syntax('Comment$', a:lnum, idx + 1)
          \ || (has('nvim-0.5.0') && luaeval("require'caw'.has_syntax(_A[1], _A[2])", [a:lnum, idx + 1]))
      break
    endif
    let start = idx + 1
  endwhile
  return idx + 1
endfunction

function! s:comment_detectable.has_any_comment(start, end) abort
  for lnum in range(a:start, a:end)
    if self.has_comment_normal(lnum)
      return 1
    endif
  endfor
  return 0
endfunction

" Returns true when all lines are consisted of commented lines and *blank lines*
function! s:comment_detectable.has_all_comment(start, end) abort
  for lnum in range(a:start, a:end)
    if getline(lnum) !~# '^\s*$' && !self.has_comment_normal(lnum)
      return 0
    endif
  endfor
  return 1
endfunction

function! s:comment_detectable.has_syntax(synpat, lnum, col) abort
  for id in synstack(a:lnum, a:col)
    if synIDattr(synIDtrans(id), 'name') =~# a:synpat
      return 1
    endif
  endfor
  if s:has_vim8_prop
    for prop in prop_list(a:lnum)
      if prop.type =~# a:synpat && prop.col <= a:col && a:col <= prop.col + prop.length
        return 1
      endif
    endfor
  endif
  return 0
endfunction

function! s:comment_detectable.search_synstack(lnum, cmt, synpat) abort
  let line = getline(a:lnum)
  let cols = []
  let idx  = -1
  while 1
    let idx = stridx(line, a:cmt, (idx ==# -1 ? 0 : idx + 1))
    if idx == -1
      break
    endif
    call add(cols, idx + 1)
  endwhile

  if empty(cols)
    return -1
  endif

  for col in cols
    if self.has_syntax(a:synpat, a:lnum, col)
      return col
    endif
  endfor
  return -1
endfunction
