-- https://github.com/Hammerspoon/hammerspoon/issues/1128
--
-- setting
--
local mapping = {
  --    { first = { key = 'g', mods = {'ctrl'} }, second = { { key = 'h' }, { key = 'l' } } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'h' } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'l' } },
}

--
-- implement
--
local module = {
  timeout = 0.5, -- when to timeout 2nd stroke
  debugging = false, -- whether to print status updates
}

local eventtap = require "hs.eventtap"
local event    = eventtap.event
local inspect  = require "hs.inspect"
local timer  = require "hs.timer"

local startTimer = function ()
  module.timer = timer.doAfter(module.timeout, function() module.init() end)
end

local stopTimer = function ()
  if module.timer then
    module.timer:stop()
  end
end

local continueTimer = function ()
  stopTimer()
  startTimer()
end

local find = function (evt, map, type)
  local mapSameKeys = hs.fnutils.filter(map, function(elm)
    return hs.keycodes.map[evt:getKeyCode()] == elm[type].key
  end)
  if module.debbuging then log.d(inspect(mapSameKeys)) end
  local target = hs.fnutils.filter(mapSameKeys, function (elm)
    local mods = elm[type].mods or {}
    return evt:getFlags():containExactly(mods)
  end)
  if module.debbuging then log.d(inspect(target)) end
  return target
end

local strokeFirst = function (evt)
  if module.debbuging then log.d("1st stroke") end
  local target = find(evt, mapping, "first")
  if #target > 0 then
    module.wait_strokes = target
    startTimer()
  else
    module.wait_strokes = {}
  end
end

local strokeSecond = function (evt)
  if module.debbuging then log.d("2nd stroke") end
  local target = find(evt, module.wait_strokes, "second")
  if #target == 1 and (not module.is_burst) then
    module.is_burst = true
    continueTimer()
    return false
  elseif #target == 1 then
    local replaceEvent = {
      event.newKeyEvent(target[1].first.mods, target[1].first.key, true),
      event.newKeyEvent(target[1].first.mods, target[1].first.key, false),
      event.newKeyEvent(target[1].second.mods, target[1].second.key, true),
      event.newKeyEvent(target[1].second.mods, target[1].second.key, false),
    }
    continueTimer()
    return true, replaceEvent
  else
    module.wait_strokes = {}
    module.is_burst = false
    stopTimer()
    return false
  end
end

local keyHandler = function (event)
  if #module.wait_strokes > 0 then
    return strokeSecond(event)
  else
    strokeFirst(event)
    return false
  end
end

module.keyListener = eventtap.new({ event.types.keyDown }, keyHandler)

module.start = function() module.keyListener:start() end
module.stop  = function() module.keyListener:stop() end
module.init = function()
  module.wait_strokes = {}
  module.is_burst = false
  stopTimer()
end

module.init()
module.start() -- autostart

return module
