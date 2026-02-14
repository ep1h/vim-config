" Cscope ---------------------------------------------------------------------
" TODO: Cscope related logic will not work with dir/file names with spaces.
"       It is impossible to correctly parse cscope output if there are spaces
"       in dir/file name.

nnoremap \Cscan :CscopeScan<CR>
nnoremap \Cs :CscopeSymbol<Space>
nnoremap \Cg :CscopeGlobalDefinition<Space>
nnoremap \Cd :CscopeCallee<Space>
nnoremap \Cc :CscopeCaller<Space>
nnoremap \Ct :CscopeText<Space>
nnoremap \Ce :CscopeEgrep<Space>
nnoremap \Cf :CscopeFile<Space>
nnoremap \Ci :CscopeIncludes<Space>
nnoremap \Ca :CscopeAssignment<Space>
nnoremap \Cct :CscopeCallStacksTo<Space>
nnoremap \Ccf :CscopeCallStacksFrom<Space>
nnoremap \Ch :CscopeHelp<CR>

command! -nargs=0 CscopeScan execute 'silent! call system("cscope -Rbq")' | echo "Cscope index updated."
command! -nargs=1 CscopeSymbol call CscopeSearch('0', <f-args>) " Cs
command! -nargs=1 CscopeGlobalDefinition call CscopeSearch('1', <f-args>) " Cg
command! -nargs=1 CscopeCallee call CscopeSearch('2', <f-args>) " Cd
command! -nargs=1 CscopeCaller call CscopeSearch('3', <f-args>) " Cc
command! -nargs=? CscopeText call CscopeSearch('4', <f-args>) " Ct
command! -nargs=? CscopeEgrep call CscopeSearch('6', <f-args>) " Ce
command! -nargs=1 CscopeFile call CscopeSearch('7', <f-args>) " Cf
command! -nargs=1 CscopeIncludes call CscopeSearch('8', <f-args>) " Ci
command! -nargs=1 CscopeAssignment call CscopeSearch('9', <f-args>) " Ca
command! -nargs=+ CscopeCallStacksTo call CscopeCallstacksTo(<f-args>) " Cct 
command! -nargs=+ CscopeCallStacksFrom call CscopeCallstacksFrom(<f-args>) " Ccf 
command! -nargs=0 CscopeHelp call Cscope_ShowHelp()

function! Cscope_ShowHelp()
    echo "Cscope Key Bindings:"
    echo "  \\Cscan Analyze current dir recursively"
    echo "  \\Cs    Find this C symbol"
    echo "  \\Cg    Find global definition"
    echo "  \\Cd    Find functions called by this function"
    echo "  \\Cc    Find functions calling this function"
    echo "  \\Ct    Find this text string"
    echo "  \\Ce    Find this egrep pattern"
    echo "  \\Cf    Find this file"
    echo "  \\Ci    Find files #including this file"
    echo "  \\Ca    Find places where this symbol is assigned a value"
    echo "  \\Cct   Show callstacks to function"
    echo "  \\Ccf   Show callstack from function"
    echo "  \\Ch    Show this help message"
endfunction

" Check if one call stack is a subset of another
function! Cscope_IsSubset(small_stack, big_stack)
    if len(a:small_stack) > len(a:big_stack)
        return 0
    endif
    for idx in range(0, len(a:small_stack)-1)
        let small_call = a:small_stack[idx]
        let big_call = a:big_stack[idx]
        if small_call.filename != big_call.filename || small_call.lnum != big_call.lnum || small_call.text != big_call.text
            return 0
        endif
    endfor
    return 1
endfunction


