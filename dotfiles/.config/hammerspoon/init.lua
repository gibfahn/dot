-- local log = hs.logger.new('init.lua', 'debug')
-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function() hs.reload() end)

require('hidutil')
require('hyper') -- Uses RemapKeys from hidutil, so require order matters.
require('control-escape')

-- Always remap keys on first loading hammerspoon.
RemapKeys()

-- Always connect to VPN on first loading Hammerspoon.
CallVpn("corporate")

hs.notify.new({
    title = 'Hammerspoon',
    informativeText = 'Gib config restored 🤘',
    withdrawAfter = 3
}):send()
