source ~/.config/nvim/vimfiles/highlights.vim
source ~/.config/nvim/vimfiles/grep.vim
source ~/.config/nvim/vimfiles/quickfix.vim


function! OpenFileWithCompletion()
  let l:fname = input('Open file: ', '', 'file')
  if filereadable(l:fname)
    execute 'edit' fnameescape(l:fname)
  endif
endfunction

command! OpenFile call OpenFileWithCompletion()
