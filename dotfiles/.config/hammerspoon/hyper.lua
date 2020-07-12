-- Keyboard Mappings for Hyper mode
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

-- {{{ Keybindings for launching apps in Hyper Mode

hyperModeAppMappings = {

  { key='/', app='Finder' },
  { key='f', app='Firefox Nightly' },
  { key='g', app='Google Chrome' },
  { key='m', app='Mail' },
  { key='k', app='Calendar' },
  { key='r', app='Radar 8' },
  { key='s', app='Slack' },
  { key='t', app='Kitty' },
  { key='w', app='Workflowy' },
  { key='x', app='Messages' },

}
for i, mapping in ipairs(hyperModeAppMappings) do
  hyperMode:bind({}, mapping.key, function()
    hs.application.launchOrFocus(mapping.app)
  end)
end
-- }}} Keybindings for launching apps in Hyper Mode

-- {{{ Hyper-, -> toggle microphone muting.

local messageMuting = message.new('muted 🎤')
local messageHot = message.new('hot 🎤')

hyperMode:bind({}, ',', function()
  local device = hs.audiodevice.defaultInputDevice()
  if device:muted() then
    device:setMuted(false)
    messageHot:notify()
  else
    device:setMuted(true)
    messageMuting:notify()
  end
  displayStatus()
end
)

-- }}} Hyper-, -> toggle microphone muting.

-- Hyper-; -> lock screen
hyperMode:bind({}, ';', hs.caffeinate.lockScreen)
hyperMode:bind({'shift'}, ';', hs.caffeinate.restartSystem)


