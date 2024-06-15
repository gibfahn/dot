local log = hs.logger.new("init.lua", "debug")
log.d("Loading module")
-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({ "ctrl" }, "`", nil, function()
  hs.reload()
end)

local home_dir = os.getenv("HOME")
local user = os.getenv("USER")

require("hidutil")

local isWrkMachine = false
for file in hs.fs.dir(home_dir) do
  if file == "wrk" then
    log.d("Requiring work config as ~/wrk present.")
    isWrkMachine = true
  end
end

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
    require("wrk")
  end
end
require("window-management")

-- Always remap keys on first loading hammerspoon.
RemapKeys()

-- Always connect to VPN on first loading Hammerspoon.
if isWrkMachine then
  CallVpn("corporate")
end

hs.notify.new({ title = "Hammerspoon", informativeText = "✅ " .. user .. " config restored" }):send()
