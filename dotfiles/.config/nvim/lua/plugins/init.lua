return {
  {
    "LazyVim/LazyVim", -- Prebuilt setup configuring many many plugins for you.
    version = false, -- Use latest main not latest release.
  },
  -- Disable lazyvim plugins I don't use.
  -- https://www.lazyvim.org/configuration/plugins#-disabling-plugins
  { "catppuccin", enabled = false }, -- I have my own colorscheme.
  { "folke/persistence.nvim", enabled = false }, -- I don't use sessions.
  { "folke/tokyonight.nvim", enabled = false }, -- I have my own colorscheme.
  { "nvim-neo-tree/neo-tree.nvim", enabled = false }, -- I use oil.nvim instead.
  { "MeanderingProgrammer/render-markdown.nvim", enabled = false }, -- Super-slow.

  {
    "akinsho/bufferline.nvim", -- Show buffers in the tab line.
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

  {
    "apple/pkl-neovim", -- Support for the Pkl language https://pkl-lang.org
    lazy = true,
    ft = "pkl",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "L3MON4D3/LuaSnip",
    },
    build = function()
      vim.cmd("TSInstall! pkl")
    end,
    config = function()
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
  },

  "chrisbra/Recover.vim", -- add a diff option when a swap file is found.

  "coderifous/textobj-word-column.vim", -- Adds ic/ac and iC/aC motions to block select word column in paragraph.

  {
    "echasnovski/mini.ai", -- a and i operators, e.g. vaL selects the current line.
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
    "echasnovski/mini.diff", -- visualise git diffs, stage/reset/delete hunks, jump between hunks.
    opts = { -- https://github.com/echasnovski/mini.diff?tab=readme-ov-file#default-config
      mappings = {
        goto_prev = "<A-G>",
        goto_next = "<A-g>",
      },
      options = {
        -- Whether to wrap around edges during hunk navigation
        wrap_goto = true,
      },
    },
  },

  {
    "echasnovski/mini.operators", -- operators like `gsip` to sort current paragraph
    opts = {
      -- Replace text with register
      replace = {
        prefix = "gp",
      },
    },
  },

  { "echasnovski/mini.splitjoin", config = true }, -- gS to split something over multiple lines.

  "fladson/vim-kitty", -- Syntax highlighting for kitty.conf file.

  {
    "folke/flash.nvim", -- Quickly jump anywhere you can see.
    event = "VeryLazy",
    opts = { -- https://github.com/folke/flash.nvim#%EF%B8%8F-configuration
      labels = "arstdhneioqwfpgjluyzxcvbkm1234567890", -- Colemak order, include numbers
      jump = {
        autojump = true, -- automatically jump when there is only one match
      },
      label = {
        -- flash tries to re-use labels that were already assigned to a position,
        -- when typing more characters. By default only lower-case labels are re-used.
        reuse = "lowercase", ---@type "lowercase" | "all" | "none"
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
    "folke/snacks.nvim",
    opts = {
      ---@class snacks.dashboard.Config
      dashboard = {
        enabled = false, -- I don't use the dashboard.
      },
      ---@class snacks.indent.Config
      indent = {
        enabled = true,
        -- Ideally enable indent_at_cursor if <https://github.com/folke/snacks.nvim/issues/282> is implemented.
      },
      ---@class snacks.scroll.Config
      scroll = {
        enabled = false, -- Scrolling is visual noise for me.
      },

      ---@class snacks.picker.Config
      picker = {
        win = {
          input = {
            keys = {
              -- <Alt-y> copies content to the clipboard.
              ["<a-y>"] = {
                "copy_content",
                mode = { "n", "i" },
              },
              -- lazyvim already adds <Alt-c> action to toggle cwd
            },
          },
        },
        actions = {
          -- Copies currently focused picker line to clipboard.
          ---@param picker snacks.Picker
          copy_content = function(picker)
            vim.fn.setreg("+", picker:current({ resolve = false }).text, "c")
          end,
        },
      },
    },
  },

  {
    "folke/trouble.nvim", -- better diagnostics list and others
    opts = {
      focus = true, -- Automatically move focus to window when opened.
      win = {
        type = "split", -- Open in a real split you can jump to.
        position = "right", -- Open trouble windows on the right.
        size = {
          -- Use 1/3 of the nvim window width or 100, whichever is smaller.
          width = math.min(math.floor(vim.api.nvim_win_get_width(0) / 3), 100), -- width of the list when position is left or right
          height = 0.8,
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
    opts = {
      preset = "modern", -- helix doesn't show everything by default
      spec = {
        { "<leader>l", group = "lazy" },
        { "<leader>h", group = "insert todos" },
      },
    },
  },

  "fweep/vim-zsh-path-completion", -- Nicer file browser plugin.

  {
    "gibfahn/gib-noir.nvim", -- My colorscheme.
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    -- the colorscheme should be available when starting Neovim
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- load the colorscheme here
      vim.cmd([[colorscheme gib-noir]])
    end,
  },

  { "godlygeek/tabular", cmd = "Tabularize" }, -- Make tables easier (:help Tabular).

  {
    "ibhagwan/fzf-lua",
    -- <https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#default-options>
    opts = {
      winopts = {
        width = 1.00, -- Make fzf-lua always full-screen
        height = 1.00,
      },
      defaults = {
        file_icons = false, -- No icons means Ctrl-y fzf mapping doesn't copy icons too.
        git_icons = false,
      },
    },
  },

  "junegunn/vim-peekaboo", -- Pop up register list when pasting/macroing.

  {
    "kdheepak/lazygit.nvim", -- Wrapper around the lazygit CLI.
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
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
        visual = "z",
        visual_line = "gz",
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

  -- Disable default Tab Key mappings in LuaSnip so we can set them in nvim-cmp above.
  -- See <https://github.com/LazyVim/LazyVim/issues/2533> for other options.
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },

  {
    "mfussenegger/nvim-lint", -- Pluggable linter framework.
    optional = true,
    opts = {
      linters_by_ft = {
        bzl = { "buildifier" },
        sieve = { "check_sieve" },
        python = { "pylint", "mypy" },
        zsh = { "zsh" },
        bash = { "shellcheck" },
        -- Use the "*" filetype to run linters on all filetypes.
        -- ['*'] = { 'global linter' },
        -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
        -- ['_'] = { 'fallback linter' },
        ["*"] = { "typos" },
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
        ["markdownlint-cli2"] = {
          args = {
            -- By default there isn't a global configuration option for markdownlint-cli2.
            "--config",
            vim.fn.expand("~") .. ".config/markdownlint-cli2/markdownlint.yaml",
          },
        },
      },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {

            -- Suggest imports like `crate::path::to::item` not `super::to::item`.
            -- https://github.com/rust-lang/rust-analyzer/discussions/18520
            imports = {
              prefix = "crate",
            },

            -- https://github.com/rust-analyzer/rust-analyzer/issues/3627
            rustfmt = {
              extraArgs = { "+nightly" },
            },
            -- Docs: https://github.com/fannheyward/coc-rust-analyzer#configurations
            check = {
              -- If your client supports the colorDiagnosticOutput experimental capability, you can use --message-format=json-diagnostic-rendered-ansi.
              overrideCommand = {
                "cargo",
                "+nightly",
                "clippy",
                "--workspace",
                "--message-format=json",
                "--all-targets",
              },
            },
          },
        },
      },
    },
  },

  { "mtdl9/vim-log-highlighting", ft = "log" }, -- Log file syntax highlighting.

  { "mzlogin/vim-markdown-toc", ft = "markdown", cmd = "GenTocGFM" }, -- Markdown Table of Contents.

  {
    "neovim/nvim-lspconfig", -- Configure language servers.
    opts = {
      servers = {
        -- https://github.com/rcjsuen/dockerfile-language-server?tab=readme-ov-file#language-server-settings
        dockerls = {
          settings = {
            docker = {
              languageserver = {
                formatter = {
                  -- Formatter doesn't handle inline multiline shell commands well (because it's hard).
                  ignoreMultilineInstructions = true,
                },
              },
            },
          },
        },

        -- Swift support.
        -- <https://www.swift.org/documentation/articles/zero-to-swift-nvim.html>
        sourcekit = {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true,
              },
            },
          },
        },

        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://github.com/gibfahn/up/releases/latest/download/up-task-schema.json"] = "**/up/tasks/*.yaml",
              },
            },
          },
          on_new_config = function(new_config)
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas({
                ignore = {
                  -- Conflicts with tasks schema above.
                  "Ansible Tasks File",
                },
              })
            )
          end,
        },
      },
    },
  },

  -- LSP keymaps
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- Disable overriding of my a-n keymap.
      keys[#keys + 1] = { "<a-n>", false }
      -- Disable overriding of my a-p keymap.
      keys[#keys + 1] = { "<a-p>", false }
    end,
  },

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
    "nvimtools/none-ls.nvim", -- Make anything a languageserver.
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

  { "pechorin/any-jump.nvim" }, -- Go to definition that doesn't require a language server.

  {
    "rcarriga/nvim-notify", -- Notification plugin used by noice.
    event = "VeryLazy",
    opts = {
      top_down = false, -- Notifications start at the bottom to stay out of your way.
    },
  },

  {
    "Saecki/crates.nvim", -- Linting, completions etc. for Cargo.toml
    opts = {
      -- Make code actions show up in Cargo.toml
      -- <https://github.com/Saecki/crates.nvim/wiki/Documentation-v0.4.0#code-actions>
      null_ls = {
        enabled = true,
      },
    },
  },

  {
    "saghen/blink.cmp",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      completion = {
        ghost_text = {
          enabled = true,
        },
      },

      -- experimental signature help support
      signature = { enabled = true },

      -- Don't use Enter preset as that conflicts with Enter for a newline.
      -- <https://cmp.saghen.dev/configuration/keymap.html#super-tab>
      keymap = {
        preset = "super-tab",
      },
    },
  },

  "simnalamburt/vim-mundo", -- Graphical undo tree (updated fork of Gundo).

  {
    "stevearc/conform.nvim", -- Formatter framework (format on save).
    optional = true,
    opts = {
      formatters_by_ft = {
        bzl = { "buildifier" },
        python = { "isort", "black" },
      },
    },
  },

  {
    "stevearc/oil.nvim", -- File browser (create, move, rename files etc.)
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

  { "subnut/nvim-ghost.nvim", build = ":call nvim_ghost#installer#install()", cmd = { "GhostTextStart" } }, -- Edit browser text areas in Neovim (:h ghost).

  { "tpope/vim-abolish", cmd = { "Abolish", "Subvert", "S" } }, -- Work with variants of words (replacing, capitalizing etc).
  "tpope/vim-fugitive", -- Git commands in vim.
  "tpope/vim-repeat", -- Allows you to use . with plugin mappings.
  "tpope/vim-rhubarb", -- GitHub support.
  "tpope/vim-rsi", -- Insert/commandline readline-style mappings, e.g. C-a for beginning of line.
}
