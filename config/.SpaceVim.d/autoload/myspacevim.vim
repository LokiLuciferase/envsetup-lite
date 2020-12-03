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
    autocmd BufNewFile,BufRead *.config set ft=nextflow
endfunction

function! myspacevim#after() abort
    inoremap <S-Tab> <C-d>
endfunction

