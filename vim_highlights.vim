" Colorscheme -----------------------------------------------------------------

if exists("b:custom_syntax_applied")
  finish
endif
let b:custom_syntax_applied = 1

syntax clear
syntax on
"augroup custom_syntax_highlights
"  autocmd!
"  autocmd FileType c,cpp source ~/vim-config/vim_highlights.vim
"augroup END

" Define an autocmd group for custom syntax highlights
augroup custom_syntax_highlights
  autocmd!
  autocmd FileType c,cpp,objc,objcpp,java,lua call ApplySyntax()
  autocmd BufRead,BufNewFile *.y,*.l set filetype=c
augroup END

function ApplySyntax()
  " Functions
  syntax cluster cPreProcGroup add=cCustomFunc
  syntax match cCustomFunc "\w\+\ze\s*("
  syntax match cCustomFuncPtr "[( \t*]*\i\+[) \t*]*\[.\+\][) \t]*\ze("
  " Types
  "syntax match cCustomType "\w\+\ze[ \t\n*]\+\w"
  syntax match cCustomType  "\(\%(\.\s*\w*\)\s*\)\@<!\(\w\+\ze[ \t\n*]\+\w\)"
  syntax cluster cPreProcGroup add=cCustomType
  " Type casts
  "syntax match cCustomTypeCast      "(\(\s*\w\+[ \t*]*\)\+)"
  syntax match cCustomTypeCast "\(\%(\w\+\)\s*\)\@<!(\(\s*\w\+[ \t*]*\)\+)\ze[ \t*)(]*\i"
  highlight cCustomFunc     ctermfg=LightYellow
  highlight link cCustomFuncPtr cCustomFunc
  highlight link cCustomType Type
  highlight link cCustomTypeCast Type
endfunction

highlight Normal        ctermfg=LightGray
highlight LineNr        ctermfg=DarkGrey
highlight CursorLineNr  ctermfg=Black       ctermbg=LightGrey
highlight StatusLine    ctermfg=Blue        ctermbg=White
highlight SpecialKey    ctermfg=DarkGrey
highlight NonText       ctermfg=DarkGray

highlight Number        ctermfg=LightGreen
highlight Float         ctermfg=LightGreen
highlight String        ctermfg=LightGreen
highlight Character     ctermfg=LightGreen
highlight Boolean       ctermfg=DarkCyan
highlight Special       ctermfg=Green
highlight Constant      ctermfg=Magenta
highlight Label         ctermfg=Red


highlight Comment       ctermfg=DarkGrey
highlight PreProc       ctermfg=DarkMagenta
highlight Statement     ctermfg=DarkCyan
highlight Type          ctermfg=DarkCyan
highlight IncSearch     gui=reverse cterm=reverse gui=reverse
highlight Search        ctermfg=Black ctermbg=Cyan

highlight qfFileName    ctermfg=LightGreen
