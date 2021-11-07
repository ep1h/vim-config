
nnoremap \lt :call ListAllTags()<CR>
nnoremap \lf :call ListAllFiles()<CR>
nnoremap \sa :call GrepText()<CR>
nnoremap \sf :call GrepFileName()<CR>

function! ListAllTags()
    let l:tagsfile = findfile('tags', '.;')
    if empty(l:tagsfile)
        echo "Tags file not found."
        return
    endif
    " Use ripgrep to find all non-comment lines (lines not starting with '!') in the tags file
    if executable('rg')
        let l:command = 'rg -v "^!" ' . shellescape(l:tagsfile)
        let l:grep_output = systemlist(l:command)
        if empty(l:grep_output)
            echo "No valid tags found."
            return
        endif
        let l:items = []
        for l:line in l:grep_output
            let l:fields = split(l:line, "\t")
            if len(l:fields) < 3
                continue
            endif
            let l:tagname = l:fields[0]
            let l:filename = l:fields[1]
            let l:lineinfo = l:fields[2]
            let l:lnum = matchstr(l:lineinfo, '^\d\+')
            let l:item = {
                        \ 'filename': l:filename,
                        \ 'lnum': str2nr(l:lnum),
                        \ 'text': l:tagname,
                        \ 'col': 1
                        \ }
            call add(l:items, l:item)
        endfor
    else
        try
            let l:lines = readfile(l:tagsfile)
        catch
            echo "Failed to read tags file: " . l:tagsfile
            return
        endtry

        let l:items = []
        for l:line in l:lines
            if l:line =~ '^!'
                continue
            endif
            let l:fields = split(l:line, "\t")
            if len(l:fields) < 3
                continue
            endif
            let l:tagname = l:fields[0]
            let l:filename = l:fields[1]
            let l:lineinfo = l:fields[2]
            let l:lnum = matchstr(l:lineinfo, '^\d\+')
            let l:item = {
                        \ 'filename': l:filename,
                        \ 'lnum': str2nr(l:lnum),
                        \ 'text': l:tagname,
                        \ 'col': 1
                        \ }
            call add(l:items, l:item)
        endfor
    endif
    call setqflist(l:items, 'r')
    execute "vertical " . (winwidth(0) / 2) . " copen"
    if !empty(getqflist())
        cfirst
        wincmd p
    endif
endfunction



function! ListAllFiles()
    " Check if ripgrep is installed
    if executable('rg')
        let l:command = 'rg --files --hidden --glob "!.git/*" --glob "!*.o" --glob "!*.out"'
        let l:files = systemlist(l:command)
    else
        let l:files = systemlist('find . -type f \( ! -path "*/.git/*" ! -name "*.o" ! -name "*.out" \)')
    endif
    if empty(l:files)
        echo "No files found."
        return
    endif
    let l:qf_list = []
    for l:file in l:files
        let l:qf_entry = {'filename': l:file, 'lnum': 1, 'text': 'File: ' . l:file}
        call add(l:qf_list, l:qf_entry)
    endfor
    call setqflist(l:qf_list)
    tabnew
    execute "vertical " . (winwidth(0) / 2) . " copen"
    if !empty(getqflist())
        cfirst
        wincmd p
    endif
endfunction

function! GrepText()
    let l:pattern = input('Enter text to grep (Vim regex): ')
    if empty(l:pattern)
        echo "No pattern entered."
        return
    endif

    " If ripgrep is installed, use ripgrep
    if executable('rg')
        let l:command = 'rg --vimgrep --hidden --glob "!.git/*" --glob "!*.md" --glob "!*.o" --glob "!cscope.out" --glob "!cscope.in.out" --glob "!cscope.po.out" --glob "!tags" ' . shellescape(l:pattern)
        let l:grep_output = systemlist(l:command)
        if empty(l:grep_output)
            echo "No matches found."
            return
        endif
        call setqflist([]) " Clear previous quickfix list
        call setqflist(map(l:grep_output, '{"filename": split(v:val, ":")[0], "lnum": split(v:val, ":")[1], "col": split(v:val, ":")[2], "text": join(split(v:val, ":", 4)[-1:], ":") }'))
    else
        let l:files = systemlist('find . -type f \( ! -path "*/.git/*" ! -name "*.md" ! -name "*.o" ! -name "cscope.out" ! -name "cscope.in.out" ! -name "cscope.po.out" ! -name "tags" \)')
        if empty(l:files)
            echo "No files to search."
            return
        endif
        let l:file_list = join(map(l:files, 'fnameescape(v:val)'), ' ')
        execute 'vimgrep /' . escape(l:pattern, '/\') . '/j ' . l:file_list
    endif
    tabnew
    execute "vertical " . (winwidth(0) / 2) . " copen"
    " Automatically preview the first result, if any
    if !empty(getqflist())
        cfirst
        wincmd p
    endif
endfunction

function! GrepFileName()
    let l:pattern = input('Enter text to search in file name or path: ')
    if empty(l:pattern)
        echo "No pattern entered."
        return
    endif
    if executable('rg')
        let l:command = 'rg --files --hidden --glob "!.git/*" --glob "*' . l:pattern . '*"'
        let l:files = systemlist(l:command)
    else
        let l:exclude_list = '-not -path "*/.git/*"'
        let l:files = system('find . -type f ' . l:exclude_list . ' -path "*' . l:pattern . '*"')
        let l:files = split(l:files, '\n')
    endif

    if !empty(l:files)
        let l:qf_list = []
        for l:file in l:files
            let l:qf_entry = {'filename': l:file, 'lnum': 1, 'text': 'File: ' . l:file}
            call add(l:qf_list, l:qf_entry)
        endfor
        call setqflist(l:qf_list)
        tabnew
        execute "vertical " . (winwidth(0) / 2) . " copen"
    else
        echo "No files found."
    endif
    if !empty(getqflist())
        cfirst
        wincmd p
    endif
endfunction

