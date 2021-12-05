-- Lua core configuration for neovim.
-- Docs:
--   https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
--   https://neovim.io/doc/user/lua.html
--   https://github.com/nanotee/nvim-lua-guide
--
-- {{{ Global variables
-- Sometimes vim runs before my dotfiles.
if not vim.env.PATH:find('/usr/local/bin') then
    vim.env.PATH:append('/usr/local/bin:')
end

vim.env.XDG_CACHE_HOME = vim.env.XDG_CACHE_HOME or vim.env.HOME .. '/.cache'
vim.env.XDG_CONFIG_HOME = vim.env.XDG_CONFIG_HOME or vim.env.HOME .. '/.config'
vim.env.XDG_DATA_HOME = vim.env.XDG_DATA_HOME or vim.env.HOME .. '/.local/share'

vim.g.any_jump_disable_default_keybindings = 1 -- Conflicts with other useful bindings.
vim.g.buftabline_indicators = 1 -- Show a + if the buffer has been modified.
vim.g.buftabline_numbers = 2 -- Show buftabline's count (use <Leader>1-9 to switch.
vim.g.coc_snippet_next = '<a-u>' -- Use <Alt-u> for jump to next placeholder.
vim.g.coc_snippet_prev = '<a-l>' -- Use <Alt-l> for jump to previous placeholder.
vim.g.colorizer_use_virtual_text = 1 -- Use virtual text
vim.g.fzf_history_dir = vim.env.XDG_CACHE_HOME .. '/fzf-history' -- Save history of fzf vim commands.
vim.g.is_posix = 1 -- Assume shell for syntax highlighting.
vim.g.lightspeed_last_motion = '' -- :h lightspeed-custom-mappings
vim.g.loaded_netrw = 1 -- Skip loading netrw file browser (use vim-readdir instead).
vim.g.loaded_netrwPlugin = 1 -- Don't use the built-in file browser (use vim-readdir instead).
vim.g.mapleader = ' ' -- use space as a the leader key
vim.g.mundo_preview_bottom = 1 -- Undo diff preview on bottom.
vim.g.mundo_right = 1 -- Undo window on right.
vim.g.peekaboo_window = "vert bo 50new" -- Increase peekaboo window width to 50.
vim.g.surround_97 = "\1before: \1\r\2after: \2" -- yswa surrounds with specified text (prompts for before/after).
vim.g.surround_no_mappings = 1 -- Manually map surround, see SurroundOp() function.
vim.g.terminal_scrollback_buffer_size = 100000 -- Store lots of terminal history (neovim-only).

-- Settings for custom statusline.
vim.g.lightline = {
    colorscheme = 'wombat',
    active = {
        left = {
            {'mode', 'paste'}, {'readonly', 'relativepath', 'modified'},
            {'gitbranch'}, {'truncate_here'},
            {'coc_error', 'coc_warning', 'coc_info', 'coc_hint'}
        },
        right = {
            {'lineinfo'}, {'percent'},
            {'fileformat', 'fileencoding', 'filetype'}, {'currentfunction'}
        }
    },
    inactive = {left = {{'relativepath'}}, right = {{'lineinfo'}, {'percent'}}},
    tabline = {left = {{'tabs'}}, right = {{'close'}}},
    component = {
        truncate_here = '%<',
        fileformat = '%{&ff=="unix"?"":&ff}',
        fileencoding = '%{&fenc=="utf-8"?"":&fenc}'
    },
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
    component_function = {
        currentfunction = 'CocCurrentFunction',
        gitbranch = 'fugitive#head'
    }
}

if vim.fn.executable("nvr") then
    -- Use existing nvim window to open new files (e.g. `g cm`).
    vim.env.VISUAL = 'nvr --remote-wait'
end
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
vim.opt.updatetime = 100 -- Delay after which to write to swap file and run CursorHold event.
vim.opt.visualbell = true -- Flash the screen instead of beeping when doing something wrong.
vim.opt.wildignorecase = true -- Case insensitive file tab completion with :e.
vim.opt.wildmode = {"list", "longest"} -- 1st Tab completes to longest common string, 2nd+ cycles through options.

-- }}} Vim options

