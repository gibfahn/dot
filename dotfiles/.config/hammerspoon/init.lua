local log = hs.logger.new('init.lua', 'debug')
-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function() hs.reload() end)

function RequireIfAvailable(module)
    local function requiref(module) require(module) end
    local res = pcall(requiref, module)
    if not (res) then log.d("Module not loaded as not found: " .. module) end
end

require('hidutil')
require('hyper') -- Uses RemapKeys from hidutil, so require order matters.
require('control-escape')

-- require('wrk')
RequireIfAvailable('wrk') -- Uses RemapKeys from hidutil, so require order matters.

-- Always remap keys on first loading hammerspoon.
RemapKeys()

-- Always connect to VPN on first loading Hammerspoon.
CallVpn("corporate")

hs.notify.new({
    title = 'Hammerspoon',
    informativeText = 'Gib config restored 🤘',
    withdrawAfter = 3
}):send()
