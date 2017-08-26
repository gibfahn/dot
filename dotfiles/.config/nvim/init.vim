try
  call plug#begin('~/.local/share/nvim/plugged')    " Load plugins with vim-plug.
  Plug 'ap/vim-buftabline'                          " Show buffers in the tab bar.
  Plug 'tpope/vim-fugitive'                         " Git commands in vim.
  Plug 'rust-lang/rust.vim'                         " Rust language bindings.
  Plug 'pangloss/vim-javascript'                    " JS   language bindings.
  Plug 'tpope/vim-surround'                         " Add/mod/remove surrounding chars.
  Plug 'tpope/vim-repeat'                           " Allows you to use . with above.
  Plug 'tpope/vim-commentary'                       " Autodetect comment type for lang.
  Plug 'tpope/vim-vinegar'                          " Nicer file browser plugin.
  Plug '~/.local/share/nvim/plugged/YouCompleteMe'  " Autocompletion for some langs.
" - = .. | I = help | ~ = ~ | <C-i/o> = Quit | cg = cd $cwd | R = rename | D = delete
  call plug#end()                                   " Initialize plugin system
catch| echo 'vim-plug not installed, use :PI to install'
endtry

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
set wildchar=<Tab> wildmenu wildmode=full           " More info with : and Tab.
set list listchars=tab:»·,trail:·,nbsp:·            " Display extra whitespace.

nnoremap k gk|                                      " Move up   visually , don't skip wrapped lines,
nnoremap j gj|                                      "  ↳   down visually , don't skip wrapped lines.
nnoremap gk k|                                      " Move up   logically, do    skip wrapped lines,
nnoremap gj j|                                      "  ↳   down logically, do    skip wrapped lines.
nnoremap Y y$|                                      " Make Y work like C and D (yank to end of line, not whole line).
nnoremap <leader>a @a<CR>|                          " Apply macro a (add with qa or yank to a reg with "ay).
nnoremap <leader>c :YcmCompleter GoTo<CR>|          " GoTo definition for YouCompleteMe.
nnoremap <leader>C :YcmCompleter GetDoc<CR>|        " GoTo docs for YouCompleteMe.
nnoremap <leader>d :bp\|bd  #<CR>|                  " Close buffer without closing split,
nnoremap <leader>D :bp\|bd! #<CR>|                  "  ↳ Force close buffer.
nnoremap <leader>f :find |                          " Search file names    for file,
nnoremap <leader>F :grep |                          "  ↳          contents for file.
nnoremap <Leader>gd :w !diff % - <CR>|              " Diff between saved file and current.
nnoremap <Leader>gr :reg<CR>|                       " Show register contents.
nnoremap <Leader>gt :set et!<CR>:set et?<CR>|       " Toggle tabs/spaces.
nnoremap <Leader>gq :set fo+=t<CR>:set fo?<CR>|     " Turn on  line wrapping,
nnoremap <Leader>gQ :set fo-=t<CR>:set fo?<CR>|     "  ↳   off line wrapping.
nnoremap <leader>j :sp<CR><C-w>k:bp<CR>|            " Open horizontal split,
nnoremap <leader>l :vsp<CR><C-w>h:bp<CR>|           "  ↳   vertical split.
nnoremap <leader>k <C-w>q|                          " Close current split (keeps buffer).
nnoremap <leader>o :on<CR>|                         " Close all other buffers.
nnoremap <leader>q :q<CR>|                          " Quit,
nnoremap <leader>Q :q!<CR>|                         "  ↳ Quit losing unsaved changes.
nnoremap <leader>r :%s//<Left>|                     " Replace (add middle delimiter yourself, e.g. <Space>rold/new),
nnoremap <leader>R :%s//c<Left><Left>|              "  ↳ Replace with prompt on each match.
nnoremap <leader>w :up<CR>|                         " Write if there were changes.
nnoremap <leader>W :w<CR>|                          "  ↳    whether or not there were changes.
nnoremap <leader>x :x<CR>|                          " Save (if changes) and quit.
nnoremap <leader>X :qa<CR>|                         " Quit all windows.
nnoremap <leader>y  "+y|                            " Copy to clipboard (normal mode).
vnoremap <leader>y  "+y|                            "  ↳                (visual mode).
nnoremap <leader>Y  "+yg_|                          "  ↳   line to clipboard (normal mode).
vnoremap <leader>p "+p|                             " Paste from clipboard (visual mode).
nnoremap <leader>p "+p|                             "  ↳                   (normal mode).
nnoremap <leader>P "+P|                             "  ↳    line from clipboard (normal mode).
nnoremap <leader>z  zz|                             " Center screen on current line.
nnoremap <leader>/ :noh<CR>|                        " Turn off find highlighting.
nnoremap <leader>? /<Up><CR>|                       " Search for last searched thing.

nnoremap <C-h> <C-w>h|                              " Switch left  a window,
nnoremap <C-j> <C-w>j|                              "  ↳     down  a window,
nnoremap <C-k> <C-w>k|                              "  ↳     up    a window,
nnoremap <C-l> <C-w>l|                              "  ↳     right a window.
nnoremap <Tab> :bn<CR>|                             " Tab to switch to next buffer,
nnoremap <S-Tab> :bp<CR>|                           "  ↳ Shift-Tab to switch to previous buffer.
inoremap kj <ESC>|                                  " kj = Esc in insert mode.

" Testing stuff, not sure I need any of it.
inoremap <C-J> mpo<Esc>`p|                          " Create a line below in Insert mode.
" inoremap <C-K> <Esc>mpO<Esc>`pa|                    " Create a line above in insert mode.
inoremap <C-K> <Esc>mpO|                            " Above but don't change back, do I need this?
inoremap <S-Enter> <Esc>mpO<Esc>`pa|                " Same as Ctrl+k, but only works on GUI vim or configured terminals.

map q: <Nop>|                                       " Disable Ex modes (avoids,
nnoremap Q <nop>|                                   "  ↳ accidental triggering..
vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'|    " Search for selected text with // (very no-magic mode, escaped backslashes).

if has("nvim")
  let g:terminal_scrollback_buffer_size = 100000
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

command! W w !sudo tee % > /dev/null|               " :W saves file as sudo.
command! PU PlugUpdate | PlugUpgrade|               " :PU updates plugins and vim-plug.
command! PI !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &&
    \ ln -s ~/.local/share/nvim/site/autoload ~/.vim/autoload
let g:is_posix = 1                                  " Assume shell for syntax highlighting.
let g:ycm_rust_src_path = expand('~/.rustup/toolchains/nightly-*/lib/rustlib/src/rust/src')
"let g:rustfmt_autosave = 1                          " Run rustfmt on save (from rust.vim).
set path=.,/usr/include,,**                         " Add ** to the search path so :find x works recursively.

" Nicer line wrapping for long lines.
if exists('+breakindent')| set breakindent| let &showbreak = '↳ '| set cpo+=n| end

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
