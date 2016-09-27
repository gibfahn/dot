execute pathogen#infect()
set nocompatible         " Remove vi compatibility hacks
let mapleader = "," " Set leader (default shortcut) key to ,

syntax on
filetype plugin indent on
set shiftwidth=2         " 
set softtabstop=2        " 
set expandtab            " 
set backspace=2          " Backspace deletes like most programs in insert mode
set ignorecase           " Ignore case for lowercase searches
set smartcase            " Don't ignore case for mixed-case searches
set gdefault             " Replace /g on by default (/g turns it off)
set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
"set title                " change the terminal's title
set ruler                " show the cursor position all the time
set showcmd              " display incomplete commands
set incsearch            " do incremental searching
set laststatus=2         " Always display the status line
set hidden               " Don't force me to save buffers before switching
set textwidth=79         " Wrap at 79 chars
set autoread             " Auto read when file is changed from the outside
set nojoinspaces         " Use one space, not two, after punctuation.
set mouse=a              " Use the mouse in all modes
set number               " Turn on line numbers
set relativenumber       " Show line nos relative to curr line (except curr line)
set numberwidth=5        " Width of line number buffer

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

nnoremap <leader><leader> <Esc> " Switch between the last two files

set wildchar=<Tab> wildmenu wildmode=full " More info with : and Tab

" :W saves file as sudo
command W w !sudo tee % > /dev/null
" Ctrl S saves from any mode
inoremap <C-s> <esc>:up<cr>a
nnoremap <C-s> :up<cr>a

" Use normal regex
nnoremap / /\v
vnoremap / /\v

" Tab and Shift-Tab for changing buffers
nnoremap <Tab> :bn<CR>
nnoremap <S-Tab> :bp<CR>  
" Space and Shift-Space for opening/closing buffers
nnoremap <space> :vsp<CR><Tab>
nnoremap <S-space> :on<CR>

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Nicer line wrapping for long lines
if has('linebreak')
  set breakindent
  let &showbreak = '↳ '
  set cpo+=n
end

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
  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

set t_Co=256 " Use 256 color terminal (useful for monokai)

" Ctrl P for CtrlP
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
  endif
endif


" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Run commands that require an interactive shell
nnoremap <Leader>r :RunInInteractiveShell<space>

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Quicker window movement Ctrl + direction
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Always use vertical diffs
set diffopt+=vertical
