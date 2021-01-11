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

--   ## Mapped
--   ,---,---,---,---,---,   ,---,---,---,---,---,
--   | ✓ | ✓ | ✓ | ✓ | ✓ |   | ✓ | ✓ | ✓ | ✓ | ✓ |
--   |---|---|---|---|---|   |---|---|---|---|---|---,
--   | ✓ | ✓ | ✓ | ✓ | g |   | ✓ | ✓ | ✓ | ✓ | ✓ | - |
--   |---|---|---|---|---|   |---|---|---|---|---|---|
--   | ✓ | ✓ | ✓ | ✓ | ✓ |   | ✓ | ✓ | ✓ | ✓ | o | ' |
--   |---|---|---|---|---|   |---|---|---|---|---|---|
--   | z | ✓ | ✓ | ✓ | ✓ |   | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
--   '---'---'---'---'---'   '---'---'---'---'---'---'

local log = hs.logger.new('init.lua', 'debug')

local message = require('status-message')

-- {{{ F17 -> Hyper Key

-- A global variable for Hyper Mode
hyperMode = hs.hotkey.modal.new({})

-- Enter Hyper Mode when F17 (right option key) is pressed
pressedF17 = function() hyperMode:enter() end

-- Leave Hyper Mode when F17 (right option key) is released.
releasedF17 = function() hyperMode:exit() end

-- Bind the Hyper key
f17 = hs.hotkey.bind({}, 'F17', pressedF17, releasedF17)

-- }}} F17 -> Hyper Key

-- {{{ Hyper-<key> -> Launch apps
hyperModeAppMappings = {

  { key='/', app='Finder' },
  { key='a', app='Activity Monitor' },
  { key='b', app='Safari' },
  { key='c', app='Slack' },
  { key='f', app='Firefox Nightly' },
  { key='k', app='Calendar' },
  { key='m', app='Mail' },
  { key='r', app='Radar 8' },
  { key='s', app='Spotify' },
  { key='t', app='Kitty' },
  { key='w', app='Workflowy' },
  { key='x', app='Messenger', mods={'alt'} },
  { key='x', app='Messages' },

}
for i, mapping in ipairs(hyperModeAppMappings) do
  hyperMode:bind(mapping.mods, mapping.key, function()
    hs.application.launchOrFocus(mapping.app)
  end)
end
-- }}} Hyper-<key> -> Launch apps

-- {{{ Global microphone muting hotkeys.
local messageMuting = message.new('muted 🎤')
local messageHot = message.new('hot 🎤')

-- Hyper-, -> hold to enable mic (while held), tap to mute.
hyperMode:bind({}, ',', function()
    local device = hs.audiodevice.defaultInputDevice()
    -- TODO(gib): stop changing volume and go back to muting when Webex works.
    -- device:setInputMuted(true)
    device:setInputVolume(0)
    messageMuting:notify()
    displayStatus()
  end
)

-- Hyper-. -> tap to unmute mic.
hyperMode:bind({}, '.', function()
    local device = hs.audiodevice.defaultInputDevice()
    -- TODO(gib): stop changing volume and go back to muting when Webex works.
    -- device:setInputMuted(false)
    device:setInputVolume(100)
    messageHot:notify()
    displayStatus()
  end
)
-- }}} Global microphone muting hotkeys.

-- {{{ Hyper-; -> lock screen
hyperMode:bind({}, ';', hs.caffeinate.lockScreen)
-- }}} Hyper-; -> lock screen

-- {{{ Hyper-q -> Work setup
-- Open work apps and turn on VPN.
hyperMode:bind({}, 'q', function()
  hs.notify.new({title='Work Setup', withdrawAfter=3}):send()
  callVpn("corporate")
  appsToOpen = {
    'Activity Monitor',
    'Safari',
    'Slack',
    'Firefox Nightly',
    'Calendar',
    'Mail',
    'Radar 8',
    'Kitty',
    'Workflowy',
  }
  for _, app in ipairs(appsToOpen) do
    hs.application.launchOrFocus(app)
  end
end)
-- }}} Hyper-q -> Work setup

-- {{{ Hyper-⇧-w -> Restart Wi-Fi
hyperMode:bind({'shift'}, 'w', function()
  hs.notify.new({title='Restarting Wi-Fi...', withdrawAfter=3}):send()
  hs.wifi.setPower(false)
  hs.wifi.setPower(true)
end)
-- }}} Hyper-⇧-w -> Restart Wi-Fi

-- {{{ Hyper-d -> Paste today's date.
hyperMode:bind({}, 'd', function()
  local date = os.date("%Y-%m-%d")
  hs.pasteboard.setContents(date)
  hyperMode:exit()
  hs.eventtap.keyStrokes(date)
end)
-- }}} Hyper-d -> Paste today's date.

-- {{{ Hyper-⇧-d -> Paste today's date and time.
hyperMode:bind({'shift'}, 'd', function()
  local date = os.date("%Y-%m-%d %H:%M:%S")
  hs.pasteboard.setContents(date)
  hyperMode:exit()
  hs.eventtap.keyStrokes(date)
end)
-- }}} Hyper-⇧-d -> Paste today's date and time.

-- {{{ Hyper-⌥-d -> Paste build number.
hyperMode:bind({'alt'}, 'd', function()
  hs.task.new("/usr/bin/sw_vers", function(exitCode, stdOut, stdErr)
    hs.notify.new({title='Typing current build number', subTitle=output, informativeText=exitCode.." "..stdOut, stdErr, withdrawAfter=3}):send()
    -- Copy and type build version with trailing newline removed.
    stdOut = stdOut:gsub("%s*$", "")
    hs.pasteboard.setContents(stdOut)
    hyperMode:exit()
    hs.eventtap.keyStrokes(stdOut)
  end
  , {"-buildVersion"}):start()
end)
-- }}} Hyper-⌥-d -> Paste build number.

