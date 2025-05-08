local layout = require("hs.layout")
local geometry = require("hs.geometry")
local keycodes = require("hs.keycodes")
local eventtap = require("hs.eventtap")
local hotkey = require("hs.hotkey")
local event    = eventtap.event
local logger = require("hs.logger")
local log = logger.new(debug.getinfo(1,'S').source, 'debug')

local module = {}

--------------------------------------------------------------------------------
-- layout bind
--------------------------------------------------------------------------------
local remapKey = function (modifiers, key, command)
  hotkey.bind(modifiers, key, command, nil, command)
end

--------------------------------------------------------------------------------
-- modmaps
--------------------------------------------------------------------------------
-- if keycodes.currentLayout() == "U.S." then
  local modmaps = require("modmaps")
  modmaps.standalones = {
    cmd = {
      event.newKeyEvent(nil, keycodes.map.eisu, true),
      event.newKeyEvent(nil, keycodes.map.eisu, false),
    },
    rightcmd = {
      event.newKeyEvent(nil, keycodes.map.kana, true),
      event.newKeyEvent(nil, keycodes.map.kana, false),
    },
  },
  modmaps.start()
  module.modmaps = modmaps
-- end

