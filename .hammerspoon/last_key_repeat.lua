-- https://github.com/Hammerspoon/hammerspoon/issues/1128
--
-- setting
--
local module = {
  mapping = {
    -- { first = { key = 'g', mods = {'ctrl'} }, second = { { key = 'h' }, { key = 'l' } } },
  },
  timeout = 0.5, -- when to timeout 2nd stroke
  debugging = false, -- whether to print status updates
  app_disable = {
    ["iTerm2"] = true,
  },
}

--
-- implement
--
local application = require "hs.application"
local eventtap = require "hs.eventtap"
local event    = eventtap.event
local inspect  = require "hs.inspect"
local timer  = require "hs.timer"
local fnutils = require "hs.fnutils"
local logger = require "hs.logger"
local log = logger.new('lastkeyrepeat', 'debug')
local hash = require "hs.hash"
local keycodes = require "hs.keycodes"
local doHash = function (t)
  fnutils.sortByKeyValues(t.mods)
  return hash.MD5(t.key .. "::" .. inspect(t.mods))
end

local getInvertedMap = function (mapping)
  return fnutils.foldLeft(mapping, function (invMaps, map)
    fnutils.each({"first", "second"}, function (key)
      if map[key].mods then
        fnutils.sortByKeyValues(map[key].mods)
      else
        map[key].mods = {} -- default is {}
      end
    end)

    local firstHash = doHash(map.first)
    local secondHash = doHash(map.second)
    invMaps[firstHash] = invMaps[firstHash] or {}
    invMaps[firstHash][secondHash] = map
    return invMaps
  end, {})
end

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

local find = function (evt, map)
  local evtHash = doHash({
    key = keycodes.map[evt:getKeyCode()],
    mods = fnutils.keys(evt:getFlags())
  })
  return map[evtHash]
end

local strokeFirst = function (evt)
  if module.debbuging then log:d("1st stroke") end
  local target = find(evt, module.invertedMap)
  if target then
    module.wait_strokes = target
    startTimer()
  else
    module.wait_strokes = nil
  end
end

local strokeSecond = function (evt)
  if module.debbuging then log:d("2nd stroke") end
  local target = find(evt, module.wait_strokes)
  if target and (not module.is_burst) then
    module.is_burst = true
    continueTimer()
    return false
  elseif target then
    local replaceEvent = {
      event.newKeyEvent(target.first.mods,  target.first.key, true),
      event.newKeyEvent(target.first.mods,  target.first.key, false),
      event.newKeyEvent(target.second.mods, target.second.key, true),
      event.newKeyEvent(target.second.mods, target.second.key, false),
    }
    continueTimer()
    return true, replaceEvent
  else
    module.wait_strokes = nil
    module.is_burst = false
    stopTimer()
    return false
  end
end

local keyHandler = function (event)
  if module.wait_strokes then
    return strokeSecond(event)
  else
    strokeFirst(event)
    return false
  end
end

module.applicationListener = application.watcher.new(function (name, event, app)
  if event == application.watcher.activated then
    if module.app_disable[name] then
      module.disabled = true
      module.stop()
    elseif module.disabled then
      module.start()
      module.disabled = false
    end
  end
end)

module.keyListener = eventtap.new({ event.types.keyDown }, keyHandler)

module.start = function() module.keyListener:start() end
module.stop  = function() module.keyListener:stop() end
module.init = function()
  module.applicationListener:start()
  module.wait_strokes = nil
  module.is_burst = false
  module.invertedMap = getInvertedMap(module.mapping)
  return module
end

return module
