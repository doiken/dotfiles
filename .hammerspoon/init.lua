--
-- common functions
--
local emacsBinds = {}
function getEmacsBinds() return emacsBinds end
function keyCode(key, modifiers, delay)
  local modifiers = modifiers or {}
  local delay = delay or 1000
  return function()
    hs.eventtap.keyStroke(modifiers, key, delay)
  end
end

function remapKey(modifiers, key, keyCode)
  local bind = hs.hotkey.bind(modifiers, key, nil, keyCode, nil, keyCode)
  -- stock emacs binds for enable/disable
  local caller = debug.getinfo(2).short_src:match( "([^/]+).lua$" )
  if caller == "keymaps" then
    table.insert(emacsBinds, bind)
  end
end

require("monitor")
require("layout")
require("keymaps")

require("lastkeyrepeat")
