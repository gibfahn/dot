local log = hs.logger.new('init.lua', 'debug')

-- Use Control+` to reload Hammerspoon config
hs.hotkey.bind({'ctrl'}, '`', nil, function()
  hs.reload()
end)

-- {{{ § -> Run hidutil script to re-apply key mappings.
-- This key is one I don't use, that only exists pre-mapping.
-- TODO: actually use the plist functionality to make the mappings persistent.
hs.hotkey.bind({}, '§', function()
  local cmd = os.getenv("HOME").."/bin/hid"
  local output, status, _, rc = hs.execute(cmd)
  hs.notify.new({title='Running Hidutil...', informativeText=rc.." "..output, withdrawAfter=3}):send()
end)
-- }}} § -> Run hidutil script to re-apply key mappings.

require('hyper')
require('control-escape')

hs.notify.new({title='Hammerspoon', informativeText='Gib config restored 🤘', withdrawAfter=3}):send()
