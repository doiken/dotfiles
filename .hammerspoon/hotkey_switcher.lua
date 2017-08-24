local application = require("hs.application")
local hotkey = require("hs.hotkey")
local logger = require("hs.logger")
local log = logger.new(debug.getinfo(1,'S').source, 'debug')
local eventtap = require("hs.eventtap")

local idx = function (mods, key)
  local dummy_fn = function () end
  return hotkey.new(mods, key, dummy_fn, dummy_fn, dummy_fn).idx
end
local module = {
  -- applications disable binds
  apps_custom = {
    -- app name = { idx1, ... }
    ["iTerm2"] = { },
    ["Emacs"] = { },
    ["IntelliJ IDEA"] = {
      [idx({'ctrl'}, 'n')] = true,
      [idx({'ctrl'}, 'p')] = true,
      [idx({'ctrl'}, 'm')] = true,
      [idx({'ctrl'}, 'd')] = true,
      [idx({'ctrl'}, 'h')] = true,
    },
  },
  -- system properties
  binds = {},
}

--
-- implement
--
local disableHotkeys = function (idxs)
  local fn = next(idxs)
    and (function (v)
      if (not idxs[v.idx]) then v['_hk']:disable() end
    end)
    or (function (v)
      v['_hk']:disable()
    end)

  fnutils.each(module.binds, fn)
end

local enableHotkeys = function ()
  fnutils.each(module.binds, function (v)
    v['_hk']:enable()
  end)
end

local handleGlobalAppEvent = function (name, event, app)
  if event == application.watcher.activated then
    if module.apps_custom[name] then
      module.disabled = true
      disableHotkeys(module.apps_custom[name])
    elseif module.disabled then
      enableHotkeys()
      module.disabled = false
    end
  end
end

local keyCode = function (key, modifiers, delay)
  local modifiers = modifiers or {}
  local delay = delay or 1000
  return function()
    eventtap.keyStroke(modifiers, key, delay)
  end
end

module.remapKey = function (modifiers, key, ...)
  local keyCodes = fnutils.map({...}, function (code)
    return keyCode(code[1], code[2])
  end)
  local fn = function () fnutils.ieach(keyCodes, function (f) f() end) end
  table.insert(module.binds, hotkey.bind(modifiers, key, fn, nil, fn))
end

module.applicationListener = application.watcher.new(handleGlobalAppEvent)
module.start = function () module.applicationListener:start() end
return module
