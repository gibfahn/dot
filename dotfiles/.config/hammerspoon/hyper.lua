-- Keyboard Mappings for Hyper mode
-- Keycodes: https://www.hammerspoon.org/docs/hs.keycodes.html#map
--   ## Colemak Layout
--   ,---,---,---,---,---,   ,---,---,---,---,---,
--   | 1 | 2 | 3 | 4 | 5 |   | 6 | 7 | 8 | 9 | 0 |
--   |---|---|---|---|---|   |---|---|---|---|---|---,
--   | q | w | f | p | g |   | j | l | u | y | ; | - |
--   |---|---|---|---|---|   |---|---|---|---|---|---|
--   | a | r | s | t | d |   | h | n | e | i | o | ' |
--   |---|---|---|---|---|   |---|---|---|---|---|---|
--   | z | x | c | v | b |   | k | m | , | . | / | \ |
--   '---'---'---'---'---'   '---'---'---'---'---'---'
--   ## Mapped (inc work mappings).
--   ,---,---,---,---,---,   ,---,---,---,---,---,
--   | ✓ | ✓ | ✓ | ✓ | ✓ |   | ✓ | ✓ | ✓ | ✓ | ✓ |
--   |---|---|---|---|---|   |---|---|---|---|---|---,
--   | ✓ | ✓ | ✓ | ✓ | g |   | ✓ | ✓ | ✓ | ✓ | ✓ | - |
--   |---|---|---|---|---|   |---|---|---|---|---|---|
--   | ✓ | ✓ | ✓ | ✓ | ✓ |   | ✓ | ✓ | ✓ | ✓ | o | ✓ |
--   |---|---|---|---|---|   |---|---|---|---|---|---|
--   | z | ✓ | ✓ | ✓ | ✓ |   | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
--   '---'---'---'---'---'   '---'---'---'---'---'---'
local message = require("status-message")
local log = hs.logger.new("hyper.lua", "debug")
log.d("Loading module")

local home_dir = os.getenv("HOME")

if hs.eventtap.isSecureInputEnabled() then
  hs.notify
    .new({
      title = "Hammerspoon",
      informativeText = "⚠️  Secure input is enabled.",
      otherButtonTitle = "Okay",
    })
    :send()
end

-- {{{ F17 -> Hyper Key

-- A global variable for Hyper Mode
HyperMode = hs.hotkey.modal.new({})

-- Enter Hyper Mode when F17 (right option key) is pressed
local pressedF17 = function()
  HyperMode:enter()
end

-- Leave Hyper Mode when F17 (right option key) is released.
local releasedF17 = function()
  HyperMode:exit()
end

-- Bind the Hyper key
hs.hotkey.bind({}, "F17", pressedF17, releasedF17)

-- }}} F17 -> Hyper Key

-- {{{ Generally useful functions

-- Kill all instances of something.
-- Args:
--   killArgs: string value of thing to kill, or an array if multiple arguments needed.
--     e.g. killAll('Dock'), killAll({'-9', 'docker'})
--   sudo: optionally set to true to run with `sudo killall`
--     e.g. killAll('Dock', {sudo=true})
KillAll = function(killArgs, opts)
  HyperMode:exit()
  local sudo = opts and opts.sudo or false
  if type(killArgs) ~= "table" then
    killArgs = { killArgs }
  end
  -- -v means print what we kill, use -s in your command to print but not kill.
  table.insert(killArgs, 1, "-v")
  local command = "/usr/bin/killall"
  if sudo then
    table.insert(killArgs, 1, command)
    command = "/usr/bin/sudo"
  end
  log.d("Running killAll command: " .. command .. " " .. table.concat(killArgs, " "))
  hs.task
    .new(command, function(exitCode, stdOut, stdErr)
      hs.notify
        .new({
          title = "Killed all " .. table.concat(killArgs, " ") .. "...",
          informativeText = exitCode .. " " .. stdOut .. " " .. stdErr,
        })
        :send()
    end, killArgs)
    :start()
end

-- }}} Generally useful functions

