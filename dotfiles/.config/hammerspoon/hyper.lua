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
local message = require('status-message')
-- local log = hs.logger.new('hyper.lua', 'debug')

-- {{{ F17 -> Hyper Key

-- A global variable for Hyper Mode
local hyperMode = hs.hotkey.modal.new({})

-- Enter Hyper Mode when F17 (right option key) is pressed
local pressedF17 = function() hyperMode:enter() end

-- Leave Hyper Mode when F17 (right option key) is released.
local releasedF17 = function() hyperMode:exit() end

-- Bind the Hyper key
hs.hotkey.bind({}, 'F17', pressedF17, releasedF17)

-- }}} F17 -> Hyper Key

-- {{{ Generally useful functions

-- Kill all instances of something.
-- Args:
--   killArgs: string value of thing to kill, or an array if multiple arguments needed.
--     e.g. killAll('Dock'), killAll({'-9', 'docker'})
--   sudo: optionally set to true to run with `sudo killall`
--     e.g. killAll('Dock', {sudo=true})
local killAll = function(killArgs, opts)
    hyperMode:exit()
    local sudo = opts and opts.sudo or false
    if (type(killArgs) ~= "table") then killArgs = {killArgs} end
    local command = "/usr/bin/killall"
    if (sudo) then
        table.insert(killArgs, 1, command)
        command = "sudo"
    end
    hs.task.new(command, function(exitCode, stdOut, stdErr)
        hs.notify.new({
            title = 'Killed all ' .. table.concat(killArgs, " ") .. '...',
            informativeText = exitCode .. " " .. stdOut .. " " .. stdErr,
            withdrawAfter = 3
        }):send()
    end, killArgs):start()
end

-- }}} Generally useful functions

-- {{{ Hyper-<key> -> Launch apps
local hyperModeAppMappings = {

    {key = '/', app = 'Finder'}, {key = 'a', app = 'Activity Monitor'},
    {key = 'b', app = 'Safari'}, {key = 'c', app = 'Slack'},
    {key = 'f', app = 'Firefox Nightly'}, {key = 'k', app = 'Calendar'},
    {key = 'm', app = 'Mail'}, {key = 'r', app = 'Radar 8'},
    {key = 's', app = 'Spotify'}, {key = 't', app = 'Kitty'},
    {key = 'w', app = 'Workflowy'},
    {key = 'x', app = 'Messenger', mods = {'alt'}},
    {key = 'x', app = 'Messages'}

}
for _, mapping in ipairs(hyperModeAppMappings) do
    hyperMode:bind(mapping.mods, mapping.key,
                   function() hs.application.launchOrFocus(mapping.app) end)
end
-- }}} Hyper-<key> -> Launch apps

