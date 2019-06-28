" BREAKING CHANGES: s is now sneak (use `cl` for `s`) function (:h sneak).
"                   <C-i> is now :bn (<C-i>==Tab for vim), use <C-p> for <C-i> function.
" Complete list of all vim commands: http://vimdoc.sourceforge.net/htmldoc/vimindex.html

" {{{ Load plugins (uses vim-plug)

if empty($XDG_CONFIG_HOME)| let $XDG_CONFIG_HOME = $HOME . '/.config'| endif
if empty($XDG_CACHE_HOME)| let $XDG_CACHE_HOME = $HOME . '/.cache'| endif
if empty($XDG_DATA_HOME)| let $XDG_DATA_HOME = $HOME . '/.local/share'| endif

" Sometimes vim runs before my dotfiles.
if $PATH !~ '/usr/local/bin'| let $PATH = '/usr/local/bin/:' . $PATH| endif

" Plugins are installed here.
let s:plugin_path = $XDG_DATA_HOME . '/nvim/plugged'
" Path to colorscheme, change if you use a different color scheme.
let $colorscheme_path = s:plugin_path . '/vim-gib/colors/gib.vim'

try
  " Add vim-plug dir to vim runtimepath (already there for nvim).
  exe 'set rtp+=' . $XDG_DATA_HOME . '/nvim/site'
  " Install vim-plug if not already installed.
  if empty(glob($XDG_DATA_HOME . '/nvim/site/autoload/plug.vim'))
    echo "Vim-Plug not installed, downloading..."
    !curl -fLo "$XDG_DATA_HOME/nvim/site/autoload/plug.vim" --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

  call plug#begin(s:plugin_path)    " Load plugins with vim-plug.

  " Conditionally enable plugin (always install, only activate if condition met).
  function! Cond(cond, ...)
    let opts = get(a:000, 0, {})
    return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
  endfunction

  Plug 'AndrewRadev/splitjoin.vim'                  " gS to split, gJ to join lines.
  Plug 'airblade/vim-gitgutter'                     " Show git diffs in the gutter (left of line numbers) (:h gitgutter).
  Plug 'ap/vim-buftabline'                          " Show buffers in the tab bar.
  Plug 'ap/vim-readdir'                             " Nicer file browser plugin that works with buftabline.
  Plug 'cespare/vim-toml'                           " Toml syntax highlighting.
  Plug 'chrisbra/Colorizer'                         " Color ansi escape codes (:h Colorizer).
  Plug 'coderifous/textobj-word-column.vim'         " Adds ic/ac and iC/aC motions to block select word column in paragraph.
  Plug 'fweep/vim-zsh-path-completion'              " Nicer file browser plugin.
  Plug 'gibfahn/vim-gib'                            " Use vim colorscheme.
  Plug 'godlygeek/tabular'                          " Make tables easier (:help Tabular).
  Plug 'itchyny/lightline.vim'                      " Customize statusline and tabline.
  Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf', 'do': './install --bin' } " :h fzf
  Plug 'junegunn/fzf.vim'                           " Try :Files, :GFiles? :Buffers :Lines :History :Commits :BCommits
  Plug 'junegunn/vim-peekaboo'                      " Pop up register list when pasting/macroing.
  Plug 'justinmk/vim-sneak'                         " sab -> go to next ab in code (:h sneak-mappings for default mappings).
  Plug 'kana/vim-operator-user'                     " Make it easier to define operators.
  Plug 'kana/vim-textobj-line'                      " Adds `il` and `al` text objects for current line.
  Plug 'kana/vim-textobj-user'                      " Allows you to create custom text objects (used in vim-textobj-line).
  Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}
  Plug 'raghur/vim-ghost', {'do': ':GhostInstall'}  " Edit browser text areas in Neovim (:h ghost).
  Plug 'rust-lang/rust.vim'                         " Rust language bindings.
  Plug 'simnalamburt/vim-mundo'                     " Graphical undo tree (updated fork of Gundo).
  Plug 'takac/vim-hardtime'                         " Disable key repeat.
  Plug 'tpope/vim-abolish'                          " Work with variants of words (replacing, capitalizing etc).
  Plug 'tpope/vim-commentary'                       " Autodetect comment type for lang.
  Plug 'tpope/vim-fugitive'                         " Git commands in vim.
  Plug 'tpope/vim-markdown'                         " Better markdown highlight including support for code block highlighting.
  Plug 'tpope/vim-repeat'                           " Allows you to use . with plugin mappings.
  Plug 'tpope/vim-rhubarb'                          " GitHub support.
  Plug 'tpope/vim-surround'                         " Add/mod/remove surrounding chars.
  Plug 'tpope/vim-unimpaired'                       " [ and ] mappings (help unimpaired).

  " Plugins where order is important (last one wins).
  Plug 'sheerun/vim-polyglot'                       " Syntax files for a large number of different languages.
  Plug 'tpope/vim-sleuth'                           " Automatically detect indentation.
  Plug 'editorconfig/editorconfig-vim'              " Parse .editorconfig files (https://editorconfig.org/).

  call plug#end()                                   " Initialize plugin system
  catch /E117: Unknown function: plug#begin/
    echo "ERROR:\tvim-plug automatic install failed. Original error was:\n\t" . v:exception . "\n"
