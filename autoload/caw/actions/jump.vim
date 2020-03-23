scriptencoding utf-8

function! caw#actions#jump#new() abort
  let obj = deepcopy(s:jump)
  let obj.comment_database = caw#new('comments.oneline')
  return obj
endfunction


let s:jump = {}

function! s:jump.comment_next() abort
  return self.comment_jump(1)
endfunction
let s:jump['comment-next'] = s:jump.comment_next

function! s:jump.comment_prev() abort
  return self.comment_jump(0)
endfunction
let s:jump['comment-prev'] = s:jump.comment_prev

function! s:jump.comment_jump(next) abort
  let comments = self.comment_database.get_comments()
  if empty(comments)
    return
  endif
  let cmt = comments[0]

  " Begin a new line and insert
  " the online comment leader with whitespaces.
  " And start Insert mode at the end of the inserted line.
  call s:ex_insert_str(a:next,
  \       cmt .  caw#get_var('caw_jump_sp'))
  if a:next
    call cursor(caw#context().firstline + 1, 1)
  endif
  startinsert!
endfunction

function! s:ex_insert_str(next, insert_str) abort
  let save_fo = &l:formatoptions
  setlocal formatoptions-=o
  try
    execute 'normal! ' . (a:next ? 'o' : 'O') . a:insert_str
  finally
    let &l:formatoptions = save_fo
  endtry
endfunction
