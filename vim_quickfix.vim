" Quickfix -------------------------------------------------------------------

" nnoremap <F8> :call <SID>QuickFixAutoPreview()<CR>
" autocmd CursorMoved * call s:QuickFixAutoPreview()
autocmd CursorMoved * call timer_start(1, { -> QuickFixAutoPreview() })
nnoremap <leader>sss :call QuickfixDoubleSearch()<CR>

function! QuickfixDoubleSearch()
    let l:second_pattern = input('Enter pattern to search within results: ')
    if empty(l:second_pattern)
        echo "No pattern entered."
        return
    endif
    " Get the current quickfix list
    let l:current_qflist = getqflist()
    " Prepare a new list for filtered results
    let l:new_qflist = []
    " Loop through the quickfix list and filter by the pattern
    for l:qf_entry in l:current_qflist
        " Check if the current entry text matches the pattern
        if l:qf_entry.text =~ l:second_pattern
            call add(l:new_qflist, l:qf_entry)
        endif
    endfor
    " If no matches were found, notify the user
    if empty(l:new_qflist)
        echo "No matches found in the quickfix list."
        return
    endif
    " Set the filtered quickfix list
    call setqflist(l:new_qflist)
    " Open the quickfix window to show the refined results
    copen
endfunction

function! QuickFixAutoPreview()
    if &buftype == 'quickfix'
        " let qf_list = getqflist({'idx': 0})
        " let idx = qf_list['idx']
        let line_num = line('.')
        let l:winnr = winnr()
        execute 'cc ' . l:line_num
        " call ApplySyntax()
        if l:winnr !=# winnr()
            wincmd p
        endif
    endif
endfunction