-- XXX(gib): port this.
-- "rules": [
-- {
--   "description": "Ж+Key switches to or opens App. Free keys: ⏎,q,z",
--   "manipulators": [
--   {
--     "description": "Ж+⌘+Enter = open clipboard contents",
--     "type": "basic",
--     "from": {
--       "key_code": "return_or_enter",
--       "modifiers": { "mandatory": [ "command" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "open \"$(pbpaste)\"" }
--   }, {
--     "description": "Ж+d (Ж+g) = print today's date",
--     "type": "basic",
--     "from": { "key_code": "g" },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "printf `date \"+%Y-%m-%d\"` | pbcopy" },
--     "to_after_key_up": { "key_code": "v", "modifiers": [ "command" ] }
--   }, {
--     "description": "Ж+⇧+m = format Mail Message ID in clipboard into link. Select Message ID then press this to copy + format.",
--     "type": "basic",
--     "from": {
--       "key_code": "m",
--       "modifiers": { "mandatory": [ "shift" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "key_code": "c", "modifiers": [ "command" ] },
--     "to_after_key_up": { "shell_command": "$HOME/bin/mail_link" }
--   }, {
--     "description": "Ж+v = Connect to VPN",
--     "type": "basic",
--     "from": { "key_code": "v" },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "$HOME/bin/vpn corporate" }
--   }, {
--     "description": "Ж+⇧+v = Disconnect from VPN",
--     "type": "basic",
--     "from": {
--       "key_code": "v",
--       "modifiers": { "mandatory": [ "shift" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "$HOME/bin/vpn off" }
--   }, {
--     "description": "Ж+⌘+v = Connect to DCVPN",
--     "type": "basic",
--     "from": {
--       "key_code": "v",
--       "modifiers": { "mandatory": [ "command" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "$HOME/bin/vpn dc" }
--   }, {
--     "description": "Ж+⌘+w = enable wifi",
--     "type": "basic",
--     "from": {
--       "key_code": "w",
--       "modifiers": { "mandatory": [ "command" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "networksetup -setairportpower en0 on 2>&1 | /usr/local/bin/terminal-notifier -title 'Starting Wifi' -group Karabiner-Elements" }
--   }, {
--     "description": "Ж+⇧+w = disable wifi",
--     "type": "basic",
--     "from": {
--       "key_code": "w",
--       "modifiers": { "mandatory": [ "shift" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "networksetup -setairportpower en0 off 2>&1 | /usr/local/bin/terminal-notifier -title 'Stopping Wifi' -group Karabiner-Elements" }
--   }, {
--     "description": "Ж+⌥+x = Open Caprine (Facebook Messenger)",
--     "type": "basic",
--     "from": {
--       "key_code": "x",
--       "modifiers": { "mandatory": [ "option" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "open -a Caprine" }
--   }, {
--     "description": "Ж+⇧+x = restart the touch strip",
--     "type": "basic",
--     "from": {
--       "key_code": "x",
--       "modifiers": { "mandatory": [ "shift" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "shell_command": "pkill ControlStrip 1>&2 | /usr/local/bin/terminal-notifier -title 'Touch Strip Restarting' -group Karabiner-Elements" }
--   }
-- }, {
--   "description": "Ж+; (Ж+p) = lock screen (go to sleep).",
--   "manipulators": [
--   {
--     "type": "basic",
--     "from": {
--       "key_code": "p",
--       "modifiers": { "optional": [ "any" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "key_code": "power", "modifiers": [ "left_control", "left_shift" ] }
--   }
--   ]
-- }, {
--   "description": "Ж+p (Ж+r) = print screen (Screenshot to Clipboard)",
--   "manipulators": [
--   {
--     "type": "basic",
--     "from": {
--       "key_code": "r",
--       "modifiers": { "optional": [ "any" ] }
--     },
--     "conditions": [ { "name": "hyper", "type": "variable_if", "value": 1 } ],
--     "to": { "key_code": "4", "modifiers": [ "right_shift", "left_command", "left_control" ] }
--   }
--   ]
-- }
-- ]



-- {{{ Hyper-{h,n,e,i} -> Arrow Keys, Hyper-{j,l,u,y} -> Home,PgDn,PgUp,End
local fastKeyStroke = function(modifiers, character, isdown)
  -- log.d('Sending:', modifiers, character, isdown)
  local event = require("hs.eventtap").event
  event.newKeyEvent(modifiers, character, isdown):post()
end

hs.fnutils.each({

  { key='h', direction='left', mods={}},
  { key='h', direction='left', mods={'cmd'}},
  { key='h', direction='left', mods={'cmd', 'shift'}},
  { key='h', direction='left', mods={'alt'}},
  { key='h', direction='left', mods={'alt', 'shift'}},

  { key='n', direction='down', mods={}},
  { key='n', direction='down', mods={'cmd'}},
  { key='n', direction='down', mods={'cmd', 'shift'}},
  { key='n', direction='down', mods={'alt'}},
  { key='n', direction='down', mods={'alt', 'shift'}},

  { key='e', direction='up', mods={}},
  { key='e', direction='up', mods={'cmd'}},
  { key='e', direction='up', mods={'cmd', 'shift'}},
  { key='e', direction='up', mods={'alt'}},
  { key='e', direction='up', mods={'alt', 'shift'}},


  { key='i', direction='right', mods={}},
  { key='i', direction='right', mods={'cmd'}},
  { key='i', direction='right', mods={'cmd', 'shift'}},
  { key='i', direction='right', mods={'alt'}},
  { key='i', direction='right', mods={'alt', 'shift'}},

  { key='j', direction='home', mods={}},
  { key='j', direction='home', mods={'cmd'}},
  { key='j', direction='home', mods={'cmd', 'shift'}},
  { key='j', direction='home', mods={'alt'}},
  { key='j', direction='home', mods={'alt', 'shift'}},

  { key='l', direction='pagedown', mods={}},
  { key='l', direction='pagedown', mods={'cmd'}},
  { key='l', direction='pagedown', mods={'cmd', 'shift'}},
  { key='l', direction='pagedown', mods={'alt'}},
  { key='l', direction='pagedown', mods={'alt', 'shift'}},

  { key='u', direction='pageup', mods={}},
  { key='u', direction='pageup', mods={'cmd'}},
  { key='u', direction='pageup', mods={'cmd', 'shift'}},
  { key='u', direction='pageup', mods={'alt'}},
  { key='u', direction='pageup', mods={'alt', 'shift'}},

  { key='y', direction='end', mods={}},
  { key='y', direction='end', mods={'cmd'}},
  { key='y', direction='end', mods={'cmd', 'shift'}},
  { key='y', direction='end', mods={'alt'}},
  { key='y', direction='end', mods={'alt', 'shift'}},

}, function(hotkey)
    -- hs.hotkey.bind(mods, key, message, pressedfn, releasedfn, repeatfn) -> hs.hotkey object
    hyperMode:bind(
      hotkey.mods,
      hotkey.key,
      function() fastKeyStroke(hotkey.mods, hotkey.direction, true) end,
      function() fastKeyStroke(hotkey.mods, hotkey.direction, false) end,
      function() fastKeyStroke(hotkey.mods, hotkey.direction, true) end
    )
  end
)
-- }}} Hyper-{h,n,e,i} -> Arrow Keys

-- vim: foldmethod=marker
