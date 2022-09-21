# Manual Setup

Note that these are the manual steps I personally use (that I haven't yet managed to automate).
You will probably have different things you want/need to set up.

## macOS

### PreReqs

While running `up-rs` for the first time, you will need to ensure you set up gpg and ssh keys you
need in later steps.

### System Preferences:

Set the computer name (needs restart to take effect):

```shell
# e.g. name="$USER-MBP-$year"
scutil --set LocalHostName ${name:?}
scutil --set ComputerName ${name:?}
```

- `Touch ID` -> Add other fingerprints
- `Keyboard`:
  - `Shortcuts`
    - `Services` -> remove mappings from `man Page` shortcuts
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
