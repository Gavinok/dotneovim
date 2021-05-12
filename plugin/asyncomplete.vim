call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
			\ 'name': 'buffer',
			\ 'allowlist': ['*'],
			\ 'blocklist': ['go'],
			\ 'completor': function('asyncomplete#sources#buffer#completor'),
			\ 'config': {
			\    'max_buffer_size': 5000000,
			\  },
\ }))

call asyncomplete#register_source(asyncomplete#sources#nextword#get_source_options({
			\   'name': 'nextword',
			\   'allowlist': ['mail', 'markdown', 'org', 'gitcommit', 'groff', 'nroff', 'troff'],
			\   'args': ['-n', '10000'],
			\   'completor': function('asyncomplete#sources#nextword#completor')
			\   }))

call asyncomplete#register_source(asyncomplete#sources#lsp#get_source_options({}))
