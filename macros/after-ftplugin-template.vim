" vim:foldmethod=marker:fen:
scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

<ONELINE>
<WRAP_ONELINE>
<WRAP_MULTILINE>

if exists('b:undo_ftplugin')
  let b:undo_ftplugin .= ' | '
else
  let b:undo_ftplugin = ''
endif
<UNDO_FTPLUGIN>

let &cpo = s:save_cpo
