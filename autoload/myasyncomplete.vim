function! myasyncomplete#setup()
	call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
				\ 'name': 'buffer',
				\ 'allowlist': ['*'],
				\ 'blocklist': ['go'],
				\ 'completor': function('asyncomplete#sources#buffer#completor'),
				\ 'config': {
				\    'max_buffer_size': 5000000,
				\  },
				\ }))

	call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
				\ 'name': 'tags',
				\ 'allowlist': ['*'],
				\ 'completor': function('asyncomplete#sources#tags#completor'),
				\ 'config': {
				\    'max_file_size': 50000000,
				\  },
				\ }))
endfunction