function! Cscope_RecursiveCallsSearch(name, depth, max_depth, current_stack, all_callstacks, search_type, cache, visited)
    " Stop recursion if depth limit is reached
    if a:depth >= a:max_depth
        call add(a:all_callstacks, copy(a:current_stack))
        return
    endif

    " Cycle detection: skip if already in current call stack
    if index(map(copy(a:current_stack), 'v:val.function'), a:name) >= 0
        call add(a:all_callstacks, copy(a:current_stack))
        return
    endif

    " Check if the current function has been cached to avoid duplicate cscope calls
    if has_key(a:cache, a:name)
        let l:output = a:cache[a:name]
    else
        " Determine whether to search for callers (-3) or callees (-2)
        let l:cmd_option = a:search_type == 'to' ? '-3' : '-2'

        " Get the corresponding functions using cscope
        let l:cmd = 'cscope -dL ' . l:cmd_option . ' ' . shellescape(a:name)
        let l:output = systemlist(l:cmd)

        " Cache the output for this function
        let a:cache[a:name] = l:output
    endif

    if empty(l:output)
        " No further functions, add the current call stack to the results
        call add(a:all_callstacks, copy(a:current_stack))
        return
    endif

    for l:line in l:output
        let l:parts = split(l:line, '\t\|\s\+')
        if len(l:parts) >= 4
            let l:call_info = {
                        \ 'filename': l:parts[0],
                        \ 'function': l:parts[1],
                        \ 'lnum': l:parts[2],
                        \ 'text': join(l:parts[3:], ' '),
                        \ 'depth': a:depth
                        \ }
            call add(a:current_stack, l:call_info)
            let l:next_function_name = l:parts[1]
            " Recursively process the next function
            call Cscope_RecursiveCallsSearch(l:next_function_name, a:depth + 1, a:max_depth, a:current_stack, a:all_callstacks, a:search_type, a:cache, a:visited)
            " Backtracking: remove the last function call after recursion
            call remove(a:current_stack, -1)
        endif
    endfor
endfunction


" Filter out shorter call stacks that are subsets of longer ones
function! Cscope_FilterCallStacks(callstacks)
    " Sort callstacks by length (descending)
    let l:sorted_callstacks = sort(copy(a:callstacks), {a, b -> len(b) - len(a)})
    let l:filtered_callstacks = []
    " Compare each call stack with the longer ones
    for i in range(0, len(l:sorted_callstacks)-1)
        let l:is_subset = 0
        for j in range(0, i-1)
            if Cscope_IsSubset(l:sorted_callstacks[i], l:sorted_callstacks[j])
                let l:is_subset = 1
                break
            endif
        endfor
        " Add to filtered list if it's not a subset
        if !l:is_subset
            call add(l:filtered_callstacks, l:sorted_callstacks[i])
        endif
    endfor
    return l:filtered_callstacks
endfunction

function! Cscope_AddTargetFunc(name, filtered_callstacks)
    let l:updated_callstacks = []

    " Iterate through each call stack in the filtered call stacks
    for l:callstack in a:filtered_callstacks
        " Create a dictionary for the target function
        let l:target_func = {
                    \ 'filename': '',
                    \ 'function': a:name,
                    \ 'lnum': '',
                    \ 'text': '',
                    \ 'depth': 0
                    \ }
        " Prepend the target function to the call stack
        call insert(l:callstack, l:target_func, 0)
        " Add the updated call stack to the new list
        call add(l:updated_callstacks, l:callstack)
    endfor
    return l:updated_callstacks
endfunction

" Main Function to Initiate Recursive Search
function! Cscope_BuildCallstacksTo(function_name, max_depth)
    let l:all_callstacks = []
    let l:current_stack = []
    let l:cache = {}
    let l:visited = {}
    call Cscope_RecursiveCallsSearch(a:function_name, 1, a:max_depth, l:current_stack, l:all_callstacks, 'to', l:cache, l:visited)
    " Filter the call stacks to remove redundant shorter ones
    let l:filtered_callstacks = Cscope_FilterCallStacks(l:all_callstacks)
    let l:callstacks = Cscope_AddTargetFunc(a:function_name, l:filtered_callstacks)
    if !empty(l:callstacks)
        " let l:callstacks = reverse(l:callstacks)
        for l:callstack in l:callstacks
            let l:callstack = reverse(l:callstack)
        endfor
    endif
    return l:callstacks
endfunction

