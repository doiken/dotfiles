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
  local bind = hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
  -- stock emacs binds for enable/disable
  local caller = debug.getinfo(2).short_src:match( "([^/]+).lua$" )
  if caller == "keymaps" then
    table.insert(emacsBinds, bind)
  end
end

--
-- enhance fnutils
--
local fnutils = hs.fnutils
fnutils.foldLeft = function (tbl, func, val)
  for _, v in pairs(tbl) do
    val = func(val, v)
  end
  return val
end
fnutils.keys = function (tbl)
  local keys = {}
  for k, _ in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

require("monitor")
require("layout")
require("keymaps")

require("lastkeyrepeat")
-- require("modmaps")

