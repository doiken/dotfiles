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

" theme
Plug 'blueshirts/darcula'

" for vimfilter
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimfiler'

Plug 'Townk/vim-autoclose'

Plug 'tpope/vim-pathogen'
Plug 'scrooloose/syntastic'

Plug 'bronson/vim-trailing-whitespace'

Plug 'ctrlpvim/ctrlp.vim'

Plug 'majutsushi/tagbar'

" Initialize plugin system
call plug#end()

syntax on
filetype plugin indent off
colorscheme darcula

" vimfiler
let g:vimfiler_as_default_explorer = 1

" syntastic
execute pathogen#infect()
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
" let g:syntastic_enable_perl_checker = 1
" let g:syntastic_perl_checkers = ['perl', 'podchecker']
