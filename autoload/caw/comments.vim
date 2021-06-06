scriptencoding utf-8

function! caw#comments#parse_commentstring(cms) abort
  let parsed = {}

  let oneline = caw#comments#oneline#new().parse_commentstring(a:cms)
  if !empty(oneline)
    let parsed.oneline = oneline
  endif

  let wrap_oneline = caw#comments#wrap_oneline#new().parse_commentstring(a:cms)
  if !empty(wrap_oneline)
    let parsed.wrap_oneline = wrap_oneline
  endif

  return parsed
endfunction
