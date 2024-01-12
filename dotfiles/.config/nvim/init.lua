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

local home_dir = os.getenv("HOME")

if vim.fn.executable("nvr") then
  -- Use existing nvim window to open new files (e.g. `g cm`).
  vim.env.VISUAL = 'nvr --remote-wait'
end

vim.g.any_jump_disable_default_keybindings = 1                   -- Conflicts with other useful bindings.
vim.g.buftabline_indicators = 1                                  -- Show a + if the buffer has been modified.
vim.g.buftabline_numbers = 2                                     -- Show buftabline's count (use <Leader>1-9 to switch.
vim.g.coc_snippet_next = '<a-u>'                                 -- Use <Alt-u> for jump to next placeholder.
vim.g.coc_snippet_prev = '<a-l>'                                 -- Use <Alt-l> for jump to previous placeholder.
vim.g.colorizer_use_virtual_text = 1                             -- Use virtual text
vim.g.fzf_history_dir = vim.env.XDG_CACHE_HOME .. '/fzf-history' -- Save history of fzf vim commands.
vim.g.is_posix = 1                                               -- Assume shell for syntax highlighting.
vim.g.loaded_netrw = 1                                           -- Skip loading netrw file browser (use vim-readdir instead).
vim.g.loaded_netrwPlugin = 1                                     -- Don't use the built-in file browser (use vim-readdir instead).
vim.g.mapleader = ' '                                            -- use space as a the leader key
vim.g.mundo_preview_bottom = 1                                   -- Undo diff preview on bottom.
vim.g.mundo_right = 1                                            -- Undo window on right.
vim.g.peekaboo_window = "vert bo 50new"                          -- Increase peekaboo window width to 50.
vim.g.terminal_scrollback_buffer_size = 100000                   -- Store lots of terminal history (neovim-only).

-- Extensions (plugins) for CoC language client.
vim.g.coc_global_extensions = { 'coc-actions', 'coc-ccls', 'coc-clangd', 'coc-css', 'coc-diagnostic',
  'coc-dictionary',
  'coc-eslint', 'coc-go', 'coc-groovy', 'coc-highlight', 'coc-html', 'coc-java', 'coc-json',
  'coc-lua',
  'coc-prettier', 'coc-markdownlint', 'coc-python', 'coc-rust-analyzer', 'coc-snippets',
  'coc-solargraph',
  'coc-sourcekit', 'coc-svg', 'coc-syntax', 'coc-tabnine', 'coc-tsserver', 'coc-vetur', 'coc-word',
  'coc-yaml'
}

-- }}} Global variables

