-- Lua core configuration for neovim.
-- Docs:
--   https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
--   https://neovim.io/doc/user/lua.html
--   https://github.com/nanotee/nvim-lua-guide
--
-- {{{ Global variables
-- Sometimes vim runs before my dotfiles.
if not vim.env.PATH:find('/usr/local/bin') then vim.env.PATH = '/usr/local/bin:' .. vim.env.PATH end
if vim.fn.filereadable('/opt/homebrew/bin/python3') == 1 then
  -- Speed up startup by not looking for python3 every time.
  vim.g.python3_host_prog = "/opt/homebrew/bin/python3"
end

vim.env.XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME or vim.env.HOME .. '/.cache'
vim.env.XDG_CONFIG_HOME = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. '/.config'
vim.env.XDG_DATA_HOME = vim.env.XDG_DATA_HOME or vim.env.HOME .. '/.local/share'

if vim.fn.executable("nvr") then
  -- Use existing nvim window to open new files (e.g. `g cm`).
  vim.env.VISUAL = 'nvr --remote-wait'
end

vim.g.any_jump_disable_default_keybindings = 1 -- Conflicts with other useful bindings.
vim.g.buftabline_indicators = 1 -- Show a + if the buffer has been modified.
vim.g.buftabline_numbers = 2 -- Show buftabline's count (use <Leader>1-9 to switch.
vim.g.coc_snippet_next = '<a-u>' -- Use <Alt-u> for jump to next placeholder.
vim.g.coc_snippet_prev = '<a-l>' -- Use <Alt-l> for jump to previous placeholder.
vim.g.colorizer_use_virtual_text = 1 -- Use virtual text
vim.g.fzf_history_dir = vim.env.XDG_CACHE_HOME .. '/fzf-history' -- Save history of fzf vim commands.
vim.g.is_posix = 1 -- Assume shell for syntax highlighting.
vim.g.loaded_netrw = 1 -- Skip loading netrw file browser (use vim-readdir instead).
vim.g.loaded_netrwPlugin = 1 -- Don't use the built-in file browser (use vim-readdir instead).
vim.g.mapleader = ' ' -- use space as a the leader key
vim.g.mundo_preview_bottom = 1 -- Undo diff preview on bottom.
vim.g.mundo_right = 1 -- Undo window on right.
vim.g.peekaboo_window = "vert bo 50new" -- Increase peekaboo window width to 50.
vim.g.surround_97 = "\1before: \1\r\2after: \2" -- yswa surrounds with specified text (prompts for before/after).
vim.g.surround_no_mappings = 1 -- Manually map surround, see SurroundOp() function.
vim.g.terminal_scrollback_buffer_size = 100000 -- Store lots of terminal history (neovim-only).

-- Extensions (plugins) for CoC language client.
vim.g.coc_global_extensions = { 'coc-actions', 'coc-ccls', 'coc-clangd', 'coc-css', 'coc-diagnostic', 'coc-dictionary',
  'coc-emoji', 'coc-eslint', 'coc-go', 'coc-groovy', 'coc-highlight', 'coc-html', 'coc-java', 'coc-json', 'coc-lua',
  'coc-prettier', 'coc-markdownlint', 'coc-python', 'coc-rust-analyzer', 'coc-snippets', 'coc-solargraph',
  'coc-sourcekit', 'coc-svg', 'coc-syntax', 'coc-tabnine', 'coc-tsserver', 'coc-vetur', 'coc-word', 'coc-yaml'
}

-- Settings for custom statusline.
vim.g.lightline = {
  colorscheme = 'wombat',
  component = {truncate_here = '%<', fileformat = '%{&ff=="unix"?"":&ff}', fileencoding = '%{&fenc=="utf-8"?"":&fenc}'},
  component_expand = {
    coc_error = 'LightlineCocErrors',
    coc_warning = 'LightlineCocWarnings',
    coc_info = 'LightlineCocInfos',
    coc_hint = 'LightlineCocHints'
  },
  component_visible_condition = {
    truncate_here = 0,
    fileformat = '&ff&&&ff!="unix"',
    fileencoding = '&fenc&&&fenc!="utf-8"'
  },
  component_type = {
    coc_error = 'error',
    coc_warning = 'warning',
    coc_info = 'tabsel',
    coc_hint = 'middle',
    coc_fix = 'middle',
    truncate_here = 'raw'
  },
  component_function = {currentfunction = 'CocCurrentFunction', gitbranch = 'FugitiveHead'},
  active = {
    left = {
      {'mode', 'paste'}, {'readonly', 'relativepath', 'modified'}, {'gitbranch'}, {'truncate_here'},
      {'coc_error', 'coc_warning', 'coc_info', 'coc_hint'}
    },
    right = {{'lineinfo'}, {'percent'}, {'fileformat', 'fileencoding', 'filetype'}, {'currentfunction'}}
  },
  inactive = {left = {{'relativepath'}}, right = {{'lineinfo'}, {'percent'}}},
  tabline = {left = {{'tabs'}}, right = {{'close'}}}
}
-- }}} Global variables

