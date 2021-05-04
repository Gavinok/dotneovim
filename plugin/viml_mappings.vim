" shortcut to change filetype
nnoremap <leader>ft  :setfiletype<space>
" shortcut to search help
nnoremap <leader>hh  :help<Space>

"For Proper Tabbing And Bracket Insertion"
inoremap {<CR> {<CR>}<c-o><s-o>
inoremap (<CR> (<CR>)<c-o><s-o>

" if this is a normal buffer use <CR> to toggle folding
nmap <expr> <CR> &buftype ==# '' ? 'za' : "\<CR>"

" change variable and repeat with .
nnoremap c*			*Ncgn
nnoremap <C-N>      yiW/<C-r>0<CR>Ncgn
xnoremap <C-N>      y/<C-r>0<CR>Ncgn

cnoremap <expr> / wildmenumode() ? "\<C-Y>" : "/"

" use syntax for omnicomplete if none exists
augroup SyntaxComplete
	" this one is which you're most likely to use?
	autocmd Filetype *
				\	if &omnifunc == '' |
				\		setlocal omnifunc=syntaxcomplete#Complete |
				\	endif
augroup end

" remove trailing whitespaces
command! StripWhitespace :%s/\s\+$//e

" sort based on visual block
command! -range -nargs=0 -bang SortVis sil! keepj <line1>,<line2>call dotvim#VisSort(<bang>0)
" use s to sort visual selection
xmap s :SortVis<CR>
" 2}}} "VisualSort
" Extra commands {{{2
" Minimal Gist this is actually IX but i always think its XI
command! -range=% XI  silent execute <line1> . "," . <line2> . "w !curl -F 'f:1=<-' ix.io | tr -d '\\n' | xsel -i"
" Yank all matches in last search
command! -register YankMatch call dotvim#YankMatches(<q-reg>)

" Do not use smart case in command line mode,
" extracted from https://goo.gl/vCTYdK
if exists('##CmdLineEnter')
	augroup dynamic_smartcase
		autocmd!
		autocmd CmdLineEnter : set nosmartcase
		autocmd CmdLineLeave : set smartcase
	augroup END
endif
imap <silent><expr> <c-f> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
