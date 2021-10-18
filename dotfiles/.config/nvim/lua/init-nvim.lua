-- Lua core configuration for neovim.
-- Docs:
--   https://vonheikemen.github.io/devlog/tools/configuring-neovim-using-lua/
--   https://neovim.io/doc/user/lua.html
--   https://github.com/nanotee/nvim-lua-guide
--
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
    instant_repeat_fwd_key = ';',
    instant_repeat_bwd_key = ',',
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