-- {{{ Hyper-⌥-m -> Format selected Message ID as link and copy to clipboard.
hyperMode:bind({'shift'}, 'm', function()
  hs.eventtap.keyStroke({'cmd'}, 'c') -- Copy selected email message ID (e.g. from Mail.app).
  -- Allow some time for the command+c keystroke to fire asynchronously before
  -- we try to read from the clipboard
  hs.timer.doAfter(0.2, function()
    -- '<messageID>' -> 'message://%3CmessageID%3E'
    local messageID = hs.pasteboard.getContents()
    -- Remove non-printable and whitespace characters.
    local messageID = messageID:gsub("[%s%G]", "")
    local messageID = messageID:gsub("^<?", "message://%%3C", 1)
    local messageID = messageID:gsub(">?$", "%%3E", 1)
    hs.pasteboard.setContents(messageID)
  end)
end)
-- }}} Hyper-⌥-m -> Format selected Message ID as link and copy to clipboard.

-- {{{ Hyper-p -> Screenshot of selected area to clipboard.
hyperMode:bind({}, 'p', function()
  hs.eventtap.keyStroke({'cmd', 'ctrl', 'shift'}, '4')
end)
-- }}} Hyper-p -> Screenshot of selected area to clipboard.

-- {{{ Hyper-Enter -> Open clipboard contents.
hyperMode:bind({}, 'return', function()
  local clipboard = hs.pasteboard.getContents():gsub("%s*$", "")
  hs.task.new("/usr/bin/open", function(exitCode, stdOut, stdErr)
    hs.notify.new({title='Opening Clipboard Contents...', subTitle=clipboard, informativeText=exitCode.." "..stdOut, stdErr, withdrawAfter=3}):send()
  end
  , {clipboard}):start()
end)
-- }}} Hyper-Enter -> Open clipboard contents.

-- {{{ Hyper-<mods>-\ -> Quit things.
local killAll = function(arg)
  hyperMode:exit()
  hs.task.new("/usr/bin/killall", function(exitCode, stdOut, stdErr)
    hs.notify.new({title='Killed all '..arg..'...', informativeText=exitCode.." "..stdOut.." "..stdErr, withdrawAfter=3}):send()
  end
  , {arg}):start()
end
hyperMode:bind({}, '\\', function()
  killAll("Dock")
end)
hyperMode:bind({'shift'}, '\\', function()
  killAll("Finder")
end)
hyperMode:bind({'alt'}, '\\', function()
  killAll("entangled")
end)
hyperMode:bind({'cmd'}, '\\', function()
  -- Restart WindowServer (logs you out).
  local cmd = "sudo killall -HUP WindowServer"
  hyperMode:exit()
  local output, status, _, rc = hs.execute(cmd)
  hs.notify.new({title='Restarting WindowServer...', informativeText=rc.." "..output, withdrawAfter=3}):send()
end)

-- {{{ Hyper-⇧-x -> Restart the touch strip.
hyperMode:bind({'shift'}, 'x', function()
  killAll("ControlStrip")
end)
-- }}} Hyper-⇧-x -> Restart the touch strip.

-- {{{ Hyper-<mods>-v -> Connect to VPN
callVpn = function(arg)
  hs.task.new(os.getenv("HOME").."/bin/vpn", function(exitCode, stdOut, stdErr)
    hs.notify.new({title='VPN '..arg..'...', informativeText=exitCode.." "..stdOut.." "..stdErr, withdrawAfter=3}):send()
  end
  , {arg}):start()
end
hyperMode:bind({}, 'v', function()
  callVpn("corporate")
end)
hyperMode:bind({'shift'}, 'v', function()
  callVpn("off")
end)
hyperMode:bind({'cmd'}, 'v', function()
  callVpn("dc")
end)
-- }}} Hyper-<mods>-v -> Connect to VPN

-- {{{ Hyper-{h,n,e,i} -> Arrow Keys, Hyper-{j,l,u,y} -> Home,PgDn,PgUp,End
local fastKeyStroke = function(modifiers, character, isdown)
  -- log.d('Sending:', modifiers, character, isdown)
  local event = require("hs.eventtap").event
  event.newKeyEvent(modifiers, character, isdown):post()
end

for i, hotkey in ipairs({
  { key='h', direction='left'},
  { key='n', direction='down'},
  { key='e', direction='up'},
  { key='i', direction='right'},
  { key='j', direction='home'},
  { key='l', direction='pagedown'},
  { key='u', direction='pageup'},
  { key='y', direction='end'},
}) do
  for j, mods in ipairs({
    {},
    {'cmd'},
    {'alt'},
    {'ctrl'},
    {'shift'},
    {'cmd', 'shift'},
    {'alt', 'shift'},
    {'ctrl', 'shift'},
  }) do
    -- hs.hotkey.bind(mods, key, message, pressedfn, releasedfn, repeatfn) -> hs.hotkey object
    hyperMode:bind(
      mods,
      hotkey.key,
      function() fastKeyStroke(mods, hotkey.direction, true) end,
      function() fastKeyStroke(mods, hotkey.direction, false) end,
      function() fastKeyStroke(mods, hotkey.direction, true) end
    )
  end
end

-- }}} Hyper-{h,n,e,i} -> Arrow Keys

-- vim: foldmethod=marker
