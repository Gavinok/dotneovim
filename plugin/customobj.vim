" File: customobj.vim
" Maintainer: Gavin Jaeger-Freeborn <gavinfreeborn@gmail.com>
" Created: Tue 02 Mar 2021 10:23:38 AM
" License:
" Copyright (c) Gavin Jaeger-Freeborn.  Distributed under the same terms as Vim itself.
" See :help license
"
" Description:
" Custom text objects
"
" line text objects
" -----------------
" il al
xnoremap il g_o^
onoremap il :<C-u>normal vil<CR>
xnoremap al $o0
onoremap al :<C-u>normal val<CR>

" number text object (integer and float)
" --------------------------------------
" in
function! VisualNumber()
	call search('\d\([^0-9\.]\|$\)', 'cW')
	normal! v
	call search('\(^\|[^0-9\.]\d\)', 'becW')
endfunction
xnoremap in :<C-u>call VisualNumber()<CR>
onoremap in :<C-u>normal vin<CR>

" buffer text objects
" -------------------
" i% a%
xnoremap i% :<C-u>let z = @/\|1;/^./kz<CR>G??<CR>:let @/ = z<CR>V'z
onoremap i% :<C-u>normal vi%<CR>
xnoremap a% GoggV
onoremap a% :<C-u>normal va%<CR>


" Inside And Arround {{{1
" inside or arround ...
" ----------------------
" i" i' i. i_ i| i/ i\ i*
" a" a' a. a_ a| a/ a\ a*
for char in [ '_', '.', '\|', ';','$', '@', '/', '<bslash>', '*' ]
	execute 'xnoremap i' . char . ' :<C-u>normal! T' . char . 'vt' . char . '<CR>'
	execute 'onoremap i' . char . ' :normal vi' . char . '<CR>'
	execute 'xnoremap a' . char . ' :<C-u>normal! F' . char . 'vf' . char . '<CR>'
	execute 'onoremap a' . char . ' :normal va' . char . '<CR>'
endfor
" 1}}} "Inside And Arround
" TODO: Find a better location for this <17-06-20 Gavin Jaeger-Freeborn>
let g:surround_insert_tail = '{{++}}'

" wip starter \\\([fn\*]\)\(.\|(..\|\[\{-}\]\)
" function! VisualNumber()
" 	call search('\\\([fnm\*]\)\(.\|(..\|\[\{-}\]\)', 'cW')
" 	normal v
" 	call search('\(^\|[^0-9\.]\d\)', 'becW')
" endfunction
" xnoremap in :<C-u>call VisualNumber()<CR>
" onoremap in :<C-u>normal vin<CR>
