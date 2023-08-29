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
  'ggandor/leap.nvim', -- Quickest way to jump to any char on the screen (alternative to easymotion/sneak/hop/lightspeed/pounce).
  'gibfahn/vim-gib', -- Use vim colorscheme.
  'honza/vim-snippets', -- Work around https://github.com/neoclide/coc-snippets/issues/126 .
  'itchyny/lightline.vim', -- Customize statusline and tabline.
  'junegunn/fzf.vim', -- Try :Files, :GFiles? :Buffers :Lines :History :Commits :BCommits
  'junegunn/vim-peekaboo', -- Pop up register list when pasting/macroing.
  'kana/vim-operator-user', -- Make it easier to define operators.
  { 'kana/vim-textobj-line', dependencies = {'kana/vim-textobj-user'}, }, -- Adds `il` and `al` text objects for current line.
  'kana/vim-textobj-user', -- Allows you to create custom text objects (used in vim-textobj-line).
   -- use 'puremourning/vimspector', -- Multi-language debugger using the VSCode Debug Adapter Protocol.
  'sedm0784/vim-resize-mode', -- Continuous resizing.
  'simnalamburt/vim-mundo', -- Graphical undo tree (updated fork of Gundo).
  'tpope/vim-commentary', -- Autodetect comment type for lang.
  'tpope/vim-fugitive', -- Git commands in vim.
  'tpope/vim-repeat', -- Allows you to use . with plugin mappings.
  'tpope/vim-rhubarb', -- GitHub support.
  'tpope/vim-rsi', -- Insert/commandline readline-style mappings, e.g. C-a for beginning of line.
  'tpope/vim-surround', -- Add/mod/remove surrounding chars.
  'tpope/vim-unimpaired', -- [ and ] mappings (help unimpaired).
  { 'cespare/vim-toml', ft = 'toml' }, -- Toml syntax highlighting.
  { 'godlygeek/tabular', cmd = 'Tabularize' }, -- Make tables easier (:help Tabular).
  { 'moll/vim-bbye', cmd = 'Bdelete' }, -- Delete buffer without closing split.
  { 'mzlogin/vim-markdown-toc', ft = 'markdown', cmd = 'GenTocGFM' }, -- Markdown Table of Contents.
  { 'nanotee/zoxide.vim', cmd = 'Zi' }, -- Use zoxide to quickly jump to directories.
  { 'neoclide/coc.nvim', branch = 'release' }, -- Language Server with VSCode Extensions.
  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' }, -- Treesitter syntax highlighting.
  { 'pechorin/any-jump.nvim', cmd = 'AnyJump' }, -- Go to definition that doesn't require a language server.
  { 'rust-lang/rust.vim', ft = 'rust' }, -- Rust language bindings.
  { 'sheerun/vim-polyglot', config = function() vim.opt.shortmess:remove("A") end }, -- Syntax files for languages + work around <https://github.com/sheerun/vim-polyglot/issues/765>.
  { 'subnut/nvim-ghost.nvim', build = ':call nvim_ghost#installer#install()' }, -- Edit browser text areas in Neovim (:h ghost). Disabled until https://github.com/subnut/nvim-ghost.nvim/issues/50 is fixed.
  { 'tpope/vim-abolish', cmd = { 'Abolish', 'Subvert', 'S' } }, -- Work with variants of words (replacing, capitalizing etc).
  { 'tpope/vim-sleuth', dependencies = {'vim-polyglot'} }, -- Automatically detect indentation.
  { dir = '~/.local/share/fzf', name = 'fzf', build = './install, --bin' }, -- :h fzf

}
