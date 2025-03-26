" Quickfix -------------------------------------------------------------------

" autocmd CursorMoved * call s:QuickFixAutoPreview()
" :autocmd CursorMoved * call timer_start(1, { -> QuickFixAutoPreview() })
nnoremap <C-j> :cn<CR>
nnoremap <C-k> :cp<CR>

" Normal search
nnoremap <leader>sss :call QuickfixDoubleSearch('content', 0)<CR>
nnoremap <leader>ssf :call QuickfixDoubleSearch('filename', 0)<CR>

" Inverted search (filter out matches)
nnoremap <leader>sns :call QuickfixDoubleSearch('content', 1)<CR>
nnoremap <leader>snf :call QuickfixDoubleSearch('filename', 1)<CR>

" TODO: Implement logic to undo previous sss/ssf/sns/snf

function! QuickfixDoubleSearch(type, invert)
    " Prompt for search pattern with a default hint
    let l:second_pattern = input('Enter pattern to filter quickfix list: ')
    if empty(l:second_pattern)
        echo "No pattern entered."
        return
    endif

    " Get the current quickfix list
    let l:current_qflist = getqflist()

    if empty(l:current_qflist)
        echo "Quickfix list is empty."
        return
    endif

    " Prepare the filter pattern based on invert flag
    let l:match_operator = a:invert ? '!~' : '=~'

    " Filter by content or filename
    if a:type == 'content'
        let l:new_qflist = filter(l:current_qflist, 'v:val.text ' . l:match_operator . ' l:second_pattern')
    elseif a:type == 'filename'
        let l:new_qflist = filter(l:current_qflist, 'bufname(v:val.bufnr) ' . l:match_operator . ' l:second_pattern')
    else
        echo "Unknown search type."
        return
    endif

    " If no matches found, echo a message and return
    if empty(l:new_qflist)
        echo "No matches found in the quickfix list."
    endif

    " Update the quickfix list with filtered results and open quickfix window
    call setqflist(l:new_qflist)
    copen
endfunction

function! QuickFixAutoPreview()
    if &buftype == 'quickfix'
        let line_num = line('.')
        let l:winnr = winnr()
        execute 'cc ' . l:line_num
        if l:winnr !=# winnr()
            wincmd p
        endif
    endif
endfunction
