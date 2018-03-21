# Setting up FireFox

See [this link][Hide Native Tabs]

## Steps

1. Find your profile folder
  - macOS: `~/Library/Application Support/Firefox/Profiles/*default*/`
  - Linux: `~/.mozilla/firefox/`
2. Create a folder `chrome` in the profile folder:
  ```bash
  mkdir -p <profile folder>/chrome/
  ```
3. Copy `userChrome.css` from this folder into that folder:
  ```bash
  cp ./userChrome.css <profile folder>/chrome/
  ```
4. Restart Firefox
5. Install TreeStyleTabs Addon
6. Paste `TreeStyleTabs.css` into the textbox in the Addon settings (`about:addons`).

[Hide Native Tabs]: https://www.reddit.com/r/firefox/comments/736cji/how_to_hide_native_tabs_in_firefox_57_tree_style/
