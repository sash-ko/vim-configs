set nocompatible

set ruler

set statusline=[%l,%c\ %P%M]\ %f\ %r%h%w\ git:%{GitBranch()}

set nu 
set incsearch
set ignorecase

set autoindent
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab
set softtabstop=4

set novisualbell

set wrap
set linebreak

set nobackup
set noswapfile

set encoding=utf-8

"set mouse=a

syntax on
colorscheme desert

filetype on
filetype plugin on

let python_highlight_all = 1

set t_Co=256
set cursorline
" 22 for nice green line
hi CursorLine ctermbg=235 cterm=none

au BufWinEnter *.py let w:m1=matchadd('Search', '\%>80v.*', -1)

autocmd FileType python set omnifunc=pythoncomplete#Complete
"tab auto complete
function InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\"
    else
        return "\<c-p>"
    endif
endfunction

imap <c-r>=InsertTabWrapper()"show auto complete options
set complete=""
set complete+=.
set complete+=k
set complete+=b
set complete+=t
"set dictionary+=.vim/autoload/autocomplit.dict

autocmd FileType python compiler pylint
let g:pylint_show_rate = 0
let g:pylint_onwrite = 0
let g:NERDTreeIgnore = ['^.\+\.pyc$', '^.\+\.o$', '^.\+\.so$']
let g:session_autosave = 1
let g:session_autoload = 0
"let g:loaded_session = 1
set sessionoptions-=tabpages

" template for python files
autocmd BufNewFile *.py 0r ~/.vim/templates/py.tmpl

"autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``
"autocmd BufReadPost *.py normal :%s/\_s\+\_$//g
"map <c-f9> :%s/\.\+\(\_s\+\)\_$//g<cr>

autocmd BufRead,BufWrite *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class

autocmd BufRead,BufWrite *.py map <f1> :Pydoc <C-r><C-w><cr>
map <f2> :w<cr>
map <f3> :Tlist<cr>
map <f4> :NERDTreeToggle<cr>
map <f5> :call Pyflakes()\|NERDTreeClose\|w\|!python % <cr>
autocmd BufRead,BufWrite *.sh map <f5> :w\|!bash %<cr>
autocmd BufRead,BufWrite *.c map <f5> :w\|!cc % -o %:r\|./%:r<cr>
autocmd BufRead,BufWrite *.cpp map <f5> :w\|!gcc % -o %:r\|./%:r<cr>
" %:e - current file extenstion (%)
map <f7> :execute "vimgrep /" . expand("<cword>") . "/j ********/*.%:e" <Bar> cw<CR>
map <f9> :set hls!<cr>
map <f10> :OpenSession 
map <c-f10> :SaveSession 

map <s-tab> :tabnext<cr>
map <c-s-tab> :tabpewvious<cr>

imap <s-tab> <esc>:tabnext<cr>
imap <c-s-tab> <esc>:tabpewvious<cr>

:nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

"inoremap {<Space>      {}<Left>
"inoremap {<CR>  {<CR>}<Esc>O
"inoremap {}     {}
"inoremap (<Space>      ()<Left>
"inoremap ()     ()
"inoremap /*<Space>       /**/<Left><Left>
"inoremap /*<Space>   /*<Space><Space>*/<Left><Left><Left>
"inoremap /*<CR>      /*<CR>*/<Esc>O
"inoremap def<Space>     def ():<Left><Left><Left>
"inoremap class<Space>     class (object):<Left><Left><Left><Left><Left><Left><Left><Left><Left>

let g:pydoc_cmd = "/usr/bin/pydoc"
let g:pydoc_highlight=0

command Pyflakes :call Pyflakes()
function! Pyflakes()
    let tmpfile = tempname()
    execute "w" tmpfile
    execute "set makeprg=(pyflakes\\ " . tmpfile . "\\\\\\|sed\\ s@" . tmpfile ."@%@)"
    silent make
    cw
endfunction

command Pylint :call Pylint()

abbr weigth weight
abbr lenght length
abbr rigth right
abbr improt import
