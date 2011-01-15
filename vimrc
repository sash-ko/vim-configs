" ====== General ======

set nocompatible "non Vi-compatible
set nu "show line number
set incsearch
set ignorecase
set autoindent "copy indent from current line
set shiftwidth=4
set tabstop=4
set smarttab
set expandtab
set softtabstop=4
set novisualbell
set wrap
set linebreak
set backup
set writebackup
set noswapfile
set history=200
set encoding=utf-8
set infercase "adjusting completetion case to the typed case
set wildmenu

syntax on
colorscheme desert

filetype on
filetype plugin on

"thesaurus

set title
set titlelen=50

set t_Co=256
set cursorline
" 22 for nice green line
hi CursorLine ctermbg=235 cterm=none

function ShowGitBranch()
    let b=GitBranch()
    if b != "" 
        return "git branch:" . b 
    else 
        return '' 
    endif
endfunction

set statusline=[%l,%c\ %P%M]\ %f\ %r%h%w\ %{ShowGitBranch()}
set laststatus=2 " to display status line always
"set ruler

" ====== Plugins config ======

let python_highlight_all = 1
let g:pydoc_cmd = "/usr/bin/pydoc"
let g:pydoc_highlight=0

" pylint
autocmd FileType python compiler pylint
let g:pylint_show_rate = 0
let g:pylint_onwrite = 0

" NERDTree
let g:NERDTreeIgnore = ['^.\+\.pyc$', '^.\+\.o$', '^.\+\.so$']

" sessions
let g:session_autosave = 1
let g:session_autoload = 0
"let g:loaded_session = 1
set sessionoptions-=tabpages

" ====== Other ======

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
" default complete is good enough
"set complete=".kbtw"
"set dictionary+=.vim/autoload/autocomplit.dict

" template for python files
autocmd BufNewFile *.py 0r ~/.vim/templates/py.tmpl

"autocmd BufWritePre *.py normal m`:%s/\s\+$//e ``
"autocmd BufReadPost *.py normal :%s/\_s\+\_$//g
"map <c-f9> :%s/\.\+\(\_s\+\)\_$//g<cr>

"set cindent for c and c++
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

" ====== Menu.Tools ======

command OpenTmpWindow :call OpenTmpWindow()
function! OpenTmpWindow()
    let tmpfile = tempname()
    execute "w" tmpfile
    split tmpfile
    set filetype=sql
endfunction
:menu Tools.SaveSudo :w !sudo tee %<CR>
:menu Tools.Tmp :OpenTmpWindow<CR>

" ====== Menu.Postgres ======

let g:pg_version="8.4"
"let g:pg_version=execute "!pg_config | grep 'VERSION' | grep -o -P '\d.\d'"
let g:pg_daemon="/etc/init.d/postgresql-" . pg_version
let g:pg_access=""
"uncomment if current user does not have access to db
"let g:pg_access="sudo -u postgres "

command ShowDatabases :call ShowDatabases()
function! ShowDatabases()
    botright new
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    execute "$read !" . g:pg_access . " psql -l"
    silent! execute 'resize ' . line('$')
    silent! execute 1
    setlocal nomodifiable
endfunction

function! GetDBCn()
    if exists("g:pg_default_db")    
        let dbname=g:pg_default_db
    else
        let dbname=input('dbname: ')
    endif
    return 'psql -d ' . dbname
endfunction

command SetDefaultDB :call SetDefaultDB()
function! SetDefaultDB()
    let change='y'
    if exists("g:pg_default_db")    
        echo "Current default db is '" . g:pg_default_db . "'"
        let change=input('change (y/n): ')
    endif
    if change=='y'
        let g:pg_default_db=input('dbname: ')
    endif
endfunction

" usage :em Postgres.Connect
:menu Postgres.Connect :execute "!" . pg_access . " " . GetDBCn() . ""<CR>
:menu Postgres.ExecuteAll :execute "!" . pg_access . " " . GetDBCn() . " < % <BAR> less"<CR>
:menu Postgres.DefaultDb :SetDefaultDB <CR>
:menu Postgres.Restart :execute "!sudo su -c '" . pg_daemon . " stop && " . pg_daemon . " start'"<CR>
:menu Postgres.Configure :execute "e /etc/postgresql/" . pg_version . "/main/postgresql.conf"<CR>
" copy configs to db dir, e.g. cp synonym_geocode.syn /usr/share/postgresql/8.4/tsearch_data/
:menu Postgres.CopyTo :execute "!sudo cp % /usr/share/postgresql/" . pg_version . "/"
:menu Postgres.Upload :execute "!" . pg_access ." '" . GetDBCn() . " -f % "<CR>
:menu Postgres.DBList :ShowDatabases <CR>
