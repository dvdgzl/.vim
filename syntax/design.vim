if exists("b:current_syntax")
	finish
endif

syn match designTag '^\[.*\]'
syn match designStub '\[stub\]'

highlight designTag guifg=#FDD017
highlight designStub guifg=#E37130