-- {{{ Vim options

vim.cmd 'colorscheme habamax' -- Default colorscheme in case plugins don't load.

vim.opt.breakindent = true -- Nicer line wrapping for long lines.
vim.opt.completeopt = "menu,menuone,noselect" -- Nicer completion behaviour.
-- vim.opt.conceallevel = 3 -- In markdown, hide markup (* for bold/italic, ` for code, [] for links)
vim.opt.confirm = true -- Ask if you want to save unsaved files instead of failing.
vim.opt.diffopt:append("vertical") -- Always use vertical diffs.
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.fileformats = "unix" -- Force Unix line endings (\n) (always show \r (^M), never autoinsert them).
vim.opt.foldlevel = 99 -- expand all by default.
vim.opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"
vim.opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()" -- Format with conform/LSP
vim.opt.formatoptions = "jcroqlnt" -- Sets line wrapping/formatting options.
vim.opt.gdefault = true -- Global replace default (off: /g).
vim.opt.grepformat = '%f:%l:%c:%m,%f:%l:%m' -- Teach vim how to parse the ripgrep output.
vim.opt.grepprg = 'rg -S --vimgrep --no-heading --hidden --glob !.git' -- Use ripgrep for file searching.
vim.opt.hidden = true -- Enable background buffers
vim.opt.history = 1000 -- More command/search history.
vim.opt.ignorecase = true -- Ignore case for lowercase searches (re-enable with \C in pattern),
vim.opt.inccommand = "split" -- Show search and replace in a split as you type.
vim.opt.joinspaces = false -- No double spaces with join
vim.opt.list = true -- Show some invisible characters (see listchars).
vim.opt.listchars = { tab = "»·", trail = "·", nbsp = "☠" } -- Display extra whitespace.
vim.opt.mouse = "a" -- Mouse in all modes (mac: Fn+drag = copy).
vim.opt.number = false -- Don't show line numbers by default.
vim.opt.shiftround = true -- Round indent to multiple of 'shiftwidth'. Applies to > and < commands.
vim.opt.shiftwidth = 2 -- Size of an indent
vim.opt.showbreak = "↳   " -- Nicer line wrapping for long lines.
vim.opt.showmode = false -- Don't show when in insert mode (set in lualine).
vim.opt.shortmess:append({ I = true, c = true, C = true }) -- Avoid some "hit-enter" prompts
vim.opt.sidescrolloff = 8 -- Keep 8 columns of context either side (horizontally) of the cursor.
vim.opt.signcolumn = "auto" -- Resize the sign column automatically.
vim.opt.smartcase = true -- Do not ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.softtabstop = 2 -- Number of spaces tabs count for
vim.opt.spelllang = { "en" } -- Default to English for spellchecker.
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitkeep = "screen" -- When opening/closing/resizing splits, keep text in same place on screen.
vim.opt.splitright = true -- Put new windows right of current
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.termguicolors = true -- True color support
vim.opt.undofile = true -- Persistent undo file saved between file edits.
vim.opt.undolevels = 10000 -- Keep 10,000 changes of undo history.
vim.opt.updatetime = 50 -- Delay after which to write to swap file and run CursorHold event.
vim.opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
vim.opt.visualbell = true -- Flash the screen instead of beeping when doing something wrong.
vim.opt.wildignorecase = true -- Case insensitive file tab completion with :e.
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode, 1st tab completes longest common.

vim.opt.fillchars = {
  fold = " ", -- Don't show dots after a folded fold.
  foldsep = " ",
}

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true -- Scroll screen lines not real lines.
end

-- TODO: causes freezes on <= 0.9, so only enable on >= 0.10 for now
-- Remove once 0.10 ships (copied from lazyvim).
if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
else
  vim.opt.foldmethod = "indent"
end


-- Fix markdown indentation settings (copied from lazyvim).
vim.g.markdown_recommended_style = 0
-- {{{ Package Manager Setup
-- variable that is only set if we're bootstrapping (Packer hasn't been installed).

-- Always require the wrk.lua config if ~/wrk exists.
if vim.fn.isdirectory(home_dir .. '/wrk') ~= 0 then
  require("wrk")
end

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--origin=origin",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Disable lazyvim options setting.
package.loaded["lazyvim.config.options"] = true

require("lazy").setup({
  -- List of things to import.
  spec = {
    { "LazyVim/LazyVim",
      -- import = "lazyvim.plugins" -- We don't import anything by default.
    },
    { import = "plugins" }, -- Everything in ~/.config/nvim/lua/plugins/
  },
  install = {
    colorscheme = { "gib-noir" },
  },
  -- lazyvim defaults. For what these default to see
  -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/init.lua>
  defaults = {
    autocmds = false, -- Don't load lazyvim.config.autocmds
    keymaps = false,  -- Don't load lazyvim.config.keymaps
    -- lazyvim.config.options can't be configured here since that's loaded before lazyvim setup
    -- if you want to disable loading options, add `package.loaded["lazyvim.config.options"] = true` to the top of your init.lua
  },
  news = {
    -- When enabled, NEWS.md will be shown when changed.
    -- This only contains big new features and breaking changes.
    lazyvim = true,
    -- Same but for Neovim's news.txt
    neovim = true,
  },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})


-- }}} Package Manager Setup

-- {{{ Functions

-- Used in K mapping above.
-- Copied from coc.nvim README, ported to lua, opens vim help or language server help.
-- <https://stackoverflow.com/questions/59440719/vime523-not-allowed-here>
function Show_Documentation()
  if (vim.tbl_contains({ 'vim', 'help' }, vim.bo.filetype) or vim.fn.expand('%:p') == vim.fn.stdpath('config') .. 'init.lua') then
    vim.cmd('help ' .. vim.fn.expand('<cword>'))
  elseif (vim.fn['coc#rpc#ready']()) then
    vim.fn.CocActionAsync('doHover')
  else
    vim.cmd(vim.o.keywordprg .. " " .. vim.fn.expand('<cword>'))
  end
end

-- Used in Tab mapping above. If the popup menu is visible, switch to next item in that. Else prints a tab if previous
-- char was empty or whitespace. Else triggers completion.
function Smart_Tab()
  local check_back_space = function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return (col == 0 or vim.api.nvim_get_current_line():sub(col, col):match('%s')) and true
  end

  -- Replace termcodes in input string (e.g. converts '<C-a>' -> '').
  local function t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  if (vim.fn['coc#pum#visible']() ~= 0) then
    return vim.fn['coc#pum#next'](1)
  elseif (check_back_space()) then
    return t('<Tab>')
  end
  return vim.fn['coc#refresh']()
end

-- }}} Functions

-- {{{ Mappings
--
-- (see http://vim.wikia.com/wiki/Unused_keys for unused keys)

vim.keymap.set('c', '<A-/>', "<C-R>=expand('%:p:h') . '/'<CR>", { desc = "Insert dirname of current file" })
vim.keymap.set('i', ',', ',<c-g>u', { desc = "Set undo breakpoint on ," })
vim.keymap.set('i', '.', '.<c-g>u', { desc = "Set undo breakpoint on ." })
vim.keymap.set('i', ';', ';<c-g>u', { desc = "Set undo breakpoint on ;" })
vim.keymap.set('i', '<A-CR>', 'coc#_select_confirm()', { expr = true, silent = true, desc = "accept first result" })
vim.keymap.set('i', '<A-t>', ' <C-r><C-r>=&commentstring<CR><C-o>:s/%s/TODO(gib): /<CR><C-o>A',
  { silent = true, desc = "insert TODO comment" })
vim.keymap.set('i', '<A-x>', ' <C-r><C-r>=&commentstring<CR><C-o>:s/%s/XXX(gib): /<CR><C-o>A',
  { silent = true, desc = "insert XXX comment (ignore-xxx)" })
vim.keymap.set('i', '<C-u>', '<C-g>u<C-u>', { desc = "<C-u> but undo-friendly" })
vim.keymap.set('i', '<C-w>', '<C-g>u<C-w>', { desc = "<C-w> but undo-friendly" })
vim.keymap.set('i', '<CR>', [[coc#pum#visible() ? coc#pum#confirm() : "\<CR>"]],
  { expr = true, desc = "If in completion, select current, else normal <Enter> (with coc hook)" })
vim.keymap.set('i', '<S-Tab>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]],
  { expr = true, desc = "Previous entry if completion menu open" })
vim.keymap.set('i', '<Tab>', Smart_Tab,
  { expr = true, desc =
  "If in completion, next entry, else if previous character was a space indent, else trigger completion manually" })
vim.keymap.set('n', '-', '<Cmd>e %:h<CR>', { desc = "Open buffer dirname in file browser" }) -- repeat for `cd ..`
vim.keymap.set('n', '<A-C>', '<Plug>(coc-diagnostic-prev)', { noremap = false, desc = "Prev Coc diagnostic" })
vim.keymap.set('n', '<A-Down>', '<C-e>', { desc = "Scroll down a line" })
vim.keymap.set('n', '<A-E>', "<cmd>resize -1<cr>", { desc = "Decrease window height" })
vim.keymap.set('n', '<A-Enter>', '<plug>(coc-codelens-action)',
  { noremap = false, desc = "Run available CodeLens actions (e.g. run tests)" })
vim.keymap.set('n', '<A-F>', '<Cmd>CocPrev<CR>', { noremap = false, desc = "Next Coc list (e.g. compile errors)" })
vim.keymap.set('n', '<A-G>', '<Plug>(GitGutterPrevHunk)', { noremap = false, desc = "Prev changed git hunk" })
vim.keymap.set('n', '<A-H>', "<cmd>vertical resize -1<cr>", { desc = "Decrease window width" })
vim.keymap.set('n', '<A-I>', "<cmd>vertical resize +1<cr>", { desc = "Increase window width" })
vim.keymap.set('n', '<A-L>', '<Cmd>lprev<CR>', { desc = "Go to previous location list item" })
vim.keymap.set('n', '<A-Left>', 'zh', { desc = "Scroll view left a char" })
vim.keymap.set('n', '<A-N>', "<cmd>resize +1<cr>", { desc = "Increase window height" })
vim.keymap.set('n', '<A-Q>', '<Cmd>cprev<CR>', { desc = "Go to previous Quickfix list item" })
vim.keymap.set('n', '<A-Right>', 'zl', { desc = "Scroll view right a char" })
vim.keymap.set('n', '<A-S>', '[s', { desc = "Go to previous spelling mistake" })
vim.keymap.set('n', '<A-Space>', 'v<Plug>(coc-codeaction-selected)<Esc>',
  { noremap = false, desc = "Run available LSP actions" })                                                                                        -- neoclide/coc.nvim#1981
vim.keymap.set('n', '<A-T>', '<Cmd>tabprev<CR>', { desc = "Prev tab" })
vim.keymap.set('n', '<A-TAB>', '<Plug>(coc-range-select)',
  { silent = true, noremap = false, desc = "Visually select increasingly large ranges" })                                                         -- requires LS 'textDocument/selectionRange'
vim.keymap.set('n', '<A-Up>', '<C-y>', { desc = "Scroll up a line" })
vim.keymap.set('n', '<A-c>', '<Plug>(coc-diagnostic-next)',
  { noremap = false, desc = "Next changed Coc message (e.g. compile error)" })
vim.keymap.set('n', '<A-d>', '<Cmd>tabclose<CR>', { desc = "Close tab" })
vim.keymap.set('n', '<A-e>', '<C-w>k', { desc = "Switch up a window" })
vim.keymap.set('n', '<A-f>', '<Cmd>CocNext<CR>', { noremap = false, desc = "Next Coc list" }) -- e.g. compile error if you hit <Leader>ce
vim.keymap.set('n', '<A-g>', '<Plug>(GitGutterNextHunk)', { noremap = false, desc = "Next changed git hunk" })
vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = "Switch left a window," })
vim.keymap.set('n', '<A-i>', '<C-w>l', { desc = "Switch right a window" })
vim.keymap.set('n', '<A-l>', '<Cmd>lnext<CR>', { desc = "Go to next location list item" })
vim.keymap.set('n', '<A-n>', '<C-w>j', { desc = "Switch down a window," })
vim.keymap.set('n', '<A-q>', '<Cmd>cnext<CR>', { desc = "Go to next quickfix item" })
vim.keymap.set('n', '<A-s>', ']s', { desc = "Go to next spelling mistake" })
vim.keymap.set('n', '<A-t>', '<Cmd>tabnext<CR>', { desc = "Go to next tab" })
vim.keymap.set('n', '<A-x>', '<Cmd>Bdelete<CR>', { desc = "Close current buffer" })
vim.keymap.set('n', '<A-z>', '<Cmd>Zi<CR>', { desc = "Switch to different directory" })
vim.keymap.set('n', '<C-p>', '<C-i>', { desc = "Go to next jump" }) -- <C-o> = go to previous jump, <C-p> is go to next (normally <C-i>, but that == Tab, used above)
vim.keymap.set('n', '<Leader>+', '<Cmd>exe "resize ".(winheight(0) * 3/2)<CR>',
  { silent = true, desc = "Increase window height to 3/2" })
vim.keymap.set('n', '<Leader>-', '<Cmd>exe "resize ".(winheight(0) * 2/3)<CR>',
  { silent = true, desc = "Reduce window height to 2/3" })
vim.keymap.set('n', '<Leader>/', '<Cmd>noh<CR>', { desc = "Turn off search highlight" })
vim.keymap.set('n', '<Leader>1', '<Plug>BufTabLine.Go(1)', { noremap = false, desc = "Go to buffer 1" })
vim.keymap.set('n', '<Leader>2', '<Plug>BufTabLine.Go(2)', { noremap = false, desc = "Go to buffer 2" })
vim.keymap.set('n', '<Leader>3', '<Plug>BufTabLine.Go(3)', { noremap = false, desc = "Go to buffer 3" })
vim.keymap.set('n', '<Leader>4', '<Plug>BufTabLine.Go(4)', { noremap = false, desc = "Go to buffer 4" })
vim.keymap.set('n', '<Leader>5', '<Plug>BufTabLine.Go(5)', { noremap = false, desc = "Go to buffer 5" })
vim.keymap.set('n', '<Leader>6', '<Plug>BufTabLine.Go(6)', { noremap = false, desc = "Go to buffer 6" })
vim.keymap.set('n', '<Leader>7', '<Plug>BufTabLine.Go(7)', { noremap = false, desc = "Go to buffer 7" })
vim.keymap.set('n', '<Leader>8', '<Plug>BufTabLine.Go(8)', { noremap = false, desc = "Go to buffer 8" })
vim.keymap.set('n', '<Leader>9', '<Plug>BufTabLine.Go(-1)', { noremap = false, desc = "Go to last buffer" })
vim.keymap.set('n', '<Leader>;', '@:', { desc = "Repeat last :command" })
vim.keymap.set('n', '<Leader><', '<Cmd>exe "vertical resize ".(winwidth(0) * 2/3)<CR>',
  { silent = true, desc = "Decrease window width to 2/3" })
vim.keymap.set('n', '<Leader>>', '<Cmd>exe "vertical resize ".(winwidth(0) * 3/2)<CR>',
  { silent = true, desc = "Increase window width to 3/2" })
vim.keymap.set('n', '<Leader>D', '<Cmd>%d<CR>', { desc = "Delete all text in buffer" })
vim.keymap.set('n', '<Leader>E', '<C-W>z:cclose<CR>:lclose<CR>:helpclose<CR><Plug>(coc-float-hide)',
  { desc = "Close preview windows" })                                                                                                  -- e.g. language server definitions
vim.keymap.set('n', '<Leader>F', ':grep ', { desc = "Search file contents for file" })
vim.keymap.set('n', '<Leader>P', '"+P', { desc = "Paste from system clipboard before cursor" })
vim.keymap.set('n', '<Leader>R', ':/ce <bar> up<Home>cfdo %s/', { desc = "Replace in all quickfix files" }) -- use after gr
vim.keymap.set('n', '<Leader>S', ':<C-u>set operatorfunc=SortLinesOpFunc<CR>g@', { desc = "Sort lines in <motion>" })
vim.keymap.set('n', '<Leader>T', '<Cmd>term<CR>', { desc = "Open terminal in current split" })
vim.keymap.set('n', '<Leader>W', '<Cmd>w<CR>', { desc = "Force write" }) -- whether or not there were changes
vim.keymap.set('n', '<Leader>X', '<Cmd>xa<CR>', { desc = "Write all & exit" })
vim.keymap.set('n', '<Leader>Y', '<Cmd>%y+<CR>', { desc = "Copy file to clipboard" })
vim.keymap.set('n', '<Leader>Z', [[&foldlevel ? 'zM' :'zR']], { expr = true, desc = 'Toggle folding everywhere' }) -- see also "zi
vim.keymap.set('n', '<Leader>a', '@a', { desc = 'Apply macro a' })                                                -- add with qa or yank to a reg with "ay
vim.keymap.set('n', '<Leader>b', '<Cmd>Buffers<CR>', { desc = "Search buffer list for file" })
vim.keymap.set('n', '<Leader>cD', ':call DupBuffer()<CR><Plug>(coc-definition)',
  { silent = true, noremap = false, desc = "Go to definition in other split" })
vim.keymap.set('n', '<Leader>cE', ':<C-u>CocList diagnostics<cr>',
  { silent = true, desc = "List all diagnostics in workspace" })
vim.keymap.set('n', '<Leader>cR', '<Plug>(coc-refactor)', { noremap = false, desc = "Refactor current selection" })
vim.keymap.set('n', '<Leader>cc', '<Cmd>CocList commands<CR>', { silent = true, desc = "Show Coc commands" })
vim.keymap.set('n', '<Leader>cd', '<Plug>(coc-definition)', { silent = true, noremap = false, desc = "Go to definition" })
vim.keymap.set('n', '<Leader>ce', ':<C-u>CocList --first diagnostics<cr>',
  { silent = true, desc = "Show all diagnostics" })                                                                         -- <C-a><C-q> to open all in quickfix
vim.keymap.set('n', '<Leader>cf', '<Plug>(coc-format)', { noremap = false, desc = "Format current buffer" })
vim.keymap.set('n', '<Leader>ci', '<Plug>(coc-implementation)',
  { silent = true, noremap = false, desc = "Go to implementation" })
vim.keymap.set('n', '<Leader>co', '<Cmd>CocList outline<CR>', { silent = true, desc = "Show symbols in current document" })
vim.keymap.set('n', '<Leader>cp', '<Cmd>CocListResume<CR>', { silent = true, desc = "Resume latest coc list" })
vim.keymap.set('n', '<Leader>cq', '<Cmd>cexpr getreg("+")<CR>', { desc = "Open current clipboard in the Quickfix window" })
vim.keymap.set('n', '<Leader>cr', '<Plug>(coc-rename)', { noremap = false, desc = "Rename current word" })
vim.keymap.set('n', '<Leader>cs', '<Cmd>CocList -I symbols<CR>', { silent = true, desc = "Search workspace symbols" })
vim.keymap.set('n', '<Leader>ct', '<Plug>(coc-type-definition)',
  { silent = true, noremap = false, desc = "Go to type definition" })
vim.keymap.set('n', '<Leader>cu', '<Plug>(coc-references)', { silent = true, noremap = false, desc = "Go to usages" })
vim.keymap.set('n', '<Leader>e', '<C-w>q', { desc = "Close current split" }) -- keeps buffer
vim.keymap.set('n', '<Leader>f', '<Cmd>Files<CR>', { desc = "Search file names" })
vim.keymap.set('n', '<Leader>gC', '<Cmd>CocConfig<CR>', { desc = "Edit Coc config file" })
vim.keymap.set('n', '<Leader>gG', ':Resolve<CR>|:Gcd<CR>', { desc = "Chdir to root of git directory current file is in" })
vim.keymap.set('n', '<Leader>gQ', '<Cmd>set fo+=t<CR><Cmd>set fo?<CR>', { desc = "Auto-add newline for long lines" })
vim.keymap.set('n', '<Leader>ga', '<Cmd>AnyJumpLastResults<CR>', { desc = "Open last closed coc window" })
vim.keymap.set('n', '<Leader>gb', '<Cmd>AnyJumpBack<CR>', { desc = "open previous opened file" })   -- after jump
vim.keymap.set('n', '<Leader>gc', '<Cmd>cd %:p:h<CR>', { desc = "Change to current file's dirname" }) -- e.g. for <space>f, :e
vim.keymap.set('n', '<Leader>gd', '<Cmd>w !git diff --no-index % - <CR>', { desc = "Diff between saved file and buffer" })
vim.keymap.set('n', '<Leader>gf', '<Cmd>call DupBuffer()<CR>gF',
  { desc = "Open file path:row:col under cursor in last window" })
vim.keymap.set('n', '<Leader>gg', ':Resolve<CR>|:tab Git<CR>', { desc = "Open fugitive in a new tab" })
vim.keymap.set('n', '<Leader>gn', '<Cmd>set number!<CR>', { desc = "Toggle line numbers" })
vim.keymap.set('n', '<Leader>gp', '`[v`]', { desc = "Visually select last thing you copied/pasted" })
vim.keymap.set('n', '<Leader>gq', '<Cmd>set fo-=t<CR><Cmd>set fo?<CR>', { desc = "Don't auto-add newline for long lines" })
vim.keymap.set('n', '<Leader>gt', '<Cmd>set et!<CR>:set et?<CR>', { desc = "Toggle tabs/spaces" })
vim.keymap.set('n', '<Leader>gv', '<Cmd>e $MYVIMRC<CR>', { desc = "<Space>gv opens vimrc in the editor" }) -- autoreloaded on save
vim.keymap.set('n', '<Leader>gw', '<Cmd>setlocal wrap!<CR>', { desc = "Toggle soft-wrapping of text" })  -- whether text runs off the screen
vim.keymap.set('n', '<Leader>gx', '<Cmd>grep -F "XXX(gib)"<CR>', { desc = "Search for XXX comments" })
vim.keymap.set('n', '<Leader>ht', 'ITODO(gib): <Esc>:Commentary<CR>$', { desc = "Insert a TODO" })       -- Write todo, then `<Space>ht`
vim.keymap.set('n', '<Leader>hx', 'IXXX(gib): <Esc>:Commentary<CR>$', { desc = "Insert an XXX" })        -- Write todo, then `<Space>hx`
vim.keymap.set('n', '<Leader>i', '<Cmd>vsp<CR><C-w>h:bp<CR>', { desc = "Open vertical split" })
vim.keymap.set('n', '<Leader>j', '<Cmd>AnyJump<CR>', { desc = "Jump to definition under cursor" })
vim.keymap.set('n', '<Leader>l', ':Locate ', { desc = "Search filesystem for files" })
vim.keymap.set('n', '<Leader>n', '<Cmd>sp<CR><C-w>k:bp<CR>', { desc = "Open horizontal split" })
vim.keymap.set('n', '<Leader>o', '<Plug>(coc-openlink)', { noremap = false, desc = "Open selected text" }) -- like netrw-gx
vim.keymap.set('n', '<Leader>p', '"+p', { desc = "Paste from clipboard" })
vim.keymap.set('n', '<Leader>q', '<Cmd>qa<CR>', { desc = "Quit if no unsaved changes" })                  -- for single file use <Space>d instead
vim.keymap.set('n', '<Leader>r', ':%s/', { desc = "Replace in buffer" })
vim.keymap.set('n', '<Leader>t', '<Cmd>vsplit term://$SHELL<CR>i', { desc = "Open terminal in new split" })
vim.keymap.set('n', '<Leader>u', '<Cmd>MundoToggle<CR>', { desc = "Show/hide undo tree" })
vim.keymap.set('n', '<Leader>w', '<Cmd>up<CR>', { desc = "Write if changes" })
vim.keymap.set('n', '<Leader>x', '<Cmd>x<CR>', { desc = "Save and quit" }) -- Only saves if changes.
vim.keymap.set('n', '<Leader>y', '"+y', { desc = "Copy to clipboard" })
vim.keymap.set('n', '<Leader>z', 'za', { desc = "Fold current line" })
vim.keymap.set('n', '<S-Tab>', '<Cmd>bp<CR>', { desc = "Go to previous buffer" })
vim.keymap.set('n', '<Tab>', '<Cmd>bn<CR>', { desc = "Go to next buffer" })
vim.keymap.set('n', 'K', Show_Documentation, { desc = "Show documentation" })
vim.keymap.set('n', 'N', '(v:searchforward) ? "N" : "n"', { expr = true, desc = 'Go to next match' })             -- N is always "next one up" even if you hit #
vim.keymap.set('n', 'Q', '<nop>', { desc = "unused" })                                                            -- disabled to avoid accidental triggering
vim.keymap.set('n', 'gr', '<Plug>(operator-ripgrep-root)', { noremap = false, desc = "Ripgrep search for operator" })
vim.keymap.set('n', 'n', '(v:searchforward) ? "n" : "N"', { expr = true, desc = 'Go to previous match' })         -- N is always "next one down" even if you hit #
vim.keymap.set('o', 'af', '<Plug>(coc-funcobj-a)', { noremap = false, desc = "Select around function" })          -- requires 'textDocument.documentSymbol'
vim.keymap.set('o', 'if', '<Plug>(coc-funcobj-i)', { noremap = false, desc = "Select in function" })              -- requires 'textDocument.documentSymbol'
vim.keymap.set('t', '<A-e>', [[<C-\><C-n><C-w>k]], { desc = "Switch up a window" })                               -- in terminal
vim.keymap.set('t', '<A-h>', [[<C-\><C-n><C-w>h]], { desc = "Switch left a window" })                             -- in terminal
vim.keymap.set('t', '<A-i>', [[<C-\><C-n><C-w>l]], { desc = "Switch right a window" })                            -- in terminal
vim.keymap.set('t', '<A-n>', [[<C-\><C-n><C-w>j]], { desc = "Switch down a window" })                             -- in terminal
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = "Go to normal mode" })                                      -- in terminal
vim.keymap.set('v', '//', [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], { desc = "Search for selected text" })           -- very no-magic mode, searches for exactly what you select
vim.keymap.set('v', '<A-Space>', '<Plug>(coc-codeaction-selected)', { noremap = false, desc = "Run LSP actions" }) -- https://github.com/neoclide/coc.nvim/issues/1981
vim.keymap.set('v', '<Leader>cf', '<Plug>(coc-format-selected)', { noremap = false, desc = "Format selected region" })
vim.keymap.set('v', '<Leader>d', '"+d', { desc = "Cut from clipboard (visual mode)" })
vim.keymap.set('v', '<Leader>gs', ':<C-u>call SumVis()<CR>', { desc = "Sum selected numbers" })
vim.keymap.set('v', '<Leader>p', '"+p', { desc = "Paste from clipboard" })
vim.keymap.set('v', '<Leader>y', '"+y', { desc = "Copy from clipboard" })
vim.keymap.set('v', 'g//', [[y/\V<C-R>=&ic?'\c':'\C'<CR><C-r>=escape(@",'/\')<CR><CR>]],
  { desc = "Search for selected text case-insensitively" })
vim.keymap.set('v', 'gr', '<Plug>(operator-ripgrep-root)', { noremap = false, desc = "Ripgrep search for selection" })
vim.keymap.set('x', 'P', 'p', { desc = "Paste and update clipboard" })
vim.keymap.set('x', 'af', '<Plug>(coc-funcobj-a)', { noremap = false, desc = "Select around function" }) -- requires 'textDocument.documentSymbol'
vim.keymap.set('x', 'if', '<Plug>(coc-funcobj-i)', { noremap = false, desc = "Select in function" })    -- requires 'textDocument.documentSymbol'
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<A-w>', '<cmd>w<cr><esc>', { desc = 'Save file' })
vim.keymap.set({ 'i', 'n' }, '<Esc>', '<cmd>noh<cr><Esc>', { desc = "Escape and clear hlsearch" })

-- }}} Mappings

-- {{{ User Commands

-- :PU asynchronously updates plugins.
vim.api.nvim_create_user_command(
  'PU',
  function(_)
    require("lazy").sync()
    if vim.fn.exists(":TSUpdateSync") ~= 0 then
      vim.cmd "TSUpdateSync"
    end
    -- Not using CocUpdateSync as it gives no UI output.
    if vim.fn.exists(":CocUpdateSync") ~= 0 then
      vim.cmd "CocUpdateSync"
    end
  end, { desc = "Updating plugins..." }
)

-- Run :Trim to trim trailing whitespace in this file.
vim.api.nvim_create_user_command(
  'Trim',
  -- Trim trailing whitespace in the current file.
  -- <https://vi.stackexchange.com/questions/37421/how-to-remove-neovim-trailing-white-space>
  function(_)
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  { desc = "Trimming whitespace..." }
)

-- }}} User Commands

-- {{{ Vimscript Commands and Functions
vim.cmd([[
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

  " Opens current buffer in previous split (at the same position but centered).
  function! DupBuffer()
    let pos = getpos(".") " Save cursor position.
    let buff = bufnr('%') " Save buffer number of current buffer.
    execute "normal! \<c-w>p:b " buff "\<CR>"| " Change to previous buffer and open saved buffer.
    call setpos('.', pos) " Set cursor position to what is was before.
  endfunction

  " Function to sort lines as an operator.
  function! SortLinesOpFunc(...)
      '[,']sort
  endfunction

  " Sums the selected numbers.
  function! SumVis()
      try
          let l:a_save = @a
          norm! gv"ay
          let @a = substitute(@a,'[^0-9. ]','+','g')
          exec "norm! '>o"
          exec "norm! iTotal \<c-r>=\<c-r>a\<cr>"
      finally
          let @a = l:a_save
      endtry
  endfun

  " See https://github.com/jonhoo/proximity-sort , makes closer paths to cwd higher priority.
  function! s:list_cmd(kind, query)
    if a:kind == 'find'
      let base = fnamemodify(expand('%'), ':h:.:S')
      return base == '.' ? 'fd --hidden --type file --exclude=.git' : printf('fd --hidden --type file --exclude=.git | proximity-sort %s', expand('%'))
    elseif a:kind == 'locate'
      return 'locate -i ' . a:query . ' | proximity-sort ' . getcwd()
    endif
  endfunction

  " Convert buffer to its realpath (resolving symlinks).
  " https://github.com/tpope/vim-fugitive/pull/814#issuecomment-446767081
  function! s:Resolve() abort
    let current = expand('%')
    let resolved = resolve(current)
    if current !~# '[\/][\/]' && current !=# resolved
      silent execute 'keepalt file' fnameescape(resolved)
      return 'edit'
    endif
    return ''
  endfunction

  command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!| " :W writes as sudo.

  command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'source': s:list_cmd('find', ''),
    \                               'options': '--tiebreak=index'}, <bang>0)

  command! -bang -nargs=? -complete=dir Locate
    \ call fzf#vim#locate(<q-args>, {'source': s:list_cmd('locate', <q-args>),
    \                               'options': '--tiebreak=index'}, <bang>0)

  " Use Rg to specify the string to search for (can be regex).
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg  --vimgrep --color=always --smart-case --hidden ' . shellescape(<q-args>), 1,
    \   fzf#vim#with_preview({'options': ['-m', '--bind=ctrl-a:toggle-all,alt-j:jump,alt-k:jump-accept']}, 'right:50%', 'ctrl-p'))

  " https://github.com/tpope/vim-fugitive/pull/814#issuecomment-446767081
  command! -bar Resolve execute s:Resolve()
]])

-- }}} Vimscript Commands and Functions

-- {{{ Autocommands

-- AutoCmd group for my custom commands.
local gib_autogroup = vim.api.nvim_create_augroup("gib_autogroup", { clear = true })

-- Bats is a shell test file type.
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", },
  { pattern = { "*.bats" }, command = "set filetype=sh", group = gib_autogroup })

-- Work around https://github.com/fannheyward/coc-rust-analyzer/issues/1113
-- Setup formatexpr specified filetype(s).
vim.api.nvim_create_autocmd("FileType",
  {
    pattern = { "typescript,json,rust" },
    command = "setlocal formatexpr=CocAction('formatSelected')",
    group = gib_autogroup
  })

-- Highlight symbol under cursor on CursorHold (show other instances of current word).
vim.api.nvim_create_autocmd("CursorHold",
  {
    pattern = { "*" },
    -- Work around https://github.com/neoclide/coc.nvim/issues/4577
    callback = function(opts)
      if (string.find(opts.file, ".log") == nil) then
        vim.fn
            ['CocActionAsync']('highlight')
      end
    end
    ,
    group = gib_autogroup
  })

-- Update signature help on jump placeholder (show function signature when you jump to it).
vim.api.nvim_create_autocmd("User",
  {
    pattern = { "CocJumpPlaceholder" },
    callback = function() vim.fn['CocActionAsync']('showSignatureHelp') end,
    group = gib_autogroup
  })

-- Reload colorscheme on save.
vim.api.nvim_create_autocmd("BufWritePost",
  {
    pattern = { "*/colors/gib-noir.lua" },
    command = "colorscheme gib-noir",
    nested = true,
    group = gib_autogroup
  })

-- YAML files should be folded by indent.
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "*" }, command = "setlocal foldmethod=expr", group = gib_autogroup })

-- Some files should be folded by indent.
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "yaml,json,python" }, command = "setlocal foldmethod=indent", group = gib_autogroup })

-- Hide rust imports by default.
-- Refs: https://www.reddit.com/r/neovim/comments/seq0q1/plugin_request_autofolding_file_imports_using/
vim.api.nvim_create_autocmd("FileType",
  {
    pattern = { "rust" },
    callback = function()
      vim.opt_local.foldlevelstart = 19
      vim.opt_local.foldlevel = 19
      vim.opt_local.foldexpr =
      "v:lnum==1?'>1':getline(v:lnum)=~'^ *use'?20:nvim_treesitter#foldexpr()"
    end,
    group = gib_autogroup
  })

-- https://github.com/tpope/vim-fugitive/issues/1926
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "fugitive" }, command = "nmap <buffer> S sk]czz", group = gib_autogroup })
-- Skip to next git hunk.
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "fugitive" }, command = "nmap <buffer> <A-g> ]czz", group = gib_autogroup })
-- Skip to previous git hunk.
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "fugitive" }, command = "nmap <buffer> <A-G> [czz", group = gib_autogroup })
-- Don't highlight tabs in Go.
vim.api.nvim_create_autocmd("FileType",
  {
    pattern = { "go" },
    command = [[set listchars=tab:\ \ ,trail:·,nbsp:☠ ]],
    group = gib_autogroup
  })
-- Open new help windows on the right,
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "help" }, command = "wincmd L", group = gib_autogroup })
-- Allow comments in json.
vim.api.nvim_create_autocmd("FileType",
  { pattern = { "json" }, command = [[syntax match Comment +\/\/.\+$+]], group = gib_autogroup })
-- Check if files modified when you open a new window, switch back to vim, or if you don't move the cursor for 100ms.
-- Use getcmdwintype() to avoid running in the q: window (otherwise you get lots of errors).
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
  {
    pattern = { "*" },
    command = "if getcmdwintype() == '' | checktime | endif",
    group = gib_autogroup
  })
-- Open the quickfix window on grep.
vim.api.nvim_create_autocmd("QuickFixCmdPost",
  { pattern = { "*grep*" }, command = "cwindow", group = gib_autogroup })
-- Don't allow starting Vim with multiple tabs.
vim.api.nvim_create_autocmd("VimEnter",
  { pattern = { "*" }, command = "silent! tabonly", group = gib_autogroup })

-- No line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen",
  { pattern = "*", command = "setlocal nonumber norelativenumber", group = gib_autogroup })
-- Soft line wrapping in terminal.
vim.api.nvim_create_autocmd("TermOpen",
  { pattern = "*", command = "setlocal wrap", group = gib_autogroup })
-- Create dir if it doesn't already exist on save.
vim.api.nvim_create_autocmd("BufWritePre",
  {
    pattern = "*",
    command =
    [[if expand("<afile>:p:h") !~ "fugitive:" | call mkdir(expand("<afile>:p:h"), "p") | endif]],
    group = gib_autogroup
  })

-- On open jump to last cursor position if possible.
vim.api.nvim_create_autocmd("BufReadPost",
  {
    pattern = "*",
    command =
    [[if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") | execute "normal g`\"" | endif]]
    ,
    group = gib_autogroup
  })

-- When yanking text, briefly highlight it.
vim.api.nvim_create_autocmd("TextYankPost",
  {
    pattern = "*",
    callback = function() vim.highlight.on_yank() end,
    group = gib_autogroup
  })


-- }}} Autocommands

-- {{{ Package Setup

vim.cmd 'colorscheme gib-noir'

-- Set up Treesitter languages.
require 'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  -- List of parsers to ignore installing (for "all")
  ignore_install = {
  },
  highlight = { enable = true }, indent = { enable = true }
}

-- }}} Package Setup

-- vim: foldmethod=marker
