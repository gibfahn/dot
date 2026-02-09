local log = hs.logger.new("init.lua", "debug")
log.i("\n\n\n===========================\nRestarting Hammerspoon\n===========================\n")
log.d("Loading module")
-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({ "ctrl" }, "`", nil, function()
  hs.reload()
end)
hs.console.darkMode(true)
hs.dockIcon(false)

local home_dir = os.getenv("HOME")
local user = os.getenv("USER")

require("hidutil")

local function checkIsWrkMachine(home_dir)
  local wrk_dot_dir = home_dir .. "/code/dotfiles-apple"
  local mode, err = hs.fs.attributes(wrk_dot_dir, "mode")
  log.df("mode: %s, err: %s", mode, err)
  if mode == "directory" then
    log.df("Requiring work config as %s present.", wrk_dot_dir)
    return true
  end
  log.df("Not requiring work config as %s not present.", wrk_dot_dir)
  return false
end
local isWrkMachine = checkIsWrkMachine(home_dir)

if user == "gib" or user == "brian" then
  log.d("Loading " .. user .. " configuration...")

  -- Work app mappings, used in hyper.lua below.
  WrkHyperModeAppMappings = nil
  if isWrkMachine then
    WrkHyperModeAppMappings = require("wrk-app-mappings")
  end

  require("hyper")
  require("control-escape")

  if isWrkMachine then
    -- Uses the HyperMode global from hyper.lua required above.
    require("wrk")
  end
end
require("window-management")

-- Always remap keys on first loading hammerspoon.
RemapKeys()
-- Always set brightness on first loading hammerspoon.
LGSetBrightness()

-- Always connect to VPN on first loading Hammerspoon.
if isWrkMachine then
  require("audio") -- Only needed on my work Mac for now.

  CallVpn("corporate")
end

hs.notify.new({ title = "Hammerspoon", informativeText = "✅ " .. user .. " config restored" }):send()
