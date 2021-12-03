-- Lua core configuration for neovim.
-- Docs:
--   https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
--   https://neovim.io/doc/user/lua.html
--   https://github.com/nanotee/nvim-lua-guide
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
