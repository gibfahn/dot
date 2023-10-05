return {

  "fladson/vim-kitty", -- Syntax highlighting for kitty.conf file.
  'AndrewRadev/splitjoin.vim', -- gS to split, gJ to join lines.
  'airblade/vim-gitgutter', -- Show git diffs in the gutter (left of line numbers) (:h gitgutter).
  'ap/vim-buftabline', -- Show buffers in the tab bar.
  'ap/vim-readdir', -- Nicer file browser plugin that works with buftabline.
  'chrisbra/Colorizer', -- Color ansi escape codes (:h Colorizer).
  'chrisbra/Recover.vim', -- add a diff option when a swap file is found.
  'coderifous/textobj-word-column.vim', -- Adds ic/ac and iC/aC motions to block select word column in paragraph.
  'fweep/vim-zsh-path-completion', -- Nicer file browser plugin.
  'gibfahn/gib-noir.nvim', -- Use my neovim colorscheme.
  'honza/vim-snippets', -- Work around https://github.com/neoclide/coc-snippets/issues/126 .
  'itchyny/lightline.vim', -- Customize statusline and tabline.
  'junegunn/fzf.vim', -- Try :Files, :GFiles? :Buffers :Lines :History :Commits :BCommits
  'junegunn/vim-peekaboo', -- Pop up register list when pasting/macroing.
  'kana/vim-operator-user', -- Make it easier to define operators.
  'kana/vim-textobj-user', -- Allows you to create custom text objects (used in vim-textobj-line).
  'sedm0784/vim-resize-mode', -- Continuous resizing.
  'simnalamburt/vim-mundo', -- Graphical undo tree (updated fork of Gundo).
  'tpope/vim-commentary', -- Autodetect comment type for lang.
  'tpope/vim-fugitive', -- Git commands in vim.
  'tpope/vim-repeat', -- Allows you to use . with plugin mappings.
  'tpope/vim-rhubarb', -- GitHub support.
  'tpope/vim-rsi', -- Insert/commandline readline-style mappings, e.g. C-a for beginning of line.
  'tpope/vim-unimpaired', -- [ and ] mappings (help unimpaired).
  { 'cespare/vim-toml',                ft = 'toml' }, -- Toml syntax highlighting.
  { 'godlygeek/tabular',               cmd = 'Tabularize' }, -- Make tables easier (:help Tabular).
  { 'kana/vim-textobj-line',           dependencies = { 'kana/vim-textobj-user' }, }, -- Adds `il` and `al` text objects for current line.
  { 'moll/vim-bbye',                   cmd = 'Bdelete' }, -- Delete buffer without closing split.
  { 'mzlogin/vim-markdown-toc',        ft = 'markdown',                                      cmd = 'GenTocGFM' }, -- Markdown Table of Contents.
  { 'nanotee/zoxide.vim',              cmd = 'Zi' }, -- Use zoxide to quickly jump to directories.
  { 'neoclide/coc.nvim',               branch = 'release' }, -- Language Server with VSCode Extensions.
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' }, -- Treesitter syntax highlighting.
  { 'pechorin/any-jump.nvim',          cmd = 'AnyJump' }, -- Go to definition that doesn't require a language server.
  { 'rust-lang/rust.vim',              ft = 'rust' }, -- Rust language bindings.
  { 'sheerun/vim-polyglot',            config = function() vim.opt.shortmess:remove("A") end }, -- Syntax files for languages + work around <https://github.com/sheerun/vim-polyglot/issues/765>.
  { 'subnut/nvim-ghost.nvim',          build = ':call nvim_ghost#installer#install()' }, -- Edit browser text areas in Neovim (:h ghost). Disabled until https://github.com/subnut/nvim-ghost.nvim/issues/50 is fixed.
  { 'tpope/vim-abolish',               cmd = { 'Abolish', 'Subvert', 'S' } }, -- Work with variants of words (replacing, capitalizing etc).
  { 'tpope/vim-sleuth',                dependencies = { 'vim-polyglot' } }, -- Automatically detect indentation.
  { dir = '~/.local/share/fzf',        name = 'fzf',                                         build = './install, --bin' }, -- :h fzf

  {
    "folke/noice.nvim", -- Fancier UI for messages, cmdline, popups
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },


  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      labels = "arstdhneioqwfpgjluyzxcvbkm1234567890", -- Colemak order, include numbers
      jump = {
        autojump = true, -- automatically jump when there is only one match
        inclusive = false, -- delete up to the char entered, not including it.
      },
      label = {
        reuse = "all", -- flash tries to re-use labels that were already assigned to a position
      },
    },
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },

  {
    "kylechui/nvim-surround", -- Add/change/remove surrounding pairs of characters.
    version = "*",
    event = "VeryLazy",
    opts = {
      -- Use z for surround because s is for flash.
      keymaps = {
        normal = "yz",
        normal_cur = "yzz",
        normal_line = "yZ",
        normal_cur_line = "yZZ",
        visual = "Z",
        visual_line = "gZ",
        delete = "dz",
        change = "cz",
      },
      surrounds = {
        -- Add markdown link with link as contents of system clipboard.
        -- <https://github.com/kylechui/nvim-surround/discussions/53#discussioncomment-3134891>
        ["l"] = {
          add = function()
            local clipboard = vim.fn.getreg("+"):gsub("\n", "")
            return {
              { "[" },
              { "](" .. clipboard .. ")" },
            }
          end,
          find = "%b[]%b()",
          delete = "^(%[)().-(%]%b())()$",
          change = {
            target = "^()()%b[]%((.-)()%)$",
            replacement = function()
              local clipboard = vim.fn.getreg("+"):gsub("\n", "")
              return {
                { "" },
                { clipboard },
              }
            end,
          },
        },
      },
    },
  },
}
