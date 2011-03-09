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
set noswapfile
set history=200
set encoding=utf-8
set infercase "adjusting completetion case to the typed case
set wildmenu
set noequalalways
set viminfo+=! " to save global variables in viminfo (uppercase only!)

set backup
set writebackup
if filewritable('/tmp')
    set backupdir=/tmp
endif

set complete+=k~/.vim/autoload/autocomplit.dict
set complete+=s~/.vim/autoload/autocomplit.ths
"set complete-=t "exclude tags from complete - performace issues

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
set ruler

set tags=tags
"set tags+=~/.ctags/tags

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

" tag list
let Tlist_Use_Right_Window = 1
let TList_Auto_Highlight_Tag = 1
let TList_Auto_Update = 1

" ====== Python specific ======

autocmd BufEnter *.py let w:m1=matchadd('Search', '\%>80v.*', -1)
autocmd BufLeave *.py :silent! call matchdelete(w:m1)
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

" ====== C/C++ specific ======

function! HideComments()
    set foldmarker=/*,*/
    set foldmethod=marker
    set foldenable
endfunction

autocmd BufEnter *.cpp,*.h,*.c,*.hpp execute "call HideComments()"
autocmd BufEnter *.cpp,*.h,*.c,*.hpp nmap <F6> :A<CR>
autocmd BufEnter *.cpp,*.h,*.c,*.hpp nmap <S-i> :IHS<CR>
autocmd BufNewFile,BufEnter,BufWrite *.c,*.cpp,*.h,*.hpp set cindent

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
map <C-F7> [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
map <F9> :set hls!<CR>
map <F10> :OpenSession<CR>
map <C-F10> :SaveSession 
nnoremap <silent> <F11> :YRShow<CR>

map <S-Tab> :tabnext<CR>
map <C-S-Tab> :tabpewvious<CR>

imap <S-Tab> <ESC>:tabnext<CR>
imap <C-S-Tab> <ESC>:tabpewvious<CR>

"FuzzyFinder mappings
map <Leader>fe :FufCoverageFile!<CR>
map <Leader>te :FufBufferTagAll<CR>

" find and replace
:nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

function! FindAndReplace()
    let f = input("find: ", expand("<cword>"))
    if f != ''
        let r = input("replace by: ", f)
        silent! execute ':%s/\<' . f . '\>/' . r . '/g'
        echo f . ' replaced by ' . r
    else
        echo
    endif
endfunction
:map <C-h> :call FindAndReplace()<CR>

" ====== Other ======

function! ErlTemplate()
    execute "normal i-module(" . expand('%:r') . ").\n-compile(export_all).\n"
endfunction

autocmd BufNewFile *.erl :call ErlTemplate()

inoremap {<Space>      {}<Left>
inoremap {<CR>  {<CR>}<Esc>O
inoremap {}     {}
"inoremap (<Space>      ()<Left>
"inoremap ()     ()
"autocmd BufEnter *.c,*.cpp inoremap /*<Space>       /**/<Left><Left>
"autocmd BufEnter *.c,*.cpp inoremap /*<CR>      /*<CR>*/<Esc>
"inoremap /*<Space>   /*<Space><Space>*/<Left><Left><Left>
"inoremap def<Space>     def ():<Left><Left><Left>
"inoremap class<Space>     class (object):<Left><Left><Left><Left><Left><Left><Left><Left><Left>

" ====== Abbreviations ======

abbr weigth weight
abbr lenght length
abbr rigth right
abbr improt import
abbr heigth height

" ====== Menu.Tools ======

:menu Tools.SaveSudo :w !sudo tee %<CR>

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
        if !exists("g:PG_LAST_DB")
            let g:PG_LAST_DB = ""
        endif
        let dbname=input('dbname: ', g:PG_LAST_DB)
        let g:PG_LAST_DB = dbname
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
    let s:pg_admin_tab = "~/.vim_pg_admin_edit"
    execute ":tabnew " . s:pg_admin_tab
    map <buffer> <f5> :call PgAdminExecute()<CR>
endfunction

" usage :em Postgres.Connect
:menu Postgres.PgAdmin :PgAdmin<CR>
:menu Postgres.Connect :execute "!" . pg_access . " " . GetDBCn() . ""<CR>
:menu Postgres.ExecuteAll :execute "!" . pg_access . " " . GetDBCn() . " -f %" <CR>
:menu Postgres.DefaultDb :SetDefaultDB <CR>
:menu Postgres.Restart :execute "!sudo su -c '" . pg_daemon . " stop && " . pg_daemon . " start'"<CR>
:menu Postgres.Configure :execute "e /etc/postgresql/" . pg_version . "/main/postgresql.conf"<CR>
:menu Postgres.DBList :ShowDatabases <CR>
