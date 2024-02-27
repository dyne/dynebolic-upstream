set tabstop=8     " tabs are at proper location
set expandtab     " don't use actual tab character (ctrl-v)
set shiftwidth=4  " indenting is 4 spaces by default
set autoindent    " turns it on
set smartindent   " does the right thing (mostly) in programs
set cindent       " stricter rules for C programs

" set relativenumber
set number relativenumber

let mapleader = " " " map leader to Space

" == VIM PLUG ================================
call plug#begin('~/.vim/plugged')
"------------------------ THEME ------------------------
" Plug 'dikiaap/minimalist'
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-t> :NERDTree<CR>
nnoremap <C-s> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-repeat'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'feline-nvim/feline.nvim'

call plug#end()
" == VIMPLUG END ================================

" set background=dark
" colorscheme minimalist
colorscheme elflord

if has('nvim')
  tnoremap <Esc> <C-\><C-n>
  tnoremap <C-v><Esc> <Esc>
endif

if has('nvim')
  highlight! link TermCursor Cursor
  highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15
endif

" Normal mode
nnoremap <M-h> <c-w>h
nnoremap <M-j> <c-w>j
nnoremap <M-k> <c-w>k
nnoremap <M-l> <c-w>l

" split a'la emacs
nnoremap <C-x>2 :split<CR>
nnoremap <C-x>3 :vsplit<CR>


" Terminal mode
if has('nvim')
  tnoremap <M-h> <c-\><c-n><c-w>h
  tnoremap <M-j> <c-\><c-n><c-w>j
  tnoremap <M-k> <c-\><c-n><c-w>k
  tnoremap <M-l> <c-\><c-n><c-w>l
endif
" Insert mode
inoremap <M-h> <ESC><c-w>h
inoremap <M-j> <ESC><c-w>j
inoremap <M-k> <ESC><c-w>k
inoremap <M-l> <ESC><c-w>l
" Visual mode
vnoremap <M-h> <ESC><c-w>h
vnoremap <M-j> <ESC><c-w>j
vnoremap <M-k> <ESC><c-w>k
vnoremap <M-l> <ESC><c-w>l

nnoremap <silent> [b :bprevious<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [B :bfirst<CR>
nnoremap <silent> ]B :blast<CR>

" Expand to path of current buffer
map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

map ,o :FZF<CR>

set hidden

