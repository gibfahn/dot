-- Keyboard Mappings for Hyper mode
-- Keycodes: https://www.hammerspoon.org/docs/hs.keycodes.html#map
--
-- The full Hyper modifier-layers table lives in the work dotfiles: dotfiles-apple/.config/hammerspoon/wrk.lua. Update
-- that table whenever you change a binding here or there.

local appLauncher = require("app-launcher")
local statusMessage = require("status-message")
local log = hs.logger.new("hyper.lua", "debug")
log.d("Loading module")

-- {{{ Helper Functions

AlertIfSecureInputEnabled = function()
  if hs.eventtap.isSecureInputEnabled() then
    hs.notify
      .new({
        title = "Hammerspoon",
        informativeText = "⚠️  Secure input is enabled.",
        otherButtonTitle = "Okay",
      })
      :send()
  end
end
-- Actually run the alert.
AlertIfSecureInputEnabled()

-- Finds Webex and returns {currentApp, webexApp}, or {nil, nil} with a notification on failure.
local function focusWebex(message)
  local current = hs.application.frontmostApplication()
  local webexApp = hs.application.find("Webex")
  log.df("Current app: %s", current)
  log.df("Webex app: %s", webexApp)
  if not webexApp then
    statusMessage.new("⚠ " .. message .. " failed: couldn't find Webex app"):notify()
    return nil, nil
  end
  return current, webexApp
end

-- Run a webex menu action that isn't global by switching to Webex, running the action, and switching back.
-- This doesn't seem to work when sharing one's screen unfortunately.
local function webexMenuAction(menuItem, message, switchBack)
  local current, webexApp = focusWebex(message)
  if not webexApp then
    return
  end

  local webexWindow = nil
  for windowIndex, window in ipairs(webexApp:allWindows()) do
    log.df("Checking Webex window %s: %s", windowIndex, window)
    window:focus()
    if webexApp:findMenuItem(menuItem).enabled then
      webexWindow = window
      break
    end
  end

  if not webexWindow then
    statusMessage.new("⚠ " .. message .. " failed: failed to find menu item: " .. menuItem):notify()
    return
  end

  if not webexApp:selectMenuItem(menuItem) then
    statusMessage.new("⚠ " .. message .. " failed: failed to run menu item: " .. menuItem):notify()
    return
  end

  if switchBack then
    if not current:activate() then
      statusMessage.new("⚠ " .. message .. " failed: failed to switch back"):notify()
      return
    end
  end

  statusMessage.new(message .. " success"):notify()
end

-- Run a webex keystroke action by switching to Webex, sending the key, and switching back.
local function webexKeyAction(mods, key, message, switchBack)
  local current, webexApp = focusWebex(message)
  if not webexApp then
    return
  end
  if not current then
    return
  end

  webexApp:activate()
  -- Wait before and after we do the keyboard shortcut to ensure it actually sticks.
  -- Otherwise the keyboard shortcut isn't applied to the right place.
  hs.timer.doAfter(0.1, function()
    hs.eventtap.keyStroke(mods, key)
    if switchBack then
      hs.timer.doAfter(0.1, function()
        if not current:activate() then
          statusMessage.new("⚠ " .. message .. " failed: failed to switch back"):notify()
          return
        end
      end)
    end
    statusMessage.new(message .. " success"):notify()
  end)
end

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

-- Launch specified app, switch focus to app, or rotate to next window of app, or next app.
-- Modified version of <https://rakhesh.com/coding/using-hammerspoon-to-switch-apps/>
local function switchToApp(apps)
  log.df("Opening or focusing apps: [%s]", table.concat(apps, ", "))
  if #apps == 1 then
    log.df("Only one app in list, switching to %s", apps[1])
    hs.application.launchOrFocus(apps[1])
    return
  end

  local currentIndex = nil
  -- See https://www.hammerspoon.org/docs/hs.window.html#application
  -- This gives the path - /path/to/<application>.app.
  local focusedWindow = hs.window.focusedWindow()
  if focusedWindow ~= nil then
    local focusedWindowApplication = focusedWindow:application()
    if focusedWindowApplication ~= nil then
      local focusedWindowPath = focusedWindowApplication:path()
      if focusedWindowPath ~= nil then
        -- Extract <application> from the path. This isn't the same as the name the application gives
        -- itself.
        local focusedApp = string.lower(string.gsub(focusedWindowPath, ".*/([^/]*).app", "%1"))

        for i, v in ipairs(apps) do
          if string.lower(v) == focusedApp then
            currentIndex = i
            break
          end
        end
        log.df("Focused app: %s, currentIndex: %s, focusedWindowPath: %s", focusedApp, currentIndex, focusedWindowPath)
      end
    end
  end

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

DefaultBrowserBundleID = (function()
  local handlers = hs.plist.read(
    os.getenv("HOME") .. "/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
  )
  if handlers == nil or handlers.LSHandlers == nil then
    return "com.apple.safari"
  end

  -- Use the default web browser.
  for _, handler in ipairs(handlers.LSHandlers) do
    -- log.df("Handler: %s", handler.LSHandlerRoleAll)
    -- Ignore Velja as it's not a real browser <https://sindresorhus.com/velja>
    if handler.LSHandlerURLScheme == "https" and handler.LSHandlerRoleAll ~= "com.sindresorhus.velja" then
      return handler.LSHandlerRoleAll
    end
  end

  -- If we didn't find a matching handler, default to Safari.
  return "com.apple.safari"
end)()

-- }}} Helper Functions

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

