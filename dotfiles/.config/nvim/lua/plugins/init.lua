-- Copy of the wombat colorscheme colors I actually use here.
-- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/themes/wombat.lua
local wombat_colors = {
  base03  = '#242424',
  base023 = '#353535',
  base01  = '#585858',
  base3   = '#d0d0d0',
  yellow  = '#cae682',
  orange  = '#e5786d',
}
-- Wombat colorscheme's `b` section color.
local wombat_b = { fg = wombat_colors.base3, bg = wombat_colors.base01 }

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
    'nvim-lualine/lualine.nvim', -- Statusline plugin.
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = false,
        theme = 'wombat',
        component_separators = '',
        section_separators = '',
      },
      sections = { -- What to show for the active buffer.
        lualine_a = {
          'mode', -- e.g. NORMAL, INSERT, VISUAL, V-LINE, O-PENDING
        },
        lualine_b = {
          {
            'filename',
            path = 1, -- Relative path
            shorting_target = 60,-- Shorten path to leave N chars space in the window for other components.
            symbols = {
              readonly = '[RO]', -- Show when the file is non-modifiable or readonly.
            },
            -- Workaround for https://github.com/nvim-lualine/lualine.nvim/pull/1170
            color = wombat_b,
          },
        },
        lualine_c = {
          'branch', -- git branch
          {
            'diff', -- Diff of saved file vs committed.
            symbols = {added = '+', modified = '~', removed = '-'}, -- Changes the symbols used by the diff.
          },
          {
            'diagnostics', -- LanguageServer diagnostics.
            icons_enabled = true,
            symbols = {error = '✖ ', warn = '⚠ ', info = 'ℹ ', hint = 'ℹ '},
            diagnostics_color = {
              -- Use lightline defaults.
              error = { fg = wombat_colors.base03, bg = wombat_colors.orange },
              warn  = { fg = wombat_colors.base023, bg = wombat_colors.yellow },
            },
          }
        },
        lualine_x = {
          'CocCurrentFunction', -- Function the cursor is in.
          {
            'encoding', -- File encoding.
            -- Hide unless it's not a unix file. I don't need to know in the common case.
            cond = function() return vim.bo.fileencoding ~= 'utf-8' end,
          },
          {
            'fileformat', -- unix, mac, dos (line endings \n , \n\r, \r).
            -- Hide unless it's not a unix file. I don't need to know in the common case.
            cond = function() return vim.bo.fileformat ~= 'unix' end,
          },
          'filetype', -- vim filetype, e.g. 'lua'
        },
        lualine_y = {
          {
            'progress', -- %progress in file
            color = wombat_b, -- Make this section clearer than wombat default.
          },
          {
            'selectioncount', -- number of selected characters or lines
            color = wombat_b, -- Make this section clearer than wombat default.
          },
          {
            'WordCount', -- number of words in file/selection,
            color = wombat_b, -- Make this section clearer than wombat default.
          },
        },
        lualine_z = {
          {
            'searchcount', -- Number of matches (when searching with /)
            maxcount = 999, -- Show the actual count if high (vim tops out at >99).
            timeout = 500,
          },
          'location', -- location in file in line:column format
        }
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            path = 1, -- Relative path
            symbols = {
              readonly = '[RO]', -- Show when the file is non-modifiable or readonly.
            },
          },
        },
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
      },
      tabline = {}, -- Disable tabline.
      extensions = {
        'quickfix', -- Show 'Quickfix List' not '[No Name]' for Quickfix buffers
      },
    },
  },

  {
    "rcarriga/nvim-notify", -- Notification plugin used by noice.
    event = "VeryLazy",
    opts = {
      top_down = false, -- Notifications start at the bottom to stay out of your way.
    },
  },


  {
    "folke/noice.nvim", -- Fancier UI for messages, cmdline, popups
    event = "VeryLazy",
    opts = {
      presets = {
        long_message_to_split = true, -- long messages will be sent to a split
      },
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
      },
      label = {
        reuse = "all", -- flash tries to re-use labels that were already assigned to a position
      },
      modes = {
        search = {
          enabled = false, -- off by default
        },
      },
    },
    keys = {
      { "s",     mode = { "n" },           function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "<a-s>", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
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
        normal = "ys",
        normal_cur = "yss",
        normal_line = "yZ",
        normal_cur_line = "yZZ",
        visual = "s",
        visual_line = "gs",
        delete = "ds",
        change = "cs",
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
