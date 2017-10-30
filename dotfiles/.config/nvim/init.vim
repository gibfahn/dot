" BREAKING CHANGES: s is now sneak (use `cl` for `s`) function.
"                   <C-i> is now :bn (<C-i>==Tab for vim), use <C-p> for <C-i> function.

"*** Load Plugins (uses vim-plug). ***"
try
  call plug#begin('~/.local/share/nvim/plugged')    " Load plugins with vim-plug.
  Plug 'AndrewRadev/splitjoin.vim'                  " gS to split, gJ to join lines.
  Plug 'ap/vim-buftabline'                          " Show buffers in the tab bar.
  Plug 'easymotion/vim-easymotion'                  " Go to any word instantly.
  Plug 'fweep/vim-zsh-path-completion'              " Nicer file browser plugin.
  Plug 'godlygeek/tabular'                          " Make tables easier (:help Tabular).
  Plug 'haya14busa/incsearch.vim'                   " Highlight search matches as you type.
  Plug 'justinmk/vim-sneak'                         " sab -> go to next ab in code.
  Plug 'pangloss/vim-javascript'                    " JS   language bindings.
  Plug 'rust-lang/rust.vim'                         " Rust language bindings.
  Plug 'tpope/vim-commentary'                       " Autodetect comment type for lang.
  Plug 'tpope/vim-fugitive'                         " Git commands in vim.
  Plug 'tpope/vim-repeat'                           " Allows you to use . with plugin mappings.
  Plug 'tpope/vim-surround'                         " Add/mod/remove surrounding chars.
  Plug 'tpope/vim-vinegar'                          " Nicer file browser plugin.
  call plug#end()                                   " Initialize plugin system
catch| echo 'vim-plug not installed, use :PI to install'
endtry

"*** Set vim options ***"
set nocompatible                                    " Remove vi compatibility hacks.
let mapleader = "\<Space>"                          " Set <Leader> (default shortcut used in mappings below) to Spacebar.

syntax on                                           " Turn on syntax highlighting.
filetype plugin indent on                           " Use file-specific plugins.
set sw=2 ts=2 sts=2                                 " Set tab width to 2.
set expandtab                                       " Insert spaces when tab key pressed.
set backspace=2                                     " Backspace works across lines.
set ignorecase                                      " Ignore case for lowercase searches,
set smartcase                                       "  ↳ don't for mixed-case.
set autoindent smartindent                          " Be more clever about indenting.
set gdefault                                        " Global replace default (off: /g).
set history=1000                                    " More command/search history.
set undolevels=1000                                 " More undo history.
set ruler                                           " Always show cursor position.
set showcmd                                         " Display incomplete commands.
set lazyredraw                                      " Don't redraw if you don't have to (e.g. in macros).
set incsearch                                       " Incremental searching.
set laststatus=2                                    " Always display the status line.
set hidden                                          " Don't force saving buffers on switching.
set textwidth=80                                    " Wrap at 79 chars (change: set tw=72).
set formatoptions-=t                                " Don't autowrap text at 80.
set autoread                                        " Auto read when file is changed elsewhere.
set nojoinspaces                                    " One space (not two) after punctuation..
set mouse=a                                         " Mouse in all modes (mac: Fn+drag = copy).
set number                                          " Turn on line numbers.
set numberwidth=5                                   " Width of line number buffer.
set hlsearch                                        " Highlight search matches (off: <Space>/).
colo desert                                         " Use the desert colorscheme.
set ffs=unix                                        " Only use the Unix fileformat.
set t_Co=256                                        " Use 256 color terminal.
set splitbelow                                      " Open new split panes to right and,
set splitright                                      "  ↳ bottom, which feels more natural.
set diffopt+=vertical                               " Always use vertical diffs.
set wildchar=<Tab> wildmenu                         " Tab complete with files (e.g. `:e`)
set wildmode=list:longest,list:full                 " 1st Tab completes to longest common string, 2nd+ cycles through options.
set list listchars=tab:»·,trail:·,nbsp:·            " Display extra whitespace.
if !isdirectory("/tmp/.vim-undo-dir")| call mkdir("/tmp/.vim-undo-dir", "", 0700)| endif
set undofile undodir="/tmp/.vim-undo-dir"           " Persistent history, save files here.
set path=.,/usr/include,,**                         " Add ** to the search path so :find x works recursively.
if exists('+breakindent')| set breakindent| let &showbreak = '↳ '| set cpo+=n| end " Nicer line wrapping for long lines.