-- Launch specified app, switch focus to app, or rotate to next window of app, or next app.
-- Modified version of <https://rakhesh.com/coding/using-hammerspoon-to-switch-apps/>
local function switchToApp(apps)
  log.df("Opening or focusing apps: [%s]", table.concat(apps, ", "))
  if #apps == 1 then
    log.df("Only one app in list, switching to %s", apps[1])
    hs.application.launchOrFocus(apps[1])
    return
  end

  -- See https://www.hammerspoon.org/docs/hs.window.html#application
  -- This gives the path - /path/to/<application>.app.
  local focusedWindowPath = hs.window.focusedWindow():application():path()
  -- Extract <application> from the path. This isn't the same as the name the application gives
  -- itself.
  local focusedApp = string.lower(string.gsub(focusedWindowPath, ".*/([^/]*).app", "%1"))

  local currentIndex = nil
  for i, v in ipairs(apps) do
    if string.lower(v) == focusedApp then
      currentIndex = i
      break
    end
  end
  log.df("Focused app: %s, currentIndex: %s, focusedWindowPath: %s", focusedApp, currentIndex, focusedWindowPath)

  -- If none of the apps in the list are currently focused, select the first app from the list.
  if currentIndex == nil then
    hs.application.launchOrFocus(apps[1])
    return
  end

  -- The next app in the list after the currently found app.
  local newIndex = currentIndex + 1
  if currentIndex == #apps then
    newIndex = 1
  end
  -- An app in the list is currently focused, so select the next app in the list
  hs.application.launchOrFocus(apps[newIndex])
end

-- {{{ Hyper-<key> -> Launch apps
local hyperModeAppMappings = {
  -- Keys used in work config: r, shift-r
  { key = "/", app = "Finder" },
  { key = "a", app = "Activity Monitor" },
  { key = "c", apps = { "Slack", "Slack Web" } },
  { key = "f", app = "Firefox" },
  { key = "k", app = "Calendar" },
  { key = "m", app = "Mail" },
  { key = "s", app = "Spotify" },
  { key = "t", app = "kitty" },
  { key = "w", app = "Webex", mods = { "shift" } },
  { key = "w", app = "WorkFlowy" },
  { key = "x", app = "Messenger", mods = { "alt" } },
  { key = "x", app = "Messages" },
}
-- Add in wrk mappings if present.
if WrkHyperModeAppMappings ~= nil then
  for _, val in ipairs(WrkHyperModeAppMappings) do
    table.insert(hyperModeAppMappings, val)
  end
end

for _, mapping in ipairs(hyperModeAppMappings) do
  local apps = mapping.apps
  if apps == nil then
    apps = { mapping.app }
  end
  HyperMode:bind(mapping.mods, mapping.key, function()
    switchToApp(apps)
  end)
end
-- }}} Hyper-<key> -> Launch apps

-- Hyper-b -> launch default browser.
DefaultBrowserBundleID = (function()
  local handlers = hs.plist.read(
    os.getenv("HOME") .. "/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
  )
  if handlers == nil or handlers.LSHandlers == nil then
    return "com.apple.safari"
  end
  for _, handler in ipairs(handlers.LSHandlers) do
    if handler.LSHandlerURLScheme == "https" then
      return handler.LSHandlerRoleAll
    end
  end
  -- If we didn't find a matching handler, default to Safari.
  return "com.apple.safari"
end)()
HyperMode:bind({}, "b", function()
  log.d("Opening default browser " .. DefaultBrowserBundleID)
  hs.application.launchOrFocusByBundleID(DefaultBrowserBundleID)
end)
-- }}} Global microphone muting hotkeys.