endtry
" }}} Load plugins (uses vim-plug)

" {{{ Set vim options

set nocompatible                                    " Remove vi compatibility hacks.
let mapleader = "\<Space>"                          " Set <Leader> (default shortcut used in mappings below) to Spacebar.

syntax enable                                       " Turn on syntax highlighting.
filetype plugin indent on                           " Use file-specific plugins and indentation rules.

set autoindent                                      " Moving to a new line keeps the same indentation (overridden by filetype indent on).
set autoread                                        " Auto read when file is changed elsewhere.
set backspace=indent,eol,start                      " Backspace works across lines.
set confirm                                         " Ask if you want to save unsaved files instead of failing.
set diffopt+=vertical                               " Always use vertical diffs.
set expandtab                                       " Insert spaces when tab key pressed.
set ffs=unix                                        " Force Unix line endings (\n) (always show \r (^M), never autoinsert them).
set foldmethod=syntax foldlevel=99                  " Fold according to the syntax rules, expand all by default.
set formatoptions-=t                                " Don't autowrap text at 80.
set gdefault                                        " Global replace default (off: /g).
set hidden                                          " Don't force saving buffers on switching.
set history=1000                                    " More command/search history.
set hlsearch                                        " Highlight search matches (off: <Space>/).
set ignorecase                                      " Ignore case for lowercase searches (re-enable with \C in pattern),
set incsearch                                       " Incremental searching.
set laststatus=2                                    " Always display the status line.
set lazyredraw                                      " Don't redraw if you don't have to (e.g. in macros).
set list listchars=tab:»·,trail:·,nbsp:☠            " Display extra whitespace.
set mouse=a                                         " Mouse in all modes (mac: Fn+drag = copy).
set nojoinspaces                                    " One space (not two) after punctuation..
set noshowmode                                      " Don't show when in insert mode (set in lightline).
set notildeop                                       " Keep tilde (~) as it's default. If you want the operator version use g~.
set number                                          " Turn on line numbers.
set ruler                                           " Always show cursor position.
set shiftwidth=2 tabstop=2 softtabstop=2            " Set tab width to 2.
set showcmd                                         " Display incomplete commands.
set signcolumn=auto                                 " Resize the sign column automatically.
set smartcase                                       "  ↳ don't for mixed-case.
set splitbelow                                      " Open new split panes to right and,
set splitright                                      "  ↳ bottom, which feels more natural.
set t_Co=256                                        " Use 256 color terminal.
set termguicolors                                   " Uses 24-bit colors in the terminal (guifg and guibg).
set undolevels=1000                                 " More undo history.
set updatetime=100                                  " Delay after which to write to swap file and run CursorHold event.
set visualbell                                      " Flash the screen instead of beeping when doing something wrong.
set wildchar=<Tab> wildmenu                         " Tab complete with files (e.g. `:e`)
set wildmode=list:longest,list:full                 " 1st Tab completes to longest common string, 2nd+ cycles through options.

