" vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

" for vimfilter
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimfiler'

Plug 'Townk/vim-autoclose'

Plug 'bronson/vim-trailing-whitespace'

Plug 'ctrlpvim/ctrlp.vim'

" Initialize plugin system
call plug#end()

syntax on
filetype plugin indent off
colorscheme desert

" vimfiler
let g:vimfiler_as_default_explorer = 1

