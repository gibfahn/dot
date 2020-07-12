-- Keyboard Mappings for Hyper mode
local log = hs.logger.new('init.lua', 'debug')

local message = require('status-message')

-- A global variable for Hyper Mode
hyperMode = hs.hotkey.modal.new({})

-- Keybindings for launching apps in Hyper Mode
hyperModeAppMappings = {

  { '/', 'Finder' },
  { 'f', 'Firefox Nightly' },
  { 'g', 'Google Chrome' },
  { 'm', 'Mail' },
  { 'k', 'Calendar' },
  { 'r', 'Radar 8' },
  { 's', 'Slack' },
  { 't', 'Kitty' },
  { 'w', 'Workflowy' },
  { 'x', 'Messages' },

}
for i, mapping in ipairs(hyperModeAppMappings) do
  hyperMode:bind({}, mapping[1], function()
    hs.application.launchOrFocus(mapping[2])
  end)
end

local microphone_toggle = require('microphone')

-- Hyper-comma: toggle microphone muting.

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

-- Print running apps in console:
-- for k, v in pairs(hs.application.runningApplications()) do print(k, v) end
-- hyperMode:bind({}, '8', function()
--   if (hs.application.get('Karabiner-Menu') ~= nil) then
--     hs.application.get('Karabiner-Menu'):kill()
--   end
--   hs.application.launchOrFocus('Karabiner-Menu')
--   end
-- )

-- Enter Hyper Mode when F17 (right option key) is pressed
pressedF17 = function() hyperMode:enter() end

-- Leave Hyper Mode when F17 (right option key) is released.
releasedF17 = function() hyperMode:exit() end

-- Bind the Hyper key
f17 = hs.hotkey.bind({}, 'F17', pressedF17, releasedF17)

local fastKeyStroke = function(modifiers, character, isdown)
  -- log.d('Sending:', modifiers, character, isdown)
  local event = require("hs.eventtap").event
  event.newKeyEvent(modifiers, character, isdown):post()
end

hs.fnutils.each({
  -- Movement
  { key='h', modIn={},  modOut={}, direction='left'},
  { key='n', modIn={},  modOut={}, direction='down'},
  { key='e', modIn={},  modOut={}, direction='up'},
  { key='i', modIn={},  modOut={}, direction='right'},
  { key='h', modIn={'cmd'},  modOut={'cmd'}, direction='left'},
  { key='n', modIn={'cmd'},  modOut={'cmd'}, direction='down'},
  { key='e', modIn={'cmd'},  modOut={'cmd'}, direction='up'},
  { key='i', modIn={'cmd'},  modOut={'cmd'}, direction='right'},
  { key='h', modIn={'alt'},  modOut={'alt'}, direction='left'},
  { key='n', modIn={'alt'},  modOut={'alt'}, direction='down'},
  { key='e', modIn={'alt'},  modOut={'alt'}, direction='up'},
  { key='i', modIn={'alt'},  modOut={'alt'}, direction='right'},
}, function(hotkey)
  -- hs.hotkey.bind(mods, key, message, pressedfn, releasedfn, repeatfn) -> hs.hotkey object
  hyperMode:bind(
      hotkey.modIn,
      hotkey.key,
      function() fastKeyStroke(hotkey.modOut, hotkey.direction, true) end,
      function() fastKeyStroke(hotkey.modOut, hotkey.direction, false) end,
      function() fastKeyStroke(hotkey.modOut, hotkey.direction, true) end
    )
  end
)

-- vim: foldmethod=marker
