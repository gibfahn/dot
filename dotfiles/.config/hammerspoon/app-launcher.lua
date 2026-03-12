-- App launcher using hs.chooser for autocompleting app search.
local log = hs.logger.new("app-launcher.lua", "debug")
log.d("Loading module")

local function buildAppDirs()
  local dirs = {
    "/Applications",
    "/Applications/Utilities",
    "/System/Applications",
    "/System/Applications/Utilities",
    os.getenv("HOME") .. "/Applications",
  }
  -- Add /*/Applications/ (e.g. /Users/gib/Applications, /Volumes/Foo/Applications)
  local iter, state = hs.fs.dir("/")
  if iter then
    for entry in iter, state do
      if entry ~= "." and entry ~= ".." then
        local candidate = "/" .. entry .. "/Applications"
        if hs.fs.attributes(candidate, "mode") == "directory" then
          dirs[#dirs + 1] = candidate
        end
      end
    end
  end
  return dirs
end

local appDirs = buildAppDirs()

local function getApps()
  local apps = {}
  local seen = {}

  for _, dir in ipairs(appDirs) do
    local iter, state = hs.fs.dir(dir)
    if iter then
      for entry in iter, state do
        if entry:match("%.app$") then
          local name = entry:gsub("%.app$", "")
          local path = dir .. "/" .. entry
          if not seen[name] then
            seen[name] = true
            local icon = hs.image.imageFromAppBundle(
              hs.application.infoForBundlePath(path) and hs.application.infoForBundlePath(path)["CFBundleIdentifier"]
                or ""
            ) or hs.image.imageFromPath(path)
            table.insert(apps, { text = name, subText = path, image = icon, path = path })
          end
        end
      end
    end
  end

  table.sort(apps, function(a, b)
    return a.text:lower() < b.text:lower()
  end)
  return apps
end

local chooser = nil

AppLauncher = {}

AppLauncher.toggle = function()
  if chooser and chooser:isVisible() then
    chooser:hide()
    return
  end

  local apps = getApps()

  chooser = hs.chooser.new(function(choice)
    if choice then
      log.df("Launching app: %s", choice.text)
      hs.application.launchOrFocus(choice.text)
    end
  end)

  chooser:choices(apps)
  -- Don't search app full path, just app name.
  chooser:searchSubText(false)
  chooser:show()
end

return AppLauncher
