source ~/vim-config/vim_highlights.vim
source ~/vim-config/vim_grep.vim
source ~/vim-config/vim_quickfix.vim
source ~/vim-config/vim_cscope.vim
source ~/vim-config/vim_fzf.vim



nnoremap \Tscan :CtagsScan<CR>
command! -nargs=0 CtagsScan execute 'silent! call system("ctags -R -n .")' | echo "Ctags index updated."

" Git Functions --------------------------------------------------------------
nnoremap <leader>gb :call GitBlameCurrentLine()<CR>

function! GitBlameCurrentLine()
  let l:line = line(".")
  let l:file = expand("%:p")
  let l:blame_info = system('git blame -L ' . line(".") . ',' . l:line . ' -- ' . shellescape(expand("%:p")) . ' --date=iso')
  echom l:blame_info
endfunction"

" Clang-format ---------------------------------------------------------------
nnoremap <Leader>cff :call FormatCurrentFile()<CR>
function! FormatCurrentFile()
    let l:cursor_pos = getpos('.')
    let l:clang_format_style = '{' .
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
    execute ':%!clang-format -style=' . shellescape(l:clang_format_style)
    call setpos('.', l:cursor_pos)
endfunction

" Terminal Split -------------------------------------------------------------
nnoremap <Leader>term :call SpawnLocalTerm()<CR>

function SpawnLocalTerm()
    let current_directory = expand('%:p:h')
    bel term
    resize 10
endfunction

" Invisible characters -------------------------------------------------------
:au InsertEnter * set list
:au InsertLeave * set nolist
:set listchars=eol:$,tab:>·,trail:·,extends:>,precedes:<,space:·

" General Settings  ----------------------------------------------------------
" set ut=250
" set timeoutlen=100
set number
set cursorline
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smartindent
set autoindent
set showmatch
set wildmenu
set incsearch
set hlsearch