"*** Key mappings (see http://vim.wikia.com/wiki/Unused_keys for unused keys) ***"
" Available (normal): <C-Space>, K, +, _, <C-q/s/n/[/_>, <leader>b/c/e/h/m/n/s/u/v
map K <Plug>(easymotion-bd-jk)|                     " EasyMotion: Move to line with K.
nnoremap k gk|                                      " Move up   visually , don't skip wrapped lines,
nnoremap j gj|                                      "  ↳   down visually , don't skip wrapped lines.
nnoremap gk k|                                      " Move up   logically, do    skip wrapped lines,
nnoremap gj j|                                      "  ↳   down logically, do    skip wrapped lines.
nnoremap Y y$|                                      " Make Y work like C and D (yank to end of line, not whole line).
nnoremap <leader>a @a<CR>|                          " Apply macro a (add with qa or yank to a reg with "ay).
nnoremap <leader>d :bp\|bd  #<CR>|                  " Close buffer without closing split,
nnoremap <leader>D :bp\|bd! #<CR>|                  "  ↳ Force close buffer.
nnoremap <leader>f :find |                          " Search file names    for file,
nnoremap <leader>F :grep |                          "  ↳          contents for file.
nnoremap <Leader>gd :w !diff % - <CR>|              " Diff between saved file and current.
nnoremap <Leader>gt :set et!<CR>:set et?<CR>|       " Toggle tabs/spaces.
nnoremap <Leader>gq :set fo+=t<CR>:set fo?<CR>|     " Turn on  line wrapping,
nnoremap <Leader>gQ :set fo-=t<CR>:set fo?<CR>|     "  ↳   off
nnoremap <Leader>gw :call Trim()<CR>|               " <Space>gw trims trailing whitespace for file.
nnoremap <Leader>id :r !date +\%Y-\%m-\%d<CR>|      "  Insert readable    date on new line.
nnoremap <Leader>iD :r !date +\%d-\%b-\%y<CR>|      "         `:sort`able date
nnoremap <Leader>it ITODO(gib): <ESC>:Commentary<CR>$| " Insert a TODO (change to your name). Write todo, then do <Space>it.
nnoremap <leader>j :sp<CR><C-w>k:bp<CR>|            " Open horizontal split,
nnoremap <leader>k <C-w>q|                          " Close current split (keeps buffer).
nnoremap <leader>l :vsp<CR><C-w>h:bp<CR>|           "  ↳   vertical split.
nnoremap <leader>o :on<CR>|                         " Close all other buffers.
nnoremap <leader>p "+p|                             "  ↳                   (normal mode).
nnoremap <leader>P "+P|                             "  ↳  line from clipboard (normal mode).
nnoremap <leader>q :q<CR>|                          " Quit,
nnoremap <leader>Q :q!<CR>|                         "  ↳ Quit losing unsaved changes.
nnoremap <leader>r :%s//<Left>|                     " Replace (add middle delimiter yourself, e.g. <Space>rold/new),
nnoremap <leader>R :%s//c<Left><Left>|              "  ↳ Replace with prompt on each match.
map <Leader>s <Plug>(easymotion-bd-w)|              " EasyMotion: Move to word.
nnoremap <leader>w :up<CR>|                         " Write if there were changes.
nnoremap <leader>W :w<CR>|                          "  ↳    whether or not there were changes.
nnoremap <leader>x :x<CR>|                          " Save (if changes) and quit.
nnoremap <leader>X :qa<CR>|                         " Quit all windows.
nnoremap <leader>y "+y|                             " Copy to clipboard (normal mode).
nnoremap <leader>Y :%y+<CR>|                        "  ↳  file to clipboard (normal mode).
nnoremap <leader>z  zz|                             " Center screen on current line.
nnoremap <leader>/ :noh<CR>|                        " Turn off find highlighting.
nnoremap <leader>? /<Up><CR>|                       " Search for last searched thing.

vnoremap <leader>y "+y|                             "  ↳                (visual mode).
vnoremap <leader>d "+d|                             " Cut from clipboard (visual mode).
vnoremap <leader>p "+p|                             " Paste from clipboard (visual mode).

nnoremap <C-h> <C-w>h|                              " Switch left  a window,
nnoremap <C-j> <C-w>j|                              "  ↳     down  a window,
nnoremap <C-k> <C-w>k|                              "  ↳     up    a window,
nnoremap <C-l> <C-w>l|                              "  ↳     right a window.
nnoremap <Tab> :bn<CR>|                             " Tab to switch to next buffer,
nnoremap <S-Tab> :bp<CR>|                           "  ↳ Shift-Tab to switch to previous buffer.
nnoremap <C-p> <C-i>|                               " <C-o> = go to previous jump, <C-p> is go to next (normally <C-i>, but that == Tab, used above).
inoremap kj <ESC>|                                  " kj = Esc in insert mode.
map q: <Nop>|                                       " Disable Ex modes (avoids,
nnoremap Q <nop>|                                   "  ↳ accidental triggering).
vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'|    " Search for selected text with // (very no-magic mode, escaped backslashes).

