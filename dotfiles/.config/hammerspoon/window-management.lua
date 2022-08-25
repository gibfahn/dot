-- Replacement for Spectacle/Rectangle.
local log = hs.logger.new('window-management.lua', 'debug')

-- Symlinked in in up/run/unix
hs.loadSpoon("Lunette")

local customBindings = {
  leftHalf = {
    {{"cmd", "alt"}, "h"},
  },
  nextDisplay = {
    {{"cmd", "alt"}, "n"},
  },
  fullScreen = {
    {{"cmd", "alt"}, "e"},
  },
  rightHalf = {
    {{"cmd", "alt"}, "i"},
  },
  prevDisplay = false,
  nextThird = false,
  prevThird = false,
  enlarge = false,
  shrink = false,
  undo = false,
  redo = false,
}

spoon.Lunette:bindHotkeys(customBindings)
