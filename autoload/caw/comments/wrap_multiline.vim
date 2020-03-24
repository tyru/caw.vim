scriptencoding utf-8

function! caw#comments#wrap_multiline#new() abort
  let obj = caw#comments#base#new()
  return extend(obj, deepcopy(s:wrap_multiline))
endfunction


let s:wrap_multiline = {}
unlet! s:METHODS
let s:METHODS = ['get_comment_vars']
lockvar! s:METHODS

function! s:wrap_multiline.get_comments() abort
  let comments = []
  for method in s:METHODS
    let comments += self[method]()
  endfor
  return caw#uniq_keep_order(comments)
endfunction

function! s:wrap_multiline.get_possible_comments(context) abort
  return self._get_possible_comments(a:context, 'caw_wrap_multiline_comment', function('s:by_length_desc'))
endfunction

function! s:by_length_desc(c1, c2) abort
  let [l1, r1] = [a:c1.left, a:c1.right]
  let [l2, r2] = [a:c2.left, a:c2.right]
  let d = strlen(l2) - strlen(l1)
  if d !=# 0
    return d
  endif
  return strlen(r2) - strlen(r1)
endfunction

function! s:wrap_multiline.get_comment_vars() abort
  return self._get_comment_vars('caw_wrap_multiline_comment')
endfunction