let s:undodir = $XDG_CACHE_HOME . "/vim/undo"
if !isdirectory(s:undodir)| call mkdir(s:undodir, "p", 0700)| endif
set undofile                                        " Persist undo history on file close.
let &undodir=s:undodir                              " Store undo files in cache dir.
set path=.,/usr/include,,**                         " Add ** to the search path so :find x works recursively.
if exists('+breakindent')| set breakindent| let &showbreak = '↳   '| set cpo+=n| end " Nicer line wrapping for long lines.
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
" Available (normal): <C-Space>, +, _, <C-q/s/[/_>, <leader>e/m/n/v

" In insert mode, if completion dropdown open, Tab/Shift-Tab switch between entries. Otherwise if
" the previous character was a space they indent, else Tab will trigger the completion manually.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)
" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" Shift-Tab is previous entry if completion menu open.
inoremap <expr>   <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

nnoremap          Q <nop>|                          "  ↳ accidental triggering).
nnoremap          Y y$|                             " Make Y work like C and D (yank to end of line, not whole line).
" To open vim's current directory, use `:e .`.
nnoremap - :e %:h<CR>|    " - open current buffer directory in file browser (repeat for `cd ..`).
nmap     f <Plug>Sneak_f| " Use sneak for f (multiline+highlight).
nmap     F <Plug>Sneak_F| " ↳             F
nmap     t <Plug>Sneak_t| " ↳             t
nmap     T <Plug>Sneak_T| " ↳             T

" Delete window to the left/below/above/to the right with d<C-h/j/k/l>.
nnoremap d<C-j> <C-w>j<C-w>c
nnoremap d<C-k> <C-w>k<C-w>c
nnoremap d<C-h> <C-w>h<C-w>c
nnoremap d<C-l> <C-w>l<C-w>c

nnoremap <Leader>a @a|       " Apply macro a (add with qa or yank to a reg with "ay).
nnoremap <Leader>b :Buffers<CR>| " Search buffer list for file.

""""""""""""""""""
" CoC Remappings "
""""""""""""""""""

" Remap keys for gotos
nmap <silent> <Leader>cd <Plug>(coc-definition)
nmap <silent> <Leader>cD :call DupBuffer()<CR><Plug>(coc-definition)
nmap <silent> <Leader>cy <Plug>(coc-type-definition)
nmap <silent> <Leader>cY :call DupBuffer()<CR><Plug>(coc-type-definition)
nmap <silent> <Leader>ci <Plug>(coc-implementation)
nmap <silent> <Leader>cI :call DupBuffer()<CR><Plug>(coc-implementation)
nmap <silent> <Leader>cu <Plug>(coc-references)
nmap <silent> <Leader>cU :call DupBuffer()<CR><Plug>(coc-references)

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Remap for rename current word
nmap <Leader>cr <Plug>(coc-rename)

" Remap for format selected region
vmap <Leader>cf  <Plug>(coc-format-selected)
nmap <Leader>cf  <Plug>(coc-format-selected)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
" vmap <Leader>a  <Plug>(coc-codeaction-selected)
" nmap <Leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <Leader>ca  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <Leader>cf  <Plug>(coc-fix-current)

" Using CocList
" Show all diagnostics
nnoremap <silent> <Leader>ca  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <Leader>ce  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <Leader>cc  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <Leader>co  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>cs  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>cj  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>ck  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>cp  :<C-u>CocListResume<CR>

