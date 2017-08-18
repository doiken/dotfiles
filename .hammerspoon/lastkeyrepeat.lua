local module = {}

local TIMEOUT = 0.5

local modal = hs.hotkey.modal.new('ctrl', 'g')

function modal:entered()
    modal.alertId = hs.alert.show("Prefix Mode", 9999)
    modal.timer = hs.timer.doAfter(TIMEOUT, function() modal:exit() end)
end

function modal:exited()
    if modal.alertId then
        hs.alert.closeSpecific(modal.alertId)
    end
    module.cancelTimeout()
end

function module.exit()
    modal:exit()
end

function module.cancelTimeout()
    if modal.timer then
        modal.timer:stop()
    end
end

function module.continueTimeout()
    if modal.timer then
        modal.timer:stop()
				modal.timer = hs.timer.doAfter(TIMEOUT, function() modal:exit() end)
    end
end

function module.bind(mod, key, fn)
    modal:bind(mod, key, nil, function() fn(); module.exit() end)
end

function module.bindMultiple(mod, key, pressedFn, releasedFn, repeatFn)
    modal:bind(mod, key, function() pressedFn(); module.continueTimeout() end, releasedFn, repeatFn)
end

module.bind('', 'escape', module.exit)

module.bindMultiple('', 'h', keyCode('', 'a'))

return module
