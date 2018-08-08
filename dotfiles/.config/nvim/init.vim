" BREAKING CHANGES: s is now sneak (use `cl` for `s`) function (:h sneak).
"                   <C-i> is now :bn (<C-i>==Tab for vim), use <C-p> for <C-i> function.
" Complete list of all vim commands: http://vimdoc.sourceforge.net/htmldoc/vimindex.html

" {{{ Load plugins (uses vim-plug)

if empty($XDG_CONFIG_HOME)| let $XDG_CONFIG_HOME = $HOME . '/.config'| endif
if empty($XDG_CACHE_HOME)| let $XDG_CACHE_HOME = $HOME . '/.cache'| endif
if empty($XDG_DATA_HOME)| let $XDG_DATA_HOME = $HOME . '/.local/share'| endif

try
  call plug#begin('~/.local/share/nvim/plugged')    " Load plugins with vim-plug.

if has("nvim")                                      " NeoVim specific settings.
  Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh', } " LSP Support (:h LanguageClient).
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' } " Asynchronous completion framework for neovim/Vim8 (used in LanguageClient).
else
  Plug 'Shougo/deoplete.nvim'                       " Same as neovim one but without UpdateRemotePlugins.
  Plug 'roxma/nvim-yarp'                            " nvim compatibility plugin for vim used by deoplete.
  Plug 'roxma/vim-hug-neovim-rpc'                   " nvim compatibility plugin for vim used by deoplete.
endif

  Plug 'AndrewRadev/splitjoin.vim'                  " gS to split, gJ to join lines.
  Plug 'ap/vim-buftabline'                          " Show buffers in the tab bar.
  Plug 'ap/vim-readdir'                             " Nicer file browser plugin that works with buftabline.
  Plug 'easymotion/vim-easymotion'                  " Go to any word instantly.
  Plug 'eclipse/eclipse.jdt.ls', { 'dir': '~/.local/share/eclipse.jdt.ls', 'do': './mvnw clean verify' } " Java Language Server.
  Plug 'fweep/vim-zsh-path-completion'              " Nicer file browser plugin.
  Plug 'gibfahn/vim-gib'                            " Use vim colorscheme.
  Plug 'godlygeek/tabular'                          " Make tables easier (:help Tabular).
  Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': './install --bin' } " :h fzf
  Plug 'junegunn/fzf.vim'                           " Try :Files, :GFiles? :Buffers :Lines :History :Commits :BCommits
  Plug 'junegunn/vim-peekaboo'                      " Pop up register list when pasting/macroing.
  Plug 'justinmk/vim-sneak'                         " sab -> go to next ab in code.
  Plug 'keith/swift.vim'                            " Swift syntax highlighting.
  Plug 'pangloss/vim-javascript'                    " JS   language bindings.
  Plug 'rust-lang/rust.vim'                         " Rust language bindings.
  Plug 'sjl/gundo.vim'                              " Interactive undo tree (<space>u to toggle on/off, q to quit).
  Plug 'tpope/vim-abolish'                          " Work with variants of words (replacing, capitalizing etc).
  Plug 'tpope/vim-commentary'                       " Autodetect comment type for lang.
  Plug 'tpope/vim-fugitive'                         " Git commands in vim.
  Plug 'tpope/vim-repeat'                           " Allows you to use . with plugin mappings.
  Plug 'tpope/vim-surround'                         " Add/mod/remove surrounding chars.
  Plug 'tpope/vim-unimpaired'                       " [ and ] mappings (help unimpaired).

  call plug#end()                                   " Initialize plugin system
  catch /E117: Unknown function: plug#begin/
    echo "ERROR:\tvim-plug not installed, use :PI to install. Original error was:\n\t" . v:exception . "\n"
endtry

" }}} Load plugins (uses vim-plug)

" {{{ Set vim options

set nocompatible                                    " Remove vi compatibility hacks.
let mapleader = "\<Space>"                          " Set <Leader> (default shortcut used in mappings below) to Spacebar.