nnoremap <Leader>d :call BufferClose('')<CR>| " Close buffer without closing split,
nnoremap <Leader>f :Files<CR>|             " Search file names    for file,
nnoremap <Leader>F :grep |                 "  ↳          contents for file.
nnoremap <Leader>gc :cd %:p:h<CR>|         " Change vim directory (:pwd) to current file's dirname (e.g. for <space>f, :e).
nnoremap <Leader>gC :e ~/.config/nvim/coc-settings.json<CR> " Edit colorscheme file.
nnoremap <Leader>gd :w !git diff --no-index % - <CR>|     " Diff between saved file and current.
nnoremap <Leader>gf :call DupBuffer()<CR>gF| " Open file path:row:col under cursor in last window.
nnoremap <Leader>gh :call <SID>SynStack()<CR>| " Show which syntax is set for current cursor location.
nnoremap <Leader>gH :e $colorscheme_path<CR> " Edit colorscheme file.
nnoremap <Leader>gl :source <C-r>=SessionFile()<CR><CR>| " Load saved session for vim cwd to a default session path.
nnoremap <Leader>gL :source <C-r>=SessionFile()<CR>| " Load saved session for vim cwd to a custom path.
nnoremap <Leader>gp `[v`]| " Visual selection of the last thing you copied or pasted.
nnoremap <Leader>gs :mksession! <C-r>=SessionFile()<CR><CR>| " Save current session for vim cwd from a default session path.
nnoremap <Leader>gS :mksession! <C-r>=SessionFile()<CR>| " Save current session for vim cwd from a custom path.
nnoremap <Leader>gt :set et!<CR>:set et?<CR>|   " Toggle tabs/spaces.
nnoremap <Leader>gq :set fo-=t<CR>:set fo?<CR>| " Turn off line wrapping (auto-inserting newlines when you go over the textwidth).
nnoremap <Leader>gQ :set fo+=t<CR>:set fo?<CR>| " ↳    on
nnoremap <Leader>gv :e $MYVIMRC<CR>|  " <Space>gv opens vimrc in the editor (autoreloaded on save).
nnoremap <Leader>gw :setlocal wrap!<CR>| " <Space>gw toggles the soft-wrapping of text (whether text runs off the screen).
nnoremap <Leader>id :r !date +\%Y-\%m-\%d<CR>| " Insert readable    date on new line.
nnoremap <Leader>iD :r !date +\%d-\%b-\%y<CR>| " ↳      `:sort`able date on new line.
nnoremap <Leader>it ITODO(gib): <ESC>:Commentary<CR>$| " Insert a TODO, (Write todo, then `<Space>it`).
nnoremap <Leader>j :sp<CR><C-w>k:bp<CR>|   " Open horizontal split,
nnoremap <Leader>k <C-w>q|                 " Close current split (keeps buffer).
nnoremap <Leader>K :cclose<CR>:lclose<CR>:helpclose<CR><C-W>z| " Close open preview windows (e.g. language server definitions).
nnoremap <Leader>l :vsp<CR><C-w>h:bp<CR>|  " Open vertical split.
nnoremap <Leader>L <C-w>b<C-w>q|           " Close last split (keeps buffer). Useful for quickfix splits.
nnoremap <Leader>o :set operatorfunc=OpenUrl<CR>g@| " Open the selected text with the appropriate program (like netrw-gx).
nnoremap <Leader>p "+p|                    "  Paste from clipboard after cursor.
nnoremap <Leader>P "+P|                    "                    ↳  before cursor.
nnoremap <Leader>q :qa<CR>|                " Quit if no    unsaved changes (for single file use <Space>d instead).
nnoremap <Leader>QQ :q!<CR>|               "      ↳ losing unsaved changes (DANGER).
nnoremap <Leader>r :%s/|                   " Replace in current doc.
nnoremap <Leader>R :cfdo %s//ce <bar> up<S-Left><S-Left><Left><Left><Left><Left>| " Replace in all quickfix files (use after gr).
nnoremap <Leader>u :MundoToggle<CR>|       " Toggle Undo tree visualisation.
nnoremap <Leader>w :up<CR>|                " Write if there were changes.
nnoremap <Leader>W :w<CR>|                 " Write whether or not there were changes.
nnoremap <Leader>x :x<CR>|                 " Save (if changes) and quit.
nnoremap <Leader>X :xa<CR>|                " Quit all windows.
nnoremap <Leader>y "+y|                    " Copy to clipboard (normal mode).
nnoremap <Leader>Y :%y+<CR>|               "  ↳  file to clipboard (normal mode).
nnoremap <Leader>z  za|                    " Toggle folding on current line.
nnoremap <expr> <Leader>Z &foldlevel ? 'zM' :'zR'| " Toggle folding everywhere (see also "zi).
nnoremap <Leader>; @:|                     " Repeat the last executed command.
nnoremap <Leader>/ :noh<CR>|               " Turn off find highlighting.
nnoremap <Leader>? /<Up><CR>|              " Search for last searched thing.

