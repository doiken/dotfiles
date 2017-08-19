--
-- setting
--
local mapping = {
  --    { first = { key = 'g', mods = {'ctrl'} }, second = { { key = 'h' }, { key = 'l' } } },
  { first = { key = 'g', mods = {'ctrl'} }, second = { { key = 'h' } } },
}

--
-- implement
--
local LastKeyRepeat = {}
LastKeyRepeat.__index = LastKeyRepeat
LastKeyRepeat.TIMEOUT = 0.5

local log = hs.logger.new('lastkeyrepeat','debug')
function LastKeyRepeat.new(first, second)
  local self = setmetatable({}, LastKeyRepeat)
  self.modal = hs.hotkey.modal.new(first["mods"], first["key"])
  self.first = first
  self.modal.in_ready = true
  self:_methodizeModal()

  -- bind second stroke
  hs.fnutils.map(second, function (t)
    self:bindMultiple(t["mods"], t["key"], self:fn(t["mods"], t["key"], true))
  end)
  -- self.modal:bind('', 'escape')
  return self
end

function LastKeyRepeat:_methodizeModal()
  function self.modal:entered()
    if self.alertId then
      log:d("alertId already set")
      return
    end

    self.alertId = hs.alert.show("Prefix Mode", 9999)
    self.timer = hs.timer.doAfter(LastKeyRepeat.TIMEOUT, function() self:exit() end)
    -- fire original key code
    if self.in_ready then
      self.in_ready = false
      keyCode(lkr.first["key"], lkr.first["modifiers"])()
    end
  end

  function self.modal:exited()
    if self.alertId then
        hs.alert.closeSpecific(self.alertId)
        self.alertId = nil
    end

    self.in_ready = true
    self:_cancelTimeout()
  end

  function self.modal:_cancelTimeout()
    if self.timer then
        self.timer:stop()
    end
  end

  function self.modal:continueTimeout()
    if self.timer then
        self.timer:stop()
        self.timer = hs.timer.doAfter(LastKeyRepeat.TIMEOUT, function() self:exit() end)
    end
  end

--  function self.modal:bind(mod, key, fn)
--    self:bind(mod, key, nil, function() fn(); self:exit() end)
--  end
end

function LastKeyRepeat:fn(mods, key, is_first)
  local lkr = self
  local switcher
  if is_first then
    log:d("is_first: true")
  else
    log:d("is_first: false")
  end

  if is_first then
    return function()
      log:d("first switcher")
      lkr:bindMultiple(mods, key, self:fn(mods, key, false))
    end
  else
    return function()
      log:d("second or later switcher")
      keyCode(lkr.first["key"], lkr.first["modifiers"])()
    end
  end
  -- wait enough for key delay
  --    hs.timer.usleep(10000)
  --    self.modal:enter()
end

function LastKeyRepeat:bindMultiple(mods, key, fn)
  local lkr = self
  local f = function ()
    log:d("fire fn")
    fn()
    lkr.modal:continueTimeout()
  end
  self.modal:bind(mods, key, nil, f, nil, f)
end

return hs.fnutils.map(mapping, function (t)
  return LastKeyRepeat.new(t["first"], t["second"])
end)


