" rg --vimgrep --hidden --glob '!*.out' --glob '!*.c.sav' 'Llc;'
"grep -rnI --exclude="*.c" --exclude="*.c.sav"  'Llc;'

nnoremap \sa :call GrepText()<CR>
nnoremap \sf :call GrepFileName()<CR>

let g:has_rg = executable('rg')
let g:grep_ignore_list = ['.git', 'cscope.out', 'tags', '*.c.sav', '*.u', '*.pem']

function! BuildIgnoreParams()
    let l:ignore_params = []
    for ignore in g:grep_ignore_list
        if g:has_rg
            call add(l:ignore_params, "--glob '!". ignore . "'")
        else
            call add(l:ignore_params, "--exclude=" . ignore)
        endif
    endfor
    return join(l:ignore_params, ' ')
endfunction

function! BuildGrepTextCommand(pattern)
    if g:has_rg
        return "rg --vimgrep --hidden " . BuildIgnoreParams() . " " . shellescape(a:pattern)
    else
        return "grep -rnI " . BuildIgnoreParams() . " " . shellescape(a:pattern) . " ."
    endif
endfunction

function! BuildGrepFilesCommand(pattern)
    if g:has_rg
        return "rg --files -g '*" . a:pattern . "*' --hidden"
    else
        return "find . -type f -name '*" . a:pattern . "*'"
    endif
endfunction

function! GrepText()
    let l:pattern = input("Enter text to search: ")
    if empty(l:pattern)
        echo "No pattern entered"
        return
    endif
    let l:command = BuildGrepTextCommand(l:pattern)
    let l:results = systemlist(l:command)
    if empty(l:results)
        echo "No matches found"
        return
    endif
    call setqflist(map(l:results, { idx, val -> {
                \ 'filename': split(val, ':')[0],
                \ 'lnum': str2nr(split(val, ':')[1]),
                \ 'col': 1,
                \ 'text': join(split(val, ':')[2:], ':')
                \ } }))
    " execute "vertical 40 cwindow"
    execute "vertical " . (winwidth(0) / 2) . " cwindow"
    " cwindow
endfunction

function! GrepFileName()
    let l:pattern = input("Enter file name or path to search: ")
    let l:results = systemlist(BuildGrepFilesCommand(l:pattern))
    if empty(l:results)
        echo "No matches found"
        return
    endif
    call setqflist(map(l:results, { idx, val -> {'filename': val, 'lnum': 1, 'text': 'File: ' . val} }))
    "execute "vertical 40 cwindow"
    execute "vertical " . (winwidth(0) / 2) . " cwindow"
    "cwindow
endfunction

