set nocompatible
set nomodeline

set history=100

set viminfo='1000,f1,:100,/100,h
syntax on
set synmaxcol=300
if has("gui_running")
	set titlestring=
	set titlestring+=%F\                     " file name
	set titlestring+=%h%m%r%w                " flags
	autocmd WinLeave * setlocal nocursorcolumn nocursorline
	autocmd WinEnter * setlocal cursorline
	autocmd BufLeave * setlocal nocursorcolumn nocursorline
	autocmd BufEnter * setlocal cursorline
	hi cursorline guibg=#000011

	let g:zenburn_high_Contrast = 0
	colorscheme zenburn

	set guicursor=a:blinkon0

	set guifont=Consolas:h11
	set guioptions-=m
	set guioptions-=T
	set guioptions-=l
	set guioptions-=L
	set guioptions-=r
	set guioptions-=R
	autocmd GUIEnter * simalt ~x
else
	colorscheme desert
endif

let mapleader = ","

set wildmenu
" Ignore these patterns when completing file names
set wildignore+=*.fxp,*.fr[tx],*.bak,*.~*,*.pj[tx],*.DEF,*.aps,*.vc*

set ruler
set completeopt-=preview
set completeopt+=menu

" turn off backup
set nobackup
set nowb
set noswapfile

" enable filetype detection
filetype on
filetype plugin on

" turn off word wrap
set nowrap

" allow h and l to wrap between lines
set whichwrap=h,l,~,[,]

noremap * *N
noremap # #N

" incremental search, highlight results
set incsearch
set hlsearch

" search won't wrap around to bof
set nowrapscan

" I don't like case sensitive searching
set ignorecase
" But I like the smartcase feature
set smartcase

" set tabs
set tabstop=2
set shiftwidth=2
set expandtab

" smart indenting
set smartindent

" fix backspace
set backspace=indent,eol,start

" Nice statusbar
set laststatus=2
set cmdheight=2
"set statusline=[%l,%c\ %P%M]\ %F\ %r%h%w%y\ [ascii=\%03.3b]\ [hex=\%02.2B]
"let g:airline#extensions#tabline#enabled=1

" http://jeffkreeftmeijer.com/2012/relative-line-numbers-in-vim-for-super-fast-movement/
set number
set numberwidth=5

function! NumberToggle()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc

nnoremap <C-n> :call NumberToggle()<cr>

:au FocusLost * :set number
:au FocusGained * :set relativenumber

autocmd InsertEnter * :set number
autocmd InsertLeave * :set relativenumber


set hidden

" Start scrolling 3 lines before the border
set scrolloff=3

autocmd BufRead,BufNewfile *.txt setlocal wrap 
autocmd BufRead,BufNewfile *.txt setlocal linebreak
autocmd BufRead,BufNewfile *.txt setlocal nolist
"autocmd BufRead,BufNewfile *.txt setlocal nonumber

autocmd filetype design setlocal wrap
autocmd filetype design setlocal linebreak
autocmd filetype design setlocal nolist
autocmd filetype design :noremap j gj
autocmd filetype design :noremap k gk

autocmd filetype css :nmap <leader>l <ESC>_i/*<ESC>A*/<ESC>_
autocmd filetype css :nmap <leader>k <ESC>$F/2x/\*\/<CR>2x_

autocmd filetype html setlocal isk+=-
autocmd filetype css setlocal isk+=-

autocmd filetype sql setlocal isk+=-

" while in insert mode, move around with control + h, j, k, l
" as in normal mode
imap <C-h> <left>
imap <C-j> <down>
imap <C-k> <up>
imap <C-l> <right>

imap <C-BS> <DEL>

" shift tab places cursor one shiftwidth to the left
imap <S-Tab> <C-d>

" do the same for command mode
cmap <C-h> <left>
cmap <C-l> <right>

" quickly insert empty line
nmap <CR> o<ESC>
nmap <C-CR> i<CR><ESC>

nmap <C-Tab> :bnext<CR>
nmap <C-S-Tab> :bprevious<CR>

nmap <C-b> :b#<CR>
imap <C-b> <ESC>:b#<CR>

nmap <M-e> <C-W>W<C-e><C-W>W
nmap <M-y> <C-W>W<C-y><C-W>W

cabbrev B b

" stop vim from auto-commenting
" au FileType c,cpp setlocal comments-=:// comments+=f://

set list
set listchars=tab:»\ ,trail:·

"autocmd BufEnter * lcd %:p:h
nnoremap <leader>e :e **/
nnoremap <leader>b :b <C-d>
set path=.\**

" TFS integration
function! TFSCheckoutFunction()
	silent! exe '!tf checkout "' expand('%:p') '"'
endfunction

function! TFSCheckinFunction()
	silent! exe '!tf checkin "' expand('%:p') '"'
endfunction

function! TFSUndoFunction()
	silent! exe '!tf undo "' expand('%:p') '"'
endfunction

function! TFSDiffFunction()
	silent! exe '!tf diff /format:visual /version:T "' expand('%:p') '"'
endfunction

"command! TFSCheckout :call TFSCheckoutFunction()
"command! TFSCheckin :call TFSCheckinFunction()
"command! TFSUndo :call TFSUndoFunction()
"command! TFSDiff :call TFSDiffFunction()

" https://svn.mageekbox.net/repositories/vim/trunk/.vimrc
let s:_ = ''

function! s:ExecuteInShell(command, bang)
	let _ = a:bang != '' ? s:_ : a:command == '' ? '' : join(map(split(a:command), 'expand(v:val)'))

	if (_ != '')
		let s:_ = _
		let bufnr = bufnr('%')
		let winnr = bufwinnr('^' . _ . '$')
		silent! execute  winnr < 0 ? 'new ' . fnameescape(_) : winnr . 'wincmd w'
		setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap number
		silent! :%d
		let message = 'Execute ' . _ . '...'
		call append(0, message)
		echo message
		silent! 2d | resize 1 | redraw
		silent! execute 'silent! %!'. _
		silent! execute 'resize ' . line('$')
		silent! execute 'syntax on'
		silent! execute 'autocmd BufUnload <buffer> execute bufwinnr(' . bufnr . ') . ''wincmd w'''
		silent! execute 'autocmd BufEnter <buffer> execute ''resize '' .  line(''$'')'
		silent! execute 'nnoremap <silent> <buffer> <CR> :call <SID>ExecuteInShell(''' . _ . ''', '''')<CR>'
		silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . _ . ''', '''')<CR>'
		silent! execute 'nnoremap <silent> <buffer> <LocalLeader>g :execute bufwinnr(' . bufnr . ') . ''wincmd w''<CR>'
		nnoremap <silent> <buffer> <C-W>_ :execute 'resize ' . line('$')<CR>
		silent! syntax on
	endif
endfunction

command! -complete=shellcmd -nargs=* -bang Shell call s:ExecuteInShell(<q-args>, '<bang>')
cabbrev shell Shell

" :call ReloadAllSnippets

nnoremap <Left> :vertical resize +2<CR>
nnoremap <Right> :vertical resize -2<CR>
nnoremap <Up> :resize -2<CR>
nnoremap <Down> :resize +2<CR>