syntax on                                           " Turn on syntax highlighting.
filetype plugin indent on                           " Use file-specific plugins and indentation rules.
set shiftwidth=2 tabstop=2 softtabstop=2            " Set tab width to 2.
set expandtab                                       " Insert spaces when tab key pressed.
set backspace=indent,eol,start                      " Backspace works across lines.
set ignorecase                                      " Ignore case for lowercase searches,
set smartcase                                       "  ↳ don't for mixed-case.
set autoindent                                      " Moving to a new line keeps the same indentation (overridden by filetype indent on).
set foldmethod=syntax foldlevel=99                  " Fold according to the syntax rules, expand all by default.
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
set ffs=unix                                        " Force Unix line endings (\n) (always show \r (^M), never autoinsert them).
set t_Co=256                                        " Use 256 color terminal.
set splitbelow                                      " Open new split panes to right and,
set splitright                                      "  ↳ bottom, which feels more natural.
set diffopt+=vertical                               " Always use vertical diffs.
set visualbell                                      " Flash the screen instead of beeping when doing something wrong.
set confirm                                         " Ask if you want to save unsaved files instead of failing.
set notildeop                                       " Keep tilde (~) as it's default. If you want the operator version use g~.
set wildchar=<Tab> wildmenu                         " Tab complete with files (e.g. `:e`)
set wildmode=list:longest,list:full                 " 1st Tab completes to longest common string, 2nd+ cycles through options.
set list listchars=tab:»·,trail:·,nbsp:·            " Display extra whitespace.
let s:undodir = $XDG_CACHE_HOME . "/vim/undo"
if !isdirectory(s:undodir)| call mkdir(s:undodir, "p", 0700)| endif
set undofile                                        " Persist undo history on file close.
let &undodir=s:undodir                              " Store undo files in cache dir.
set path=.,/usr/include,,**                         " Add ** to the search path so :find x works recursively.
if exists('+breakindent')| set breakindent| let &showbreak = '↳ '| set cpo+=n| end " Nicer line wrapping for long lines.
if exists('&inccommand')| set inccommand=split| endif " Show search and replace as you type.
if exists("&wildignorecase")| set wildignorecase| endif " Case insensitive file tab completion with :e.
try
  colo gib                                          " Use my colorscheme
catch /E185: Cannot find color scheme 'gib'/
  echo "ERROR:\tGib colorscheme not installed, falling back to desert.\n\tRun :PU or check Plugin setup in vimrc file."
  echo "\tOriginal error was:\n\t\t" . v:exception . "\n"
  colo desert
endtry

" }}} Set vim options

" {{{ Key mappings (see http://vim.wikia.com/wiki/Unused_keys for unused keys)
" Available (normal): <C-Space>, +, _, <C-q/s/[/_>, <leader>b/c/e/h/m/n/u/v

inoremap          kj <ESC>|                         " kj = Esc in insert mode.
inoremap <expr>   <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"| " Tab is next entry if completion menu open.
inoremap <expr>   <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"| " Shift-Tab is previous entry if completion menu open.
nnoremap          k gk|                             " Move up   visually , don't skip wrapped lines,
nnoremap          j gj|                             "  ↳   down visually , don't skip wrapped lines.
nnoremap          Q <nop>|                          "  ↳ accidental triggering).
nnoremap <silent> gd :call DupBuffer()<CR>:call LanguageClient_textDocument_definition()<CR>| " Go to definition in last window.
nnoremap <silent> gD :call LanguageClient_textDocument_definition()<CR>| " Go to definition in the same window.
nnoremap          gk k|                             " Move up   logically, do    skip wrapped lines,
nnoremap          gj j|                             "  ↳   down logically, do    skip wrapped lines.
nnoremap <silent> gr :call LanguageClient_textDocument_rename()<CR>| " Rename var/func under cursor.
nnoremap          Y y$|                             " Make Y work like C and D (yank to end of line, not whole line).
" To open vim's current directory, use `:e .`.
nnoremap          - :e %:h<CR>|             " - open current buffer directory in file browser (repeat for `cd ..`).
nmap              f <Plug>Sneak_f|                  " Use sneak for f (multiline+highlight).
nmap              F <Plug>Sneak_F|                  " ↳             F
nmap              t <Plug>Sneak_t|                  " ↳             t
nmap              T <Plug>Sneak_T|                  " ↳             T

