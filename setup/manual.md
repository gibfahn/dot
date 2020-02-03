# Manual Setup

## macOS

### PreReqs

Before you can run the macOS setup for the first time, you need to do the
following:

- Install the Xcode Command Line Tools:
  - Open `Terminal.app` and run `git`, follow prompts to install.
- Set up relevant ssh/gpg keys.

### System Preferences:

- `Touch ID` -> Add other fingerprints
- `Software Update` -> `Automatically keep my mac up to date`
- `Keyboard` -> `Shortcuts`:
  - `Screen Shots`: Swap `Save picture of selected area as file` and `Copy
    picture of selected area to the clipboard`.
  - `Input Sources` -> tick `Select the previous input source`
  - `Services` -> remove mappings from `man Page` shortcuts

### CopyQ

- `General`
  - `Vi style navigation`
  - `Autostart`
- `History` -> `Maximum number of items in history` -> `9999`
- `Notifications`:
  - `Notification position` -> `Top Right`
  - `Interval in seconds to display notifications` -> `2`
  - `Number of lines for clipboard notification` -> `5`
  - `Maximum height` -> `300`
- `Shortcuts`:
  - `Show/Hide Main Window` -> <kbd>⌘</kbd><kbd>Shift</kbd><kbd>v</kbd>
  - `Paste as Plain Text` -> <kbd>Shift</kbd><kbd>Enter</kbd>
- `Appearance` -> `Theme` -> `Dark`

### Spectacle

- <kbd>⌘</kbd><kbd>Space</kbd>`Spectacle`<kbd>Enter</kbd>
- Click on the spectacles in the Menu Bar, click Preferences
- Check the box at the bottom: `Launch Spectacle at login`

### HyperSwitch

- General:
  - Check `Run HyperSwitch in the background.`
  - Active the window switcher for `all windows` -> <kbd>⌘</kbd><kbd>Tab</kbd>
  - Check `Include windows from other screens`
- `App Switcher`
  - `App Switcher` -> `Delay activation for` -> `0` ms for both.
- `Appearance`
  - `Hide animation:` -> `None`
  - `Show HyperSwitch in` -> `the menu bar`
- `About:`
  - `Download and install updates in the background`

### Safari

- Set up [sVim][] for Safari:
  - Install sVim
  - Click the `sVim` icon by the address bar, then `Show sVimrc`
  - Paste gist ids, `Sync`, `Save`
    - `sVimrc`: `22c17d0059340e2c90c3c316b746ba8b`
    - `sVimcss`: `3cf4e6a17c85ff67d29fea37ed31963d`

- `General`
  - `Safari opens with` -> `All windows from last session`
  - `New windows open with` -> `Empty page`
  - `New tabs open with` -> `Empty page`
  - `Remove history items` -> `Manually`
- `Tabs` -> `Show website icons in tabs`
- `Advanced`
  - `Show full website address` -> Tick
  - `Press Tab to highlight each item on a webpage`
  - `Show Develop menu in menu bar`

### Kitty

- Give Kitty full disk access: `System Preferences` -> `Privacy` -> `Full Disk Access`.

### NTFS

If you want to write to NTFS-formatted drives (i.e. most external hard drives), then you need third-party software.

Seagate provides [Paragon for NTFS][], which seems to be the full version, unlike the [`paragon-ntfs`][] brew cask, which is a trial version.

After installing:

- click on the icon in the menu bar
- click "Open Application"
- Open Preferences
- `NTFS for Mac Menu` -> `OFF`
- Untick `Launch on System Startup`

### Autostart

Remove things that shouldn't need to auto-start.

- `System Preferences` -> `Users & Groups` -> `Login Items`

[Paragon for NTFS]: https://www.seagate.com/gb/en/support/software/paragon/
[`paragon-ntfs`]: https://formulae.brew.sh/cask/paragon-ntfs
[sVim]: https://github.com/flippidippi/sVim
