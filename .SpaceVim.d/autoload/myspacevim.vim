function! myspacevim#before() abort
let mapleader=","
autocmd VimEnter * silent NERDTree | wincmd p
set mouse=
set clipboard=unnamed
inoremap ^[c <C-o>:call NERDComment(0, "toggle")<C-m>]
vnoremap ^[c :call NERDComment(0, "toggle")<C-m>]
nnoremap ^[c :call NERDComment(0, "toggle")<C-m>]
endfunction
