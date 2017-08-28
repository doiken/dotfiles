-- thanks to https://github.com/raulchen/dotfiles/blob/master/hammerspoon/double_cmdq_to_quit.lua
local modal = require("hs.hotkey.modal")
local alert = require("hs.alert")
local timer = require("hs.timer")
local fnutils = require("hs.fnutils")

local module = {
  timeout = 0.5,
  mapping = {
    {
      {{{'option'}, 'fn', {}, 'r'}, function () hs.reload() end},
    },
  }
}

local modalize = function (modal, timeout)
  function modal:entered()
    modal.timer = timer.doAfter(timeout, function() modal:exit() end)
  end

  function modal:exited()
    if modal.timer then
      modal.timer:stop()
    end
  end
end

local initModal = function (...)
  local stroke1st, mods1st, key1st, stroke2nd{mods2nd, key2nd, cmd}, timeout = ...
  local modal = modal.new(mods1st, key1st)
  modalize(modal)

  
end

function module.exit()
  modal:exit()
end


function module.bind(mod, key, fn)
  modal:bind(mod, key, nil, function() fn(); module.exit() end)
end

function module.bindMultiple(mod, key, pressedFn, releasedFn, repeatFn)
  modal:bind(mod, key, pressedFn, releasedFn, repeatFn)
end

for k, v in pairs(t) do -- they'll potentially be out of order, but they always were anyway
  local quitModal = modal.new('cmd','q')
  nt[isListIndex(k) and (#nt+1) or k] = fn(v) -- meh, but required for compatibility
end
local module = {}



module.bind('', 'escape', module.exit)
module.bind('ctrl', 'space', module.exit)

module.bind('', 'd', hs.toggleConsole)
module.bind('', 'r', hs.reload)

return module
