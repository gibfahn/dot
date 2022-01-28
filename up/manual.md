# Manual Setup

## macOS

### PreReqs

Before you can run the macOS setup for the first time, you need to do the
following:

- Install the Xcode Command Line Tools:
  - Open `Terminal.app` and run `git`, follow prompts to install.
- Set up relevant ssh/gpg keys.

### System Preferences:

Set the computer name (needs restart to take effect):

```shell
# e.g. scutil --set LocalHostName "$USER-MBP-$year"
scutil --set LocalHostName
```

- `Touch ID` -> Add other fingerprints
- `Keyboard`:
  - `Shortcuts`
    - `Services` -> remove mappings from `man Page` shortcuts
  - `Input Sources` -> add `Colemak`
- `Sharing`:
  - Tick the `Screen Sharing` checkbox.
- Security & Privacy:
  - Privacy -> Full Disk Access -> Add Terminal.app and Kitty
  - FileVault -> Turn on FileVault

### Autostart

Remove things that shouldn't need to auto-start.

- `System Preferences` -> `Users & Groups` -> `Login Items`

### NTFS

If you want to write to NTFS-formatted drives (i.e. most external hard drives), then you need third-party software.

Seagate provides [Paragon for NTFS][], which seems to be the full version, unlike the [`paragon-ntfs`][] brew cask, which is a trial version.

After installing:

- click on the icon in the menu bar
- click "Open Application"
- Open Preferences
- `NTFS for Mac Menu` -> `OFF`
- Untick `Launch on System Startup`

[Paragon for NTFS]: https://www.seagate.com/gb/en/support/software/paragon/
[`paragon-ntfs`]: https://formulae.brew.sh/cask/paragon-ntfs
[sVim]: https://github.com/flippidippi/sVim
