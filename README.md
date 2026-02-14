# vim-config

Personal Vim configuration with modular plugin scripts.

## Dependencies

- [ripgrep](https://github.com/BurntSushi/ripgrep) — fast grep (`rg`), used by grep and fzf modules
- [fzf](https://github.com/junegunn/fzf) — fuzzy finder (installed via vim-plug)
- [ctags](https://ctags.io/) — tag generation for code navigation
- [cscope](http://cscope.sourceforge.net/) — C/C++ code browsing
- [clang-format](https://clang.llvm.org/docs/ClangFormat.html) — code formatting

## Setup

```bash
bash setup.sh
```

Then open Vim and run `:PlugInstall`.

## Structure

| File | Description |
|------|-------------|
| `.vimrc` | Entry point — sources all modules, git helpers |
| `.vim-config/highlights.vim` | Syntax highlighting, colorscheme, invisible chars |
| `.vim-config/grep.vim` | Workspace text/file search via `rg`/`grep` |
| `.vim-config/quickfix.vim` | Quickfix list filtering (by content/filename, with undo) |
| `.vim-config/utils.vim` | Terminal spawning, clang-format, ctags, WSL clipboard |
| `.vim-config/vim_fzf.vim` | fzf integration (files, tags, grep) |
| `.vim-config/vim_cscope.vim` | Cscope integration with call stack tracing |

## Key Bindings

### Git
| Mapping | Action |
|---------|--------|
| `<leader>gb` | Git blame current line |
| `<leader>gd` | Git diff current file |

### Grep
| Mapping | Action |
|---------|--------|
| `\sa` | Search text in workspace |
| `\sf` | Search file by name |

### Quickfix
| Mapping | Action |
|---------|--------|
| `<C-j>` / `<C-k>` | Next / previous quickfix entry |
| `<leader>sss` | Filter quickfix by content |
| `<leader>ssf` | Filter quickfix by filename |
| `<leader>sns` | Invert-filter quickfix by content |
| `<leader>snf` | Invert-filter quickfix by filename |
| `<leader>su` | Undo last quickfix filter |

### fzf
| Mapping | Action |
|---------|--------|
| `<leader>ff` | Fuzzy find files |
| `<leader>ft` | Fuzzy find tags |
| `<leader>fa` | Fuzzy grep all |

### Terminal
| Mapping | Action |
|---------|--------|
| `<leader>termw` | Terminal above |
| `<leader>terma` | Terminal left |
| `<leader>terms` | Terminal below |
| `<leader>termd` | Terminal right |

### Formatting
| Mapping | Action |
|---------|--------|
| `<leader>cff` | clang-format current file |
| `<leader>cfv` | clang-format selection |

### Cscope
| Mapping | Action |
|---------|--------|
| `\Cscan` | Build cscope index |
| `\Cs` | Find symbol |
| `\Cg` | Find global definition |
| `\Cd` | Find callees |
| `\Cc` | Find callers |
| `\Ct` | Find text |
| `\Ce` | Find egrep pattern |
| `\Cf` | Find file |
| `\Ci` | Find includes |
| `\Ca` | Find assignments |
| `\Cct` | Call stacks to function |
| `\Ccf` | Call stacks from function |
| `\Ch` | Show cscope help |

### Ctags
| Mapping | Action |
|---------|--------|
| `\Tscan` | Rebuild ctags index |