-- {{{ Global microphone muting hotkeys.
local messageMuting = message.new('muted 🎤')
local messageHot = message.new('hot 🎤')
local messageUnmutable = message.new(
                             ' ⚠️  WARNING: 🎤 does not support muting! ⚠️')

-- Hyper-, -> tap to mute.
hyperMode:bind({}, ',', function()
    local device = hs.audiodevice.defaultInputDevice()
    local unmuteSuccess = device:setInputMuted(true)
    if (unmuteSuccess) then
        messageMuting:notify()
    else
        messageUnmutable:notify()
    end
end)

-- Hyper-. -> tap to unmute mic.
hyperMode:bind({}, '.', function()
    local device = hs.audiodevice.defaultInputDevice()
    local muteSuccess = device:setInputMuted(false)

    -- TODO(gib): stop this workaround once Webex handles global unmuting properly.
    -- Webex recognises that you've muted the microphone globally, and mutes
    -- itself too. However when you unmute the microphone globally, Webex
    -- doesn't notice, so you stay muted forever.
    --
    -- Work around this by doing the equivalent of Cmd-Tabbing to Webex and
    -- clicking Participant > Unmute Me.
    -- NOTE: this only works if you have already disabled the other Webex
    -- window, as each window has a different Menu bar, and the other one
    -- doesn't have an unmute option. Fortunately I don't have a use for that
    -- window anyway, so am happy to disable it by running:
    -- ```
    -- chmod -x "/Applications/Cisco Webex Meetings.app/Contents/MacOS/Cisco Webex Meetings"
    -- ```
    --
    -- This solves the unmuting problem, but there's another issue. If you mute
    -- and your mic volume is set to 100%, when you unmute Webex sets it to
    -- 25%, even if you untick "Automatically adjust volume". Manually
    -- setting it back up to 100% doesn't seem to work either, probably because
    -- Webex hasn't processed the unmuting fully when I change the volume back.
    --
    -- The below 500ms sleep seems to work for me, but if not you can try
    -- hitting this unmute hotkey twice. Sad but it seems to work.

    local webex = hs.application.find("Cisco Webex Meetings")
    if (webex ~= nil) then webex:selectMenuItem("Unmute Me") end
    if (muteSuccess) then
        messageHot:notify()
    else
        messageUnmutable:notify()
    end

    -- Sleep 0.5s before setting the volume to full again.
    hs.timer.usleep(500000)
    device:setInputVolume(100)
    local inputVolume = device:inputVolume()
    -- Error if this failed (e.g. Webex didn't process the new volume).
    if (inputVolume ~= 100) then
        messageHot =
            message.new(' ⚠️ at ' .. inputVolume .. '% 🎤'):notify()
    end
end)
-- }}} Global microphone muting hotkeys.

-- {{{ Hyper-; -> lock screen
hyperMode:bind({}, ';', hs.caffeinate.lockScreen)
-- }}} Hyper-; -> lock screen

-- {{{ Hyper-q -> Work setup
-- Open work apps and turn on VPN.
hyperMode:bind({}, 'q', function()
    hs.notify.new({title = 'Work Setup', withdrawAfter = 3}):send()
    local appsToOpen = {
        'Activity Monitor', 'Safari', 'Slack', 'Calendar', 'Mail', 'Radar 8',
        'Kitty', 'Workflowy'
    }
    for _, app in ipairs(appsToOpen) do hs.application.launchOrFocus(app) end
end)
-- }}} Hyper-q -> Work setup

-- {{{ Hyper-shift-q -> Minimal setup
-- Open work apps I actually use and turn on VPN.
hyperMode:bind({'shift'}, 'q', function()
    hs.notify.new({title = 'Minimal Work Setup', withdrawAfter = 3}):send()
    local appsToOpen = {'Activity Monitor', 'Safari', 'Kitty'}
    for _, app in ipairs(appsToOpen) do hs.application.launchOrFocus(app) end
end)
-- }}} Hyper-shift-q -> Minimal setup

-- {{{ Hyper-⌥-q -> Force Quit Webex
-- Quit webex without spending an age trying to find the button.
hyperMode:bind({'alt'}, 'q',
               function() killAll({'-9', '-m', '.*Meeting Center.*'}) end)
-- }}} Hyper-⌥-q -> Force Quit Webex

-- {{{ Hyper-⇧-w -> Restart Wi-Fi
hyperMode:bind({'shift'}, 'w', function()
    hs.notify.new({title = 'Restarting Wi-Fi...', withdrawAfter = 3}):send()
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
        hs.notify.new({
            title = 'Typing current build number',
            informativeText = exitCode .. " " .. stdOut,
            stdErr,
            withdrawAfter = 3
        }):send()
        -- Copy and type build version with trailing newline removed.
        stdOut = stdOut:gsub("%s*$", "")
        hs.pasteboard.setContents(stdOut)
        hyperMode:exit()
        hs.eventtap.keyStrokes(stdOut)
    end, {"-buildVersion"}):start()
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
        messageID = messageID:gsub("[%s%G]", "")
        messageID = messageID:gsub("^<?", "message://%%3C", 1)
        messageID = messageID:gsub(">?$", "%%3E", 1)
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
        hs.notify.new({
            title = 'Opening Clipboard Contents...',
            subTitle = clipboard,
            informativeText = exitCode .. " " .. stdOut,
            stdErr,
            withdrawAfter = 3
        }):send()
    end, {clipboard}):start()
end)
-- }}} Hyper-Enter -> Open clipboard contents.

