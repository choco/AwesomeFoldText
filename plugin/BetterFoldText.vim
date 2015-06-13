function! s:GenerateFoldText()
  "get first non-blank line
  let fs = v:foldstart
  while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
    let line = getline(v:foldstart)
  else
    let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif
  let text = line

  " Foldtext can't display tabs so replace them with spaces
  let indent = indent(v:foldstart)
  let text   = substitute(text, '^\t\+', repeat(' ', indent), '')

  " Replace content between {} with {...}
  let startbrace = substitute(line, '^.*{[ \t]*$', '{', 'g')
  if startbrace == '{'
    let line     = getline(v:foldend)
    let endbrace = substitute(line, '^[ \t]*}\(.*\)$', '}', 'g')
    if endbrace == '}'
      let text .= substitute(line, '^[ \t]*}\(.*\)$', '...}\1', 'g')
    endif
  endif
  let foldlen = v:foldend - v:foldstart + 1
  let percent = printf("[%.1f", (foldlen * 1.0)/line('$') * 100) . "%] "
  let info    = " " . foldlen . " lines " . percent . repeat('+--', v:foldlevel) . '|'
  let w = winwidth(0) - &foldcolumn - (&number ? &numberwidth : 0) - (GetSignsCount() ? 2 : 0)
  " truncate foldtext according to window width
  if exists("*strwdith")
    let expansionString = repeat(' ', w - strwidth(text . info))
  else
    let expansionString = repeat(' ', w - strlen(substitute(text . info, '.', 'x', 'g')))
  endif
  return text . expansionString . info
endfunction

function! s:GetSignsCount()
  let lang = v:lang
  language message C
  redir => signlist
    silent! execute 'sign place buffer='. bufnr('%')
  redir END
  silent! execute 'language message' lang
  return len(split(signlist, '\n'))-1
endfunction

set foldtext=GenerateFoldText()
