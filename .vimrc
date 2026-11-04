" Vim defaults for everyday editing and Python work.
set nocompatible
syntax enable
filetype plugin indent on

set background=dark
set encoding=utf-8
set number
set cursorline
set ruler
set showcmd
set hidden
set mouse=a
set splitbelow
set splitright
set scrolloff=5
set wildmenu
set wildmode=list:longest,full

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
set autoindent

set ignorecase
set smartcase
set incsearch
set hlsearch
set showmatch

set undofile
set undodir=~/.vim/undo//
set noerrorbells
set visualbell

" Install vim-plug using setup.sh before launching Vim.
call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree'
Plug 'Yggdroot/indentLine'
Plug 'ntpeters/vim-better-whitespace'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'junegunn/fzf.vim'
Plug 'mattn/emmet-vim'
Plug 'mg979/vim-visual-multi'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-surround'
Plug 'dense-analysis/ale'
call plug#end()

let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrows = 1
nnoremap <silent> <F6> :NERDTreeToggle<CR>
nnoremap <silent> <leader>n :NERDTreeToggle<CR>

" Keep Vim fast to launch: open NERDTree on demand instead of at startup.
let g:indentLine_enabled = 1
