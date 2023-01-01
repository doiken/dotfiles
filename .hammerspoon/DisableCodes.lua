local eventtap = require("hs.eventtap")
local event    = eventtap.event
local keycodes = require("hs.keycodes")
local logger = require("hs.logger").new('DisableCodes')

local module = {
    disable_codes = {
        -- code -> true
        -- なぜか ctrl + eisuu/kana が ctrl + space に変換されて spotlight が暴れるため無効化
        [keycodes.map.eisu] = true,
        [keycodes.map.kana] = true,
    },
}

local function handleEvent(e)
    if not module.disable_codes[e:getKeyCode()] then
        return false
    elseif e:getFlags():containExactly({}) then
        return false
    end
    return true
end
module.eventListener = eventtap.new({ event.types.flagsChanged, event.types.keyDown, event.types.keyUp }, handleEvent)
module.start = function() module.eventListener:start() end
module.stop = function() module.eventListener:stop() end

return module