nnoremap          <Leader>a @a<CR>|                 " Apply macro a (add with qa or yank to a reg with "ay).
nnoremap          <Leader>b :Buffers<CR>|           " Search buffer list for file.
nnoremap          <Leader>d :call BufferClose('')<CR>| " Close buffer without closing split,
nnoremap          <Leader>f :Files<CR>|             " Search file names    for file,
nnoremap          <Leader>F :grep |                 "  ↳          contents for file.
nnoremap          <Leader>gc :cd %:p:h<CR>|         " Change vim directory (:pwd) to current file's dirname (e.g. for <space>f, :e).
nnoremap          <Leader>gd :w !git diff --no-index % - <CR>|     " Diff between saved file and current.
nnoremap          <Leader>gf :call DupBuffer()<CR>gF| " Open file path:row:col under cursor in last window.
nnoremap          <Leader>gg :call LanguageClient_textDocument_documentSymbol()<CR>| " Grep for symbols in the current file.
nnoremap          <Leader>gl :source <C-r>=SessionFile()<CR><CR>| " Load saved session for vim cwd to a default session path.
nnoremap          <Leader>gL :source <C-r>=SessionFile()<CR>| " Load saved session for vim cwd to a custom path.
nnoremap          <Leader>gp `[v`]| " Visual selection of the last thing you copied or pasted.
nnoremap          <Leader>gs :mksession! <C-r>=SessionFile()<CR><CR>| " Save current session for vim cwd from a default session path.
nnoremap          <Leader>gS :mksession! <C-r>=SessionFile()<CR>| " Save current session for vim cwd from a custom path.
nnoremap          <Leader>gt :set et!<CR>:set et?<CR>|   " Toggle tabs/spaces.
nnoremap          <Leader>gq :set fo-=t<CR>:set fo?<CR>| " Turn off line wrapping,
nnoremap          <Leader>gQ :set fo+=t<CR>:set fo?<CR>| " ↳    on
nnoremap          <Leader>gv :e ~/.vimrc<CR>|  " <Space>gv opens ~/.vimrc in the editor (autoreloaded on save).
nnoremap          <Leader>gw :setlocal wrap!<CR>| " <Space>gw toggles the soft-wrapping of text.
nnoremap          <Leader>id :r !date +\%Y-\%m-\%d<CR>| " Insert readable    date on new line.
nnoremap          <Leader>iD :r !date +\%d-\%b-\%y<CR>| " ↳      `:sort`able date on new line.
nnoremap          <Leader>it ITODO(gib): <ESC>:Commentary<CR>$| " Insert a TODO, (Write todo, then `<Space>it`).
nnoremap          <Leader>j :sp<CR><C-w>k:bp<CR>|   " Open horizontal split,
nnoremap          <Leader>k <C-w>q|                 " Close current split (keeps buffer).
nnoremap <silent> <Leader>K :call LanguageClient_textDocument_hover()<CR>| " Show definition.
nnoremap          <Leader>l :vsp<CR><C-w>h:bp<CR>|  " Open vertical split.
nnoremap          <Leader>o :set operatorfunc=OpenUrl<CR>g@| " Open the selected text with the appropriate program (like netrw-gx).
nnoremap          <Leader>p "+p|                    "  Paste from clipboard after cursor.
nnoremap          <Leader>P "+P|                    "                    ↳  before cursor.
nnoremap          <Leader>q :qa<CR>|                " Quit if no    unsaved changes (for single file use <Space>d instead).
nnoremap          <Leader>QQ :q!<CR>|               "      ↳ losing unsaved changes (DANGER).
nnoremap          <Leader>r :%s/|                   " Replace (e.g. <Space>rold/new),
nnoremap          <Leader>R :%s//c<Left><Left>|     "  ↳ Replace with prompt on each match.
map               <Leader>s <Plug>(easymotion-bd-w)| " EasyMotion: Move to word.
nnoremap          <Leader>u :GundoToggle<CR>|       " Toggle Undo tree visualisation.
nnoremap          <Leader>w :up<CR>|                " Write if there were changes.
nnoremap          <Leader>W :w<CR>|                 "  ↳    whether or not there were changes.
nnoremap          <Leader>x :x<CR>|                 " Save (if changes) and quit.
nnoremap          <Leader>X :xa<CR>|                " Quit all windows.
nnoremap          <Leader>y "+y|                    " Copy to clipboard (normal mode).
nnoremap          <Leader>Y :%y+<CR>|               "  ↳  file to clipboard (normal mode).
nnoremap          <Leader>z  za|                    " Toggle folding on current line.
nnoremap <expr>   <Leader>Z &foldlevel ? 'zM' :'zR'| " Toggle folding everywhere (see also "zi).
nnoremap          <Leader>/ :noh<CR>|               " Turn off find highlighting.
nnoremap          <Leader>? /<Up><CR>|              " Search for last searched thing.

