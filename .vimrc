source ~/.vim-config/highlights.vim
source ~/.vim-config/grep.vim
source ~/.vim-config/quickfix.vim
source ~/.vim-config/utils.vim
source ~/.vim-config/vim_fzf.vim
source ~/.vim-config/vim_cscope.vim




" Git ------------------------------------------------------------------------

function! GitBlameCurrentLine()
  let l:line = line(".")
  let l:file = expand("%:p")
  let l:blame_info = system('git blame -L ' . line(".") . ',' . l:line . ' -- ' . shellescape(expand("%:p")) . ' --date=iso')
  echom l:blame_info
endfunction
nnoremap <leader>gb :call GitBlameCurrentLine()<CR>

nnoremap <leader>gd :!git diff -p %<CR>
