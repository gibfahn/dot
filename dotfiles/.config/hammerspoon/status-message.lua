local log = hs.logger.new("statusmess", "debug")
log.d("Loading module")

-- Copied from https://github.com/jasonrudolph/keyboard/blob/master/hammerspoon/control-escape.lua
local drawing = require("hs.drawing")
local geometry = require("hs.geometry")
local screen = require("hs.screen")
local styledtext = require("hs.styledtext")

local statusmessage = {}
statusmessage.new = function(messageText)
  log.d("Building status message with contents: " .. messageText)
  local buildParts = function(messageText)
    local frame = screen.primaryScreen():frame()

    local styledTextAttributes = { font = { name = "Monaco", size = 24 } }

    local styledText = styledtext.new("🔨 " .. messageText, styledTextAttributes)

    local styledTextSize = drawing.getTextDrawingSize(styledText)
    local textRect = {
      x = frame.w - styledTextSize.w - 40,
      y = frame.h - styledTextSize.h - 40,
      w = styledTextSize.w + 40,
      h = styledTextSize.h + 40,
    }
    local text = drawing.text(textRect, styledText):setAlpha(0.7)

    local background = drawing.rectangle({
      x = frame.w - styledTextSize.w - 45,
      y = frame.h - styledTextSize.h - 48,
      w = styledTextSize.w + 15,
      h = styledTextSize.h + 6,
    })
    background:setRoundedRectRadii(10, 10)
    background:setFillColor({
      red = 256,
      green = 256,
      blue = 256,
      alpha = 0.6,
    })

    return background, text
  end

  return {
    _buildParts = buildParts,
    show = function(self)
      log.d("Showing status message with contents: " .. messageText)
      self:hide()

      self.background, self.text = self._buildParts(messageText)
      self.background:show()
      self.text:show()
    end,
    hide = function(self)
      log.d("Hiding status message with contents: " .. messageText)
      if self.background then
        self.background:delete()
        self.background = nil
      end
      if self.text then
        self.text:delete()
        self.text = nil
      end
    end,
    notify = function(self, seconds)
      log.d("Showing and then hiding status message with contents: " .. messageText)
      local seconds = seconds or 1
      self:show()
      hs.timer.delayed
        .new(seconds, function()
          self:hide()
        end)
        :start()
    end,
  }
end

return statusmessage
