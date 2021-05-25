local log = hs.logger.new('init.lua', 'debug')
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

-- Always remap keys on first loading hammerspoon.
RemapKeys()

-- Always re-remap keys on some events.
local remapKeyWatcher = hs.caffeinate.watcher.new(
                            function(event)
        local eventsToMatch = {
            [hs.caffeinate.watcher.systemDidWake] = true, -- 0
            [hs.caffeinate.watcher.systemWillSleep] = false, -- 1
            [hs.caffeinate.watcher.systemWillPowerOff] = false, -- 2
            [hs.caffeinate.watcher.screensDidSleep] = false, -- 3
            [hs.caffeinate.watcher.screensDidWake] = false, -- 4
            [hs.caffeinate.watcher.sessionDidResignActive] = false, -- 5
            [hs.caffeinate.watcher.sessionDidBecomeActive] = true, -- 6
            [hs.caffeinate.watcher.screensaverDidStart] = false, -- 7
            [hs.caffeinate.watcher.screensaverWillStop] = false, -- 8
            [hs.caffeinate.watcher.screensaverDidStop] = false, -- 9
            [hs.caffeinate.watcher.screensDidLock] = false, -- 10
            [hs.caffeinate.watcher.screensDidUnlock] = true -- 11
        }
        -- Check event number against commented numbers above.
        log.d('Event: ', event, ' matches: ', eventsToMatch[event])
        if eventsToMatch[event] then RemapKeys() end
    end)
remapKeyWatcher:start()

-- {{{ § -> Run hidutil script to re-apply key mappings.
-- This key is one I don't use, that only exists pre-mapping.
-- TODO: actually use the plist functionality to make the mappings persistent.
hs.hotkey.bind({}, '§', RemapKeys)
-- }}} § -> Run hidutil script to re-apply key mappings.

require('hyper')
require('control-escape')

hs.notify.new({
    title = 'Hammerspoon',
    informativeText = 'Gib config restored 🤘',
    withdrawAfter = 3
}):send()
