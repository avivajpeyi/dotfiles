set background=dark

syntax enable
filetype indent on
set number
set ai
set mouse=nicr
set mouse=a
set incsearch
set confirm
set number
set ignorecase
set smartcase
set wildmenu
set wildmode=list:longest,full
set laststatus=2 " Always display the statusline in all windows
set showtabline=2 " Always display the tabline, even if there is only one tab
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
set t_Co=256 "Use 256 colours
set modelines=0
set nu
set ruler
set tabstop=2
set softtabstop=2
set shiftwidth=4
set expandtab
set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set visualbell
set noerrorbells
set ttyfast
set cursorline
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
set wrap
set formatoptions=qrn1
set linebreak
set undolevels=20
set title
set noerrorbells
set noswapfile
set nobackup
set fileformats=unix,dos

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'yggdroot/indentline'
Plug 'ntpeters/vim-better-whitespace'
Plug 'powerline/powerline'
Plug 'itchyny/lightline.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mattn/emmet-vim'
Plug 'scrooloose/nerdtree'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'
Plug 'bling/vim-bufferline'
Plug 'nathanaelkane/vim-indent-guides'
call plug#end()

let g:airline_powerline_fonts = 1 " airline configs
let g:airline_solarized_bg='dark'


let g:better_whitespace_enabled=1 " whitespacing configs
let g:better_whitespace_ctermcolor='gray'


let g:indent_guides_enable_on_vim_startup = 1 " indentation
let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=gray
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=darkgray



set autochdir " NERDTree setting (workingdir the dir where file opened in vim)
let NERDTreeChDirMode=2 " make sure CWD is the current dir
nnoremap <leader>n :NERDTree .<CR> " opens NERDTree
 au VimEnter *  NERDTree " Auto-open NERDTree
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif " close NerdTree if file closed
nmap <F6> :NERDTreeToggle<CR>
" https://stackoverflow.com/questions/5817730/changing-root-in-nerdtree