nmap <leader>1 <Plug>BufTabLine.Go(1)|         " <leader>1 goes to buffer 1 (see numbers in tab bar).
nmap <leader>2 <Plug>BufTabLine.Go(2)|         " <leader>1 goes to buffer 2 (see numbers in tab bar).
nmap <leader>3 <Plug>BufTabLine.Go(3)|         " <leader>1 goes to buffer 3 (see numbers in tab bar).
nmap <leader>4 <Plug>BufTabLine.Go(4)|         " <leader>1 goes to buffer 4 (see numbers in tab bar).
nmap <leader>5 <Plug>BufTabLine.Go(5)|         " <leader>1 goes to buffer 5 (see numbers in tab bar).
nmap <leader>6 <Plug>BufTabLine.Go(6)|         " <leader>1 goes to buffer 6 (see numbers in tab bar).
nmap <leader>7 <Plug>BufTabLine.Go(7)|         " <leader>1 goes to buffer 7 (see numbers in tab bar).
nmap <leader>8 <Plug>BufTabLine.Go(8)|         " <leader>1 goes to buffer 8 (see numbers in tab bar).
nmap <leader>9 <Plug>BufTabLine.Go(1) :bp<CR>| " <leader>1 goes to last buffer (see numbers in tab bar).

" Leader + window size keys increases/decreases height/width by 3/2.
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>
nnoremap <silent> <Leader>> :exe "vertical resize " . (winwidth(0) * 3/2)<CR>
nnoremap <silent> <Leader>< :exe "vertical resize " . (winwidth(0) * 2/3)<CR>

vnoremap          <Leader>y "+y|                    "  ↳                (visual mode).
vnoremap          <Leader>d "+d|                    " Cut from clipboard (visual mode).
vnoremap          <Leader>p "+p|                    " Paste from clipboard (visual mode).

nnoremap          <C-h> <C-w>h|                     " Switch left  a window,
nnoremap          <C-j> <C-w>j|                     "  ↳     down  a window,
nnoremap          <C-k> <C-w>k|                     "  ↳     up    a window,
nnoremap          <C-l> <C-w>l|                     "  ↳     right a window.
nnoremap          <C-n> <C-l>|                      " Redraw the screen.


nmap              <C-W>>     <C-W>><SID>ws|         " Adds mappings to make Ctrl-W -/+/</>
nmap              <C-W><     <C-W><<SID>ws|         " ↳ repeatable, so you can press Ctrl-W
nnoremap <script> <SID>ws>   <C-W>><SID>ws|         " ↳ and then hold > to increase width,
nnoremap <script> <SID>ws<   <C-W><<SID>ws|         " ↳ or hold - to decrease height.
nmap              <C-W>+     <C-W>+<SID>ws|         " ↳ Note that +,<, and > need the shift key.
nmap              <C-W>-     <C-W>-<SID>ws|         " ↳ Use <Leader> < or > for bigger
nnoremap <script> <SID>ws+   <C-W>+<SID>ws|         " ↳ modifications, and this for smaller
nnoremap <script> <SID>ws-   <C-W>-<SID>ws|         " ↳ tweaks.
nmap              <SID>ws    <Nop>

nnoremap          <Tab> :bn<CR>|                    " Tab to switch to next buffer,
nnoremap          <S-Tab> :bp<CR>|                  "  ↳ Shift-Tab to switch to previous buffer.
nnoremap          <C-p> <C-i>|                      " <C-o> = go to previous jump, <C-p> is go to next (normally <C-i>, but that == Tab, used above).
vnoremap          <Leader>o :<c-u>call OpenUrl(visualmode())<CR>| " Open the selected text with the appropriate program (like netrw-gx).
vnoremap // y/\V<C-r>=escape(@",'/\')<CR><CR>|      " Search for selected text with // (very no-magic mode, searches for exactly what you select).