-- {{{ Hyper-<key> -> Launch apps
local hyperModeAppMappings = {
  { key = "/", app = "Finder" },
  { key = "a", app = "Activity Monitor" },
  { key = "b", app = "Safari", mods = { "shift" } },
  { key = "c", app = "Slack" },
  { key = "c", app = "Slack Web", mods = { "shift" } },
  { key = "o", app = "cmux", mods = { "shift" } },
  { key = "f", app = "Firefox" },
  { key = "k", app = "Calendar" },
  { key = "m", app = "Mail" },
  { key = "m", app = "Reminders", mods = { "shift" } },
  { key = "s", app = "Spotify" },
  { key = "t", app = "Ghostty", mods = { "shift" } },
  { key = "t", app = "kitty" },
  { key = "w", app = "WorkFlowy" },
  { key = "x", app = "Messenger", mods = { "shift" } },
  { key = "x", app = "Messages" },
  { key = "z", app = "Webex" },
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

-- {{{ Hyper-b -> launch default browser.
HyperMode:bind({}, "b", function()
  log.d("Opening default browser " .. DefaultBrowserBundleID)
  hs.application.launchOrFocusByBundleID(DefaultBrowserBundleID)
end)
-- }}} Hyper-b -> launch default browser.

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
HyperMode:bind({ "alt" }, "m", function()
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

-- {{{ Hyper-o -> App Launcher
HyperMode:bind({}, "o", function()
  HyperMode:exit()
  appLauncher.toggle()
end)
-- }}} Hyper-o -> App Launcher

-- {{{ Hyper-p -> Screenshot of selected area to clipboard.
HyperMode:bind({}, "p", function()
  hs.eventtap.keyStroke({ "cmd", "ctrl", "shift" }, "4")
end)
-- }}} Hyper-p -> Screenshot of selected area to clipboard.

-- {{{ Hyper-⌥-z -> Force Quit Webex
-- Quit webex without spending an age trying to find the button.
HyperMode:bind({ "alt" }, "z", function()
  KillAll({ "Webex" })
end)
-- }}} Hyper-⌥-z -> Force Quit Webex

-- {{{ Hyper-; -> lock screen
HyperMode:bind({}, ";", hs.caffeinate.lockScreen)
-- }}} Hyper-; -> lock screen

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

-- {{{ Hyper-⇧-Enter -> Open selected URL.
HyperMode:bind({ "shift" }, "return", function()
  log.d("Opening selected URL.")
  hs.eventtap.keyStroke({ "cmd" }, "c") -- Copy the current selection.
  -- Allow some time for the command+c keystroke to fire asynchronously before
  -- we try to read from the clipboard.
  hs.timer.doAfter(0.2, function()
    local selection = hs.pasteboard.getContents():gsub("%s*$", "")
    hs.task
      .new("/usr/bin/open", function(exitCode, stdOut, stdErr)
        hs.notify
          .new({
            title = "Opening Selected URL...",
            subTitle = selection,
            informativeText = exitCode .. " " .. stdOut,
            stdErr,
          })
          :send()
      end, { selection })
      :start()
  end)
end)
-- }}} Hyper-⇧-Enter -> Open selected URL.

-- {{{ Hyper-Space -> Start Dictation.
HyperMode:bind({}, "space", function()
  log.d("Starting dictation...")
  hs.eventtap.keyStroke({ "cmd", "alt", "ctrl", "shift" }, "d")
end)
-- }}} Hyper-Space -> Start Dictation.

-- {{{ Hyper-⇧-. (Hyper >) -> Markdown quote clipboard and re-copy.
HyperMode:bind({ "shift" }, ".", function()
  log.d("Quoting clipboard contents and re-copying...")
  local text = hs.pasteboard.getContents()
  text = text:gsub("\n", "\n>")
  text = ">" .. text
  hs.pasteboard.setContents(text)
end)
-- }}} Hyper-⇧-. (Hyper >) -> Markdown quote clipboard and re-copy.

--- {{{ Hyper-. -> Mute / unmute Webex
HyperMode:bind({}, ".", function()
  log.d("Muting/Unmuting Webex...")
  -- Assumes you already bound this as a global shortcut in Webex.
  hs.eventtap.keyStroke({ "cmd", "alt", "ctrl", "shift" }, "m")
end)
--- }}} Hyper-. -> Mute / unmute Webex

--- {{{ Hyper-⌥-. -> Raise / lower hand
HyperMode:bind({ "alt" }, ".", function()
  log.d("Raising/lowering hand...")
  webexMenuAction("Raise or lower your hand", "✋ raise/lower hand", true)
end)
--- }}} Hyper-⌥-. -> Raise / lower hand

--- {{{ Hyper-, -> Start / stop video
HyperMode:bind({}, ",", function()
  log.d("Starting/Stopping Webex video...")
  webexKeyAction({ "ctrl", "shift" }, "v", "📹 video toggle", false)
end)
--- }}} Hyper-, -> Start / stop video

--- {{{ Hyper-⌥-, -> Share content
HyperMode:bind({ "alt" }, ",", function()
  log.d("Sharing Webex content...")
  webexMenuAction("Share content", "⛶ share content", false)
end)
--- }}} Hyper-⌥-, -> Share content

-- vim: foldmethod=marker
