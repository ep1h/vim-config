" Plugin manager setup
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

" Keybindings
nnoremap <leader>ff :call FzfListAllFiles()<CR>
nnoremap <leader>ft :call FzfListAllTags()<CR>
nnoremap <leader>fa :call FzfGrepAll()<CR>

" Functions
function! FzfListAllFiles()
    if executable('rg')
        let command = 'rg --files --hidden --glob "!.git/*"'
    else
        let command = 'find . -type f'
    endif
    call fzf#run(fzf#wrap({
        \ 'source': command,
        \ 'sink': 'e',
        \ 'options': '--preview "head -80 {}"'
        \ }))
endfunction

function! FzfListAllTags()
    if !filereadable('tags')
        echo "No tags file found. Run :!ctags -R . to generate one."
        return
    endif
    call fzf#run(fzf#wrap({
        \ 'source': 'cat tags | grep -v "^!" | cut -f1 | sort -u',
        \ 'sink': 'tjump',
        \ }))
endfunction

function! FzfGrepAll()
    let pattern = input("Enter pattern: ")
    if empty(pattern)
        echo "No pattern entered"
        return
    endif

    if executable('rg')
        let command = 'rg --vimgrep --hidden --glob "!.git/*" '.shellescape(pattern)
    else
        let command = 'grep -rnI '.shellescape(pattern).' .'
    endif

    call fzf#run(fzf#wrap({
        \ 'source': command,
        \ 'sink': function('FzfGrepOpen'),
        \ 'options': '--delimiter : --preview "head -80 {1}"'
        \ }))
endfunction

function! FzfGrepOpen(selected)
    let l:m = matchlist(a:selected, '^\(.\{-}\):\(\d\+\):')
    if empty(l:m)
        echo "Could not parse: " . a:selected
        return
    endif
    execute 'e ' . fnameescape(l:m[1])
    execute l:m[2]
endfunction
