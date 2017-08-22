--
-- setting
--
local module = {
  duration = 0,
}

local screen = require("hs.screen")
local window = require("hs.window")

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

return module
