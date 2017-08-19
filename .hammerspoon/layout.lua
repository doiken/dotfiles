--
-- suppose only one or two screens
--
local function mainScreen()
  return hs.screen.mainScreen()
end

local function subScreen(isForward)
  if isForward then
    mainScreen().next()
  else
    mainScreen().previous()
  end
end

local function setLayout(rect)
  return function()
    local targetWindow = hs.window.frontmostWindow()
    targetWindow:moveToUnit(rect)
  end
end

local function moveScreen(isForward)
  return function()
    local targetWindow = hs.window.frontmostWindow()
    targetWindow:moveToScreen(subScreen(isForward))
  end
end

remapKey({'option', 'ctrl', 'shift'}, 'return', setLayout(hs.geometry.rect(0.10, 0.10, 0.80, 0.80)))
remapKey({'option', 'ctrl'}, 'return', setLayout(hs.layout.maximized))
remapKey({'option', 'ctrl'}, 'left', setLayout(hs.layout.left50))
remapKey({'option', 'ctrl'}, 'right', setLayout(hs.layout.right50))
remapKey({'option', 'ctrl', 'shift'}, 'left', moveScreen(false))
remapKey({'option', 'ctrl', 'shift'}, 'right', moveScreen(true))

