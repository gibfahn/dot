-- A global variable for Hyper Mode
hyperMode = hs.hotkey.modal.new({}, 'F18')


-- Keybindings for launching apps in Hyper Mode
hyperModeAppMappings = {
  { 'g', 'Google Chrome' },         -- "B" for "Browser"
  { 't', 'Terminal' },              -- "T" for "Terminal"
  { 'f', 'Firefox' },               -- "T" for "Terminal"
  { 's', 'Slack' },                 -- "T" for "Terminal"
}
for i, mapping in ipairs(hyperModeAppMappings) do
  hyperMode:bind({}, mapping[1], function()
    hs.application.launchOrFocus(mapping[2])
  end)
end

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
  { key='j', modIn={},  modOut={}, direction='down'},
  { key='k', modIn={},  modOut={}, direction='up'},
  { key='l', modIn={},  modOut={}, direction='right'},
  { key='h', modIn={'cmd'},  modOut={'cmd'}, direction='left'},
  { key='j', modIn={'cmd'},  modOut={'cmd'}, direction='down'},
  { key='k', modIn={'cmd'},  modOut={'cmd'}, direction='up'},
  { key='l', modIn={'cmd'},  modOut={'cmd'}, direction='right'},
  { key='h', modIn={'alt'},  modOut={'alt'}, direction='left'},
  { key='j', modIn={'alt'},  modOut={'alt'}, direction='down'},
  { key='k', modIn={'alt'},  modOut={'alt'}, direction='up'},
  { key='l', modIn={'alt'},  modOut={'alt'}, direction='right'},
}, function(hotkey)
  hyperMode:bind(hotkey.modIn, hotkey.key,
      function() fastKeyStroke(hotkey.modOut, hotkey.direction) end,
      nil,
      function() fastKeyStroke(hotkey.modOut, hotkey.direction) end
    )
  end
)