-- {{{ Package Manager Setup
-- variable that is only set if we're bootstrapping (Packer hasn't been installed).
local packer_bootstrap

local install_path = vim.fn.stdpath('data') ..
                         '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    packer_bootstrap = vim.fn.system({
        'git', 'clone', '--depth', '1',
        'https://github.com/wbthomason/packer.nvim', install_path
    })
    vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use 'AndrewRadev/splitjoin.vim' -- gS to split, gJ to join lines.
    use 'airblade/vim-gitgutter' -- Show git diffs in the gutter (left of line numbers) (:h gitgutter).
    use 'ap/vim-buftabline' -- Show buffers in the tab bar.
    use 'ap/vim-readdir' -- Nicer file browser plugin that works with buftabline.
    use 'aymericbeaumet/vim-symlink' -- Resolve symlinks when opening files.
    use 'cespare/vim-toml' -- Toml syntax highlighting.
    use 'chrisbra/Colorizer' -- Color ansi escape codes (:h Colorizer).
    use 'coderifous/textobj-word-column.vim' -- Adds ic/ac and iC/aC motions to block select word column in paragraph.
    use 'fweep/vim-zsh-path-completion' -- Nicer file browser plugin.
    use 'ggandor/lightspeed.nvim' -- Quickest way to jump to any char on the screen (alternative to easymotion/sneak/hop).
    use 'gibfahn/vim-gib' -- Use vim colorscheme.
    use 'godlygeek/tabular' -- Make tables easier (:help Tabular).
    use 'honza/vim-snippets' -- Work around https://github.com/neoclide/coc-snippets/issues/126 .
    use 'itchyny/lightline.vim' -- Customize statusline and tabline.
    use 'junegunn/fzf.vim' -- Try :Files, :GFiles? :Buffers :Lines :History :Commits :BCommits
    use 'junegunn/vim-peekaboo' -- Pop up register list when pasting/macroing.
    use 'kana/vim-operator-user' -- Make it easier to define operators.
    use 'kana/vim-textobj-line' -- Adds `il` and `al` text objects for current line.
    use 'kana/vim-textobj-user' -- Allows you to create custom text objects (used in vim-textobj-line).
    use 'mzlogin/vim-markdown-toc' -- Markdown Table of Contents.
    use 'nanotee/zoxide.vim' -- Use zoxide to quickly jump to directories.
    use 'pechorin/any-jump.nvim' -- Go to definition that doesn't require a language server.
    use 'puremourning/vimspector' -- Multi-language debugger using the VSCode Debug Adapter Protocol.
    use 'rust-lang/rust.vim' -- Rust language bindings.
    use 'simnalamburt/vim-mundo' -- Graphical undo tree (updated fork of Gundo).
    use 'tpope/vim-abolish' -- Work with variants of words (replacing, capitalizing etc).
    use 'tpope/vim-commentary' -- Autodetect comment type for lang.
    use 'tpope/vim-fugitive' -- Git commands in vim.
    use 'tpope/vim-repeat' -- Allows you to use . with plugin mappings.
    use 'tpope/vim-rhubarb' -- GitHub support.
    use 'tpope/vim-rsi' -- Insert/commandline readline-style mappings, e.g. C-a for beginning of line.
    use 'tpope/vim-surround' -- Add/mod/remove surrounding chars.
    use 'tpope/vim-unimpaired' -- [ and ] mappings (help unimpaired).
    use {'neoclide/coc.nvim', branch = 'release'} -- Language Server with VSCode Extensions.
    use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'} -- Treesitter syntax highlighting.
    use {'subnut/nvim-ghost.nvim', run = ':call nvim_ghost#installer#install()'} -- Edit browser text areas in Neovim (:h ghost).
    use {'~/.local/share/fzf', as = 'fzf', run = './install --bin'} -- :h fzf

    -- Plugins where order is important (last one wins).

    use 'sheerun/vim-polyglot' -- Syntax files for a large number of different languages.
    use 'tpope/vim-sleuth' -- Automatically detect indentation.
    use 'editorconfig/editorconfig-vim' -- Parse .editorconfig files (https://editorconfig.org/).

end)

