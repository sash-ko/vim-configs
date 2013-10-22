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

set mouse=a
set mousem=popup

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

" http://vim.wikia.com/wiki/Switch_between_Vim_window_splits_easily
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

" Configure bundles

filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

Bundle "motus/pig.vim"

Bundle "scrooloose/nerdtree"
Bundle "L9"
Bundle "kien/ctrlp.vim"

Bundle "slack/vim-bufexplorer"
Bundle "cordarei/vim-python-syntax"
Bundle "kevinw/pyflakes-vim"
Bundle "Crapworks/python_fn.vim"
Bundle "tpope/vim-fugitive"
Bundle "mileszs/ack.vim"
Bundle "motemen/git-vim"
"Bundle "xolox/vim-session"
Bundle "vim-scripts/YankRing.vim"
Bundle "vim-scripts/pydoc.vim"
Bundle "vim-scripts/taglist.vim"
Bundle "vim-scripts/mru.vim"
Bundle "ervandew/supertab"
Bundle "nvie/vim-flake8"
Bundle "guns/vim-clojure-static"
Bundle "kien/rainbow_parentheses.vim"
Bundle "tpope/vim-fireplace"
Bundle "tpope/vim-classpath"
Bundle "derekwyatt/vim-scala"

filetype plugin indent on

""""""

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

map  ]3   :call PythonCommentSelection()<CR>
vmap ]3   :call PythonCommentSelection()<CR>

" NERDTree
let g:NERDTreeIgnore = ['^.\+\.pyc$', '^.\+\.o$', '^.\+\.so$', '\.\w\+\~$', '^.\+\.egg-info$', '^dist$', '^.\+\.tar.gz$']
let g:NERDTreeChDirMode = 2

" Ctrlp
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn|lib)$',
    \ 'file': '\v\.(o|so|exe|dll|bak|orig|swp|jar|bat|pyc|html|class|pdf|bson|ods|jpg|png|tar|gz|bz2|zip|pickle)$',
    \ }

let g:ctrlp_match_window_bottom = 1
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_by_filename = 1
let g:ctrlp_max_height = 15

" tag list
let Tlist_Use_Right_Window = 1
let TList_Auto_Highlight_Tag = 1
let TList_Auto_Update = 1

" ====== Python specific ======

let g:pep8_map='<leader>8'

highlight OverLength ctermbg=darkgrey ctermfg=white guibg=Gray16
autocmd Filetype python match OverLength /\%81v.\+/

"if has("gui_running")
"    highlight colorcolumn guibg=Gray16
"else
"    highlight colorcolumn ctermbg=DarkGray
"endif
"autocmd Filetype * set colorcolumn=0
"autocmd Filetype python set colorcolumn=80

" template for python files
autocmd BufNewFile *.py 0r ~/.vim/templates/py.tmpl
autocmd BufEnter,BufWrite *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd BufEnter,BufWrite *.py map <F1> :Pydoc <C-r><C-w><cr>

augroup filetypedetect
  au BufNewFile,BufRead *.pig set filetype=pig syntax=pig
augroup END

command Pyflakes :call Pyflakes()
function! Pyflakes()
    let tmpfile = tempname()
    execute "w" tmpfile
    execute "set makeprg=(pyflakes\\ " . tmpfile . "\\\\\\|sed\\ s@" . tmpfile ."@%@)"
    silent make
    cw
endfunction

" ====== C/C++ specific ======

function! HideComments()
    set foldmarker=/*,*/
    set foldmethod=marker
    set foldenable
endfunction

autocmd BufEnter *.cpp,*.h,*.c,*.hpp execute "call HideComments()"
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

let g:ackprg="ack-grep -H --nocolor --nogroup --column"

map <F2> :w<CR>
map <F3> :Tlist<CR>
map <F4> :NERDTreeToggle<CR>
map <F5> :call ExecuteFile()<CR>
map <C-F7> :execute "vimgrep /" . expand("<cword>") . "/j ********/*.%:e" <Bar> cw<CR>
"map <C-F7> [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
map <F9> :set hls!<CR>
nnoremap <silent> <F11> :YRShow<CR>

map <S-Tab> :tabnext<CR>
map <C-S-Tab> :tabpewvious<CR>

imap <S-Tab> <ESC>:tabnext<CR>
imap <C-S-Tab> <ESC>:tabpewvious<CR>

nnoremap <leader>ff :CtrlPMixed<cr>

nnoremap <Leader>r :NERDTreeFind<CR>

" find and replace
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>

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

au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
