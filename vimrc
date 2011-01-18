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
set noequalalways

set complete+=k~/.vim/autoload/autocomplit.dict
set complete+=s~/.vim/autoload/autocomplit.ths

syntax on
colorscheme desert

filetype on
filetype plugin on

set title
set titlelen=50
autocmd VimLeave * let &titleold=getcwd()
autocmd VimEnter * :redraw

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
let g:NERDTreeIgnore = ['^.\+\.pyc$', '^.\+\.o$', '^.\+\.so$', '\.\w\+\~$']

" sessions
let g:session_autosave = 1
let g:session_autoload = 0
"let g:loaded_session = 1
set sessionoptions-=tabpages

" ====== Python specific ======

autocmd BufWinEnter *.py let w:m1=matchadd('Search', '\%>80v.*', -1)
" template for python files
autocmd BufNewFile *.py 0r ~/.vim/templates/py.tmpl
autocmd BufEnter,BufWrite *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufEnter,BufWrite *.py map <F1> :Pydoc <C-r><C-w><cr>

command Pyflakes :call Pyflakes()
function! Pyflakes()
    let tmpfile = tempname()
    execute "w" tmpfile
    execute "set makeprg=(pyflakes\\ " . tmpfile . "\\\\\\|sed\\ s@" . tmpfile ."@%@)"
    silent make
    cw
endfunction

command Pylint :call Pylint()

" ====== Key mappings ======

function! ExecuteFile()
    execute "NERDTreeClose"
    execute "w"

    let ext = expand('%:e')
    if ext == "py"
        execute "call Pyflakes()"
        execute "!python %"
    elseif ext == "sh"
        execute "!bash %"
    elseif ext == "c"
        execute "!cc % -o %:r"<CR>
        execute "!./%:r"
    elseif ext == "cpp"
        execute "!gcc % -o %:r"<CR>
        execute "./%:r"
    elseif ext == "html"
        execute "!firefox %"
    else
        echo "Can not execute file " . expand("%")
    endif
endfunction

autocmd BufRead,BufWrite .vimrc map <F1> :help <C-r><C-w><cr>
map <F2> :w<CR>
map <F3> :Tlist<CR>
map <F4> :NERDTreeToggle<CR>
map <F5> :call ExecuteFile()<CR>
map <F7> :execute "vimgrep /" . expand("<cword>") . "/j ********/*.%:e" <Bar> cw<CR>
map <F9> :set hls!<CR>
map <F10> :OpenSession 
map <C-F10> :SaveSession 

map <S-Tab> :tabnext<CR>
map <C-S-Tab> :tabpewvious<CR>

imap <S-Tab> <ESC>:tabnext<CR>
imap <C-S-Tab> <ESC>:tabpewvious<CR>

" find and replace
:nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

function! FindAndReplace()
    let f = input("find: ")
    let r = input("replace by: ")
    execute ':%s/\<' . f . '\>/' . r . '/g'
    echo f . ' replaced by ' . r
endfunction
:map <C-h> :call FindAndReplace()<CR>

" ====== Other ======

function! ErlTemplate()
    execute "normal i-module(" . expand('%:r') . ").\n-export(export_all).\n"
endfunction

autocmd BufNewFile,BufEnter,BufWrite *.c,*.cpp set cindent
autocmd BufNewFile *.erl :call ErlTemplate()

inoremap {<Space>      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {}     {}
inoremap (<Space>      ()<Left>
inoremap ()     ()
"inoremap /*<Space>       /**/<Left><Left>
"inoremap /*<Space>   /*<Space><Space>*/<Left><Left><Left>
"inoremap /*<CR>      /*<CR>*/<Esc>O
"inoremap def<Space>     def ():<Left><Left><Left>
"inoremap class<Space>     class (object):<Left><Left><Left><Left><Left><Left><Left><Left><Left>

" ====== Abbreviations ======

abbr weigth weight
abbr lenght length
abbr rigth right
abbr improt import
abbr heigth height

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
        if !exists("s:pg_last_db")
            let s:pg_last_db = ""
        endif
        let dbname=input('dbname: ', s:pg_last_db)
        let s:pg_last_db = dbname
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

function! PgAdminExecute()
    silent! execute "w"
    botright new 'results'
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    let dbcn = GetDBCn()
    silent! execute "$read !" . g:pg_access . " " . dbcn . " < " . s:pg_admin_tab
endfunction

command PgAdmin :call PgAdmin()
function! PgAdmin()
    if !exists("s:pg_admin_tab")
        let s:pg_admin_tab = tempname() . '-pg_admin'
    endif
    execute ":tabnew " . s:pg_admin_tab
    map <buffer> <f5> :call PgAdminExecute()<CR>
endfunction

" usage :em Postgres.Connect
:menu Postgres.PgAdmin :PgAdmin<CR>
:menu Postgres.Connect :execute "!" . pg_access . " " . GetDBCn() . ""<CR>
:menu Postgres.ExecuteAll :execute "!" . pg_access . " " . GetDBCn() . " < % <BAR> less"<CR>
:menu Postgres.DefaultDb :SetDefaultDB <CR>
:menu Postgres.Restart :execute "!sudo su -c '" . pg_daemon . " stop && " . pg_daemon . " start'"<CR>
:menu Postgres.Configure :execute "e /etc/postgresql/" . pg_version . "/main/postgresql.conf"<CR>
" copy configs to db dir, e.g. cp synonym_geocode.syn /usr/share/postgresql/8.4/tsearch_data/
:menu Postgres.CopyTo :execute "!sudo cp % /usr/share/postgresql/" . pg_version . "/"
:menu Postgres.Upload :execute "!" . pg_access ." '" . GetDBCn() . " -f % "<CR>
:menu Postgres.DBList :ShowDatabases <CR>
