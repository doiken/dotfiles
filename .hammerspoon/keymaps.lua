local layout = require("hs.layout")
local geometry = require("hs.geometry")

--
-- common functions
--
local emacsBinds = {}
function keyCode(key, modifiers, delay)
  local modifiers = modifiers or {}
  local delay = delay or 1000
  return function()
    hs.eventtap.keyStroke(modifiers, key, delay)
  end
end

function remapKey(modifiers, key, keyCode)
  local bind = hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
  -- stock emacs binds for enable/disable
  local caller = debug.getinfo(2).short_src:match( "([^/]+).lua$" )
  if caller == "keymaps" then
    table.insert(emacsBinds, bind)
  end
end

--
-- common key bind
--
remapKey({'ctrl'}, 'n', keyCode('down'))
remapKey({'ctrl'}, 'p', keyCode('up'))
remapKey({'ctrl'}, 'm', keyCode('return'))
remapKey({'ctrl'}, 'd', keyCode('forwarddelete'))
remapKey({'ctrl'}, 'h', keyCode('delete'))

--
-- key bind(watched)
--
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

--
-- layout bind
--
local windowLayout = require("window_layout")
remapKey({'option', 'ctrl', 'shift'}, 'return', windowLayout.setLayout(geometry.rect(0.10, 0.10, 0.80, 0.80)))
remapKey({'option', 'ctrl'}, 'return', windowLayout.setLayout(layout.maximized))
remapKey({'option', 'ctrl'}, 'left', windowLayout.setLayout(layout.left50))
remapKey({'option', 'ctrl'}, 'right', windowLayout.setLayout(layout.right50))
remapKey({'option', 'ctrl', 'shift'}, 'left', windowLayout.moveScreen(false))
remapKey({'option', 'ctrl', 'shift'}, 'right', windowLayout.moveScreen(true))

--
-- last key repeat
--
lastKeyRepeat = require("last_key_repeat")
lastKeyRepeat.mapping = {
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'h' } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'l' } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'k' } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'l' } },
}
lastKeyRepeat.init().start()

--
-- hotkey_switcher (must be last)
--
hotKeySwithcer = require("hotkey_switcher")
hotKeySwithcer.hotkeys = emacsBinds
hotKeySwithcer.start()
local logger = require "hs.logger"
local log = logger.new('lastkeyrepeat', 'debug')
log:d(hs.inspect(hs.keycodes.map))

