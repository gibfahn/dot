local log = hs.logger.new("ctrl-esc", "debug")
log.d("Loading module")

-- Copied from https://github.com/jasonrudolph/keyboard/blob/master/hammerspoon/control-escape.lua
-- Credit for this implementation goes to @arbelt and @jasoncodes 🙇⚡️😻
--
--   https://gist.github.com/arbelt/b91e1f38a0880afb316dd5b5732759f1
--   https://github.com/jasoncodes/dotfiles/blob/ac9f3ac/hammerspoon/control_escape.lua
-- Skip this if running Karabiner-Elements.
if hs.application.get("Karabiner-Menu") ~= nil then
  return
end

sendEscape = false
lastMods = {}

ctrlKeyHandler = function()
  sendEscape = false
end

ctrlKeyTimer = hs.timer.delayed.new(0.15, ctrlKeyHandler)

ctrlHandler = function(evt)
  local newMods = evt:getFlags()
  if lastMods["ctrl"] == newMods["ctrl"] then
    return false
  end
  if not lastMods["ctrl"] then
    lastMods = newMods
    sendEscape = true
    ctrlKeyTimer:start()
  else
    if sendEscape then
      hs.eventtap.keyStroke({}, "escape")
    end
    lastMods = newMods
    ctrlKeyTimer:stop()
  end
  return false
end

ctrlTap = hs.eventtap.new({ hs.eventtap.event.types.flagsChanged }, ctrlHandler)
ctrlTap:start()

otherHandler = function(evt)
  sendEscape = false
  return false
end

otherTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, otherHandler)
otherTap:start()
