" Ctags scan
nnoremap \Tscan :CtagsScan<CR>
command! -nargs=0 CtagsScan execute 'silent! call system("ctags -R -n .")' | echo "Ctags index updated."

" Terminal
nnoremap <leader>termw :call SpawnLocalTerm('top')<CR>
nnoremap <leader>terma :call SpawnLocalTerm('left')<CR>
nnoremap <leader>terms :call SpawnLocalTerm('bottom')<CR>
nnoremap <leader>termd :call SpawnLocalTerm('right')<CR>

function SpawnLocalTerm(position)
    let current_directory = expand('%:p:h')
    if a:position == "top"
        topleft term
    elseif a:position == "left"
        leftabove vert term
    elseif a:position == "bottom"
        bel term
    elseif a:position == "right"
        rightbelow vert term
    endif
    "resize 10
endfunction

" Clang-format 
nnoremap <Leader>cff :call FormatCurrentFile()<CR>
vnoremap <Leader>cfv :call FormatSelection()<CR>

function! GetClangFormatStyle()
    return '{' .
                \ '"Language": "Cpp",' .
                \ '"BasedOnStyle": "Microsoft",' .
                \ '"UseTab": "Never",' .
                \ '"ColumnLimit": 80,' .
                \ '"SortIncludes": false,' .
                \ '"PointerAlignment": "Left",' .
                \ '"AlignConsecutiveMacros": false,' .
                \ '"AlignAfterOpenBracket": "DontAlign",' .
                \ '"BraceWrapping": { "AfterCaseLabel": true },' .
                \ '"MaxEmptyLinesToKeep": 3,' .
                \ '"AccessModifierOffset": -4,' .
                \ '"IndentExternBlock": "NoIndent"' .
                \ '}'
endfunction

" Format the current file 
function! FormatCurrentFile()
    let l:cursor_pos = getpos('.')
    let l:clang_format_style = GetClangFormatStyle()
    execute ':%!clang-format -style=' . shellescape(l:clang_format_style)
    call setpos('.', l:cursor_pos)
endfunction

" Format selected text
function! FormatSelection()
    let l:clang_format_style = GetClangFormatStyle()
    execute ":'<,'>!clang-format -style=" . shellescape(l:clang_format_style)
endfunction

" WSL Clipboard --------------------------------------------------------------
vnoremap <C-c> y:!echo <C-r>=escape(substitute(shellescape(getreg('"')), '\n', '\r', 'g'), '#%!')<CR> <Bar> clip.exe<CR><CR>

