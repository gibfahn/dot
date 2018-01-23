" Run this with:
" nvim karabiner.json -S format_lines.vim
" to reformat the text (and minimize the diff). vim works too.
g/"from"\|"to"\|"conditions"\|"to_if_alone"\|"to_after_key_up"/normal gJ
:normal! gg=G
g/^\s\+[\[]\n/normal! kJ
g/^\s\+[\[]\n/normal! J
g/^\s\+[{]\n/normal! kJ
g/^\s\+[}]\n/normal! J
w " To test, add temp file name here.
q!
