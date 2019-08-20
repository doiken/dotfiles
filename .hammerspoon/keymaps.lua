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
local windowLayout = require("window_layout")
remapKey({'option', 'ctrl', 'shift'}, 'return', windowLayout.setLayout(geometry.rect(0.10, 0.10, 0.80, 0.80)))
remapKey({'option', 'ctrl'}, 'return', windowLayout.setLayout(layout.maximized))
remapKey({'option', 'ctrl'}, 'left', windowLayout.setLayout(layout.left50))
remapKey({'option', 'ctrl'}, 'right', windowLayout.setLayout(layout.right50))
remapKey({'option', 'ctrl', 'shift'}, 'left', windowLayout.moveScreen(false))
remapKey({'option', 'ctrl', 'shift'}, 'right', windowLayout.moveScreen(true))
if keycodes.currentLayout() == "U.S." then
  remapKey({'option'}, '`', windowLayout.focusScreen(true))
  remapKey({'option', 'shift'}, '`', windowLayout.focusScreen(false))
else
  remapKey({'option'}, '1', windowLayout.focusScreen(true))
  remapKey({'option', 'shift'}, '1', windowLayout.focusScreen(false))
end
module.windowLayout = windowLayout


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

