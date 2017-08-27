--
-- setting
--
local module = {
  duration = 0,
}

local screen = require("hs.screen")
local window = require("hs.window")
local log = require("hs.logger").new(debug.getinfo(1,'S').source, 'debug')
local fnutils = require "hs.fnutils"

local mainScreen = function ()
  return screen.mainScreen()
end

local subScreen = function (isForward)
  if isForward then
    mainScreen().next()
  else
    mainScreen().previous()
  end
end

module.setLayout = function (rect)
  return function()
    window.frontmostWindow():moveToUnit(rect, module.duration)
  end
end

module.moveScreen = function (isForward)
  return function()
    window.frontmostWindow():moveToScreen(subScreen(isForward))
  end
end

module.focusScreen = function (isForward)
  local sortFunc = isForward
    and function(a, b) return a:id() > b:id() end
    or  function(a, b) return a:id() < b:id() end

  return function()
    local windowFocused = window.frontmostWindow()
    local app = window.frontmostWindow():application()
    if not app then
      return
    end
    local windows = app:allWindows()
    windows = fnutils.filter(windows, function(w) return w:isStandard() end)
    table.sort(windows, sortFunc)
    local len = #windows

    for i, value in ipairs(windows) do
      if value:id() == windowFocused:id() then
        return i < len
          and windows[i+1]:becomeMain():focus()
          or  windows[1]:becomeMain():focus()
      end
    end
  end
end

return module