-- {{{ Vim options

vim.cmd 'colorscheme desert' -- Default colorscheme in case plugins don't load.

vim.opt.breakindent = true -- Nicer line wrapping for long lines.
vim.opt.confirm = true -- Ask if you want to save unsaved files instead of failing.
vim.opt.diffopt:append("vertical") -- Always use vertical diffs.
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.fileformats = "unix" -- Force Unix line endings (\n) (always show \r (^M), never autoinsert them).
vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- Fold with treesitter.
vim.opt.foldlevel = 99 -- expand all by default.
vim.opt.foldmethod = "expr" -- Fold according to the syntax rules,
vim.opt.formatoptions:remove("t") -- Don't autowrap text at 80.
vim.opt.gdefault = true -- Global replace default (off: /g).
vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m' -- Teach vim how to parse the ripgrep output.
vim.opt.grepprg = 'rg -S --vimgrep --no-heading --hidden --glob !.git' -- Use ripgrep for file searching.
vim.opt.hidden = true -- Enable background buffers
vim.opt.history = 1000 -- More command/search history.
vim.opt.ignorecase = true -- Ignore case for lowercase searches (re-enable with \C in pattern),
vim.opt.inccommand = "split" -- Show search and replace as you type.
vim.opt.joinspaces = false -- No double spaces with join
vim.opt.lazyredraw = true -- Don't redraw if you don't have to (e.g. in macros).
vim.opt.list = true -- Show some invisible characters (see listchars).
vim.opt.listchars = {tab = "»·", trail = "·", nbsp = "☠"} -- Display extra whitespace.
vim.opt.mouse = "a" -- Mouse in all modes (mac: Fn+drag = copy).
vim.opt.number = false -- Show line numbers
vim.opt.path = ".,/usr/include,,**" -- Add ** to the search path so :find x works recursively.
vim.opt.shiftround = true -- Round indent to multiple of 'shiftwidth'. Applies to > and < commands.
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.showbreak = "↳   " -- Nicer line wrapping for long lines.
vim.opt.showmode = false -- Don't show when in insert mode (set in lightline).
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.signcolumn = "auto" -- Resize the sign column automatically.
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.softtabstop = 2 -- Number of spaces tabs count for
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.termguicolors = true -- True color support
vim.opt.undofile = true -- Persistent undo file saved between file edits.
vim.opt.updatetime = 100 -- Delay after which to write to swap file and run CursorHold event.
vim.opt.updatetime = 50 -- After how many characters should we save a swap file?
vim.opt.visualbell = true -- Flash the screen instead of beeping when doing something wrong.
vim.opt.wildignorecase = true -- Case insensitive file tab completion with :e.
vim.opt.wildmode = {"list", "longest"} -- 1st Tab completes to longest common string, 2nd+ cycles through options.

vim.api.nvim_set_hl(0, 'LeapBackdrop', { fg = '#707070' }) -- Grey out leap search area.

-- }}} Vim options

