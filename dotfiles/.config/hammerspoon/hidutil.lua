local log = hs.logger.new("hidutil", "debug")
log.d("Loading module")

-- Run key remapping script.
-- This is also run by a LaunchAgent, but sometimes that fails, so keep this as a backup.
RemapKeys = function()
  log.d("Remapping keys...")
  hs.task
    .new(os.getenv("HOME") .. "/bin/hid", function(exitCode, stdOut, stdErr)
      if exitCode == 0 then
        hs.notify
          .new({
            title = "✅ Key Remap succeeded",
            informativeText = exitCode .. " " .. stdOut .. " " .. stdErr,
          })
          :send()
      else
        hs.notify
          .new({
            title = "❌ Key Remap failed",
            informativeText = exitCode .. " " .. stdOut .. " " .. stdErr,
          })
          :send()
      end

      hs.hid.capslock.set(false) -- Turn off Caps Lock.
    end)
    :start()
end

-- LG 5K Displays have an issue where sometimes when you unlock the machine, the display shows as dimmed (around 75%)
-- but it thinks it is 100%. What I normally do is hit the brightness down key once, which actually makes the screen
-- brighter, and then hit the brightness up key. This attempts to automate that.
function LGSetBrightness()
  log.i("Setting brightness for LG displays...")
  for _, screen in ipairs(hs.screen.allScreens()) do
    local name = screen:name()
    local brightness = screen:getBrightness()
    log.d("Checking screen:", name, "with brightness: ", brightness)
    if name:find("LG UltraFine") and brightness == 1 then
      log.d("Setting brightness for display:", name)
      screen:setBrightness(0.49)
      screen:setBrightness(1.00)
    end
  end
end

-- Always re-remap keys when the computer wakes from sleep.
-- <https://www.hammerspoon.org/docs/hs.caffeinate.watcher.html>
-- This is useful because when you reconnect a new keyboard (and wired and bluetooth count as different keyboards for
-- Apple keyboards) it won't be covered by existing hidutil commands.
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
    [hs.caffeinate.watcher.screensDidUnlock] = true, -- 11
  }
  -- Check event number against commented numbers above.
  log.d("Event: ", event, " matches: ", eventsToMatch[event])
  if eventsToMatch[event] then
    log.d("RemapKeyWatcher found matching event: " .. event)
    RemapKeys()
    LGSetBrightness()
  end
  AlertIfSecureInputEnabled()
end)
RemapKeyWatcher:start()

-- {{{ §/CapsLock -> Run hidutil script to re-apply key mappings.
-- These keys are both keys I don't use, that only exist pre-mapping.
hs.hotkey.bind({}, "§", RemapKeys)
hs.hotkey.bind({}, "capslock", RemapKeys)
-- }}} §/CapsLock -> Run hidutil script to re-apply key mappings.
