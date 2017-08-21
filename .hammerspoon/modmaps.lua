local fnutils = require "hs.fnutils"
local eventtap = require "hs.eventtap"
local event    = eventtap.event
local inspect  = require "hs.inspect"
local keycodes = require "hs.keycodes"
local logger = require "hs.logger"
local log = logger.new('modmaps', 'debug')

local EISUU = 0x66
local KANA = 0x68
local module = {
  -- modifier -> events
  cmd = {
    event.newKeyEvent(nil, EISUU, true),
    event.newKeyEvent(nil, EISUU, false),
  },
  rightcmd = {
    event.newKeyEvent(nil, KANA, true),
    event.newKeyEvent(nil, KANA, false),
  },
}
--
-- implement
--
local function handleEvent(e)
  local keyCode = keycodes.map[e:getKeyCode()]

  local isModKeyUp = e:getFlags():containExactly({}) and e:getType() == hs.eventtap.event.types.flagsChanged
  local replaceEvents = module[module.prev]
  if isModKeyUp and replaceEvents then
    return true, replaceEvents
  end

  module.prev = keyCode
  return false
end

module.eventListener = eventtap.new({hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, handleEvent)
module.start = function() module.eventListener:start() end
module:start()