function! Cscope_RecursiveCalleesSearch(name, depth, max_depth, results, cache)
    if a:depth > a:max_depth
        return
    endif
    " Check if we already have results cached for this function name
    if has_key(a:cache, a:name)
        let l:output = a:cache[a:name]
    else
        " Get functions calling this function (cscope option '-2')
        let l:cmd = 'cscope -dL -2 ' . shellescape(a:name)
        let l:output = systemlist(l:cmd)
        " Cache the result to avoid repeated calls
        let a:cache[a:name] = l:output
    endif

    for l:line in l:output
        let l:parts = split(l:line, '\t\|\s\+')
        if len(l:parts) >= 4
            " Create a dictionary with the relevant information
            let l:call_info = {
                        \ 'filename': l:parts[0],
                        \ 'function': l:parts[1],
                        \ 'lnum': l:parts[2],
                        \ 'text': l:parts[3],
                        \ 'depth': a:depth
                        \ }
            " Store this dictionary into the results array
            call add(a:results, l:call_info)
            " Get the caller function name (assuming it's in the text)
            let l:caller_name = l:parts[1]
            " Recursively process the caller function
            call Cscope_RecursiveCalleesSearch(l:caller_name, a:depth + 1, a:max_depth, a:results, a:cache)
        endif
    endfor
endfunction

function! Cscope_BuildCallstacksFrom(function_name, max_depth)
    let l:callstack = []
    let l:cache = {}
    call Cscope_RecursiveCalleesSearch(a:function_name, 1, a:max_depth, l:callstack, l:cache)
    return l:callstack
endfunction

function! CscopeCallstacksTo(function_name, max_depth)
    let l:function_name = a:function_name
    let l:max_depth = a:max_depth
    if l:max_depth !~ '^\d\+$'
        echo "Depth is not a valid integer."
        return
    endif
    let l:max_depth = str2nr(l:max_depth)
    if l:max_depth> 0
        echo "Callstacks to " . l:function_name . " with depth: " . l:max_depth
    else
        echo "Invalid depth."
    endif

    let l:callstacks = Cscope_BuildCallstacksTo(l:function_name, l:max_depth)
    if empty(l:callstacks)
        echo "No matches found."
        return
    endif
    echo " "
    for l:callstack in l:callstacks
        for l:call in l:callstack
            let l:indentation = repeat(" ", l:max_depth - l:call.depth - 1)
            " echom l:indentation . l:call.function . " " . l:call.filename . ":" . l:call.lnum
            echom l:indentation . l:call.function
        endfor
        echom " "
    endfor
endfunction

function! CscopeCallstacksFrom(function_name, max_depth)
    let l:function_name = a:function_name
    let l:max_depth = a:max_depth
    if l:max_depth !~ '^\d\+$'
        echo "Depth is not a valid integer."
        return
    endif
    let l:max_depth = str2nr(l:max_depth)
    if l:max_depth> 0
        echo "Callstack from " . l:function_name . " with depth: " . l:max_depth
    else
        echo "Invalid depth."
    endif


    let l:callstack = Cscope_BuildCallstacksFrom(l:function_name, l:max_depth)
    if empty(l:callstack)
        echo "No matches found."
        return
    endif
    echo " "
    for l:call in l:callstack
        let l:indentation = repeat("  ", l:call.depth)
        " echom l:indentation . l:call.function . " " . l:call.filename . ":" . l:call.lnum . " " . l:call.text
        echom l:indentation . l:call.function
    endfor
endfunc

function! CscopeCmd(a1, a2)
    if empty(a:a1) || empty(a:a2)
        return
    endif
    let l:cmd = 'cscope -dL -' . a:a1 . ' ' . shellescape(a:a2)
    return systemlist(l:cmd)
endfunction

function! CscopeSearch(arg, ...)
    let l:output = CscopeCmd(a:arg, a:1)
    if empty(l:output)
        echo "No matches found."
        return
    endif
    " Process the output to create quickfix entries
    let l:qf_list = []
    for l:line in l:output
        let l:parts = split(l:line, '\t\|\s\+')
        if len(l:parts) >= 4
            let l:qf_entry = {
                        \ 'filename': l:parts[0],
                        \ 'lnum': l:parts[2],
                        \ 'text': join(l:parts[3:], ' ')
                        \ }
            call add(l:qf_list, l:qf_entry)
        endif
    endfor
    if !empty(l:qf_list)
        call setqflist(l:qf_list)
        execute "vertical " . (winwidth(0) / 2) . " copen"
        " botright copen
    else
        echo "No matches found."
    endif
endfunction
