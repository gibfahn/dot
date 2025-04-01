/*
 * Chrome/Firefox SurfingKeys mappings. Set by:
 *  - Install extension:
 *    - Chrome: <https://chrome.google.com/webstore/detail/surfingkeys/gfbliohnnapiefjpjlpjnehglfpaknnc>
 *    - Firefox: <https://addons.mozilla.org/en-US/firefox/addon/surfingkeys_ff/>
 *  - go to chrome://extensions or about:addons
 *    - Enable Developer mode
 *  - SurfingKeys > Details
 *    - Allow access to file URLs
 *  - Extension options
 *    - Advanced mode
 *    - Load settings from: /Users/gib/code/dot/config/SurfingKeys.js
 *    - Save
 *
 *  For more info see: https://github.com/brookhong/Surfingkeys#edit-your-own-settings
 */

/*
 * My mappings
 */

api.Hints.characters = "arstdhneioqwfpgjluy;zxcvbkm,./"; // Use whole alphabet for Link Hints (f).
settings.scrollStepSize = 140; // Double scroll size (for j/k), default 70.
api.iunmap(":"); // Disable emoji suggestions.

// aceVimMap("kj", "<Esc>", "insert"); // Remap kj to Esc in the insert mode Ace editor.

api.map("p", "<Alt-i>"); // Map p to toggle passthrough mode.

api.map("F", "gf"); // Map F to open links in a new tab (like in Vimium).

// Turn off SurfingKeys on some sites (see commented line for example of regex with multiple sites).
// settings.blacklistPattern = /.*quip-.*\.com.*|.*inbox.google.com.*|trello.com|duolingo.com|youtube.com|udemy.com/i;
settings.blacklistPattern = /.*quip-.*\.com.*/i;

/*
 * Examples:
 */

// an example to create a new mapping `ctrl-y`
// mapkey('<Ctrl-y>', 'Show me the money', function() {
//     Front.showPopup('a well-known phrase uttered by characters in the 1996 film Jerry Maguire (Escape to close).');
// });

// an example to replace `T` with `gt`, click `Default mappings` to see how `T` works.
// map('gt', 'T');

// an example to remove mapkey `Ctrl-i`
// unmap('<Ctrl-i>');

// Set theme of help page (triggered by ?).
settings.theme = `
.sk_theme {
    background: #000;
    color: #fff;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #d9dce0;
}
.sk_theme .url {
    color: #2173c5;
}
.sk_theme .annotation {
    color: #38f;
}
.sk_theme .omnibar_highlight {
    color: #fbd60a;
}
.sk_theme ul>li:nth-child(odd) {
    background: #1e211d;
}
.sk_theme ul>li.focused {
    background: #4ec10d;
}`;
