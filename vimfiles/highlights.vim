" colorscheme vim
"set notermguicolors

syntax on
colorscheme default
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

highlight Normal guibg=#1E1E1E
highlight Normal        guifg=#D4D4D4
highlight Statement     guifg=#569CD6
highlight NonText       guifg=#A9A9A9
highlight SpecialKey    guifg=#00FF00
highlight Comment       guifg=#6A9955
highlight LineNr        guifg=#A9A9A9
highlight CursorLineNr  guifg=#000000 guibg=#D3D3D3
highlight Type          guifg=#569CD6
highlight Number        guifg=#B5CEA8
highlight String        guifg=#CE9178
highlight Character     guifg=#90EE90
highlight Special       guifg=#D7BA7D
highlight Boolean       guifg=#008B8B
highlight Label         guifg=#FF0000
highlight Constant      guifg=#C586C0

highlight StatusLine    guifg=#0000FF guibg=#D3D3D3
highlight Search        guifg=#000000 guibg=#00FFFF
highlight IncSearch     gui=reverse cterm=reverse guifg=NONE guibg=NONE

highlight qfFileName    guifg=#90EE90

highlight Search        guibg=#008B8B
highlight CurSearch     guibg=#FF0000

highlight Directory     guifg=#008B8B
highlight PreProc       guifg=#569CD6

highlight Todo          guifg=#009900
highlight Func          guifg=#DCDCAA


augroup custom_syntax_highlights
  autocmd!
  autocmd FileType c,cpp,objc,objcpp,java,lua call ApplySyntaxC()
  autocmd FileType rust call ApplySyntaxRust()
  autocmd BufRead,BufNewFile *.y,*.l set filetype=c
augroup END

function ApplySyntaxC()
    syntax cluster cPreProcGroup add=cCustomFunc
    syntax match cCustomFunc "\w\+\ze\s*("
    syntax match cCustomFuncPtr "[( \t*]*\i\+[) \t*]*\[.\+\][) \t]*\ze("

    syntax match cCustomType  "\(\%(\.\s*\w*\)\s*\)\@<!\(\w\+\ze[ \t\n*]\+\w\)"
    syntax cluster cPreProcGroup add=cCustomType
    syntax match cCustomTypeCast "\(\%(\w\+\)\s*\)\@<!(\(\s*\w\+[ \t*]*\)\+)\ze[ \t*)(]*\i"
    highlight link cCustomType Type
    highlight link cCustomTypeCast Type
    highlight link cCustomFuncPtr cCustomFunc
    highlight link cCustomFunc    Func 
endfunction

function ApplySyntaxRust()
    highlight link rustFuncName Func
    highlight link rustFuncCall Func
    highlight link rustOperator Normal
    highlight link rustIdentifier Normal
    highlight link rustModPathSep Normal
endfunction


" Invisible characters -------------------------------------------------------
:au InsertEnter * set list
:au InsertLeave * set nolist
:set listchars=eol:$,tab:>·,trail:·,extends:>,precedes:<,space:·