" Grep for operator or visual selection, uses fixed string ripgrep search.
nmap gr <Plug>(operator-ripgrep-root)
vmap gr <Plug>(operator-ripgrep-root)

nmap <leader>1 <Plug>BufTabLine.Go(1)|         " <leader>1 goes to buffer 1 (see numbers in tab bar).
nmap <leader>2 <Plug>BufTabLine.Go(2)|         " <leader>1 goes to buffer 2 (see numbers in tab bar).
nmap <leader>3 <Plug>BufTabLine.Go(3)|         " <leader>1 goes to buffer 3 (see numbers in tab bar).
nmap <leader>4 <Plug>BufTabLine.Go(4)|         " <leader>1 goes to buffer 4 (see numbers in tab bar).
nmap <leader>5 <Plug>BufTabLine.Go(5)|         " <leader>1 goes to buffer 5 (see numbers in tab bar).
nmap <leader>6 <Plug>BufTabLine.Go(6)|         " <leader>1 goes to buffer 6 (see numbers in tab bar).
nmap <leader>7 <Plug>BufTabLine.Go(7)|         " <leader>1 goes to buffer 7 (see numbers in tab bar).
nmap <leader>8 <Plug>BufTabLine.Go(8)|         " <leader>1 goes to buffer 8 (see numbers in tab bar).
nmap <leader>9 <Plug>BufTabLine.Go(1) :bp<CR>| " <leader>1 goes to last buffer (see numbers in tab bar).

" Use `[c` and `]c` for next/previous diagnostic message.
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Use `[h` and `]h` for next and previous changed git hunk.
nmap [h <Plug>GitGutterPrevHunk
nmap ]h <Plug>GitGutterNextHunk

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

" See SurroundOp() function.
omap <expr> s '<esc>'.SurroundOp('s')
omap <expr> S '<esc>'.SurroundOp('S')
imap <C-S> <Plug>Isurround
imap <C-G>s <Plug>Isurround
imap <C-G>S <Plug>ISurround

" %% expands to dirname of current file.
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:p:h').'/' : '%%'

" }}} Key mappings (see http://vim.wikia.com/wiki/Unused_keys for unused keys)

" {{{ Functions used in key mappings above.

function! s:CallRipGrep(...) abort
  call fzf#vim#grep('rg --vimgrep --color=always --smart-case --hidden --glob !.git -F ' . shellescape(join(a:000, ' ')), 1,
        \ fzf#vim#with_preview({ 'options': ['-m', '--bind=ctrl-a:toggle-all,alt-j:jump,alt-k:jump-accept']}, 'right:50%', 'ctrl-p'), 1)
endfunction

function! s:RipWithRange() range
  call s:CallRipGrep(join(getline(a:firstline, a:lastline), '\n'))
endfunction
call operator#user#define('ripgrep-root', 'OperatorRip')

function! OperatorRip(wiseness) abort
  if a:wiseness ==# 'char'
    normal! `[v`]"ay
    call s:CallRipGrep(@a)
  elseif a:wiseness ==# 'line'
    '[,']call s:RipWithRange()
  endif
endfunction

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

function! BufferClose(bang) abort " Call BufferClose('!') to get bd!
  let oldbuf = bufnr('%') | let oldwin = winnr()
  if len(getbufinfo({'buflisted':1})) == 1 | enew | else | bp | endif " Open new if no other buffers.
  " For each window with oldbuf open, switch to previous buffer.
  while bufwinnr(oldbuf) != -1 | exec bufwinnr(oldbuf) 'wincmd w'| bp | endwhile
  " Delete oldbuf and restore window to oldwin
  exec oldwin 'wincmd w' | exec oldbuf 'bd' . a:bang
endfunc