" Adds operator-pending mappings for folds, e.g. vif and vaf like vip and vap.
vnoremap if :<C-U>silent!normal![zjV]zk<CR>
onoremap if :normal Vif<CR>
vnoremap af :<C-U>silent!normal![zV]z<CR>
onoremap af :normal Vaf<CR>

" %% expands to dirname of current file.
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:p:h').'/' : '%%'

" }}} Key mappings (see http://vim.wikia.com/wiki/Unused_keys for unused keys)

" {{{ Functions used in key mappings above.

" Open selected text with native open command, used with `<Leader>o` mappings.
function! OpenUrl(type)
  if a:type ==# 'v'| execute "normal! `<v`>y"| " If in charwise visual mode, copy selected URL.
  elseif a:type ==# 'char'| execute "normal! `[v`]y"| " If given a text object URL, copy it.
  else| return
  endif

  " This doesn't work with /usr/bin/vim on macOS (doesn't identify as macOS).
  if has('mac')| let openCmd = 'open'| else| let openCmd = 'xdg-open'| endif
    silent execute "! " . openCmd . " " . shellescape(@@, 1)| " Escape URL and pass as arg to open command.
    echo openCmd . " " shellescape(@@, 1)| " Echo what we ran so it's visible.
endfunction

" Opens current buffer in previous split (at the same position but centered).
function! DupBuffer()
  let pos = getpos(".") " Save cursor position.
  let buff = bufnr('%') " Save buffer number of current buffer.
  execute "normal! \<c-w>p:b " buff "\<CR>"| " Change to previous buffer and open saved buffer.
  call setpos('.', pos) " Set cursor position to what is was before.
endfunction

let s:sessionDir = $XDG_CACHE_HOME . "/vim/session/"
if !isdirectory(s:sessionDir)| call mkdir(s:sessionDir, "p", 0700)| endif

" Returns path to session ${XDG_CACHE_HOME:-$HOME/.cache}/vim/session/%path%to%vim%cwd
function! SessionFile()
  return $XDG_CACHE_HOME . "/vim/session/" . substitute(getcwd(), '/', '\\%', 'g')
endfunction

func! BufferClose(bang) abort " Call BufferClose('!') to get bd!
  let oldbuf = bufnr('%') | let oldwin = winnr()
  if len(getbufinfo({'buflisted':1})) == 1 | enew | else | bp | endif " Open new if no other buffers.
  " For each window with oldbuf open, switch to previous buffer.
  while bufwinnr(oldbuf) != -1 | exec bufwinnr(oldbuf) 'wincmd w'| bp | endwhile
  " Delete oldbuf and restore window to oldwin
  exec oldwin 'wincmd w' | exec oldbuf 'bd' . a:bang
endfunc

if has("nvim")                                      " NeoVim specific settings.
  let g:terminal_scrollback_buffer_size = 100000    " Store lots of terminal history.
  if executable("nvr")| let $VISUAL = 'nvr --remote-wait'| endif " Use existing nvim window to open new files (e.g. `g cm`).
  nnoremap <Leader>t :vsplit term://$SHELL<CR>i|    " Open terminal in new split.
  nnoremap <Leader>T :term<CR>|                     " Open terminal in current split.
  tnoremap <C-h> <C-\><C-n><C-w>h|                  " Switch left  a window in terminal,
  tnoremap <C-j> <C-\><C-n><C-w>j|                  "  ↳     down  a window in terminal,
  tnoremap <C-k> <C-\><C-n><C-w>k|                  "  ↳     up    a window in terminal,
  tnoremap <C-l> <C-\><C-n><C-w>l|                  "  ↳     right a window in terminal.
  tnoremap <C-n> <C-l>|                             " Ctrl-n is Ctrl-l in a terminal.
  tnoremap <Esc> <C-\><C-n>|                        " Make Escape work in terminal,
  tnoremap kj <C-\><C-n>|                           "  ↳    kj    work in terminal.
  tnoremap KJ kj|                                   "  Use KJ for a literal kj in the terminal.

  augroup gibTermGroup                              " Autocommands for nvim only
    au TermOpen * setlocal nonumber norelativenumber  " No line numbers in terminal
    au TermOpen * setlocal wrap                     " Soft line wrapping in terminal.
  augroup end
