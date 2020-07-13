local log = hs.logger.new('init.lua', 'debug')

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function()
  hs.reload()
end)

-- Function to simulate pressing then releasing a key.
keyDownUp = function(modifiers, key)
  -- log.d('Sending keystroke:', hs.inspect(modifiers), key)
  hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
  hs.eventtap.event.newKeyEvent(modifiers, key, false):post()
end

require('hyper')
require('control-escape')

hs.notify.new({title='Hammerspoon', informativeText='Gib config restored 🤘', withdrawAfter=3}):send()
