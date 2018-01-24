/*
 * Chrome/Firefox SurfingKeys mappings. Set by:
 *  - go to chrome://extensions or about:addons
 *  - SurfingKeys Preferences (after installing it)
 *  - Advanced mode
 *  - Load settings from: ~/code/dot/config/SurfingKeys.js
 *  - Save
 *  - Path should autocomplete to file:///path/to/SurfingKeys.js
 *
 *  For more info see: https://github.com/brookhong/Surfingkeys#edit-your-own-settings
*/

/*
 * My mappings
 */

Hints.characters = 'qwertyuiopasdfghjklzxcvbnm'; // Use whole alphabet for Link Hints (f).
settings.scrollStepSize = 140; // Double scroll size (for j/k), default 70.

aceVimMap('kj', '<Esc>', 'insert'); // Remap kj to Esc in the insert mode Ace editor.

map('<Ctrl-s>', '<Alt-s>'); // Map Ctrl-i to toggle SurfingKeys in normal mode.

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
