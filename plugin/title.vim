" Capital Quick first letter of a word or a regain
nmap <leader>t :set opfunc=dotvim#titlecase<CR>g@
xmap <leader>t :<C-U>call dotvim#titlecase(visualmode(),visualmode() ==# 'V' ? 1 : 0)<CR>
nmap <leader>T :set opfunc=dotvim#titlecase<Bar>exe 'norm! 'v:count1.'g@_'<CR>