-- {{{ Mappings
--
-- (see http://vim.wikia.com/wiki/Unused_keys for unused keys)
--
-- Create a mapping (noremap by default).
local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

map('c', '%%', "getcmdtype() == ':' ? expand('%:p:h').'/' : '%%'", {expr = true}) -- %%: expands to dirname of current file.
map('i', '<A-CR>', 'coc#_select_confirm()', {expr = true, silent = true}) -- Alt-Enter: accept first result.
map('i', '<C-u>', '<C-g>u<C-u>') -- Make <C-u> undo-friendly
map('i', '<C-w>', '<C-g>u<C-w>') -- Make <C-w> undo-friendly
map('i', '<CR>', [[coc#pum#visible() ? coc#_select_confirm() : "\<CR>"]], {expr = true}) -- If in completion, select current, else normal enter (with coc hook).
map('i', '<S-Tab>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], {expr = true}) -- Shift-Tab is previous entry if completion menu open.
map('i', '<Tab>', 'v:lua.Smart_Tab()', {expr = true, silent = true}) -- If in completion, next entry, else if previous character was a space indent, else trigger completion manually.
map('n', "<Leader>Z", [[&foldlevel ? 'zM' :'zR']], {expr = true}) -- Toggle folding everywhere (see also "zi).
map('n', '-', '<Cmd>e %:h<CR>') -- Use - to open the current buffer directory in the file browser (repeat for `cd ..`).
map('n', '<A-C>', '<Plug>(coc-diagnostic-prev)', {noremap = false}) -- Prev changed Coc diagnostic.
map('n', '<A-E>', '100<C-w>k') -- Switch to the top window,
map('n', '<A-G>', '<Plug>(GitGutterPrevHunk)', {noremap = false}) -- Prev changed git hunk.
map('n', '<A-H>', '100<C-w>h') -- Switch to the leftmost window,
map('n', '<A-I>', '100<C-w>l') -- Switch to the rightmost window.
map('n', '<A-L>', '<Cmd>lprev<CR>') -- Prev item in the location list.
map('n', '<A-N>', '100<C-w>j') -- Switch to the bottom window,
map('n', '<A-Q>', '<Cmd>cprev<CR>') -- Prev item in the quickfix list.
map('n', '<A-S>', '[s') -- Prev spelling mistake.
map('n', '<A-Space>', 'v<Plug>(coc-codeaction-selected)<Esc>', {noremap = false}) -- Run available LSP actions (neoclide/coc.nvim#1981).
map('n', '<A-Enter>', '<plug>(coc-codelens-action)', {noremap = false}) -- Run available CodeLens actions (e.g. run tests).
map('n', '<A-T>', '<Cmd>tabprev<CR>') -- Prev tab.
map('n', '<A-TAB>', '<Plug>(coc-range-select)', {silent = true, noremap = false}) -- Visually select increasingly large ranges (requires LS 'textDocument/selectionRange').
map('n', '<A-c>', '<Plug>(coc-diagnostic-next)', {noremap = false}) -- Next changed Coc message (e.g. compile error).
map('n', '<A-d>', '<Cmd>tabclose<CR>') -- Close current tab.
map('n', '<A-e>', '<C-w>k') -- Switch up a window,
map('n', '<A-g>', '<Plug>(GitGutterNextHunk)', {noremap = false}) -- Next changed git hunk.
map('n', '<A-h>', '<C-w>h') -- Switch left a window,
map('n', '<A-i>', '<C-w>l') -- Switch right a window.
map('n', '<A-l>', '<Cmd>lnext<CR>') -- Next item in the location list.
map('n', '<A-n>', '<C-w>j') -- Switch down a window,
map('n', '<A-q>', '<Cmd>cnext<CR>') -- Next item in the quickfix list.
map('n', '<A-s>', ']s') -- Next spelling mistake.
map('n', '<A-t>', '<Cmd>tabnext<CR>') -- Next tab.
map('n', '<A-x>', '<Cmd>Bdelete<CR>') -- Close current buffer.
map('n', '<A-z>', '<Cmd>Zi<CR>') -- Switch to different directory.
map('n', '<C-p>', '<C-i>') -- <C-o> = go to previous jump, <C-p> is go to next (normally <C-i>, but that == Tab, used above).
map('n', '<Leader>+', '<Cmd>exe "resize ".(winheight(0) * 3/2)<CR>', {silent = true}) -- Increase window height to 3/2.
map('n', '<Leader>-', '<Cmd>exe "resize ".(winheight(0) * 2/3)<CR>', {silent = true}) -- Reduce window height to 3/2.
map('n', '<Leader>/', '<Cmd>noh<CR>') -- Turn off find highlighting.
map('n', '<Leader>1', '<Plug>BufTabLine.Go(1)', {noremap = false}) -- <Leader>1 goes to buffer 1 (see numbers in tab bar).
map('n', '<Leader>2', '<Plug>BufTabLine.Go(2)', {noremap = false}) -- <Leader>1 goes to buffer 2 (see numbers in tab bar).
map('n', '<Leader>3', '<Plug>BufTabLine.Go(3)', {noremap = false}) -- <Leader>1 goes to buffer 3 (see numbers in tab bar).
map('n', '<Leader>4', '<Plug>BufTabLine.Go(4)', {noremap = false}) -- <Leader>1 goes to buffer 4 (see numbers in tab bar).
map('n', '<Leader>5', '<Plug>BufTabLine.Go(5)', {noremap = false}) -- <Leader>1 goes to buffer 5 (see numbers in tab bar).
map('n', '<Leader>6', '<Plug>BufTabLine.Go(6)', {noremap = false}) -- <Leader>1 goes to buffer 6 (see numbers in tab bar).
map('n', '<Leader>7', '<Plug>BufTabLine.Go(7)', {noremap = false}) -- <Leader>1 goes to buffer 7 (see numbers in tab bar).
map('n', '<Leader>8', '<Plug>BufTabLine.Go(8)', {noremap = false}) -- <Leader>1 goes to buffer 8 (see numbers in tab bar).
map('n', '<Leader>9', '<Plug>BufTabLine.Go(-1)', {noremap = false}) -- <Leader>1 goes to buffer 9 (last buffer (see numbers in tab bar).
map('n', '<Leader>;', '@:') -- Repeat the last executed command.
map('n', '<Leader><', '<Cmd>exe "vertical resize ".(winwidth(0) * 2/3)<CR>', {silent = true}) -- Decrease window width to 2/3.
map('n', '<Leader>>', '<Cmd>exe "vertical resize ".(winwidth(0) * 3/2)<CR>', {silent = true}) -- Increase window width to 3/2.
map('n', '<Leader>D', '<Cmd>%d<CR>') -- Delete all text in buffer.
map('n', '<Leader>E', '<C-W>z:cclose<CR>:lclose<CR>:helpclose<CR><Plug>(coc-float-hide)') -- Close open preview windows (e.g. language server definitions).
map('n', '<Leader>F', ':grep ') -- Search file contents for file.
map('n', '<Leader>P', '"+P') -- Paste from system clipboard before cursor.
map('n', '<Leader>R', ':/ce <bar> up<Home>cfdo %s/') -- Replace in all quickfix files (use after gr).
map('n', '<Leader>S', ':<C-u>set operatorfunc=SortLinesOpFunc<CR>g@') -- Sort lines in <motion>.
map('n', '<Leader>T', '<Cmd>term<CR>') -- Open terminal in current split.
map('n', '<Leader>W', '<Cmd>w<CR>') -- Write whether or not there were changes.
map('n', '<Leader>X', '<Cmd>xa<CR>') -- Quit all windows.
map('n', '<Leader>Y', '<Cmd>%y+<CR>') -- Copy file to clipboard (normal mode).
map('n', '<Leader>a', '@a') -- Apply macro a (add with qa or yank to a reg with "ay).
map('n', '<Leader>b', '<Cmd>Buffers<CR>') -- Search buffer list for file.
map('n', '<Leader>cD', ':call DupBuffer()<CR><Plug>(coc-definition)', {silent = true, noremap = false}) -- Go to definition in other slit.
map('n', '<Leader>ce', ':<C-u>CocList diagnostics<cr>', {silent = true}) -- Show all diagnostics (<C-a><C-q> to open all in quickfix).
map('n', '<Leader>cE', ':<C-u>CocList extensions<cr>', {silent = true}) -- Manage extensions
map('n', '<Leader>cc', '<Cmd>CocList commands<CR>', {silent = true}) -- Show commands
map('n', '<Leader>cd', '<Plug>(coc-definition)', {silent = true, noremap = false}) -- Go to definition.
map('n', '<Leader>cf', '<Plug>(coc-format)', {noremap = false}) -- Format current buffer.
map('n', '<Leader>ci', '<Plug>(coc-implementation)', {silent = true, noremap = false}) -- Go to implementation.
map('n', '<Leader>co', '<Cmd>CocList outline<CR>', {silent = true}) -- Find symbol of current document
map('n', '<Leader>cp', '<Cmd>CocListResume<CR>', {silent = true}) -- Resume latest coc list
map('n', '<Leader>cr', '<Plug>(coc-rename)', {noremap = false}) -- Remap for rename current word
map('n', '<Leader>cR', '<Plug>(coc-refactor)', {noremap = false}) -- Remap for refactoring current selection.
map('n', '<Leader>cs', '<Cmd>CocList -I symbols<CR>', {silent = true}) -- Search workspace symbols
map('n', '<Leader>cu', '<Plug>(coc-references)', {silent = true, noremap = false}) -- Go to usages.
map('n', '<Leader>cy', '<Plug>(coc-type-definition)', {silent = true, noremap = false}) -- Go to type definition.
map('n', '<Leader>d', '<Cmd>Bdelete<CR>') -- Close buffer without closing split,
map('n', '<Leader>e', '<C-w>q') -- Close current split (keeps buffer).
map('n', '<Leader>f', '<Cmd>Files<CR>') -- Search file names for file,
map('n', '<Leader>gC', '<Cmd>e ~/.config/nvim/coc-settings.json<CR>') -- Edit colorscheme file.
map('n', '<Leader>gG', '<Cmd>Gcd<CR>') -- Cd to root of git directory current file is in.
map('n', '<Leader>gQ', '<Cmd>set fo+=t<CR><Cmd>set fo?<CR>') -- Turn on auto-inserting newlines when you go over the textwidth.
map('n', '<Leader>ga', '<Cmd>AnyJumpLastResults<CR>') -- open last closed search window again
map('n', '<Leader>gb', '<Cmd>AnyJumpBack<CR>') -- open previous opened file (after jump)
map('n', '<Leader>gc', '<Cmd>cd %:p:h<CR>') -- Change vim directory (:pwd) to current file's dirname (e.g. for <space>f, :e).
map('n', '<Leader>gd', '<Cmd>w !git diff --no-index % - <CR>') -- Diff between saved file and current.
map('n', '<Leader>gf', '<Cmd>call DupBuffer()<CR>gF') -- Open file path:row:col under cursor in last window.
map('n', '<Leader>gg', '<Cmd>tab Git<CR>') -- Open fugitive Gstatus in a new tab.
map('n', '<Leader>gn', '<Cmd>set number!<CR>') -- Toggle line numbers.
map('n', '<Leader>gp', '`[v`]') -- Visual selection of the last thing you copied or pasted.
map('n', '<Leader>gq', '<Cmd>set fo-=t<CR><Cmd>set fo?<CR>') -- Turn off auto-inserting newlines when you go over the textwidth.
map('n', '<Leader>gt', '<Cmd>set et!<CR>:set et?<CR>') -- Toggle tabs/spaces.
map('n', '<Leader>gv', '<Cmd>e $MYVIMRC<CR>') -- <Space>gv opens vimrc in the editor (autoreloaded on save).
map('n', '<Leader>gw', '<Cmd>setlocal wrap!<CR>') -- <Space>gw toggles the soft-wrapping of text (whether text runs off the screen).
map('n', '<Leader>gx', '<Cmd>grep -F "XXX(gib)"<CR>') -- <Space>gx searches for XXX comments.
map('n', '<Leader>ht', 'ITODO(gib): <ESC>:Commentary<CR>$') -- Insert a TODO, (Write todo, then `<Space>ht`).
map('n', '<Leader>hx', 'IXXX(gib): <ESC>:Commentary<CR>$') -- Insert an XXX, (Write todo, then `<Space>hx`).
map('n', '<Leader>i', '<Cmd>vsp<CR><C-w>h:bp<CR>') -- Open vertical split.
map('n', '<Leader>j', '<Cmd>AnyJump<CR>') -- Jump to definition under cursore
map('n', '<Leader>l', ':Locate ') -- Search filesystem for files.
map('n', '<Leader>n', '<Cmd>sp<CR><C-w>k:bp<CR>') -- Open horizontal split,
map('n', '<Leader>o', '<Plug>(coc-openlink)', {noremap = false}) -- Open the selected text with the appropriate program (like netrw-gx).
map('n', '<Leader>p', '"+p') -- Paste from clipboard after cursor.
map('n', '<Leader>q', '<Cmd>qa<CR>') -- Quit if no unsaved changes (for single file use <Space>d instead).
map('n', '<Leader>r', ':%s/') -- Replace in current doc.
map('n', '<Leader>t', '<Cmd>vsplit term://$SHELL<CR>i') -- Open terminal in new split.
map('n', '<Leader>u', '<Cmd>MundoToggle<CR>') -- Toggle Undo tree visualisation.
map('n', '<Leader>w', '<Cmd>up<CR>') -- Write if there were changes.
map('n', '<Leader>x', '<Cmd>x<CR>') -- Save (if changes) and quit.
map('n', '<Leader>y', '"+y') -- Copy to clipboard (normal mode).
map('n', '<Leader>z', 'za') -- Toggle folding on current line.
map('n', '<S-Tab>', '<Cmd>bp<CR>') -- Shift-Tab to switch to previous buffer.
map('n', '<Tab>', '<Cmd>bn<CR>') -- Tab to switch to next buffer,
map('n', 'K', '<CMD>lua Show_Documentation()<CR>') -- Use K for show documentation in preview window
map('n', 'N', '(v:searchforward) ? "N" : "n"', {expr = true}) -- N is always "next one up" even if you hit #
map('n', 'Q', '<nop>') -- Q unused (disabled to avoid accidental triggering).
map('n', 'gr', '<Plug>(operator-ripgrep-root)', {noremap = false}) -- Ripgrep search for operator.
map('n', 'n', '(v:searchforward) ? "n" : "N"', {expr = true}) -- n is always "next one down" even if you hit #
map('o', 'S', "'<esc>'.SurroundOp('S')", {expr = true, noremap = false}) --
map('o', 'af', '<Plug>(coc-funcobj-a)', {noremap = false}) -- select around function (requires 'textDocument.documentSymbol')
map('o', 'if', '<Plug>(coc-funcobj-i)', {noremap = false}) -- select in function (requires 'textDocument.documentSymbol')
map('o', 's', "'<esc>'.SurroundOp('s')", {expr = true, noremap = false}) --
map('t', '<A-e>', [[<C-\><C-n><C-w>k]]) -- Switch up a window in terminal,
map('t', '<A-h>', [[<C-\><C-n><C-w>h]]) -- Switch left a window in terminal,
map('t', '<A-i>', [[<C-\><C-n><C-w>l]]) -- Switch right a window in terminal.
map('t', '<A-n>', [[<C-\><C-n><C-w>j]]) -- Switch down a window in terminal,
map('t', '<Esc>', [[<C-\><C-n>]]) -- Go to normal mode.
map('v', '//', [[y/\V<C-r>=escape(@",'/\')<CR><CR>]]) -- Search for selected text with // (very no-magic mode, searches for exactly what you select).
map('v', '<A-Space>', '<Plug>(coc-codeaction-selected)', {noremap = false}) -- Run available LSP actions (https://github.com/neoclide/coc.nvim/issues/1981).
map('v', '<C-n>', '<Plug>(coc-snippets-select)', {noremap = false}) -- Select text for visual placeholder of snippet.
map('v', '<Leader>cf', '<Plug>(coc-format-selected)', {noremap = false}) -- Format selected region
map('v', '<Leader>d', '"+d') -- Cut from clipboard (visual mode).
map('v', '<Leader>gs', ':<C-u>call SumVis()<CR>') -- Sum selected numbers.
map('v', '<Leader>p', '"+p') -- Paste from clipboard (visual mode).
map('v', '<Leader>y', '"+y') -- Copy from clipboard (visual mode).
map('v', 'g//', [[y/\V<C-R>=&ic?'\c':'\C'<CR><C-r>=escape(@",'/\')<CR><CR>]]) -- Search for selected text case-insensitively.
map('v', 'gr', '<Plug>(operator-ripgrep-root)', {noremap = false}) -- Ripgrep search for selection.
map('x', 'af', '<Plug>(coc-funcobj-a)', {noremap = false}) -- select around function (requires 'textDocument.documentSymbol')
map('x', 'if', '<Plug>(coc-funcobj-i)', {noremap = false}) -- select in function (requires 'textDocument.documentSymbol')

-- }}} Mappings

-- {{{ Functions

-- Replace termcodes in input string (e.g. converts '<C-a>' -> '').
local function t(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

-- Check whether an array (first arg) contains a value (second arg).
local function array_contains(array, value)
  for _, v in ipairs(array) do if v == value then return true end end
  return false
end

-- Used in Tab mapping above. If the popup menu is visible, switch to next item in that. Else prints a tab if previous
-- char was empty or whitespace. Else triggers completion.
function Smart_Tab()
  local check_back_space = function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return (col == 0 or vim.api.nvim_get_current_line():sub(col, col):match('%s')) and true
  end

  if (vim.fn['coc#pum#visible']() ~= 0) then
    return vim.fn['coc#pum#next'](1)
  elseif (check_back_space()) then
    return t('<Tab>')
  end
  return vim.fn['coc#refresh']()
end

-- Used in K mapping above.
-- Copied from coc.nvim README, ported to lua, opens vim help or language server help.
-- https://stackoverflow.com/questions/59440719/vime523-not-allowed-here
function Show_Documentation()
  if (array_contains({'vim', 'help'}, vim.bo.filetype) or vim.fn.expand('%:p') == vim.fn.stdpath('config') .. 'init.lua') then
    vim.cmd('help ' .. vim.fn.expand('<cword>'))
  elseif (vim.fn['coc#rpc#ready']()) then
    vim.fn.CocActionAsync('doHover')
  else
    vim.cmd(vim.o.keywordprg .. " " .. vim.fn.expand('<cword>'))
  end
end
-- }}} Functions

-- {{{ Package Manager Setup
-- variable that is only set if we're bootstrapping (Packer hasn't been installed).
local packer_bootstrap

local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  packer_bootstrap = vim.fn.system({
    'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path
  })
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use "fladson/vim-kitty" -- Syntax highlighting for kitty.conf file.
  use 'AndrewRadev/splitjoin.vim' -- gS to split, gJ to join lines.
  use 'airblade/vim-gitgutter' -- Show git diffs in the gutter (left of line numbers) (:h gitgutter).
  use 'ap/vim-buftabline' -- Show buffers in the tab bar.
  use 'ap/vim-readdir' -- Nicer file browser plugin that works with buftabline.
  use 'aymericbeaumet/vim-symlink' -- Resolve symlinks when opening files.
  use 'cespare/vim-toml' -- Toml syntax highlighting.
  use 'chrisbra/Colorizer' -- Color ansi escape codes (:h Colorizer).
  use 'chrisbra/Recover.vim' -- add a diff option when a swap file is found.
  use 'coderifous/textobj-word-column.vim' -- Adds ic/ac and iC/aC motions to block select word column in paragraph.
  use 'fweep/vim-zsh-path-completion' -- Nicer file browser plugin.
  use 'ggandor/leap.nvim' -- Quickest way to jump to any char on the screen (alternative to easymotion/sneak/hop/lightspeed/pounce).
  use 'gibfahn/vim-gib' -- Use vim colorscheme.
  use 'godlygeek/tabular' -- Make tables easier (:help Tabular).
  use 'honza/vim-snippets' -- Work around https://github.com/neoclide/coc-snippets/issues/126 .
  use 'itchyny/lightline.vim' -- Customize statusline and tabline.
  use 'junegunn/fzf.vim' -- Try :Files, :GFiles? :Buffers :Lines :History :Commits :BCommits
  use 'junegunn/vim-peekaboo' -- Pop up register list when pasting/macroing.
  use 'kana/vim-operator-user' -- Make it easier to define operators.
  use 'kana/vim-textobj-line' -- Adds `il` and `al` text objects for current line.
  use 'kana/vim-textobj-user' -- Allows you to create custom text objects (used in vim-textobj-line).
  use 'moll/vim-bbye' -- Delete buffer without closing split.
  use 'mzlogin/vim-markdown-toc' -- Markdown Table of Contents.
  use 'nanotee/zoxide.vim' -- Use zoxide to quickly jump to directories.
  use 'pechorin/any-jump.nvim' -- Go to definition that doesn't require a language server.
  use 'puremourning/vimspector' -- Multi-language debugger using the VSCode Debug Adapter Protocol.
  use 'rust-lang/rust.vim' -- Rust language bindings.
  use 'sedm0784/vim-resize-mode' -- Continuous resizing.
  use 'simnalamburt/vim-mundo' -- Graphical undo tree (updated fork of Gundo).
  use 'tpope/vim-abolish' -- Work with variants of words (replacing, capitalizing etc).
  use 'tpope/vim-commentary' -- Autodetect comment type for lang.
  use 'tpope/vim-fugitive' -- Git commands in vim.
  use 'tpope/vim-repeat' -- Allows you to use . with plugin mappings.
  use 'tpope/vim-rhubarb' -- GitHub support.
  use 'tpope/vim-rsi' -- Insert/commandline readline-style mappings, e.g. C-a for beginning of line.
  use 'tpope/vim-surround' -- Add/mod/remove surrounding chars.
  use 'tpope/vim-unimpaired' -- [ and ] mappings (help unimpaired).
  use {'editorconfig/editorconfig-vim', after = 'vim-sleuth'} -- Parse .editorconfig files (https://editorconfig.org/).
  use {'neoclide/coc.nvim', branch = 'release'} -- Language Server with VSCode Extensions.
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'} -- Treesitter syntax highlighting.
  use {'sheerun/vim-polyglot', config = 'vim.opt.shortmess:remove("A")'} -- Syntax files for a large number of different languages + workaround for https://github.com/sheerun/vim-polyglot/issues/765.
  use {'subnut/nvim-ghost.nvim', run = ':call nvim_ghost#installer#install()'} -- Edit browser text areas in Neovim (:h ghost).
  use {'tpope/vim-sleuth', after = 'vim-polyglot'} -- Automatically detect indentation.
  use {'~/.local/share/fzf', as = 'fzf', run = './install --bin'} -- :h fzf

end)

pcall(require, "wrk-init-nvim") -- Load work config if present.

vim.cmd 'command! PU PackerSync' -- :PU updates Packer plugin configuration.

if packer_bootstrap then
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  require('packer').sync()

  -- If we just bootstrapped the package manager, our packages won't be available, so skip their setup.
  vim.cmd([[
      augroup packer_bootstrap_config
        autocmd!
        autocmd User PackerComplete exec 'source '. stdpath('config') . '/init.lua'
      augroup end
    ]])
  return
end

-- }}} Package Manager Setup

-- {{{ Package Setup

vim.cmd 'colorscheme gib'

-- Set up Treesitter languages.
require'nvim-treesitter.configs'.setup {ensure_installed = "all",
  -- List of parsers to ignore installing (for "all")
  ignore_install = {
    -- Broken on Apple silicon: https://github.com/claytonrcarter/tree-sitter-phpdoc/issues/15
    "phpdoc"
  },
  highlight = {enable = true}, indent = {enable = true}
}

-- https://github.com/ggandor/leap.nvim
--   s|S char1 (char2|shortcut)? (<tab>|<s-tab>)* label?
-- (in Operator-pending mode the search is invoked with z/Z not s/S)
-- `:h leap` for more info.
require('leap').set_default_keymaps()

-- }}} Package Setup

-- {{{ Package Autocommands
vim.cmd([[
  augroup packer_user_config
    autocmd!
    " Update my colorscheme when I edit it.
    autocmd BufWritePost gib.vim source <afile>

    " Highlight symbol under cursor on CursorHold (show other instances of current word).
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Update signature help on jump placeholder (show function signature when you jump to it).
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end
]])
-- }}} Package Autocommands

vim.cmd("source " .. vim.fn.stdpath('config') .. '/init-old.vim')

-- vim: foldmethod=marker
