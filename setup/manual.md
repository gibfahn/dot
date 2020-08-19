# Manual Setup

## macOS

### PreReqs

Before you can run the macOS setup for the first time, you need to do the
following:

- Install the Xcode Command Line Tools:
  - Open `Terminal.app` and run `git`, follow prompts to install.
- Set up relevant ssh/gpg keys.

### System Preferences:

- `View` (menu bar) -> `Organise Alphabetically`
- `Touch ID` -> Add other fingerprints
- `Software Update` -> `Automatically keep my mac up to date`
- `Keyboard`:
  - `Shortcuts`
    - `Services` -> remove mappings from `man Page` shortcuts
  - `Input Sources` -> add `Colemak`
- `Sharing`:
  - Tick the `Screen Sharing` checkbox.
  - `Computer Name` -> new hostname (e.g. `GibWrkMBP2019`, `EveMBP2018`)
- `Users & Groups` -> `Login Options` -> `Show Input menu in login window`
- Security & Privacy:
  - Privacy -> Full Disk Access -> Add Terminal.app and Kitty
  - FileVault -> Turn on FileVault


### Sudo with TouchID

To use TouchID for auth you simply need to add a single line to `/etc/pam.d/sudo`:

```shell
# Inserts `auth       sufficient     pam_tid.so` on line 2 of /etc/pam.d/sudo
sudo gsed -i "2iauth       sufficient     pam_tid.so" /etc/pam.d/sudo
```

### Keyboard Layout on boot

If it doesn't boot to Colemak, run:

```shell
sudo cp ~/Library/Preferences/com.apple.HIToolbox.plist /Library/Preferences/
sudo chmod 644 /Library/Preferences/com.apple.HIToolbox.plist
```

### Mail

- Preferences
  - Viewing
    - Show Message Headers -> Custom -> List-ID, Message-ID, X-Member-Count
    - Show most recent messages at the top

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

### Sogou Pinyin

- Change Sogou keyboard layout to Colemak:
  - Change to Sogou with <kbd>Ctrl</kbd><kbd>Space</kbd>.
  - ⚙ -> 偏好号设置 -> 按键 -> 键盘布局 -> 其他键盘 -> Colemak

### Autostart

Remove things that shouldn't need to auto-start.

- `System Preferences` -> `Users & Groups` -> `Login Items`

[Paragon for NTFS]: https://www.seagate.com/gb/en/support/software/paragon/
[`paragon-ntfs`]: https://formulae.brew.sh/cask/paragon-ntfs
[sVim]: https://github.com/flippidippi/sVim
