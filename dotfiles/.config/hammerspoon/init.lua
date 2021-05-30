-- local log = hs.logger.new('init.lua', 'debug')
-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function() hs.reload() end)

-- Run key remapping script, used in hyper.lua too.
RemapKeys = function()
    local cmd = os.getenv("HOME") .. "/bin/hid"
    local output, _, _, rc = hs.execute(cmd)
    hs.hid.capslock.set(false) -- Turn off Caps Lock.
    hs.notify.new({
        title = 'Remapping Keys (running hidutil)...',
        informativeText = rc .. " " .. output,
        withdrawAfter = 3
    }):send()
end

require('hidutil')
require('hyper')
require('control-escape')

hs.notify.new({
    title = 'Hammerspoon',
    informativeText = 'Gib config restored 🤘',
    withdrawAfter = 3
}):send()
