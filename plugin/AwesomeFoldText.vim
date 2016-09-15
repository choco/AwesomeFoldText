" vim: set foldmethod=marker:
if exists('g:loaded_awesomefoldtext')
  finish
endif
let g:loaded_awesomefoldtext = 1

if !exists('g:AwesomeFoldTextSymbol')
  let g:AwesomeFoldTextSymbol = '▸'
endif
if !exists('g:AwesomeFoldTextFillChar')
  let g:AwesomeFoldTextFillChar = '·'
endif
if !exists('g:AwesomeFoldTextIndent')
  let g:AwesomeFoldTextIndent = 1
endif
if !exists('g:AwesomeFoldTextCountSurroundLeft')
  let g:AwesomeFoldTextCountSurroundLeft = '| '
endif
if !exists('g:AwesomeFoldTextCountSurroundRight')
  let g:AwesomeFoldTextCountSurroundRight = ' |'
endif
if !exists('g:AwesomeFoldTextFoldLevelSymbol')
  let g:AwesomeFoldTextFoldLevelSymbol = '＋-'
endif
if !exists('g:AwesomeFoldTextFoldLevelScale')
  let g:AwesomeFoldTextFoldLevelScale = 1
endif

function! s:GetSignsCount() " {{{
  let lang = v:lang
  language message C
  redir => signlist
    silent! execute 'sign place buffer='. bufnr('%')
  redir END
  silent! execute 'language message' lang
  return len(split(signlist, '\n'))-1
endfunction
" }}}

function! s:IsCommentBlock() " {{{
    return match(getline(v:foldstart), '^\s*/\*\+') != -1
endfunction
" }}}

function! s:FoldMarkerIsOnSeparateLine() " {{{
    let foldStartMarker = matchstr(&foldmarker, '^[^,]*')
    return match(getline(v:foldstart), '^\s*["#/\*]*\s*' . foldStartMarker . 'd*\s*["#/\*]*$', 'g') != -1
endfunction
" }}}

function! s:FilterInfo(text) " {{{
    let foldStartMarker = matchstr(&foldmarker, '^[^,]*')
    return substitute(a:text, '^\s*["#/\*]*\s*\|\s*["#/\*]*\s*' . foldStartMarker .'\d*\s*', '', 'g')
endfunction
" }}}

function! s:FoldStartsOnBracket() " {{{
    return match(getline(v:foldstart), '^\s*{\s*$') != -1
endfunction
" }}}

function! s:GetFoldInfo() " {{{
  let info = ''
  " Check if multiline comments start with '/*' or '/**' on a separate line.
  if s:IsCommentBlock()
    if match(getline(v:foldstart), '^\s*/\*\+\s*$') != -1
      " Use the next line in the comment block, and add the '/*' or '/**'
      " so that we know it's a block of comments or doc.
      let info = substitute(getline(v:foldstart), '\s*', '', 'g') . ' '
      let info = info . substitute(getline(v:foldstart + 1), '^\s*\*\+\s*', '', 'g')
    else
      let info = getline(v:foldstart)
    endif
  elseif s:FoldMarkerIsOnSeparateLine()
    let info = getline(v:foldstart + 1)
    let info = s:FilterInfo(info)
  elseif s:FoldStartsOnBracket()
    let info = '{ … }'
  else
    let info = getline(v:foldstart)
    let info = s:FilterInfo(info)
  endif
  let info = ' ' . info . ' '

  return info
endfunction
" }}}

function! s:FormatLinesCount() " {{{
  let countText = ''
  let foldlen = v:foldend - v:foldstart + 1
  let percent = printf(" (%.1f", (foldlen * 1.0)/line('$') * 100) . "%)"
  if winwidth(0) < 60
      let countText = printf("%4s", foldlen + 1)
  else
      let countText = printf("%16s", foldlen . ' lines' . percent)
  endif

  let countText = g:AwesomeFoldTextCountSurroundLeft . countText . g:AwesomeFoldTextCountSurroundRight

  return countText
endfunction
" }}}

function! s:IndentFold() " {{{
    if g:AwesomeFoldTextIndent == 1
        return repeat(' ', indent(v:foldstart))
    else
        return ''
    endif
endfunction
" }}}

function! s:FormatFoldLevel() " {{{
    return repeat(g:AwesomeFoldTextFoldLevelSymbol, v:foldlevel * g:AwesomeFoldTextFoldLevelScale)
endfunction
" }}}

function! s:CutText(text) " {{{
    let maxwidth = winwidth(0) * 2 / 3

    if strlen(a:text) > maxwidth
        return strpart(a:text, 0, maxwidth - 2) . '… '
    else
        return strpart(a:text, 0, maxwidth)
    endif
endfunction
" }}}

function! s:FormatFirstPart() " {{{
  let startText = s:IndentFold() . g:AwesomeFoldTextSymbol . s:GetFoldInfo()
  let startText = s:CutText(startText)

  return startText
endfunction
" }}}

function! s:FormatSecondPart() " {{{
  let linesCountText = s:FormatLinesCount()
  let foldLevelText = s:FormatFoldLevel()

  return foldLevelText . linesCountText . repeat(g:AwesomeFoldTextFillChar, 2)
endfunction
" }}}

function! AwesomeFoldText() " {{{
  let firstPartText = s:FormatFirstPart()
  let secondPartText = s:FormatSecondPart()
  let fillLength = winwidth(0) - strwidth(firstPartText . secondPartText) - &foldcolumn - (&number ? &numberwidth : 0) - (s:GetSignsCount() ? 2 : 0)
  return firstPartText . repeat(g:AwesomeFoldTextFillChar, fillLength) . secondPartText
endfunction
" }}}

set foldtext=AwesomeFoldText()
