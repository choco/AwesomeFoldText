let g:NeatFoldTextSymbol = '▸'
let g:NeatFoldTextFillChar = '·'
let g:NeatFoldTextIndent = 1
let g:NeatFoldTextCountSurroundLeft = '| '
let g:NeatFoldTextCountSurroundRight = ' |'
let g:NeatFoldTextFoldLevelSymbol = '+-'
let g:NeatFoldTextFoldLevelScale = 1

function s:IsCommentBlock() "{{{
    return match(getline(v:foldstart), '^\s*/\*\+') != -1
endfunction
"}}}

function s:FoldMarkerIsOnSeparateLine() "{{{
    let foldStartMarker = matchstr(&foldmarker, '^[^,]*')
    return match(getline(v:foldstart), '^\s*["#/\*]*\s*' . foldStartMarker . 'd*\s*["#/\*]*$', 'g') != -1
endfunction
"}}}

function s:FilterInfo(text) "{{{
    let foldStartMarker = matchstr(&foldmarker, '^[^,]*')
    return substitute(a:text, '^\s*["#/\*]*\s*\|\s*["#/\*]*\s*' . foldStartMarker .'\d*\s*', '', 'g')
endfunction
"}}}

function s:FoldStartsOnBracket() "{{{
    return match(getline(v:foldstart), '^\s*{\s*$') != -1
endfunction
"}}}

function s:GetFoldInfo() "{{{
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
"}}}

function s:FormatLinesCount() "{{{
  let countText = ''
  let foldlen = v:foldend - v:foldstart + 1
  let percent = printf(" (%.1f", (foldlen * 1.0)/line('$') * 100) . "%)"
  if winwidth(0) < 60
      let countText = printf("%4s", foldlen + 1)
  else
      let countText = printf("%10s", foldlen . ' lines' . percent)
  endif

  let countText = g:NeatFoldTextCountSurroundLeft . countText . g:NeatFoldTextCountSurroundRight

  return countText
endfunction
"}}}

function s:IndentFold() "{{{
    if g:NeatFoldTextIndent == 1
        return repeat(' ', indent(v:foldstart))
    else
        return ''
    endif
endfunction
"}}}

function s:FormatFoldLevel() "{{{
    return repeat(g:NeatFoldTextFoldLevelSymbol, v:foldlevel * g:NeatFoldTextFoldLevelScale)
endfunction
"}}}

function s:CutText(text) "{{{
    let maxwidth = winwidth(0) * 2 / 3

    if strlen(a:text) > maxwidth
        return strpart(a:text, 0, maxwidth - 2) . '… '
    else
        return strpart(a:text, 0, maxwidth)
    endif
endfunction
"}}}

function s:FormatFirstPart() "{{{
  let startText = s:IndentFold() . g:NeatFoldTextSymbol . s:GetFoldInfo()
  let startText = s:CutText(startText)

  return startText
endfunction
"}}}

function s:FormatSecondPart() "{{{
  let linesCountText = s:FormatLinesCount()
  let foldLevelText = s:FormatFoldLevel()

  return foldLevelText . linesCountText . repeat(g:NeatFoldTextFillChar, 8)
endfunction

function! AwesomeFoldText() "{{{
  let firstPartText = s:FormatFirstPart()
  let secondPartText = s:FormatSecondPart()
  let fillLength = winwidth(0) - strwidth(firstPartText . secondPartText) + &foldcolumn
  return firstPartText . repeat(g:NeatFoldTextFillChar, fillLength) . secondPartText
endfunction
"}}}

set foldtext=AwesomeFoldText()
