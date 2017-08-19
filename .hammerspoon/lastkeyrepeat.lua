local LastKeyRepeat = {}
LastKeyRepeat.__index = LastKeyRepeat

LastKeyRepeat.TIMEOUT = 0.5
function LastKeyRepeat.new(key, modifiers)
  local self = setmetatable({}, LastKeyRepeat)
  self.modal = hs.hotkey.modal.new(modifiers, key)
  self.modal.in_ready = true
  self.modal.key = key
  self.modal.modifiers = modifiers
  self:_methodizeModal()
  return self
end

function LastKeyRepeat:_methodizeModal()
	function self.modal:entered()
      -- fire original key code
      if self.in_ready then
				keyCode(self.key, self.modifiers)()
      end
			self.alertId = hs.alert.show("Prefix Mode", 9999)
			self.timer = hs.timer.doAfter(LastKeyRepeat.TIMEOUT, function() self:exit() end)
	end

	function self.modal:exited()
			if self.alertId then
					hs.alert.closeSpecific(self.alertId)
			end

			-- self.in_ready = true
			-- self:_cancelTimeout()
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
end

function LastKeyRepeat:bind(mod, key, fn)
    self.modal:bind(mod, key, nil, function() fn(); self.modal:exit() end)
end

function LastKeyRepeat:fn(key, mod, delay)
  self.modal:exit()
	hs.alert(key)
	hs.alert(self.modal.key)
  if self.modal.in_ready then
	hs.alert('ready')
		self.modal.in_ready = false
		keyCode(key, mod)()
  else
	hs.alert('not ready')
		keyCode(self.modal.key, self.modal.modifiers)()
		keyCode(key, mod)()
  end
  -- wait enough for key delay
  hs.timer.usleep(10000)
  self.modal:enter()
end

function LastKeyRepeat:bindMultiple(mod, key)
    local lkr = self
    local fn = function() lkr:fn(key, mod); self.modal:continueTimeout() end
    self.modal:bind(mod, key, nil, fn, nil, fn)
end

local lkr = LastKeyRepeat.new('g', {'ctrl'})
lkr:bind('', 'escape')
lkr:bindMultiple('', 'h')

return LastKeyRepeat
