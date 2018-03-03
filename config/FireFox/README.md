# Setting up FireFox

See [this link][Hide Native Tabs]

## Steps

1. Find your profile folder
  - macOS: `~/Library/Application Support/Firefox/Profiles/*default*/`
  - Linux: `~/.mozilla/firefox/`
2. Copy `userChrome.css` into that folder:
  ```js
  cp ./userChrome.css <profile folder>/
  ```
3. Restart Firefox
4. Install TreeStyleTabs Addon
5. Paste `TreeStyleTabs.css` into the textbox in the Addon settings (`about:/addons`).

[Hide Native Tabs]: https://www.reddit.com/r/firefox/comments/736cji/how_to_hide_native_tabs_in_firefox_57_tree_style/
