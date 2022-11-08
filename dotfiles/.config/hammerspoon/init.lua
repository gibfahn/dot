local log = hs.logger.new('init.lua', 'debug')
log.d("Loading module")
-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function() hs.reload() end)

function RequireIfAvailable(module)
  log.d("Requiring " .. module .. "if available...")
  local function requiref(module_name) require(module_name) end
  local res = pcall(requiref, module)
  if not (res) then log.i("Module not loaded as not found: " .. module) end
end

local user = os.getenv("USER")

require('hidutil')

if (user == "gib") then
  log.d("Loading gib configuration...")
  require('hyper') -- Uses RemapKeys from hidutil, so require order matters.
  require('control-escape')

  RequireIfAvailable('wrk') -- Uses RemapKeys from hidutil, so require order matters.
end
require('window-management')

-- Always remap keys on first loading hammerspoon.
RemapKeys()

-- Always connect to VPN on first loading Hammerspoon.
if (user == "gib") then CallVpn("corporate") end

hs.notify.new({title = 'Hammerspoon', informativeText = user .. ' config restored 🤘', withdrawAfter = 3}):send()