pcall(require, "wrk-init-nvim") -- Load work config if present.

if packer_bootstrap then
    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    require('packer').sync()

    -- If we just bootstrapped the package manager, our packages won't be available, so skip their setup.
    vim.cmd([[
      augroup packer_bootstrap_config
        autocmd!
        autocmd User PackerComplete exec 'source '. stdpath('config') . '/lua/init-nvim.lua'
      augroup end
    ]])
    return
end

-- }}} Package Manager Setup

-- {{{ Global Variables

-- Extensions (plugins) for CoC language client.
vim.g.coc_global_extensions = {
    'coc-actions', 'coc-ccls', 'coc-clangd', 'coc-css', 'coc-diagnostic',
    'coc-dictionary', 'coc-emoji', 'coc-eslint', 'coc-go', 'coc-groovy',
    'coc-highlight', 'coc-html', 'coc-java', 'coc-json', 'coc-lua',
    'coc-prettier', 'coc-python', 'coc-rust-analyzer', 'coc-snippets',
    'coc-solargraph', 'coc-sourcekit', 'coc-svg', 'coc-syntax', 'coc-tabnine',
    'coc-tsserver', 'coc-vetur', 'coc-word', 'coc-yaml'
}

-- }}} Global Variables

-- {{{ Package Setup

-- Set up Treesitter languages.
require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained",
    highlight = {enable = true},
    indent = {enable = true}
}

-- https://github.com/ggandor/lightspeed.nvim
--   s|S char1 (char2|shortcut)? (<tab>|<s-tab>)* label?
-- (in Operator-pending mode the search is invoked with z/Z not s/S)
-- `:h lightspeed` for more info.
require'lightspeed'.setup {
    jump_to_first_match = true,
    jump_on_partial_input_safety_timeout = 400,
    -- This can get _really_ slow if the window has a lot of content,
    -- turn it on only if your machine can always cope with it.
    highlight_unique_chars = false,
    -- Makes the search area more obvious.
    grey_out_search_area = true,
    -- If you have '                  ', only match the first '  '.
    match_only_the_start_of_same_char_seqs = true,
    -- How many matches to show for s/f/t.
    limit_ft_matches = 40,
    x_mode_prefix_key = '<c-x>',
    -- Allow seeing that you can match on newlines with s<char><Enter>
    substitute_chars = {['\r'] = '¬'},
    -- Labels to set for jumps.
    labels = {
        "s", "f", "n", "/", "u", "t", "q", "m", "S", "F", "G", "H", "L", "M",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "N", "U", "R", "Z",
        "T", "Q", "'", "-", "?", "\"", "`", "+", "!", "(", ")", "\\", "[", "]",
        ":", "|", "<", ">", "W", "E", "Y", "I", "O", "P", "A", "D", "J", "K",
        "X", "C", "V", "B", ".", ",", "w", "e", "r", "y", "i", "o", "p", "a",
        "d", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b"
    },
    cycle_group_fwd_key = nil,
    cycle_group_bwd_key = nil
}

vim.cmd 'colorscheme gib'
vim.cmd 'command! PU PackerSync' -- :PU updates Packer plugin configuration.

-- }}} Package Setup

-- {{{ Package Autocommands
vim.cmd([[
  augroup packer_user_config
    autocmd!
    " Update my colorscheme when I edit it.
    autocmd BufWritePost gib.vim source <afile>
    " Pull plugin updates when I edit this file.
    autocmd BufWritePost init-nvim.lua source <afile> | PackerCompile

    " Highlight symbol under cursor on CursorHold (show other instances of current word).
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Update signature help on jump placeholder (show function signature when you jump to it).
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end
]])
-- }}} Package Autocommands

-- vim: foldmethod=marker
