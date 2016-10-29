# get pathogen (package manager)
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

# Get Vim Fugitive (git manager)
cd ~/.vim/bundle
git clone git://github.com/tpope/vim-fugitive.git
vim -u NONE -c "helptags vim-fugitive/doc" -c q
# Show buffers in the tab bar
git clone https://github.com/ap/vim-buftabline.git 
# Keep cursor in middle of screen when scrolling
#git clone https://github.com/vim-scripts/scrollfix.git
# Get rust language
git clone --depth=1 https://github.com/rust-lang/rust.vim.git ~/.vim/bundle/rust.vim
# Get vim-sleuth (autodetect tab/space for file)
git clone git://github.com/tpope/vim-sleuth.git ~/.vim/bundle/vim-sleuth
# Ctrl-P (fuzzy finder)
git clone https://github.com/kien/ctrlp.vim.git ~/.vim/bundle/ctrlp
# Monokai (color scheme)
mkdir -p ~/.vim/syntax
curl https://raw.githubusercontent.com/crusoexia/vim-monokai/master/colors/monokai.vim > ~/.vim/syntax/monokai.vim
# Vim sensible (sensible defaults - needs review)
git clone git://github.com/tpope/vim-sensible.git ~/.vim/bundle/vim-sensible
# Readdir - a simpler netrw directory browser
https://github.com/ap/vim-readdir.git
