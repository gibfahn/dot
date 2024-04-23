-- Lua core configuration for neovim.
--
-- Docs:
--   https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
--   https://neovim.io/doc/user/lua.html
--   https://github.com/nanotee/nvim-lua-guide
--
-- {{{ Global variables
-- Sometimes vim runs before my dotfiles.
if not vim.env.PATH:find("/usr/local/bin") then
  vim.env.PATH = "/usr/local/bin:" .. vim.env.PATH
end
if vim.fn.filereadable("/opt/homebrew/bin/python3") == 1 then
  -- Speed up startup by not looking for python3 every time.
  vim.g.python3_host_prog = "/opt/homebrew/bin/python3"
end

vim.env.XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME or vim.env.HOME .. "/.cache"
vim.env.XDG_CONFIG_HOME = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. "/.config"
vim.env.XDG_DATA_HOME = vim.env.XDG_DATA_HOME or vim.env.HOME .. "/.local/share"

local home_dir = os.getenv("HOME")

if vim.fn.executable("nvr") then
  -- Use existing nvim window to open new files (e.g. `g cm`).
  vim.env.VISUAL = "nvr -cc vsplit --remote-wait +'set bufhidden=wipe'"
end

vim.g.any_jump_disable_default_keybindings = 1 -- Conflicts with other useful bindings.
vim.g.is_posix = 1 -- Assume shell for syntax highlighting.
vim.g.loaded_netrw = 1 -- Skip loading netrw file browser (use vim-readdir instead).
vim.g.loaded_netrwPlugin = 1 -- Don't use the built-in file browser (use vim-readdir instead).
vim.g.mapleader = " " -- use space as a the leader key
vim.g.minipairs_disable = true -- Disable mini.pairs (autopairs) by default. Enable via <Leader>up below.
vim.g.mundo_preview_bottom = 1 -- vim-mundo undo diff preview on bottom.
vim.g.mundo_right = 1 -- vim-mundo undo window on right.
vim.g.peekaboo_window = "vert bo 50new" -- Increase vim-peekaboo window width to 50.
vim.g.terminal_scrollback_buffer_size = 100000 -- Store lots of terminal history (neovim-only).
vim.g.zoxide_use_select = true -- <https://github.com/nanotee/zoxide.vim/issues/5>

-- }}} Global variables

