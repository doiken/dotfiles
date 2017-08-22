local module = {
  -- hotkeys to watch
  hotkeys = {},
  -- applications disable binds
  apps_black = {
    "iTerm2",
    "Emacs",
    "IntelliJ IDEA",
  }
}

--
-- implement
--
local application = require("hs.application")
local appsBlackInverted = fnutils.foldLeft(module.apps_black, function (tbl, name)
  tbl[name] = true
  return tbl
end, {})

local function disableHotkeys()
  fnutils.each(module.hotkeys, function (v)
    v['_hk']:disable()
  end)
end

local function enableHotkeys()
  fnutils.each(module.hotkeys, function (v)
    v['_hk']:enable()
  end)
end

local function handleGlobalAppEvent(name, event, app)
  if event == application.watcher.activated then
    if appsBlackInverted[name] then
      disableHotkeys()
    else
      enableHotkeys()
    end
  end
end

module.applicationListener = application.watcher.new(handleGlobalAppEvent)
module.start = function () module.applicationListener:start() end
return module