" Used in the Tab mappings above.
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Make vim-surround work in operator-pending mode, so the cursor changes when you press e.g. ys.
" Requires custom mapping and disabling default mappings (SurroundOp).
function! SurroundOp(char)
    if v:operator ==# 'd'
        return "\<plug>D" . a:char . "urround"
    elseif v:operator ==# 'c'
        return "\<plug>C" . a:char . "urround"
    elseif v:operator ==# 'y'
        return "\<plug>Y" . a:char . "urround"
    endif
    return ''
endfunction

" Used in <Leader>gh shortcut, show syntax group under cursor.
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  let l = line(".")
  let c = col(".")
  echo "hi<" . synIDattr(synID(l, c, 1),"name") . '> trans<'
  \ . synIDattr(synID(l, c, 0), "name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(l, c, 1)), "name") . ">"

  echo map(synstack(l, c), 'synIDattr(v:val, "name")')
endfunc

" Used in K mapping above.
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Returns the function the cursor is currently in, used in lightline status bar.
function! CocCurrentFunction()
  let f = get(b:, 'coc_current_function', '')
  return f == '' ? '' : f . '()'
endfunction

" Function to trim trailing whitespace in a file.
function! TrimWhitespace()
  let l:save = winsaveview()
  %s/\s\+$//e
  call winrestview(l:save)
endfunction

if has('nvim')                                      " NeoVim specific settings.
  let g:terminal_scrollback_buffer_size = 100000    " Store lots of terminal history.
  if executable("nvr")| let $VISUAL = 'nvr --remote-wait'| endif " Use existing nvim window to open new files (e.g. `g cm`).
  nnoremap <Leader>t :vsplit term://$SHELL<CR>i|    " Open terminal in new split.
  nnoremap <Leader>T :term<CR>|                     " Open terminal in current split.
  tnoremap <C-h> <C-\><C-n><C-w>h|                  " Switch left  a window in terminal,
  tnoremap <C-j> <C-\><C-n><C-w>j|                  "  ↳     down  a window in terminal,
  tnoremap <C-k> <C-\><C-n><C-w>k|                  "  ↳     up    a window in terminal,
  tnoremap <C-l> <C-\><C-n><C-w>l|                  "  ↳     right a window in terminal.
  tnoremap <C-n> <C-l>|                             " Ctrl-n is Ctrl-l in a terminal.
  tnoremap <Esc> <C-\><C-n>|                        " Go to normal mode.

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
  tnoremap <Esc> <C-W>N|                            " Make Escape work in terminal.

  augroup gibTermGroup                              " Autocommands for nvim only
    au TerminalOpen * if &buftype == 'terminal'| setlocal nonumber norelativenumber| endif " No line numbers in terminal
  augroup end
endif

" Used in Swapfile autocmds below.
function! s:HandleRecover()
  echo system('diff - ' . shellescape(expand('%:p')), join(getline(1, '$'), "\n") . "\n")
  if v:shell_error
    call s:DiffOrig()
  else
    call delete(b:swapname)
    echohl WarningMsg
    echomsg "No differences; deleting the old swap file."
    echohl NONE
    call feedkeys(" ")
  endif
endfunction

" Used in Swapfile autocommands below.
function! s:DiffOrig()
  vert new
  set bt=nofile
  r #
  0d_
  diffthis
  wincmd p
  diffthis
endfunction

" }}} Functions used in key mappings above.

" {{{ Custom commands, Autocommands, global variables
command! Trim call TrimWhitespace()|                " :Trim runs :call Trim() (defined below).
command! PU PlugClean | PlugUpdate | PlugUpgrade|   " :PU updates/cleans plugins and vim-plug.

" :Locate will search entire filesystem for file.
command! -nargs=1 -bang Locate call fzf#run(fzf#wrap({'source': 'locate <q-args>', 'options': '-m'}, <bang>0))

" Use Rg to specify the string to search for (can be regex).
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg  --vimgrep --color=always --smart-case --hidden ' . shellescape(<q-args>), 1,
  \   fzf#vim#with_preview({'options': ['-m', '--bind=ctrl-a:toggle-all,alt-j:jump,alt-k:jump-accept']}, 'right:50%', 'ctrl-p'))

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Run a command and interpret the output in the quickfix window
command! -nargs=+ -complete=file Cr cexpr system(<q-args>)
" Run a command and interpret the output in the location window
command! -nargs=+ -complete=file Lr lexpr system(<q-args>)

if filereadable('/usr/local/bin/python3')
  let g:python3_host_prog = "/usr/local/bin/python3"  " Speed up startup by not looking for python3 every time.
endif

let g:fzf_history_dir = $XDG_CACHE_HOME . '/fzf-history' " Save history of fzf vim commands.
let g:buftabline_indicators = 1                     " Show a + if the buffer has been modified.
let g:buftabline_numbers = 2                        " Show buftabline's count (use <Leader>1-9 to switch.
let g:echodoc#type = 'virtual' " Needs nvim 0.3.2 (`brew unlink neovim && brew install --HEAD neovim` for now).
let g:ghost_darwin_app = 'kitty'                    " Tell vim-ghost which terminal to open.
let g:github_enterprise_urls = ['https://github.pie.apple.com'] " Add your GHE repo so vim-fugitive's :Gbrowse! can use it (try with visual mode).
let g:hardtime_allow_different_key = 1              " Allow alternating keys (e.g. kj).
let g:hardtime_default_on = 1                       " Don't allow repeated keypresses by default.
let g:hardtime_ignore_quickfix = 1                  " Don't give me a hard time about repeated keys in quickfix window.
let g:is_posix = 1                                  " Assume shell for syntax highlighting.
let g:loaded_netrw = 1                              " Skip loading netrw file browser (use vim-readdir instead).
let g:loaded_netrwPlugin = 1                        " Don't use the built-in file browser (use vim-readdir instead).
let g:mundo_preview_bottom = 1                      " Undo diff preview on bottom.
let g:mundo_right = 1                               " Undo window on right.
let g:peekaboo_window = "vert bo 50new"             " Increase peekaboo window width to 50.
let g:sneak#label = 1                               " Make sneak like easymotion (but nicer).
let g:sneak#target_labels = ";sftunqm/`'-+SFGHLTUNRMQZ?0123456789!()\\[]:|<>WEYIOPADJKXCVB.\"\,:weryiopadghjklzxcvb" " Labels sneak uses to show words.
let g:sneak#use_ic_scs = 1                          " Sneak: respect smartcase setting.
let g:surround_no_mappings = 1                      " Manually map surround, see SurroundOp() function.
let g:colorizer_use_virtual_text = 1                " Use virtual text

" Settings for custom statusline.
let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'active': {
    \ 'left': [ [ 'mode', 'paste' ],
    \           [ 'readonly', 'relativepath', 'modified' ],
    \           [ 'gitbranch' ],
    \           [ 'truncate_here' ],
    \           [ 'cocstatus' ] ],
    \ 'right': [ [ 'lineinfo' ],
    \            [ 'percent' ],
    \            [ 'fileformat', 'fileencoding', 'filetype' ],
    \            [ 'currentfunction' ] ] },
  \ 'inactive': {
    \ 'left': [ [ 'filename' ], [ 'currentfunction' ]],
    \ 'right': [ [ 'lineinfo' ],
    \            [ 'percent' ] ] },
  \ 'tabline': {
    \ 'left': [ [ 'tabs' ] ],
    \ 'right': [ [ 'close' ] ] },
 \ 'component': {
    \ 'truncate_here': '%<',
    \ 'fileformat': '%{&ff=="unix"?"":&ff}',
    \ 'fileencoding': '%{&fenc=="utf-8"?"":&fenc}' },
 \ 'component_visible_condition': {
    \ 'truncate_here': 0,
    \ 'fileformat': '&ff&&&ff!="unix"',
    \ 'fileencoding': '&fenc&&&fenc!="utf-8"' },
 \ 'component_type': {
    \ 'truncate_here': 'raw' },
 \ 'component_function': {
    \ 'cocstatus': 'coc#status',
    \ 'currentfunction': 'CocCurrentFunction',
    \ 'gitbranch': 'fugitive#head', },
  \ }