-- {{{ Vim options

vim.cmd("colorscheme habamax") -- Default colorscheme in case plugins don't load.

vim.opt.breakindent = true -- Nicer line wrapping for long lines.
vim.opt.completeopt = "menu,menuone,noselect" -- Nicer completion behaviour.
vim.opt.confirm = true -- Ask if you want to save unsaved files instead of failing.
vim.opt.diffopt:append("vertical") -- Always use vertical diffs.
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.fileformats = "unix" -- Force Unix line endings (\n) (always show \r (^M), never autoinsert them).
vim.opt.foldlevel = 99 -- expand all by default.
vim.opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()" -- Format with conform/LSP
vim.opt.formatoptions = "jcroqlnt" -- Sets line wrapping/formatting options.
vim.opt.gdefault = true -- Global replace default (off: /g).
vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m" -- Teach vim how to parse the ripgrep output.
vim.opt.grepprg = "rg -S --vimgrep --no-heading --hidden --glob !.git" -- Use ripgrep for file searching.
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
vim.opt.spell = false -- No spellcheck by default.
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
if vim.fn.isdirectory(home_dir .. "/wrk") ~= 0 then
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
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
      opts = {
        colorscheme = { "gib-noir" },
        -- lazyvim defaults. For what these default to see
        -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/init.lua>
        defaults = {
          autocmds = false, -- Don't load lazyvim.config.autocmds
          keymaps = false, -- Don't load lazyvim.config.keymaps
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
      },
      keys = {
        {
          "<Leader>cf",
          function()
            require("lazyvim.util").format({ force = true })
          end,
          mode = { "n", "v" },
          desc = "Format",
        },
      },
    },

    -- { import = "lazyvim.plugins.extras.coding.yanky" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/coding/yanky.lua>
    { import = "lazyvim.plugins.extras.dap.core" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/dap/core.lua>
    -- { import = "lazyvim.plugins.extras.dap.nlua" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/dap/nlua.lua>
    { import = "lazyvim.plugins.extras.editor.navic" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/editor/navic.lua>
    { import = "lazyvim.plugins.extras.formatting.black" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/formatting/black.lua>
    { import = "lazyvim.plugins.extras.formatting.prettier" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/formatting/prettier.lua>
    -- { import = "lazyvim.plugins.extras.lang.clangd" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/clangd.lua>
    -- { import = "lazyvim.plugins.extras.lang.cmake" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/cmake.lua>
    { import = "lazyvim.plugins.extras.lang.docker" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/docker.lua>
    { import = "lazyvim.plugins.extras.lang.go" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/go.lua>
    { import = "lazyvim.plugins.extras.lang.java" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/java.lua>
    { import = "lazyvim.plugins.extras.lang.json" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/json.lua>
    { import = "lazyvim.plugins.extras.lang.markdown" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/markdown.lua>
    -- { import = "lazyvim.plugins.extras.lang.python" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/python.lua>
    -- { import = "lazyvim.plugins.extras.lang.ruby" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/ruby.lua>
    { import = "lazyvim.plugins.extras.lang.rust" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/rust.lua>
    -- { import = "lazyvim.plugins.extras.lang.tex" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/tex.lua>
    -- { import = "lazyvim.plugins.extras.lang.typescript" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/typescript.lua>
    { import = "lazyvim.plugins.extras.lang.yaml" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/yaml.lua>
    { import = "lazyvim.plugins.extras.lsp.none-ls" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lsp/none-ls.lua>
    { import = "lazyvim.plugins.extras.test.core" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/test/core.lua>
    -- { import = "lazyvim.plugins.extras.ui.alpha" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/ui/alpha.lua>
    -- { import = "lazyvim.plugins.extras.ui.edgy" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/ui/edgy.lua>
    { import = "lazyvim.plugins.extras.util.mini-hipatterns" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/util/mini-hipatterns.lua>
    -- { import = "lazyvim.plugins.extras.vscode" }, -- <https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/vscode.lua>

    { import = "plugins" }, -- Everything in ~/.config/nvim/lua/plugins/
  },
  install = {
    colorscheme = { "gib-noir" },
  },
  checker = { enabled = false }, -- automatically check for plugin updates
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

-- {{{ Mappings
--
-- (see http://vim.wikia.com/wiki/Unused_keys for unused keys)

-- Allow long lines here so I can sort mappings easily.
-- stylua: ignore start

vim.keymap.set("c", "<A-/>", "<C-R>=expand('%:p:h') . '/'<CR>", { desc = "Insert dirname of current file" })
vim.keymap.set("i", ",", ",<c-g>u", { desc = "Set undo breakpoint on ," })
vim.keymap.set("i", ".", ".<c-g>u", { desc = "Set undo breakpoint on ." })
vim.keymap.set("i", ";", ";<c-g>u", { desc = "Set undo breakpoint on ;" })
vim.keymap.set("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
vim.keymap.set("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
vim.keymap.set("i", "<A-t>", "<C-r><C-r>=&commentstring<CR><C-o>:s/%s/ TODO(gib): /<CR><C-o>A", { silent = true, desc = "insert TODO comment" })
vim.keymap.set("i", "<A-x>", "<C-r><C-r>=&commentstring<CR><C-o>:s/%s/ XXX(gib): /<CR><C-o>A", { silent = true, desc = "insert XXX comment" })
vim.keymap.set("i", "<C-u>", "<C-g>u<C-u>", { desc = "<C-u> but undo-friendly" })
vim.keymap.set("i", "<C-w>", "<C-g>u<C-w>", { desc = "<C-w> but undo-friendly" })
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<A-BS>", "<Cmd>exit<CR>", { desc = "Save and quit" }) -- Only saves if changes.
vim.keymap.set("n", "<A-C>", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
vim.keymap.set("n", "<A-Down>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-E>", "<cmd>resize -1<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<A-Enter>", vim.lsp.codelens.run, { noremap = false, desc = "CodeLens actions" })
vim.keymap.set("n", "<A-G>", function() require("gitsigns").prev_hunk() end, { noremap = false, desc = "Prev changed git hunk" })
vim.keymap.set("n", "<A-H>", "<cmd>vertical resize -1<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<A-I>", "<cmd>vertical resize +1<cr>", { desc = "Increase window width" })
vim.keymap.set("n", "<A-L>", "<Cmd>lprev<CR>", { desc = "Go to previous location list item" })
vim.keymap.set("n", "<A-Left>", "zh", { desc = "Scroll view left a char" })
vim.keymap.set("n", "<A-N>", "<cmd>resize +1<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<A-Q>", "<Cmd>cprev<CR>", { desc = "Go to previous Quickfix list item" })
vim.keymap.set("n", "<A-R>", function() require("trouble").previous({skip_groups = true, jump = true}) end, { desc = "Go to previous Trouble item" })
vim.keymap.set("n", "<A-Right>", "zl", { desc = "Scroll view right a char" })
vim.keymap.set("n", "<A-S>", "[s", { desc = "Go to previous spelling mistake" })
vim.keymap.set("n", "<A-T>", "<Cmd>tabprev<CR>", { desc = "Prev tab" })
vim.keymap.set("n", "<A-Up>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("n", "<A-c>", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
vim.keymap.set("n", "<A-d>", "<Cmd>tabclose<CR>", { desc = "Close tab" })
vim.keymap.set("n", "<A-e>", "<C-w>k", { desc = "Switch up a window" })
vim.keymap.set("n", "<A-g>", function() require("gitsigns").next_hunk() end, { noremap = false, desc = "Prev changed git hunk" })
vim.keymap.set("n", "<A-h>", "<C-w>h", { desc = "Switch left a window," })
vim.keymap.set("n", "<A-i>", "<C-w>l", { desc = "Switch right a window" })
vim.keymap.set("n", "<A-l>", "<Cmd>lnext<CR>", { desc = "Go to next location list item" })
vim.keymap.set("n", "<A-n>", "<C-w>j", { desc = "Switch down a window," })
vim.keymap.set("n", "<A-q>", "<Cmd>cnext<CR>", { desc = "Go to next quickfix item" })
vim.keymap.set("n", "<A-r>", function() require("trouble").next({skip_groups = true, jump = true}) end, { desc = "Go to next Trouble item" })
vim.keymap.set("n", "<A-s>", "]s", { desc = "Go to next spelling mistake" })
vim.keymap.set("n", "<A-t>", "<Cmd>tabnext<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<A-x>", function(n) require("mini.bufremove").delete(n, false) end, { desc = "Close current buffer", noremap = false })
vim.keymap.set("n", "<A-z>", "<Cmd>Zi<CR>", { desc = "Switch to different directory" })
vim.keymap.set("n", "<C-p>", "<C-i>", { desc = "Go to next jump" }) -- <C-o> = go to previous jump, <C-p> is go to next (normally <C-i>, but that == Tab, used above)
vim.keymap.set("n", "<Leader>+", '<Cmd>exe "resize ".(winheight(0) * 3/2)<CR>', { silent = true, desc = "Increase window height to 3/2" })
vim.keymap.set("n", "<Leader>-", '<Cmd>exe "resize ".(winheight(0) * 2/3)<CR>', { silent = true, desc = "Reduce window height to 2/3" })
vim.keymap.set("n", "<Leader>1", '<cmd>lua require("bufferline").go_to_buffer(1, true)<cr>', { silent = true, desc = "Go to 1st buffer" })
vim.keymap.set("n", "<Leader>2", '<cmd>lua require("bufferline").go_to_buffer(2, true)<cr>', { silent = true, desc = "Go to 2nd buffer" })
vim.keymap.set("n", "<Leader>3", '<cmd>lua require("bufferline").go_to_buffer(3, true)<cr>', { silent = true, desc = "Go to 3rd buffer" })
vim.keymap.set("n", "<Leader>4", '<cmd>lua require("bufferline").go_to_buffer(4, true)<cr>', { silent = true, desc = "Go to 4th buffer" })
vim.keymap.set("n", "<Leader>5", '<cmd>lua require("bufferline").go_to_buffer(5, true)<cr>', { silent = true, desc = "Go to 5th buffer" })
vim.keymap.set("n", "<Leader>6", '<cmd>lua require("bufferline").go_to_buffer(6, true)<cr>', { silent = true, desc = "Go to 6th buffer" })
vim.keymap.set("n", "<Leader>7", '<cmd>lua require("bufferline").go_to_buffer(7, true)<cr>', { silent = true, desc = "Go to 7th buffer" })
vim.keymap.set("n", "<Leader>8", '<cmd>lua require("bufferline").go_to_buffer(8, true)<cr>', { silent = true, desc = "Go to 8th buffer" })
vim.keymap.set("n", "<Leader>9", '<cmd>lua require("bufferline").go_to_buffer(-1, true)<cr>', { silent = true, desc = "Go to last buffer" })
vim.keymap.set("n", "<Leader>;", "@:", { desc = "Repeat last :command" })
vim.keymap.set("n", "<Leader><", '<Cmd>exe "vertical resize ".(winwidth(0) * 2/3)<CR>', { silent = true, desc = "Decrease window width to 2/3" })
vim.keymap.set("n", "<Leader>>", '<Cmd>exe "vertical resize ".(winwidth(0) * 3/2)<CR>', { silent = true, desc = "Increase window width to 3/2" })
vim.keymap.set("n", "<Leader>D", "<Cmd>%d<CR>", { desc = "Delete all text in buffer" })
vim.keymap.set("n", "<Leader>E", "<C-W>z:cclose<CR>:lclose<CR>:helpclose<CR>:Noice dismiss<CR>", { desc = "Close preview windows" }) -- e.g. language server definitions
vim.keymap.set("n", "<Leader>F", ":grep ", { desc = "Search file contents for file" })
vim.keymap.set("n", "<Leader>P", '"+P', { desc = "Paste from system clipboard before cursor" })
vim.keymap.set("n", "<Leader>R", ":/ce <bar> up<Home>cfdo %s/", { desc = "Replace in all quickfix files" }) -- use after gr
vim.keymap.set("n", "<Leader>T", "<Cmd>term<CR>", { desc = "Open terminal in current split" })
vim.keymap.set("n", "<Leader>W", "<Cmd>w<CR>", { desc = "Force write" }) -- whether or not there were changes
vim.keymap.set("n", "<Leader>X", "<Cmd>xa<CR>", { desc = "Write all & exit" })
vim.keymap.set("n", "<Leader>Y", "<Cmd>%y+<CR>", { desc = "Copy file to clipboard" })
vim.keymap.set("n", "<Leader>Z", [[&foldlevel ? 'zM' :'zR']], { expr = true, desc = "Toggle folding everywhere" }) -- see also "zi
vim.keymap.set("n", "<Leader>a", "@a", { desc = "Apply macro a" }) -- add with qa or yank to a reg with "ay
vim.keymap.set("n", "<Leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
vim.keymap.set("n", "<Leader>cq", '<Cmd>cexpr getreg("+")<CR>', { desc = "Open clipboard in Quickfix" })
vim.keymap.set("n", "<Leader>e", "<C-w>q", { desc = "Close current split" }) -- keeps buffer
vim.keymap.set("n", "<Leader>fx", '<Cmd>grep -F "XXX(gib)"<CR>', { desc = "Search for XXX comments" })
vim.keymap.set("n", "<Leader>gG", ":Resolve<CR>|:Gcd<CR>", { desc = "Chdir to root of git directory current file is in" })
vim.keymap.set("n", "<Leader>gQ", "<Cmd>set fo+=t<CR><Cmd>set fo?<CR>", { desc = "Auto-add newline for long lines" })
vim.keymap.set("n", "<Leader>gb", "<Cmd>GBrowse!<CR>", { desc = "Copy github URL" })
vim.keymap.set("n", "<Leader>gc", "<Cmd>cd %:p:h<CR>", { desc = "Change to current file's dirname" }) -- e.g. for <space>f, :e
vim.keymap.set("n", "<Leader>gd", "<Cmd>DiffOrig<CR>", { desc = "Diff between saved file and buffer" })
vim.keymap.set("n", "<Leader>gf", "<Cmd>call DupBuffer()<CR>gF", { desc = "Open path:row:col in last window" })
vim.keymap.set("n", "<Leader>gg", ":Resolve<CR>|:tab Git<CR>", { desc = "Open fugitive in a new tab" })
vim.keymap.set("n", "<Leader>gn", "<Cmd>set number!<CR>", { desc = "Toggle line numbers" })
vim.keymap.set("n", "<Leader>gp", "`[v`]", { desc = "Visually select last copied/pasted text" })
vim.keymap.set("n", "<Leader>gq", "<Cmd>set fo-=t<CR><Cmd>set fo?<CR>", { desc = "Don't auto-add newline for long lines" })
vim.keymap.set("n", "<Leader>gt", "<Cmd>set et!<CR>:set et?<CR>", { desc = "Toggle tabs/spaces" })
vim.keymap.set("n", "<Leader>ht", "ITODO(gib): <Esc>gcc$", { desc = "Insert a TODO" }) -- Write todo, then `<Space>ht`
vim.keymap.set("n", "<Leader>hx", "IXXX(gib): <Esc>gcc$", { desc = "Insert an XXX" }) -- Write todo, then `<Space>hx`
vim.keymap.set("n", "<Leader>i", "<Cmd>vsp<CR><C-w>h:bp<CR>", { desc = "Open vertical split" })
vim.keymap.set("n", "<Leader>j", ":AnyJump<CR>", { desc = "Jump to definition" })
vim.keymap.set("n", "<Leader>lv", "<Cmd>e $MYVIMRC<CR>", { desc = "Open init.lua" }) -- autoreloaded on save
vim.keymap.set("n", "<Leader>n", "<Cmd>sp<CR><C-w>k:bp<CR>", { desc = "Open horizontal split" })
vim.keymap.set("n", "<Leader>o", function() vim.ui.open(vim.fn.expand("<cfile>")) end, { noremap = false, desc = "Open selected text" }) -- like netrw-gx
vim.keymap.set("n", "<Leader>p", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("n", "<Leader>q", "<Cmd>qa<CR>", { desc = "Quit if no unsaved changes" }) -- for single file use <Space>d instead
vim.keymap.set("n", "<Leader>r", ":%s/", { desc = "Replace in buffer" })
vim.keymap.set("n", "<Leader>t", "<Cmd>vsplit term://$SHELL<CR>i", { desc = "Open terminal in new split" })
vim.keymap.set("n", "<Leader>uu", "<Cmd>MundoToggle<CR>", { desc = "Show/hide undo tree" })
vim.keymap.set("n", "<Leader>w", "<Cmd>update<CR>", { desc = "Write if changes" })
vim.keymap.set("n", "<Leader>y", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("n", "<Leader>z", "za", { desc = "Fold current line" })
vim.keymap.set("n", "<S-Tab>", "<Cmd>bp<CR>", { desc = "Go to previous buffer" })
vim.keymap.set("n", "<Tab>", "<Cmd>bn<CR>", { desc = "Go to next buffer" })
vim.keymap.set("n", "<leader>gl", "<Cmd>LazyGit<CR>", { desc = "Lazygit" })
vim.keymap.set("n", "<leader>lL", function() require("lazyvim.util").news.changelog() end, { desc = "LazyVim Changelog" })
vim.keymap.set("n", "<leader>uF", function() require("lazyvim.util").format.toggle(true) end, { desc = "Toggle auto format (buffer)" })
vim.keymap.set("n", "<leader>uL", function() require("lazyvim.util").toggle("relativenumber") end, { desc = "Toggle Relative Line Numbers" })
vim.keymap.set("n", "<leader>uT", function() if vim.b.ts_highlight then vim.treesitter.stop() else vim.treesitter.start() end end, { desc = "Toggle Treesitter Highlight" })
vim.keymap.set("n", "<leader>uc", function() require("lazyvim.util").toggle("conceallevel", false, { 0, 3 }) end, { desc = "Toggle Conceal" })
vim.keymap.set("n", "<leader>ud", function() require("lazyvim.util").toggle.diagnostics() end, { desc = "Toggle Diagnostics" })
vim.keymap.set("n", "<leader>uf", function() require("lazyvim.util").format.toggle() end, { desc = "Toggle auto format (global)" })
vim.keymap.set("n", "<leader>uh", function() require("lazyvim.util").toggle.inlay_hints() end, { desc = "Toggle Inlay Hints" })
vim.keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
vim.keymap.set("n", "<leader>ul", function() require("lazyvim.util").toggle.number() end, { desc = "Toggle Line Numbers" })
vim.keymap.set("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / clear hlsearch / diff update" }) -- taken from runtime/lua/_editor.lua
vim.keymap.set("n", "<leader>us", function() require("lazyvim.util").toggle("spell") end, { desc = "Toggle Spelling" })
vim.keymap.set("n", "<leader>uw", function() require("lazyvim.util").toggle("wrap") end, { desc = "Toggle Word Wrap" })
vim.keymap.set("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })
vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
vim.keymap.set("n", "Q", "<nop>", { desc = "unused" }) -- disabled to avoid accidental triggering
vim.keymap.set("n", "[<Space>", function() vim.cmd("put! =repeat(nr2char(10), v:count1)|silent ']+") end, { desc = "Add newline above" }) -- Taken from <https://github.com/tummetott/unimpaired.nvim/blob/792404dc39a754ef17c4aca964762fa7cb880baa/lua/unimpaired/functions.lua>
vim.keymap.set("n", "[e", function() vim.diagnostic.goto_prev({severity = "ERROR"}) end, { desc = "Prev Error" })
vim.keymap.set("n", "[w", function() vim.diagnostic.goto_prev({severity = "WARN"}) end, { desc = "Prev Warning" })
vim.keymap.set("n", "]<Space>", function() vim.cmd("put =repeat(nr2char(10), v:count1)|silent '[-") end, { desc = "Add newline below" })
vim.keymap.set("n", "]e", function() vim.diagnostic.goto_prev({severity = "ERROR"}) end, { desc = "Next Error" })
vim.keymap.set("n", "]w", function() vim.diagnostic.goto_prev({severity = "WARN"}) end, { desc = "Next Warning" })
vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" }) -- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("t", "<A-e>", [[<C-\><C-n><C-w>k]], { desc = "Switch up a window" }) -- in terminal
vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]], { desc = "Switch left a window" }) -- in terminal
vim.keymap.set("t", "<A-i>", [[<C-\><C-n><C-w>l]], { desc = "Switch right a window" }) -- in terminal
vim.keymap.set("t", "<A-n>", [[<C-\><C-n><C-w>j]], { desc = "Switch down a window" }) -- in terminal
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Go to normal mode" }) -- in terminal
vim.keymap.set("v", "//", [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], { desc = "Search for selected text" }) -- very no-magic mode, searches for exactly what you select
vim.keymap.set("v", "<A-Down>", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
vim.keymap.set("v", "<A-Up>", ":m '<-2<cr>gv=gv", { desc = "Move line up" })
vim.keymap.set("v", "<Leader>d", '"+d', { desc = "Cut from clipboard (visual mode)" })
vim.keymap.set("v", "<Leader>gb", ":GBrowse!<CR>", { desc = "Copy github URL" })
vim.keymap.set("v", "<Leader>p", '"+p', { desc = "Paste from clipboard" })
vim.keymap.set("v", "<Leader>y", '"+y', { desc = "Copy from clipboard" })
vim.keymap.set("v", "g//", [[y/\V<C-R>=&ic?'\c':'\C'<CR><C-r>=escape(@",'/\')<CR><CR>]], { desc = "Search for selected text case-insensitively" })
vim.keymap.set("v", "gr", [[<Cmd>exec 'Telescope grep_string default_text=' . escape(@z, ' ')<cr>]], { noremap = false, desc = "Telescope search for selection" })
vim.keymap.set("x", "<Leader>j", ":AnyJumpVisual<CR>", { desc = "Jump to definition" })
vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
vim.keymap.set("x", "P", "p", { desc = "Paste and update clipboard" })
vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
vim.keymap.set("x", "p", "P") -- Don't overwrite clipboard when pasting over text <https://vi.stackexchange.com/questions/39149/how-to-stop-neovim-from-yanking-text-on-pasting-over-selection>
vim.keymap.set({ "i", "n" }, "<Esc>", "<cmd>noh<cr><Esc>", { desc = "Escape and clear hlsearch" })
vim.keymap.set({ "i", "x", "n", "s" }, "<A-w>", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set({ "n", "v", "i" }, "<A-Space>", vim.lsp.buf.code_action, { desc = "Code Action" })

-- stylua: ignore end

-- }}} Mappings

-- {{{ User Commands

-- :PU asynchronously updates plugins.
vim.api.nvim_create_user_command("PU", function(_)
  require("lazy").sync()
  if vim.fn.exists(":TSUpdateSync") ~= 0 then
    vim.cmd("TSUpdateSync")
  end
  if vim.fn.exists(":MasonUpdate") ~= 0 then
    vim.cmd("MasonUpdate")
  end
end, { desc = "Updating plugins..." })

-- Run :Trim to trim trailing whitespace in this file.
vim.api.nvim_create_user_command(
  "Trim",
  -- Trim trailing whitespace in the current file.
  -- <https://vi.stackexchange.com/questions/37421/how-to-remove-neovim-trailing-white-space>
  function(_)
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
  { desc = "Trimming whitespace..." }
)

-- :DiffOrig diffs the current changes against the on-disk file.
vim.api.nvim_create_user_command("DiffOrig", function()
  local scratch_buffer = vim.api.nvim_create_buf(false, true)
  local current_ft = vim.bo.filetype
  vim.cmd("vertical sbuffer" .. scratch_buffer)
  vim.bo[scratch_buffer].filetype = current_ft
  vim.cmd("read ++edit #") -- load contents of previous buffer into scratch_buffer
  vim.cmd.normal('1G"_d_') -- delete extra newline at top of scratch_buffer without overriding register
  vim.cmd.diffthis() -- scratch_buffer
  vim.cmd.wincmd("p")
  vim.cmd.diffthis() -- current buffer
end, {})

-- }}} User Commands

-- {{{ Vimscript Commands and Functions
vim.cmd([[
  " Opens current buffer in previous split (at the same position but centered).
  function! DupBuffer()
    let pos = getpos(".") " Save cursor position.
    let buff = bufnr('%') " Save buffer number of current buffer.
    execute "normal! \<c-w>p:b " buff "\<CR>"| " Change to previous buffer and open saved buffer.
    call setpos('.', pos) " Set cursor position to what is was before.
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

  " https://github.com/tpope/vim-fugitive/pull/814#issuecomment-446767081
  command! -bar Resolve execute s:Resolve()
]])

-- }}} Vimscript Commands and Functions

-- {{{ Autocommands

-- AutoCmd group for my custom commands.
local gib_autogroup = vim.api.nvim_create_augroup("gib_autogroup", { clear = true })

-- Bats is a shell test file type.
vim.api.nvim_create_autocmd(
  { "BufNewFile", "BufRead" },
  { pattern = { "*.bats" }, command = "set filetype=sh", group = gib_autogroup }
)

-- Reload colorscheme on save.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*/colors/gib-noir.lua" },
  command = "colorscheme gib-noir",
  nested = true,
  group = gib_autogroup,
})

-- Hide rust imports by default.
-- Refs: https://www.reddit.com/r/neovim/comments/seq0q1/plugin_request_autofolding_file_imports_using/
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "rust" },
  callback = function()
    vim.opt_local.foldlevelstart = 19
    vim.opt_local.foldlevel = 19
    vim.opt_local.foldexpr = "v:lnum==1?'>1':getline(v:lnum)=~'^ *use'?20:nvim_treesitter#foldexpr()"
  end,
  group = gib_autogroup,
})

-- https://github.com/tpope/vim-fugitive/issues/1926
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = { "fugitive" }, command = "nmap <buffer> S sk]czz", group = gib_autogroup }
)
-- Skip to next git hunk.
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = { "fugitive" }, command = "nmap <buffer> <A-g> ]czz", group = gib_autogroup }
)
-- Skip to previous git hunk.
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = { "fugitive" }, command = "nmap <buffer> <A-G> [czz", group = gib_autogroup }
)
-- Don't highlight tabs in Go.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  command = [[set listchars=tab:\ \ ,trail:·,nbsp:☠ ]],
  group = gib_autogroup,
})
-- Open new help windows on the right,
vim.api.nvim_create_autocmd("FileType", { pattern = { "help" }, command = "wincmd L", group = gib_autogroup })
-- Allow comments in json.
vim.api.nvim_create_autocmd(
  "FileType",
  { pattern = { "json" }, command = [[syntax match Comment +\/\/.\+$+]], group = gib_autogroup }
)
-- Check if files modified when you open a new window, switch back to vim, or if you don't move the cursor for 100ms.
-- Use getcmdwintype() to avoid running in the q: window (otherwise you get lots of errors).
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = { "*" },
  command = "if getcmdwintype() == '' | checktime | endif",
  group = gib_autogroup,
})
-- Open the quickfix window on grep.
vim.api.nvim_create_autocmd("QuickFixCmdPost", { pattern = { "*grep*" }, command = "cwindow", group = gib_autogroup })
-- Don't allow starting Vim with multiple tabs.
vim.api.nvim_create_autocmd("VimEnter", { pattern = { "*" }, command = "silent! tabonly", group = gib_autogroup })

-- No line numbers in terminal
vim.api.nvim_create_autocmd(
  "TermOpen",
  { pattern = "*", command = "setlocal nonumber norelativenumber", group = gib_autogroup }
)
-- Soft line wrapping in terminal.
vim.api.nvim_create_autocmd("TermOpen", { pattern = "*", command = "setlocal wrap", group = gib_autogroup })
-- Create dir if it doesn't already exist on save.

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  group = gib_autogroup,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
  group = gib_autogroup,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "query",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
  group = gib_autogroup,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  group = gib_autogroup,
})

-- When yanking text, briefly highlight it.
vim.api.nvim_create_autocmd("TextYankPost", {
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
  group = gib_autogroup,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = gib_autogroup,
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})
-- }}} Autocommands

-- vim: foldmethod=marker
