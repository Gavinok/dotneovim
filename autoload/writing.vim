function! writing#init()
	call asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options({
				\   'name': 'nextword',
				\   'allowlist': g:writing_langs,
				\   'args': ['-n', '10000'],
				\   'completor': function('asyncomplete#sources#nextword#completor')
				\   }))
endfunction