else
  set termwinscroll=100000                          " Store lots of terminal history.
  nnoremap <Leader>t :term<CR>|wincmd L|                     " Open terminal in new split.
  nnoremap <Leader>T :term ++curwin<CR>|                     " Open terminal in current split.
  tnoremap <C-h> <C-w>h|                            " Switch left  a window in terminal,
  tnoremap <C-j> <C-w>j|                            "  ↳     down  a window in terminal,
  tnoremap <C-k> <C-w>k|                            "  ↳     up    a window in terminal,
  tnoremap <C-l> <C-w>l|                            "  ↳     right a window in terminal.
  tnoremap <C-n> <C-l>|                             " Ctrl-n is Ctrl-l in a terminal.
  tnoremap <Esc> <C-W>N|                            " Make Escape work in terminal,
  tnoremap kj <C-W>N|                               "  ↳    kj    work in terminal.
  tnoremap KJ kj|                                   "  Use KJ for a literal kj in the terminal.

  augroup gibTermGroup                              " Autocommands for nvim only
    au TerminalOpen * if &buftype == 'terminal'| setlocal nonumber norelativenumber| endif " No line numbers in terminal
  augroup end
endif

" }}} Functions used in key mappings above.

" {{{ Custom commands
command! Trim call TrimWhitespace()|                " :Trim runs :call Trim() (defined below).
command! PU PlugClean | PlugUpdate | PlugUpgrade|   " :PI installs vim-plug, :PU updates/cleans plugins and vim-plug.

command! PI !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &&
    \ ln -s ~/.local/share/nvim/site/autoload ~/.vim/autoload

let g:deoplete#enable_at_startup = 1                " Enable deoplete by default.
let g:is_posix = 1                                  " Assume shell for syntax highlighting.
"let g:rustfmt_autosave = 1                         " Run rustfmt on save (from rust.vim).
let g:sneak#use_ic_scs = 1                          " Sneak: respect smartcase setting.
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1                        " Don't use the built-in file browser (use vim-readdir instead).
let g:peekaboo_window = "vert bo 50new"             " Increase peekaboo window width to 50.
let g:gundo_right = 1                               " Undo window on right.
let g:gundo_preview_bottom = 1                      " Undo diff preview on bottom.
let g:buftabline_numbers = 2                        " Show buftabline's count (use <Leader>1-9 to switch.
let g:buftabline_indicators = 1                     " Show a + if the buffer has been modified.

let g:LanguageClient_serverCommands = {
    \ 'java': ['jdtls', '-Dlog.level=ALL'],
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'javascript.jsx': ['javascript-typescript-stdio'],
    \ 'python': ['pyls'],
    \ 'ruby': ['solargraph', 'stdio'],
    \ 'rust': ['rls'],
    \ 'sh': ['bash-language-server', 'start'],
    \ 'swift': ['langserver-swift'],
    \ }
let g:LanguageClient_settingsPath = $XDG_CONFIG_HOME . "/nvim/settings.json"

" Highlight the 81st column of text (in dark grey so it doesn't distract).
highlight ColorColumn ctermbg=234
call matchadd('ColorColumn', '\%81v', 100)

set path=.,/usr/include,,**                         " Add ** to search path
if executable("rg")
  set grepprg=rg\ -S\ --vimgrep\ --no-heading         " Use ripgrep for file searching.
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
  autocmd QuickFixCmdPost *grep* cwindow|           " Open the quickfix window on grep.
  autocmd VimEnter * silent! tabonly|               " Don't allow starting Vim with multiple tabs.
augroup END

" Function to trim trailing whitespace in a file.
function! TrimWhitespace()
  let l:save = winsaveview()
  %s/\s\+$//e
  call winrestview(l:save)
endfun

" }}} Custom commands

" vim: foldmethod=marker
