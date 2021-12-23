local log = hs.logger.new('hidutil.lua', 'debug')

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

-- Always re-remap keys on some events.
RemapKeyWatcher = hs.caffeinate.watcher.new(function(event)
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
RemapKeyWatcher:start()

-- {{{ §/CapsLock -> Run hidutil script to re-apply key mappings.
-- These keys are both keys I don't use, that only exist pre-mapping.
hs.hotkey.bind({}, '§', RemapKeys)
hs.hotkey.bind({}, 'capslock', RemapKeys)
-- }}} §/CapsLock -> Run hidutil script to re-apply key mappings.

