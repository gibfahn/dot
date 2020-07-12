-- Keyboard Mappings for Hyper mode

-- A global variable for Hyper Mode
hyperMode = hs.hotkey.modal.new({}, 'F18')


-- Keybindings for launching apps in Hyper Mode
hyperModeAppMappings = {

  { '/', 'Finder' },
  { 'f', 'Firefox Nightly' },
  { 'g', 'Google Chrome' },
  { 'm', 'Mail' },
  { 'n', 'Calendar' },
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

-- Print running apps in console:
-- for k, v in pairs(hs.application.runningApplications()) do print(k, v) end
hyperMode:bind({}, '8', function()
  if (hs.application.get('Karabiner-Menu') ~= nil) then
    hs.application.get('Karabiner-Menu'):kill()
  end
  hs.application.launchOrFocus('Karabiner-Menu')
  end
)

-- Enter Hyper Mode when F17 (right option key) is pressed
pressedF17 = function() hyperMode:enter() end

-- Leave Hyper Mode when F17 (right option key) is released.
releasedF17 = function() hyperMode:exit() end

-- Bind the Hyper key
f17 = hs.hotkey.bind({}, 'F17', pressedF17, releasedF17)

local fastKeyStroke = function(modifiers, character)
  local event = require("hs.eventtap").event
  event.newKeyEvent(modifiers, string.lower(character), true):post()
  event.newKeyEvent(modifiers, string.ilower(character), false):post()
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
      function() fastKeyStroke(hotkey.modOut, hotkey.direction) end,
      nil,
      function() fastKeyStroke(hotkey.modOut, hotkey.direction) end
    )
  end
)

-- {{{ Left Ctrl -> Escape if alone
-- Sends "escape" if "Left Control" is held for less than .2 seconds, and no other keys are pressed.
-- https://stackoverflow.com/questions/41094098/hammerspoon-remap-control-key-sends-esc-when-pressed-alone-send-control-when-p
local send_escape = false
local last_mods = {}
local control_key_timer = hs.timer.delayed.new(0.2, function()
    send_escape = false
end)

hs.eventtap.new({hs.eventtap.event.types.flagsChanged}, function(evt)
    local new_mods = evt:getFlags()
    if last_mods["ctrl"] == new_mods["ctrl"] then
        return false
    end
    if not last_mods["ctrl"] then
        last_mods = new_mods
        send_escape = true
        control_key_timer:start()
    else
        if send_escape then
            hs.eventtap.keyStroke({}, "escape")
        end
        last_mods = new_mods
        control_key_timer:stop()
    end
    return false
end):start()


hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(evt)
    send_escape = false
    return false
end):start()
-- }}} Left Ctrl -> Escape if alone

-- vim: foldmethod=marker
