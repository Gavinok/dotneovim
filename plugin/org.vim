" File: org.vim
" Maintainer: Gavin Jaeger-Freeborn <gavinfreeborn@gmail.com>
" Created: Fri 01 May 2020 02:23:20 PM
" License:
" Copyright (c) Gavin Jaeger-Freeborn.  Distributed under the same terms as Vim itself.
" See :help license
"
" Description:
" Simple implementation of orgmode support for vim

" Orgmode {{{2 "
" Simple implementation of org-capture using minisnip
function! CreateCapture(window, ...)
	" if this file has a name
	let g:org_refile='~/Documents/org/refile.org'
	if expand('%:p') !=# ''
		let g:temp_org_file=printf('file:%s:%d', expand('%:p') , line('.'))
		exec a:window . ' ' . g:org_refile
		exec '$read ' . globpath(&rtp, 'extra/org/template.org')
	elseif a:0 == 1 && a:1 == 'qutebrowser'
		exec a:window . ' ' . g:org_refile
		exec '$read ' . globpath(&rtp, 'extra/org/templateQUTE.org')
	else
		exec a:window . ' ' . g:org_refile
		exec '$read ' . globpath(&rtp, 'extra/org/templatenofile.org')
	endif
	" call feedkeys("i\<Plug>(minisnip)", 'i')
endfunction


let g:dotoo#agenda#files = ['~/Documents/org/*.org']

let g:dotoo#parser#todo_keywords = [
			\ 'TODO',
			\ 'NEXT',
			\ 'SOMEDAY',
			\ 'WAITING',
			\ 'HOLD',
			\ '|',
			\ 'CANCELLED',
			\ 'DONE',
			\]

let g:org_state_keywords = [ 'TODO', 'NEXT', 'SOMEDAY', 'DONE', 'CANCELLED' ]

let g:dotoo_headline_highlight_colors = [
			\ 'Title',
			\ 'Identifier',
			\ 'Statement',
			\ 'PreProc',
			\ 'Type',
			\ 'Special',
			\ 'Constant']

" Requires the program date to be installed
function! ChangeDate() abort
  if !executable('date')
    echoerr 'need date'
  endif

  if !exists('g:env')
    let g:env = toupper(substitute(system('uname'), '\n', '', ''))
    if !g:env =~ 'LINUX' | echoerr 'sorry but ' . g:env . ' is not supported' | endif
  endif

  let newdate = input('Enter Date: ')
  if newdate == '' | return -1 | endif

  let newdate = system('date -d "' . newdate . '" +"' . g:dotoo#time#datetime_format . '"')

  if v:shell_error | echoerr newdate . ' is not a valid date' | endif

  let newdate = substitute(newdate, '\n', '', '')
  exec 'normal! ci>' . newdate
endfunction

hi link orgHeading2 Normal
let g:org_time='%H:%M'
let g:org_date='%Y-%m-%d %a'
let g:org_date_format=g:org_date.' '.g:org_time
map <silent>gC :call CreateCapture('split')<CR>
command! -nargs=0 NGrep grep! ".*" ~/.local/Dropbox/Documents/org/**/*.org
" 2}}} "Orgmode
