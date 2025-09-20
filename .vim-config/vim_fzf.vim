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
        \ 'options': '--preview "cat {}"'
        \ }))
endfunction

function! FzfListAllTags()
    if !filereadable('tags')
        echo "No tags file found. Run :!ctags -R . to generate one."
        return
    endif
    call fzf#run(fzf#wrap({
        \ 'source': 'cat tags | cut -f1',
        \ 'sink': 'tjump',
        \ 'options': '--preview "cat {}"'
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
        \ 'options': '--preview "cat {}"'
        \ }))
endfunction

function! FzfGrepOpen(selected)
    let parts = split(a:selected, ':')
    let filename = parts[0]
    let line = parts[1]
    execute 'e ' . filename
    execute line
endfunction
