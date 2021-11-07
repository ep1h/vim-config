" Plugin manager setup
call plug#begin('~/.vim/plugged')
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

nnoremap <leader>ff :call FzfListAllFiles()<CR>
nnoremap <leader>ft :call FzfListAllTags()<CR>
nnoremap <leader>fa :call FzfGrepAll()<CR>

let g:fzf_layout = { 'down': '40%' }
let g:fzf_preview_window = ['right:60%', 'ctrl-/']

function! FzfListAllFiles()
    let files = 'find . -type f'
    if executable('rg')
    let l:command = 'rg --files --hidden --follow --glob "!.git/*" --glob "!*.o" --glob "!*.out" --glob "!*.exe" --glob "!*.dll"'
        call fzf#run({
            \ 'source': l:command,
            \ 'sink': 'e',
            \ 'options': '--multi --reverse --preview "cat {}"',
            \ })
    else
        call fzf#run({
            \ 'source': 'find . -type f \( ! -path "*/.git/*" ! -name "*.o" ! -name "*.out" ! -name "*.exe" ! -name "*.dll" \)',
            \ 'sink': 'e',
            \ 'options': '--multi --reverse --preview "cat {}"',
            \ })
    endif
endfunction

function! FzfListAllTags()
    let l:tagsfile = findfile('tags', '.;')
    if empty(l:tagsfile)
        echo "Tags file not found."
        return
    endif
    let l:command = 'rg -v "^!" ' . shellescape(l:tagsfile)
    if executable('rg')
        call fzf#run({
            \ 'source': l:command,
            \ 'sink': function('FzfListAllTagsSink'),
            \ 'options': '--delimiter="\t" --with-nth=1,2 --preview "cat `echo {2} | awk ''{print $1}''`" --reverse',
            \ })
    else
        echo "ripgrep (rg) is not installed."
    endif
endfunction

function! FzfListAllTagsSink(selected_line)
    let l:fields = split(a:selected_line, '\t')
    if len(l:fields) < 3
        echo "Invalid tag format."
        return
    endif
    let l:tagname = l:fields[0]
    let l:filename = l:fields[1]
    let l:lineinfo = l:fields[2]
    let l:lnum = matchstr(l:lineinfo, '^\d\+')
    if empty(l:lnum)
        echo "Line number not found."
        return
    endif
    execute 'edit ' . fnameescape(l:filename)
    execute l:lnum
endfunction

function! FzfGrepAll()
    let l:pattern = input('Enter text to grep (Vim regex): ')
    if empty(l:pattern)
        echo "No pattern entered."
        return
    endif

    if executable('rg')
        " Use ripgrep (rg) if available
        let l:command = 'rg --vimgrep --hidden --follow --glob "!.git/*" ' . shellescape(l:pattern)
        call fzf#run({
            \ 'source': l:command,
            \ 'sink': function('FzfGrepSink'),
            \ 'options': '--multi --reverse --preview "echo {1} | cut -d '':'' -f 1 | xargs cat | head -n 500"',
            \ })
    else
        " Fallback to regular grep
        let l:command = 'grep -r -n ' . shellescape(l:pattern) . ' .'
        call fzf#run({
            \ 'source': l:command,
            \ 'sink': function('FzfGrepSink'),
            \ 'options': '--multi --reverse --preview "echo {1} | cut -d '':'' -f 1 | xargs cat | head -n 500"',
            \ })
    endif
endfunction

" Function to handle selected grep result
function! FzfGrepSink(selected_line)
    let l:fields = split(a:selected_line, ':')
    if len(l:fields) < 3
        echo "Invalid grep result format."
        return
    endif
    let l:filename = l:fields[0]
    let l:lnum = l:fields[1]
    execute 'edit ' . fnameescape(l:filename)
    execute l:lnum
endfunction

