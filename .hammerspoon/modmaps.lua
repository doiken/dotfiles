local eventtap = require("hs.eventtap")
local event    = eventtap.event
local keycodes = require("hs.keycodes")

local module = {
  standalones = {
    -- modifier -> events
    cmd = {
      event.newKeyEvent(nil, keycodes.map.eisu, true),
      event.newKeyEvent(nil, keycodes.map.eisu, false),
    },
    rightcmd = {
      event.newKeyEvent(nil, keycodes.map.kana, true),
      event.newKeyEvent(nil, keycodes.map.kana, false),
    },
  },
}
--
-- implement
--
local function handleEvent(e)
  local keyCode = keycodes.map[e:getKeyCode()]

  local isModKeyUp = e:getFlags():containExactly({}) and e:getType() == event.types.flagsChanged
  local replaceEvents = module.standalones[module.prev]
  if isModKeyUp and replaceEvents then
    return true, replaceEvents
  end

  module.prev = keyCode
  return false
end

module.eventListener = eventtap.new({event.types.flagsChanged, event.types.keyDown, event.types.keyUp}, handleEvent)
module.start = function() module.eventListener:start() end
module.stop = function() module.eventListener:stop() end

return module