" Extensions (plugins) for CoC language client.
let g:coc_global_extensions = [
  \ 'coc-json',
  \ 'coc-tsserver',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-vetur',
  \ 'coc-java',
  \ 'coc-solargraph',
  \ 'coc-rls',
  \ 'coc-yaml',
  \ 'coc-python',
  \ 'coc-highlight',
  \ 'coc-snippets',
  \ 'coc-svg',
  \ 'coc-gocode',
  \ 'coc-ccls',
  \ 'coc-prettier',
  \ 'coc-eslint',
  \ 'coc-dictionary',
  \ 'coc-word',
  \ 'coc-emoji',
  \ 'coc-syntax',
  \ ]

" Should be parsed by vim-markdown plugin to render code blocks properly, doesn't seem to work.
" Block names: https://github.com/github/linguist/blob/master/lib/linguist/languages.yml
let g:markdown_fenced_languages = ['bash=sh', 'c', 'console=sh', 'diff', 'dockerfile', 'go',
  \ 'javascript', 'js=javascript', 'json', 'kotlin', 'python', 'rust', 'sh', 'toml', 'vim', 'yaml']

" Don't use polyglot markdown so we can use vim-markdown and get highlighted blocks.
let g:polyglot_disabled = ['markdown', 'pug']

" Highlight the 81st column of text (in dark grey so it doesn't distract).
highlight ColorColumn guibg=#383734
call matchadd('ColorColumn', '\%81v', 100)

