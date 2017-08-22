--
-- setting
--
local module = {
  names = { "DELL" }
}

--
-- implement
--
local screen = require "hs.screen"
local fnutils = require "hs.fnutils"
local timer = require "hs.timer"
local brightness = require "hs.brightness"
local caffeinate = require "hs.caffeinate"
local logger = require "hs.logger"
local log = logger.new('lastkeyrepeat', 'debug')

local darkenWhenTarget = function ()
  local matchScreen = function(name)
    return string.match(screen.primaryScreen():name(), name)
  end
  if fnutils.some(module.names, matchScreen) then
    timer.doAfter(4, function () brightness.set(0) end)
  end
end

local screenHandler = function ()
  darkenWhenTarget()
end

local caffeinateHandler = function (state)
  if state == caffeinate.watcher.systemDidWake then
    darkenWhenTarget()
  end
end

module.screenWatcher = screen.watcher.new(screenHandler)
module.caffeinateWatcher = caffeinate.watcher.new(caffeinateHandler)

module.start = function()
  module.screenWatcher:start()
  module.caffeinateWatcher:start()
end
module.stop = function()
  module.screenWatcher:stop()
  module.caffeinateWatcher:stop()
end
module.start() -- auto start

return module
