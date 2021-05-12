" File: filetype.vim
" Maintainer: Gavin Jaeger-Freeborn <gavinfreeborn@gmail.com>
" Created: Fri 06 Mar 2020 03:28:22 PM
" License:
" Copyright (c) Gavin Jaeger-Freeborn.  Distributed under the same terms as Vim itself.
" See :help license
"
" Description:
" filetype detection

if exists("did_load_filetypes")
	finish
endif

augroup filetypedetect
	autocmd! BufRead,BufNewFile *.h                      setlocal filetype=c
	autocmd! Bufread,Bufnewfile */snip/*                 setlocal filetype=minisnip
	autocmd! BufRead,BufNewFile tuir*                    setlocal filetype=markdown
	autocmd! BufRead,BufNewFile *.rkt,*.rktl,*.slideshow setlocal filetype=scheme
	autocmd! BufRead,BufNewFile *.joke                   setlocal filetype=clojure
	autocmd! BufRead,BufNewFile *.txp                    setlocal filetype=patoline
	autocmd! BufRead,BufNewFile *.org                    setlocal filetype=dotoo
augroup END