-- {{{ Hyper-<mods>-\ -> Quit things.
hyperMode:bind({}, '\\', function()
    local date = os.date("%Y-%m-%d %H-%M-%S")
    local frontmostApplicationName =
        hs.application.frontmostApplication():name()
    hs.task.new("/usr/bin/sudo", function(exitCode, stdOut, stdErr)
        hs.notify.new({
            title = 'Created spindump for frontmost app...',
            subTitle = frontmostApplicationName,
            informativeText = exitCode,
            stdErr,
            withdrawAfter = 3
        }):send()
    end, {
        "/usr/sbin/spindump", '-reveal', '-o',
        '/Users/gib/tmp/nuke/Safari ' .. date .. '.spindump.txt',
        frontmostApplicationName
    }):start()
end)
hyperMode:bind({'shift'}, '\\', function() killAll("Finder") end)
hyperMode:bind({'alt'}, '\\', function()
    hs.task.new("/usr/bin/sudo", function(exitCode, stdOut, stdErr)
        hs.notify.new({
            title = 'Sudo refreshed ...',
            informativeText = exitCode .. " " .. stdOut .. " " .. stdErr,
            withdrawAfter = 3
        }):send()
    end, {'--validate'}):start()
end)
hyperMode:bind({'cmd'}, '\\', function()
    -- Restart WindowServer (logs you out).
    killAll({"-HUP", "WindowServer"}, {sudo = true})
end)

-- {{{ Hyper-⇧-x -> Restart the touch strip.
hyperMode:bind({'shift'}, 'x', function() killAll("ControlStrip") end)
-- }}} Hyper-⇧-x -> Restart the touch strip.

-- {{{ Hyper-<mods>-v -> Connect to VPN
CallVpn = function(arg)
    hs.task.new(os.getenv("HOME") .. "/bin/vpn",
                function(exitCode, stdOut, stdErr)
        hs.notify.new({
            title = 'VPN ' .. arg .. '...',
            informativeText = exitCode .. " " .. stdOut .. " " .. stdErr,
            withdrawAfter = 3
        }):send()
    end, {arg}):start()
end
hyperMode:bind({}, 'v', function() CallVpn("corporate") end)
hyperMode:bind({'shift'}, 'v', function() CallVpn("off") end)
hyperMode:bind({'cmd'}, 'v', function() CallVpn("dc") end)
-- }}} Hyper-<mods>-v -> Connect to VPN

-- {{{ Hyper-{h,n,e,i} -> Arrow Keys, Hyper-{j,l,u,y} -> Home,PgDn,PgUp,End
local fastKeyStroke = function(modifiers, character, isdown)
    -- log.d('Sending:', modifiers, character, isdown)
    local event = require("hs.eventtap").event
    event.newKeyEvent(modifiers, character, isdown):post()
end

for _, hotkey in ipairs({
    {key = 'h', direction = 'left'}, {key = 'n', direction = 'down'},
    {key = 'e', direction = 'up'}, {key = 'i', direction = 'right'},
    {key = 'j', direction = 'home'}, {key = 'l', direction = 'pagedown'},
    {key = 'u', direction = 'pageup'}, {key = 'y', direction = 'end'}
}) do
    for _, mods in ipairs({
        {}, {'cmd'}, {'alt'}, {'ctrl'}, {'shift'}, {'cmd', 'shift'},
        {'alt', 'shift'}, {'ctrl', 'shift'}
    }) do
        -- hs.hotkey.bind(mods, key, message, pressedfn, releasedfn, repeatfn) -> hs.hotkey object
        hyperMode:bind(mods, hotkey.key, function()
            fastKeyStroke(mods, hotkey.direction, true)
        end, function() fastKeyStroke(mods, hotkey.direction, false) end,
                       function()
            fastKeyStroke(mods, hotkey.direction, true)
        end)
    end
end

-- }}} Hyper-{h,n,e,i} -> Arrow Keys

-- vim: foldmethod=marker