-- {{{ Global microphone muting hotkeys.
local messageMuting = message.new("muted 🎤")
local messageHot = message.new("hot 🎤")
local messageUnmutable = message.new(" ⚠️  WARNING: 🎤 does not support muting! ⚠️")

-- Hyper-, -> tap to mute.
HyperMode:bind({}, ",", function()
  local device = hs.audiodevice.defaultInputDevice()
  local unmuteSuccess = device:setInputMuted(true)
  if unmuteSuccess then
    messageMuting:notify()
  else
    messageUnmutable:notify()
  end
end)

-- Hyper-. -> tap to unmute mic.
HyperMode:bind({}, ".", function()
  log.d("Unmuting the mic...")
  local device = hs.audiodevice.defaultInputDevice()
  local muteSuccess = device:setInputMuted(false)

  if muteSuccess then
    messageHot:notify()
  else
    messageUnmutable:notify()
  end

  local inputVolume = device:inputVolume()
  -- Error if this failed (e.g. Webex didn't process the new volume).
  if inputVolume ~= 100 then
    messageHot = message.new(" ⚠️ at " .. inputVolume .. "% 🎤"):notify()
  end
end)
-- }}} Global microphone muting hotkeys.

-- {{{ Hyper-; -> lock screen
HyperMode:bind({}, ";", hs.caffeinate.lockScreen)
-- }}} Hyper-; -> lock screen

-- {{{ Hyper-⌥-q -> Force Quit Webex
-- Quit webex without spending an age trying to find the button.
HyperMode:bind({ "alt" }, "q", function()
  KillAll({ "Webex" })
end)
-- }}} Hyper-⌥-q -> Force Quit Webex

-- {{{ Hyper-⇧-w -> Restart Wi-Fi
HyperMode:bind({ "alt" }, "w", function()
  log.d("Restarting Wi-Fi...")
  hs.notify.new({ title = "Restarting Wi-Fi..." }):send()
  hs.wifi.setPower(false)
  hs.wifi.setPower(true)
end)
-- }}} Hyper-⇧-w -> Restart Wi-Fi

-- {{{ Hyper-d -> Paste today's date.
HyperMode:bind({}, "d", function()
  log.d("Pasting today's date...")
  local date = os.date("%Y-%m-%d")
  HyperMode:exit()
  hs.eventtap.keyStrokes(date)
end)
-- }}} Hyper-d -> Paste today's date.

-- {{{ Hyper-⇧-d -> Paste today's date and time.
HyperMode:bind({ "shift" }, "d", function()
  log.d("Pasting today's date and time...")
  local date = os.date("%Y-%m-%d %H:%M:%S")
  HyperMode:exit()
  hs.eventtap.keyStrokes(date)
end)
-- }}} Hyper-⇧-d -> Paste today's date and time.

-- {{{ Hyper-⌥-m -> Format selected Message ID as link and copy to clipboard.
HyperMode:bind({ "shift" }, "m", function()
  log.d("Copying selected email message ID as a link and copying to the clipboard...")
  hs.eventtap.keyStroke({ "cmd" }, "c") -- Copy selected email message ID (e.g. from Mail.app).
  -- Allow some time for the command+c keystroke to fire asynchronously before
  -- we try to read from the clipboard
  hs.timer.doAfter(0.2, function()
    -- '<messageID>' -> 'message://%3CmessageID%3E'
    local messageID = hs.pasteboard.getContents()
    -- Remove non-printable and whitespace characters.
    messageID = messageID:gsub("[%s%G]", "")
    messageID = messageID:gsub("^<?", "message://%%3C", 1)
    messageID = messageID:gsub(">?$", "%%3E", 1)
    hs.pasteboard.setContents(messageID)
  end)
end)
-- }}} Hyper-⌥-m -> Format selected Message ID as link and copy to clipboard.

-- {{{ Hyper-⌘-m -> Hide or show the menu bar.
HyperMode:bind({ "cmd" }, "m", function()
  log.d("Toggling menu bar hide/show...")

  hs.task
    .new(home_dir .. "/bin/toggle_menu_bar", function(exitCode, stdOut, stdErr)
      hs.notify
        .new({
          title = "Toggling menu bar hide/show...",
          informativeText = exitCode .. " " .. stdOut,
          stdErr,
        })
        :send()
    end)
    :start()
end)
-- }}} Hyper-⌘-m -> Hide or show the menu bar.

-- {{{ Hyper-p -> Screenshot of selected area to clipboard.
HyperMode:bind({}, "p", function()
  hs.eventtap.keyStroke({ "cmd", "ctrl", "shift" }, "4")
end)
-- }}} Hyper-p -> Screenshot of selected area to clipboard.

-- {{{ Hyper-Enter -> Open clipboard contents.
HyperMode:bind({}, "return", function()
  log.d("Opening clipboard contents.")
  local clipboard = hs.pasteboard.getContents():gsub("%s*$", "")
  hs.task
    .new("/usr/bin/open", function(exitCode, stdOut, stdErr)
      hs.notify
        .new({
          title = "Opening Clipboard Contents...",
          subTitle = clipboard,
          informativeText = exitCode .. " " .. stdOut,
          stdErr,
        })
        :send()
    end, { clipboard })
    :start()
end)
-- }}} Hyper-Enter -> Open clipboard contents.

-- {{{ Hyper-<mods>-\ -> Quit things.
HyperMode:bind({}, "\\", function()
  local date = os.date("%Y-%m-%d %H-%M-%S")
  local frontmostApplicationName = hs.application.frontmostApplication():name()
  hs.task
    .new("/usr/bin/sudo", function(exitCode, stdOut, stdErr)
      hs.notify
        .new({
          title = "Created spindump for frontmost app...",
          subTitle = frontmostApplicationName,
          informativeText = exitCode,
          stdErr,
        })
        :send()
    end, {
      "/usr/sbin/spindump",
      "-reveal",
      "-o",
      "/Users/gib/tmp/nuke/" .. frontmostApplicationName .. " " .. date .. ".spindump.txt",
      frontmostApplicationName,
    })
    :start()
end)
HyperMode:bind({ "shift" }, "\\", function()
  KillAll("Finder")
end)
HyperMode:bind({ "alt" }, "\\", function()
  hs.task
    .new("/usr/bin/sudo", function(exitCode, stdOut, stdErr)
      hs.notify
        .new({
          title = "Sudo refreshed ...",
          informativeText = exitCode .. " " .. stdOut .. " " .. stdErr,
        })
        :send()
    end, { "--validate" })
    :start()
end)

-- {{{ Hyper-⇧-x -> Restart the touch strip.
HyperMode:bind({ "shift" }, "x", function()
  KillAll("ControlStrip")
end)
-- }}} Hyper-⇧-x -> Restart the touch strip.

-- {{{ Hyper - '>' -> Markdown quote clipboard and re-copy.
HyperMode:bind({ "shift" }, ".", function()
  log.d("Quoting clipboard contents and re-copying...")
  local text = hs.pasteboard.getContents()
  text = text:gsub("\n", "\n>")
  text = ">" .. text
  hs.pasteboard.setContents(text)
end)
-- }}} Hyper - '>' -> Markdown quote clipboard and re-copy.

-- {{{ Hyper-{h,n,e,i} -> Arrow Keys, Hyper-{j,l,u,y} -> Home,PgDn,PgUp,End
for _, hotkey in ipairs({
  { key = "h", direction = "left" },
  { key = "n", direction = "down" },
  { key = "e", direction = "up" },
  { key = "i", direction = "right" },
  { key = "j", direction = "home" },
  { key = "l", direction = "pagedown" },
  { key = "u", direction = "pageup" },
  { key = "y", direction = "end" },
}) do
  for _, mods in ipairs({
    {},
    { "cmd" },
    { "alt" },
    { "ctrl" },
    { "shift" },
    { "cmd", "shift" },
    { "alt", "shift" },
    { "ctrl", "shift" },
  }) do
    -- hs.hotkey.bind(mods, key, message, pressedfn, releasedfn, repeatfn) -> hs.hotkey object
    HyperMode:bind(mods, hotkey.key, function()
      hs.eventtap.event.newKeyEvent(mods, hotkey.direction, true):post()
    end, function()
      hs.eventtap.event.newKeyEvent(mods, hotkey.direction, false):post()
    end, function()
      hs.eventtap.event.newKeyEvent(mods, hotkey.direction, true):post()
    end)
  end
end
-- }}} Hyper-{h,n,e,i} -> Arrow Keys

-- vim: foldmethod=marker
