local application = require("hs.application")
local hotkey = require("hs.hotkey")

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
  }
}

--
-- implement
--
local function disableHotkeys(idxs)
  local fn = next(idxs)
    and (function (v)
      if (not idxs[v.idx]) then v['_hk']:disable() end
    end)
    or (function (v)
      v['_hk']:disable()
    end)

  fnutils.each(hotkey.getHotkeys(), fn)
end

local function enableHotkeys()
  fnutils.each(hotkey.getHotkeys(), function (v)
    v['_hk']:enable()
  end)
end

local function handleGlobalAppEvent(name, event, app)
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

module.applicationListener = application.watcher.new(handleGlobalAppEvent)
module.start = function () module.applicationListener:start() end
return module