nmap f <Plug>Sneak_f|                               " Use sneak for f (multiline+highlight).
nmap F <Plug>Sneak_F|                               " ↳             F
nmap t <Plug>Sneak_t|                               " ↳             t
nmap T <Plug>Sneak_T|                               " ↳             T
map /  <Plug>(incsearch-forward)|                   " Incsearch: highlight matches as you search with / .
map ?  <Plug>(incsearch-backward)|                  " ↳                                               ? .
map g/ <Plug>(incsearch-stay)|                      " ↳                                               g/.

if has("nvim")                                      " NeoVim specific settings.
  let g:terminal_scrollback_buffer_size = 100000    " Store lots of terminal history.
  let $VISUAL = 'nvr -l --remote-wait'              " Use existing nvim window to open new files (e.g. `g cm`).
  nnoremap <Leader>t :vsplit term://$SHELL<CR>i|    " Open terminal in new split.
  nnoremap <Leader>T :term<CR>|                     " Open terminal in current split.
  tnoremap <C-h> <C-\><C-n><C-w>h|                  " Switch left  a window in terminal,
  tnoremap <C-j> <C-\><C-n><C-w>j|                  "  ↳     down  a window in terminal,
  tnoremap <C-k> <C-\><C-n><C-w>k|                  "  ↳     up    a window in terminal,
  tnoremap <C-l> <C-\><C-n><C-w>l|                  "  ↳     right a window in terminal.
  tnoremap <Esc> <C-\><C-n>|                        " Make Escape work in terminal,
  tnoremap kj <C-\><C-n>|                           "  ↳    kj    work in terminal.

  augroup gibNvimGroup                              " Autocommands for nvim only
  au TermOpen * setlocal nonumber norelativenumber  " No line numbers in terminal
  augroup end
endif

"*** Custom Commands ***"
command! W w !sudo tee % > /dev/null|               " :W saves file as sudo.
command! Trim call TrimWhitespace()|                " :Trim runs :call Trim() (defined below).
command! PU PlugUpdate | PlugUpgrade|               " :PI installs vim-plug, :PU updates plugins and vim-plug.
command! PI !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &&
    \ ln -s ~/.local/share/nvim/site/autoload ~/.vim/autoload

let g:is_posix = 1                                  " Assume shell for syntax highlighting.
"let g:rustfmt_autosave = 1                         " Run rustfmt on save (from rust.vim).
let g:sneak#use_ic_scs = 1                          " Sneak: respect smartcase setting.

" Highlight the 81st column of text (in dark grey so it doesn't distract).
highlight ColorColumn ctermbg=234
call matchadd('ColorColumn', '\%81v', 100)

set path=.,/usr/include,,**                         " Add ** to search path
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading         " Use ripgrep for file searching.
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

augroup gibAutoGroup                                " Group of automatic functions.
  au!
  au BufReadPost *|                                 " On open jump to last cursor position if possible.
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
  au BufRead,BufNewFile *.md set filetype=markdown  " Use markdown for md files.
  au FileType help wincmd L                         " Open new help windows on the right,
"  au FileType qf wincmd L                           "  ↳       build windows on the right.
  au BufWritePost .vimrc so $MYVIMRC|               " Reload .vimrc on save.
  au BufWritePost init.vim so $MYVIMRC|             " Reload init.vim (nvim) on save.
augroup END

set wildmode=list:longest,list:full                 " Insert tab at beginning of line,
fu! InsertTabWrapper()                              "  ↳ else use completion.
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'| return "\<tab>"| else| return "\<c-p>"| endif
endf
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>|        " Tab is autocomplete unless at beginning of line.
inoremap <S-Tab> <c-n>|                             " Shift-Tab is always autocomplete.

" Blink when you highlight a search match.
nnoremap <silent> n n:call HLNext(0.1)<cr>
nnoremap <silent> N N:call HLNext(0.1)<cr>
function! HLNext (blinktime)
  let target_pat = '\c\%#'.@/
  let ring = matchadd('ErrorMsg', target_pat, 101)
  redraw
  exec 'sleep ' . float2nr(a:blinktime * 1000) . 'm'
  call matchdelete(ring)
  redraw
endfunction

" Function to trim trailing whitespace in a file.
function! TrimWhitespace()
    let l:save = winsaveview()
    %s/\s\+$//e
    call winrestview(l:save)
endfun
