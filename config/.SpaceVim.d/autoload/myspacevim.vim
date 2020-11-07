function! myspacevim#before() abort
    let mapleader=","
    set mouse=
    set clipboard=unnamed
endfunction

function! myspacevim#after() abort
    inoremap <S-Tab> <C-d>
endfunction