if executable("rg")
  set grepprg=rg\ -S\ --vimgrep\ --no-heading       " Use ripgrep for file searching.
  set grepformat=%f:%l:%c:%m,%f:%l:%m               " Teach vim how to parse the ripgrep output.
endif

augroup gibAutoGroup                                " Group of automatic functions.
  autocmd!|                                         " Remove existing autocmds.
  autocmd BufReadPost *|                            " On open jump to last cursor position if possible.
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   execute "normal g`\"" |
    \ endif
  autocmd BufRead,BufNewFile *.md set filetype=markdown  " Use markdown for md files.
  autocmd FileType help wincmd L                    " Open new help windows on the right,
  " autocmd FileType qf wincmd L                       "  ↳       build windows on the right.
  autocmd FileType yaml setlocal foldmethod=indent  " YAML files should be folded by indent.
  autocmd FileType json setlocal foldmethod=indent  " JSON files should be folded by indent.
  autocmd FileType python setlocal foldmethod=indent textwidth=100  " Python files should be folded by indent.
  autocmd BufNewFile,BufRead *.bats set filetype=sh " Bats is a shell test file type.
  autocmd BufWritePost $MYVIMRC nested source $MYVIMRC " Reload vimrc on save.
  autocmd BufWritePost $colorscheme_path nested source $colorscheme_path " Reload colorscheme on save:
  autocmd QuickFixCmdPost *grep* cwindow|           " Open the quickfix window on grep.
  autocmd VimEnter * silent! tabonly|               " Don't allow starting Vim with multiple tabs.
  " Check if files modified when you open a new window, switch back to vim, or if you don't move the cursor for 100ms.
  " Use getcmdwintype() to avoid running in the q: window (otherwise you get lots of errors).
  autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if getcmdwintype() == '' | checktime | endif
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json,rust setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')
  " Allow comments in json.
  autocmd FileType json syntax match Comment +\/\/.\+$+

  " Recover deletes swapfile if no difference, or shows diff if different.
  autocmd SwapExists  * let b:swapchoice = '?' | let b:swapname = v:swapname
  autocmd BufReadPost * let b:swapchoice_likely = (&l:ro ? 'o' : 'r')
  autocmd BufEnter    * let b:swapchoice_likely = (&l:ro ? 'o' : 'e')
  autocmd BufWinEnter * if exists('b:swapchoice') && exists('b:swapchoice_likely') | let b:swapchoice = b:swapchoice_likely | unlet b:swapchoice_likely | endif
  autocmd BufWinEnter * if exists('b:swapchoice') && b:swapchoice == 'r' | call s:HandleRecover() | endif
augroup END

" }}} Custom commands, Autocommands, global variables

" vim: foldmethod=marker
