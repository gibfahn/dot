execute pathogen#infect()|                          " Load plugins from ~/.vim/bundle
set nocompatible                                    " Remove vi compatibility hacks
let mapleader = "\<Space>"                          " Set leader (default shortcut) to Space

syntax on                                           " Turn on syntax highlighting
filetype plugin indent on                           " Use file-specific plugins
set sw=2 ts=2 sts=2                                 " Set tab width to 2
set expandtab                                       " Insert spaces when tab key pressed
set backspace=2                                     " Backspace works across lines
set ignorecase                                      " Ignore case for lowercase searches
set smartcase                                       "  ↳ don't for mixed-case
set autoindent smartindent                          " Be more clever about indenting
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
set mouse=a                                         " Mouse in all modes (mac: Fn+drag = copy)
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

nnoremap <C-h> <C-w>h|                              " Switch   left  a window
nnoremap <C-j> <C-w>j|                              " ↳ Switch down  a window
nnoremap <C-k> <C-w>k|                              " ↳ Switch up    a window
nnoremap <C-l> <C-w>l|                              " ↳ Switch right a window
nnoremap <Tab> :bn<CR>|                             " Tab to switch to next buffer
nnoremap <S-Tab> :bp<CR>|                           "  ↳ Shift-Tab to switch to previous buffer
inoremap kj <ESC>|                                  " kj = Esc in insert mode
nnoremap <leader>d :bd<CR>|                         " Close buffer
nnoremap <leader>D :bd!<CR>|                        " ↳ Force close buffer
nnoremap <Leader>gd :w !diff % - <CR>|              " Diff between saved file and current
nnoremap <leader>j :sp<CR><C-w>k:bp<CR>|            " Open horizontal split
nnoremap <leader>k <C-w>q|                          " Close current split (keeps buffer)
nnoremap <leader>l :vsp<CR><C-w>h:bp<CR>|           " Open vertical split
nnoremap <leader>o :on<CR>|                         " Close all other buffers
nnoremap <leader>q :q<CR>|                          " Quit
nnoremap <leader>Q :q!<CR>|                         " ↳ Quit losing unsaved changes
nnoremap <leader>w :up<CR>|                         " Write if there were changes
nnoremap <leader>x :x<CR>|                          " Save+quit
nnoremap <leader>/ :noh<CR>|                        " Turn off find highlighting
vnoremap <leader>y  "+y|                            " Copy to clipboard
nnoremap <leader>Y  "+yg_|                          " ↳ Copy line to clipboard
nnoremap <leader>p "+p|                             " Paste from clipboard
vnoremap <leader>P "+P|                             " ↳ Paste line from clipboard

if has("nvim")
  nnoremap <Leader>t :vsplit term://$SHELL<CR>i|    " Open terminal in new split
  nnoremap <Leader>T :term<CR>|                     " Open terminal in current split
  tnoremap <C-h> <C-\><C-n><C-w>h|                  " Switch   left  a window in terminal
  tnoremap <C-j> <C-\><C-n><C-w>j|                  " ↳ Switch down  a window in terminal
  tnoremap <C-k> <C-\><C-n><C-w>k|                  " ↳ Switch up    a window in terminal
  tnoremap <C-l> <C-\><C-n><C-w>l|                  " ↳ Switch right a window in terminal
  tnoremap <Esc> <C-\><C-n>|                        " Make Escape work in terminal
  tnoremap kj <C-\><C-n>|                           " Make kj     work in terminal
endif

command! W w !sudo tee % > /dev/null|               " :W saves file as sudo
let g:is_posix = 1                                  " Assume shell for syntax highlighting

" Nicer line wrapping for long lines
if has('linebreak')| set breakindent| let &showbreak = '↳ '| set cpo+=n| end

let &t_SI .= "\<Esc>[?2004h"|                       " Automatically set paste when pasting
let &t_EI .= "\<Esc>[?2004l"
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~| set paste| return ""
endfunction
augroup gibAutoGroup|                               " Group of automatic functions
  au!
  au BufReadPost *|                                 " On open jump to last cursor position if possible
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
  au BufRead,BufNewFile *.md set filetype=markdown  " Use markdown for md files
  au FileType help wincmd L                         " Open new help windows on the right
  au FileType qf wincmd L                           " Open new build windows on the right
  au BufWritePost .vimrc so $MYVIMRC|               " Reload .vimrc on save
augroup END

set wildmode=list:longest,list:full                 " Insert tab at beginning of line,
function! InsertTabWrapper()                        "  ↳ else use completion
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'| return "\<tab>"| else| return "\<c-p>"| endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>|        " Tab is autocomplete unless at beginning of line
inoremap <S-Tab> <c-n>|                             " Shift-Tab is always autocomplete
