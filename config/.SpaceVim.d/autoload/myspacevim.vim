function! myspacevim#before() abort
    let mapleader=","
    let g:neoformat_python_black = {
    \ 'exe': 'black',
    \ 'stdin': 1,
    \ 'args': ['-q', '-', '-S', '-l', '100'],
    \ }
	let g:neoformat_enabled_python = ['black']
    autocmd VimEnter * silent NERDTree | wincmd p
    set mouse=
    set clipboard=unnamed
    inoremap ^[c <C-o>:call NERDComment(0, "toggle")<C-m>]
    vnoremap ^[c :call NERDComment(0, "toggle")<C-m>]
    nnoremap ^[c :call NERDComment(0, "toggle")<C-m>]
endfunction

function! myspacevim#after() abort
    inoremap <S-Tab> <C-d>
endfunction

