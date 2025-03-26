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

highlight Normal        ctermfg=LightGray
highlight Statement     ctermfg=DarkCyan
highlight NonText       ctermfg=DarkGray
highlight SpecialKey    ctermfg=DarkGrey
highlight Comment       ctermfg=DarkGrey
highlight LineNr        ctermfg=DarkGrey
highlight CursorLineNr  ctermfg=Black       ctermbg=LightGrey
highlight Type          ctermfg=DarkCyan
highlight Number        ctermfg=LightGreen
highlight String        ctermfg=LightGreen
highlight Character     ctermfg=LightGreen
highlight Special       ctermfg=Green
highlight Boolean       ctermfg=DarkCyan
highlight Label         ctermfg=Red
highlight Constant      ctermfg=Magenta

highlight StatusLine    ctermfg=Blue        ctermbg=LightGray
highlight Search        ctermfg=Black ctermbg=Cyan
highlight IncSearch     gui=reverse cterm=reverse gui=reverse

highlight qfFileName    ctermfg=LightGreen

highlight Search ctermbg=DarkCyan
highlight CurSearch ctermbg=Red

augroup custom_syntax_highlights
  autocmd!
  autocmd FileType c,cpp,objc,objcpp,java,lua call ApplySyntax()
  autocmd BufRead,BufNewFile *.y,*.l set filetype=c
augroup END

function ApplySyntax()
    syntax cluster cPreProcGroup add=cCustomFunc
    syntax match cCustomFunc "\w\+\ze\s*("
    syntax match cCustomFuncPtr "[( \t*]*\i\+[) \t*]*\[.\+\][) \t]*\ze("

    syntax match cCustomType  "\(\%(\.\s*\w*\)\s*\)\@<!\(\w\+\ze[ \t\n*]\+\w\)"
    syntax cluster cPreProcGroup add=cCustomType
    syntax match cCustomTypeCast "\(\%(\w\+\)\s*\)\@<!(\(\s*\w\+[ \t*]*\)\+)\ze[ \t*)(]*\i"
    highlight link cCustomType Type
    highlight link cCustomTypeCast Type


    highlight link cCustomFuncPtr cCustomFunc
    highlight cCustomFunc     ctermfg=LightYellow
endfunction

" Invisible characters -------------------------------------------------------
:au InsertEnter * set list
:au InsertLeave * set nolist
:set listchars=eol:$,tab:>·,trail:·,extends:>,precedes:<,space:·
