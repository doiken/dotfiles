--
-- setting
--

-- be sure to disable 'Automatically adjust brightness'
-- ref: https://support.apple.com/kb/PH25444?locale=en_US
local module = {
  names = { "DELL" },
  delay = 4
}

--
-- implement
--
local screen = require("hs.screen")
local fnutils = require("hs.fnutils")
local timer = require("hs.timer")
local brightness = require("hs.brightness")
local caffeinate = require("hs.caffeinate")
local log = require("hs.logger").new(debug.getinfo(1,'S').source, 'debug')
local darkenWhenTarget
darkenWhenTarget = function ()
  if not screen.primaryScreen():name() then
    log:d("failed to get screen name. retry in a few seconds.")
    timer.doAfter(module.delay, darkenWhenTarget)
    return
  end
  local matchScreen = function(name)
    return string.match(screen.primaryScreen():name(), name)
  end

  if fnutils.some(module.names, matchScreen) then
    timer.doAfter(module.delay, function () brightness.set(0) end)
  end
end

local screenHandler = function ()
  darkenWhenTarget()
end

local caffeinateHandler = function (state)
  local watcher = caffeinate.watcher
  if fnutils.some({ watcher.systemDidWake, watcher.screensDidWake }, function (s) return s == state end) then
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

return module
