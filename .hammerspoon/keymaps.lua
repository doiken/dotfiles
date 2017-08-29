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
-- hotkey_switcher (must be last)
--------------------------------------------------------------------------------
local hotKeySwithcer = require("hotkey_switcher")
module.hotKeySwithcer = hotKeySwithcer
hotKeySwithcer.remapKey({{'ctrl'}, 'f'}, {'right'})
hotKeySwithcer.remapKey({{'ctrl'}, 'b'}, {'left'})
hotKeySwithcer.remapKey({{'ctrl'}, 'n'}, {'down'})
hotKeySwithcer.remapKey({{'ctrl'}, 'p'}, {'up'})

hotKeySwithcer.remapKey({{'ctrl'}, 'e'}, {'right', {'cmd'}})
hotKeySwithcer.remapKey({{'ctrl'}, 'a'}, {'left', {'cmd'}})

hotKeySwithcer.remapKey({{'ctrl'}, 'm'}, {'return'})
hotKeySwithcer.remapKey({{'ctrl'}, 'd'}, {'forwarddelete'})
hotKeySwithcer.remapKey({{'ctrl'}, 'h'}, {'delete'})
hotKeySwithcer.remapKey({{'ctrl'}, 'u'}, {'delete', {'cmd'}})
hotKeySwithcer.remapKey({{'ctrl'}, 'k'}, {'right', {'shift', 'cmd'}}, {'forwarddelete'})

hotKeySwithcer.remapKey({{'ctrl'}, 'w'}, {'delete', {'option'}})

-- hotKeySwithcer.remapKey({{'ctrl'}, 'y'}, {'v', {'cmd'}))
-- hotKeySwithcer.remapKey({{'ctrl'}, '/'}, {'z', {'cmd'}))

hotKeySwithcer.remapKey({{'option'}, 'f'}, {'right', {'option'}})
hotKeySwithcer.remapKey({{'option'}, 'b'}, {'left', {'option'}})
hotKeySwithcer.remapKey({{'option'}, 'd'}, {'forwarddelete', {'option'}})
-- hotKeySwithcer.remapKey({{'option'}, 'h'}, {'delete', {'option'}))

hotKeySwithcer.remapKey({{'ctrl'}, 'v'}, {'pagedown'})
hotKeySwithcer.remapKey({{'option'}, 'v'}, {'pageup'})
--hotKeySwithcer.remapKey({{'option', 'cmd'}, 'r'}, function () hs.reload() end)
hotKeySwithcer.init()
hotKeySwithcer.start()

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
  remapKey({'cmd'}, '`', windowLayout.focusScreen(true))
  remapKey({'cmd', 'shift'}, '`', windowLayout.focusScreen(false))
else
  remapKey({'cmd'}, '[', windowLayout.focusScreen(true))
  remapKey({'cmd', 'shift'}, '[', windowLayout.focusScreen(false))
end
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

