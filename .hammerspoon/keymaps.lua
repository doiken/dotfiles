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
-- functions
--------------------------------------------------------------------------------
local keyCode = function (key, modifiers, delay)
  local modifiers = modifiers or {}
  local delay = delay or 1000
  return function()
    eventtap.keyStroke(modifiers, key, delay)
  end
end

local remapKey = function (modifiers, key, keyCode)
  hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end

--------------------------------------------------------------------------------
-- common key bind
--------------------------------------------------------------------------------
remapKey({'ctrl'}, 'n', keyCode('down'))
remapKey({'ctrl'}, 'p', keyCode('up'))
remapKey({'ctrl'}, 'm', keyCode('return'))
remapKey({'ctrl'}, 'd', keyCode('forwarddelete'))
remapKey({'ctrl'}, 'h', keyCode('delete'))

remapKey({'ctrl'}, 'f', keyCode('right'))
remapKey({'ctrl'}, 'b', keyCode('left'))

remapKey({'ctrl'}, 'e', keyCode('right', {'cmd'}))
remapKey({'ctrl'}, 'a', keyCode('left', {'cmd'}))
remapKey({'ctrl'}, 'u', keyCode('delete', {'cmd'}))
-- simple ctrl k not work in chrome searchbar
-- remapKey({'ctrl'}, 'k', keyCode('forwarddelete', {'cmd'}))
remapKey({'ctrl'}, 'k', function () keyCode('right', {'shift', 'cmd'})() keyCode('forwarddelete')() end)

-- remapKey({'ctrl'}, 's', keyCode('f', {'cmd'}))
-- remapKey({'ctrl'}, 'm', keyCode('return'))
remapKey({'ctrl'}, 'w', keyCode('delete', {'option'}))
-- remapKey({'ctrl'}, 'i', keyCode('tab'))

-- remapKey({'ctrl'}, 'y', keyCode('v', {'cmd'}))
-- remapKey({'ctrl'}, '/', keyCode('z', {'cmd'}))

remapKey({'option'}, 'f', keyCode('right', {'option'}))
remapKey({'option'}, 'b', keyCode('left', {'option'}))
remapKey({'option'}, 'd', keyCode('forwarddelete', {'option'}))
-- remapKey({'option'}, 'h', keyCode('delete', {'option'}))
-- remapKey({'option', 'shift'}, ',', keyCode('home'))
-- remapKey({'option', 'shift'}, '.', keyCode('end'))

remapKey({'ctrl'}, 'v', keyCode('pagedown'))
remapKey({'option'}, 'v', keyCode('pageup'))

--------------------------------------------------------------------------------
-- layout bind
--------------------------------------------------------------------------------
local windowLayout = require("window_layout")
remapKey({'option', 'ctrl', 'shift'}, 'return', windowLayout.setLayout(geometry.rect(0.10, 0.10, 0.80, 0.80)))
remapKey({'option', 'ctrl'}, 'return', windowLayout.setLayout(layout.maximized))
remapKey({'option', 'ctrl'}, 'left', windowLayout.setLayout(layout.left50))
remapKey({'option', 'ctrl'}, 'right', windowLayout.setLayout(layout.right50))
remapKey({'option', 'ctrl', 'shift'}, 'left', windowLayout.moveScreen(false))
remapKey({'option', 'ctrl', 'shift'}, 'right', windowLayout.moveScreen(true))
module.windowLayout = windowLayout

--------------------------------------------------------------------------------
-- last key repeat
--------------------------------------------------------------------------------
local lastKeyRepeat = require("last_key_repeat")
lastKeyRepeat.mapping = {
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'h' } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'l' } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'k' } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'l' } },
}
lastKeyRepeat.init().start()
-- module.lastKeyRepeat = lastKeyRepeat -- since utility class, no need to hold instance

--------------------------------------------------------------------------------
-- modmaps
--------------------------------------------------------------------------------
if keycodes.currentLayout() == "U.S." then
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
end

--------------------------------------------------------------------------------
-- hotkey_switcher (must be last)
--------------------------------------------------------------------------------
local hotKeySwithcer = require("hotkey_switcher")
hotKeySwithcer.start()
module.hotKeySwithcer = hotKeySwithcer
