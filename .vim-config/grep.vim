" rg --vimgrep --hidden --glob '!*.out' --glob '!*.c.sav' 'Llc;'
"grep -rnI --exclude="*.c" --exclude="*.c.sav"  'Llc;'

nnoremap \sa :call GrepText()<CR>
nnoremap \sf :call GrepFileName()<CR>

let g:has_rg = executable('rg')
let g:grep_ignore_list = ['Doxyfile', '.git', 'cscope.out', 'tags', '*.c.sav', '*.u', '*.pem']

function! BuildIgnoreParams()
    return join(map(copy(g:grep_ignore_list), { _, v -> g:has_rg ? "--glob '!". v . "'" : "--exclude=". v }), ' ')
endfunction

function! BuildGrepTextCommand(pattern)
    return g:has_rg
        \ ? "rg --vimgrep --hidden " . BuildIgnoreParams() . " " . shellescape(a:pattern)
        \ : "grep -rnI " . BuildIgnoreParams() . " " . shellescape(a:pattern) . " ."
endfunction

function! BuildGrepFilesCommand(pattern)
    return g:has_rg
        \ ? "rg --files -g '*" . a:pattern . "*' --hidden"
        \ : "find . -type f -name '*" . a:pattern . "*'"
endfunction

function! GrepText()
    let l:pattern = input("Enter text to search: ")
    if empty(l:pattern)
        echo "No pattern entered"
        return
    endif
    let l:results = systemlist(BuildGrepTextCommand(l:pattern))
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

