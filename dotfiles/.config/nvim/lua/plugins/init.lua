return {
  -- the colorscheme should be available when starting Neovim
  {
    "gibfahn/gib-noir.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme gib-noir]])
    end,
  },

  -- Disable lazyvim plugins I don't use.
  -- https://www.lazyvim.org/configuration/plugins#-disabling-plugins
  { "echasnovski/mini.surround", enabled = false }, -- I use kylechui/nvim-surround instead.
  { "folke/persistence.nvim", enabled = false }, -- I don't use sessions.
  { "nvim-neo-tree/neo-tree.nvim", enabled = false }, -- I use oil.nvim instead.
  { "folke/tokyonight.nvim", enabled = false }, -- I have my own colorscheme.
  { "catppuccin", enabled = false }, -- I have my own colorscheme.
  { "lukas-reineke/headlines.nvim", enabled = false }, -- Don't need fancy markdown highlighting.

  { "echasnovski/mini.splitjoin", config = true },

  {
    "stevearc/oil.nvim",
    opts = {
      -- Id is automatically added at the beginning, and name at the end
      -- See :help oil-columns
      columns = {
        "icon",
        "permissions",
        "size",
        "mtime",
      },
      -- Buffer-local options to use for oil buffers
      buf_options = {
        buflisted = true, -- Show buffer in bar.
      },
      -- Send deleted files to the trash instead of permanently deleting them (:help oil-trash)
      delete_to_trash = true,
      -- Keymaps in oil buffer. Can be any value that `vim.keymap.set` accepts OR a table of keymap
      -- options with a `callback` (e.g. { callback = function() ... end, desc = "", mode = "n" })
      -- Additionally, if it is a string that matches "actions.<name>",
      -- it will use the mapping at require("oil.actions").<name>
      -- Set to `false` to remove a keymap
      -- See :help oil-actions for a list of all available actions
      keymaps = {
        ["+"] = {
          callback = function()
            vim.cmd([[s/. \zs\([r-][w-]\).\([r-][w-]\).\([r-][w-]\)./\1x\2x\3x/]])
            vim.cmd("nohl")
          end,
          desc = "Make file executable.",
        },
      },
      view_options = {
        -- Show files and directories that start with "."
        show_hidden = true,
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        mappings = {
          i = {
            -- Open all selected files <https://github.com/nvim-telescope/telescope.nvim/issues/814#issuecomment-1759190643>
            -- Not set to <CR> to avoid conflicting with e.g. running code actions.
            ["<C-o>"] = function(p_bufnr)
              require("telescope.actions").send_selected_to_qflist(p_bufnr)
              vim.cmd.cfdo("edit")
            end,
            -- Select all <https://github.com/nvim-telescope/telescope.nvim/pull/931>
            ["<C-a>"] = function(p_bufnr)
              require("telescope.actions").toggle_all(p_bufnr)
            end,
          },
        },
      },
    },
    dependencies = {
      {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
          require("lazyvim.util").on_load("telescope.nvim", function()
            require("telescope").load_extension("ui-select")
          end)
        end,
      },
    },
  },

  {
    "echasnovski/mini.ai",
    opts = {
      -- <https://www.reddit.com/r/neovim/comments/wa819w/comment/ilfpkbd/?utm_source=share&utm_medium=web2x&context=3>
      custom_textobjects = {
        -- viL selects current line.
        L = function(ai_type)
          local line_num = vim.fn.line(".") or -1
          local line = vim.fn.getline(line_num)
          -- Select `\n` past the line for `a` to delete it whole
          local from_col, to_col = 1, line:len() + 1
          if ai_type == "i" then
            if line:len() == 0 then
              -- Don't remove empty line
              from_col, to_col = 0, 0
            else
              -- Ignore indentation for `i` textobject and don't remove `\n` past the line
              from_col = line:match("^%s*()")
              to_col = line:len()
            end
          end

          return { from = { line = line_num, col = from_col }, to = { line = line_num, col = to_col } }
        end,
        -- viB selects current buffer.
        B = function(ai_type)
          local n_lines = vim.fn.line("$") or -1
          local start_line, end_line = 1, n_lines
          if ai_type == "i" then
            -- Skip first and last blank lines for `i` textobject
            local first_nonblank, last_nonblank = vim.fn.nextnonblank(1), vim.fn.prevnonblank(n_lines)
            start_line = first_nonblank == 0 and 1 or first_nonblank
            end_line = last_nonblank == 0 and n_lines or last_nonblank
          end

          local to_col = math.max(vim.fn.getline(end_line):len(), 1)
          return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
        end,
      },
    },
  },
  {
    "echasnovski/mini.operators",
    opts = {
      -- Replace text with register
      replace = {
        prefix = "gp",
      },
    },
  },

  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.buildifier,
        nls.builtins.formatting.isort,
        nls.builtins.diagnostics.pylint,
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        bzl = { "buildifier" },
        sieve = { "check_sieve" },
        python = { "pylint", "mypy" },
        zsh = { "zsh" },
        bash = { "shellcheck" },
      },
      linters = {
        -- https://github.com/mfussenegger/nvim-lint#custom-linters
        check_sieve = {
          cmd = "check-sieve",
          stdin = false, -- Filename is automatically added to the arguments.
          ignore_exitcode = true, -- Exits 1 on lint found.
          stream = "stderr", -- where the linter outputs the result
          parser = function(output, bufnr)
            local message, line, more_message =
              string.match(output, '^Errors found in "[^"]+":%s+([^\n]+)\nOn line (%d+):%s(.*)')
            return {
              {
                bufnr = bufnr,
                lnum = tonumber(line) - 1,
                col = 0,
                message = message .. "\n\n" .. more_message,
                severity = vim.diagnostic.severity.ERROR,
              },
            }
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        bzl = { "buildifier" },
        python = { "isort", "black" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              -- https://github.com/rust-analyzer/rust-analyzer/issues/3627
              rustfmt = { extraArgs = { "+nightly" } },
            },
          },
        },
      },
    },
  },

  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        -- style_preset = require("bufferline").style_preset.minimal,
        indicator = {
          style = "none",
        },
        show_buffer_icons = false,
        show_buffer_close_icons = false,
        show_close_icon = true,
        themeable = true,
        numbers = "ordinal",
        -- separator_style = { "", "" },
      },
    },
  },

  "fladson/vim-kitty", -- Syntax highlighting for kitty.conf file.
  "chrisbra/Recover.vim", -- add a diff option when a swap file is found.
  "coderifous/textobj-word-column.vim", -- Adds ic/ac and iC/aC motions to block select word column in paragraph.
  "fweep/vim-zsh-path-completion", -- Nicer file browser plugin.
  "junegunn/vim-peekaboo", -- Pop up register list when pasting/macroing.
  "simnalamburt/vim-mundo", -- Graphical undo tree (updated fork of Gundo).
  "tpope/vim-fugitive", -- Git commands in vim.
  "tpope/vim-repeat", -- Allows you to use . with plugin mappings.
  "tpope/vim-rhubarb", -- GitHub support.
  "tpope/vim-rsi", -- Insert/commandline readline-style mappings, e.g. C-a for beginning of line.
  { "godlygeek/tabular", cmd = "Tabularize" }, -- Make tables easier (:help Tabular).
  { "mzlogin/vim-markdown-toc", ft = "markdown", cmd = "GenTocGFM" }, -- Markdown Table of Contents.
  { "nanotee/zoxide.vim", cmd = "Zi" }, -- Use zoxide to quickly jump to directories.
  { "pechorin/any-jump.nvim" }, -- Go to definition that doesn't require a language server.
  { "subnut/nvim-ghost.nvim", build = ":call nvim_ghost#installer#install()" }, -- Edit browser text areas in Neovim (:h ghost). Disabled until https://github.com/subnut/nvim-ghost.nvim/issues/50 is fixed.
  { "tpope/vim-abolish", cmd = { "Abolish", "Subvert", "S" } }, -- Work with variants of words (replacing, capitalizing etc).

  {
    "nvim-lualine/lualine.nvim", -- Statusline plugin.
    dependencies = { "nvim-tree/nvim-web-devicons" },
    -- Use a function not a table so we can `require()` other modules.
    opts = function(_, _) -- We ignore existing configuration.
      -- Copy of the wombat colorscheme colors I actually use here.
      -- https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/themes/wombat.lua
      local wombat_colors = {
        base03 = "#242424",
        base023 = "#353535",
        base01 = "#585858",
        base3 = "#d0d0d0",
        yellow = "#cae682",
        orange = "#e5786d",
      }

      local custom_wombat = require("lualine.themes.wombat")

      -- Wombat colorscheme's `b` section color.
      -- Workaround for https://github.com/nvim-lualine/lualine.nvim/pull/1170
      custom_wombat.normal.b = { fg = wombat_colors.base3, bg = wombat_colors.base01 }
      -- Make this section clearer than wombat default.
      custom_wombat.normal.y = custom_wombat.normal.b

      -- Word count: show number of words and chars in selection or file, e.g. `100w 1000c`.
      local function word_char_count()
        local word_count = vim.fn.wordcount()
        -- If there's a visual selection, show that count, else show whole file count.
        local words = word_count.visual_words or word_count.words
        local chars = word_count.visual_chars or word_count.chars
        return words .. "w " .. chars .. "c"
      end

      -- Returns the function the cursor is currently in.
      local function current_location()
        return require("nvim-navic").get_location()
      end

      return {
        options = {
          icons_enabled = false,
          theme = custom_wombat,
          component_separators = "",
          section_separators = "",
        },
        sections = { -- What to show for the active buffer.
          lualine_a = {
            "mode", -- e.g. NORMAL, INSERT, VISUAL, V-LINE, O-PENDING
          },
          lualine_b = {
            {
              "filename",
              path = 1, -- Relative path
              shorting_target = 60, -- Shorten path to leave N chars space in the window for other components.
              symbols = {
                readonly = "[RO]", -- Show when the file is non-modifiable or readonly.
              },
            },
          },
          lualine_c = {
            "branch", -- git branch
            {
              "diff", -- Diff of saved file vs committed.
              symbols = { added = "+", modified = "~", removed = "-" }, -- Changes the symbols used by the diff.
            },
            {
              "diagnostics", -- LanguageServer diagnostics.
              icons_enabled = true,
              symbols = { error = "✖ ", warn = "⚠ ", info = " ", hint = " " },
              diagnostics_color = {
                -- Use lightline defaults.
                error = { fg = wombat_colors.base03, bg = wombat_colors.orange },
                warn = { fg = wombat_colors.base023, bg = wombat_colors.yellow },
              },
            },
          },
          lualine_x = {
            {
              current_location, -- Function the cursor is in.
              cond = function()
                return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
              end,
            },
            {
              "encoding", -- File encoding.
              -- Hide unless it's not a unix file. I don't need to know in the common case.
              cond = function()
                return vim.bo.fileencoding ~= "utf-8"
              end,
            },
            {
              "fileformat", -- unix, mac, dos (line endings \n , \n\r, \r).
              -- Hide unless it's not a unix file. I don't need to know in the common case.
              cond = function()
                return vim.bo.fileformat ~= "unix"
              end,
            },
            "filetype", -- vim filetype, e.g. 'lua'
          },
          lualine_y = {
            "progress", -- %progress in file
            "selectioncount", -- number of selected characters or lines
            {
              word_char_count, -- show number of words in selection or file, e.g. `100w`.
              cond = function()
                -- Show if we're in a visual mode.
                -- See `:h mode()` for a full list of modes.
                if vim.tbl_contains({ "v", "vs", "V", "Vs", "", "s" }, vim.api.nvim_get_mode().mode) then
                  return true
                end
                -- -- Show if we're in an empty file or a markdown file.
                if vim.tbl_contains({ "", "markdown" }, vim.bo.filetype) then
                  return true
                end
                return false
              end,
            },

            {
              require("noice").api.status.mode.get, -- Show @recording when recording a macro.
              cond = require("noice").api.status.mode.has,
            },
          },
          lualine_z = {
            {
              "searchcount", -- Number of matches (when searching with /)
              maxcount = 999, -- Show the actual count if high (vim tops out at >99).
              timeout = 500,
            },

            "location", -- location in file in line:column format
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {
            {
              "filename",
              path = 1, -- Relative path
              symbols = {
                readonly = "[RO]", -- Show when the file is non-modifiable or readonly.
              },
            },
          },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {}, -- Disable tabline.
        extensions = {
          "quickfix", -- Show 'Quickfix List' not '[No Name]' for Quickfix buffers
        },
      }
    end,
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
    },
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
      {
        "s",
        mode = { "n" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "<a-s>",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<c-s>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
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
        -- Surround with markdown code block, triple backticks.
        -- <https://github.com/kylechui/nvim-surround/issues/88>
        ["~"] = {
          add = function()
            local config = require("nvim-surround.config")
            local result = config.get_input("Markdown code block language: ")
            return {
              { "```" .. result, "" },
              { "", "```" },
            }
          end,
        },
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

  {
    "folke/which-key.nvim", -- Show help when typing keys.
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    -- https://github.com/folke/which-key.nvim#%EF%B8%8F-configuration
    opts = function(_, opts)
      opts.defaults["<leader>l"] = { name = "+lazy" }
      -- Remove lazyvim <Leader>w = window prefix.
      opts.defaults["<leader>w"] = nil
      return opts
    end,
  },
}
