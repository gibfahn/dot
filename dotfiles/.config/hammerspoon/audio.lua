-- Avoid automatically setting a bluetooth audio input device
-- Copied from
-- <https://ssrubin.com/posts/fixing-macos-bluetooth-headphone-audio-quality-issues-with-hammerspoon.html>

local log = hs.logger.new("audio.lua", "debug")

LastSetDeviceTime = os.time()
LastInputDevice = nil

-- When AirPods or other Bluetooth Mics are plugged in, switch the mic input back to the previous one.
function AudioDeviceChanged(arg)
  if arg == "dev#" then
    LastSetDeviceTime = os.time()
  elseif arg == "dIn " and os.time() - LastSetDeviceTime < 2 then
    local inputDevice = hs.audiodevice.defaultInputDevice()
    if inputDevice:transportType() == "Bluetooth" then
      local internalMic = LastInputDevice or hs.audiodevice.findInputByName("Blue Snowball")
      if internalMic == nil then
        log.d("No device found...")
        return
      end
      hs.notify.new({ title = "Switching to " .. internalMic:name() .. "..." }):send()
      internalMic:setDefaultInputDevice()
    end
  end
  if hs.audiodevice.defaultInputDevice():transportType() ~= "Bluetooth" then
    LastInputDevice = hs.audiodevice.defaultInputDevice()
  end
end

hs.audiodevice.watcher.setCallback(AudioDeviceChanged)
hs.audiodevice.watcher.start()
