local eventtap = require("hs.eventtap")
local keycodes = require("hs.keycodes")

local module = {
  num_maps = {
    ["7"] = "7", ["8"] = "8", ["9"] = "9",
    ["u"] = "4", ["i"] = "5", ["o"] = "6",
    ["j"] = "1", ["k"] = "2", ["l"] = "3",
    ["m"] = "0", 
  },
}
local handler = function(e)
  local original_key = hs.keycodes.map[e:getKeyCode()]
  local fn = e:getFlags()['fn']
  replace_key = module.num_maps[original_key]

  if (fn and replace_key) then
    eventtap.keyStroke({}, replace_key, 1000)
    return ''
  end
end

module.eventListener = eventtap.new({eventtap.event.types.keyDown}, handler)
module.start = function() module.eventListener:start() end
module.stop = function() module.eventListener:stop() end

return module
