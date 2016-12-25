execute pathogen#infect()|                          " Load plugins from ~/.vim/bundle
set nocompatible                                    " Remove vi compatibility hacks
let mapleader = "\<Space>"                          " Set leader (default shortcut) to Space

syntax on                                           " Turn on syntax highlighting
filetype plugin indent on                           " Use file-specific plugins
set sw=2 ts=2 sts=2                                 " Set tab width to 2
set expandtab                                       " Insert spaces tab key pressed
set backspace=2                                     " Backspace works across lines
set ignorecase                                      " Ignore case for lowercase searches
set smartcase                                       "  ↳ don't for mixed-case
set gdefault                                        " Global replace default (off: /g)
set history=1000                                    " More command/search history
set undolevels=1000                                 " More undo history
set ruler                                           " Always show cursor position
set showcmd                                         " Display incomplete commands
set incsearch                                       " Incremental searching
set laststatus=2                                    " Always display the status line
set hidden                                          " Don't force saving buffers on switching
set textwidth=79                                    " Wrap at 79 chars
set autoread                                        " Auto read when file is changed elsewhere
set nojoinspaces                                    " One space (not two) after punctuation.
set mouse=a                                         " Mouse in all modes (mac: Fn+drag to copy)
set number                                          " Turn on line numbers
set relativenumber                                  " Line nos relative to curr line
set numberwidth=5                                   " Width of line number buffer
set hlsearch                                        " Highlight search matches (off: <Space>/)
colo desert                                         " Use the desert colorscheme
set ffs=unix                                        " Only use the Unix fileformat
set t_Co=256                                        " Use 256 color terminal
set splitbelow                                      " Open new split panes to right and
set splitright                                      "  ↳ bottom, which feels more natural
set diffopt+=vertical                               " Always use vertical diffs
set wildchar=<Tab> wildmenu wildmode=full           " More info with : and Tab
set list listchars=tab:»·,trail:·,nbsp:·            " Display extra whitespace

nnoremap <C-j> <C-w>j|                              " Move window focus
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <Tab> :bn<CR>|                             " Tab and Shift-Tab
nnoremap <S-Tab> :bp<CR>|                           "  ↳ for changing buffers
inoremap kj <ESC>|                                  " kj = Esc in insert mode
nnoremap <leader>l :vsp<CR><C-w>h:bp<CR>|           " Open/close splits
nnoremap <leader>j :sp<CR><C-w>k:bp<CR>
nnoremap <leader>k <C-w>q
nnoremap <leader>h <C-w>q
nnoremap <leader>o :on<CR>|                         " Close all other tabs
nnoremap <leader>x :x<CR>|                          " Save+quit
nnoremap <leader>w :up<CR>|                         " Write if there were changes
nnoremap <leader>q :q<CR>|                          " Quit
nnoremap <leader>d :bd<CR>|                         " Close buffer
nnoremap <leader>/ :noh<CR>|                        " Turn off find highlighting
nnoremap <Leader>r :RunInInteractiveShell<space>|   " Open shell
nnoremap <Leader>gd :w !diff % - <CR>|              " Diff between saved file and current
vnoremap <leader>y  "+y|                            " Copy to clipboard
nnoremap <leader>Y  "+yg_
nnoremap <leader>y  "+y
nnoremap <leader>p "+p|                             " Paste from clipboard
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

command W w !sudo tee % > /dev/null|                " :W saves file as sudo
let g:is_posix = 1                                  " Assume shell for syntax highlighting

" Nicer line wrapping for long lines
if has('linebreak')| set breakindent| let &showbreak = '↳ '| set cpo+=n| end

" Automatically set paste when pasting
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
augroup vimrcEx
  autocmd!
  " On open jump to last cursor position if known/valid
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
augroup END

set wildmode=list:longest,list:full                 " Insert tab at beginning of line,
function! InsertTabWrapper()                       "  ↳ else use completion
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'| return "\<tab>"| else| return "\<c-p>"| endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>
