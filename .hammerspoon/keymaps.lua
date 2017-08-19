local function disableHotkeys()
   for k, v in pairs(getEmacsBinds()) do
      v['_hk']:disable()
   end
end

local function enableHotkeys()
   for k, v in pairs(getEmacsBinds()) do
      v['_hk']:enable()
   end
end

local function handleGlobalAppEvent(name, event, app)
   if event == hs.application.watcher.activated then
      -- hs.alert.show(name)
      if (name ~= "iTerm2") and (name ~= "Emacs") then
         enableHotkeys()
      else
         disableHotkeys()
      end
   end
end

appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()

remapKey({'ctrl'}, 'e', keyCode('right', {'cmd'}))
remapKey({'ctrl'}, 'a', keyCode('left', {'cmd'}))
remapKey({'ctrl'}, 'u', keyCode('delete', {'cmd'}))
-- simple ctrl k not work in chrome searchbar
-- remapKey({'ctrl'}, 'k', keyCode('forwarddelete', {'cmd'}))
remapKey({'ctrl'}, 'k', function () keyCode('right', {'shift', 'cmd'})() keyCode('forwarddelete')() end)

remapKey({'ctrl'}, 'f', keyCode('right'))
remapKey({'ctrl'}, 'b', keyCode('left'))
remapKey({'ctrl'}, 'n', keyCode('down'))
remapKey({'ctrl'}, 'p', keyCode('up'))

remapKey({'ctrl'}, 's', keyCode('f', {'cmd'}))
remapKey({'ctrl'}, 'm', keyCode('return'))
remapKey({'ctrl'}, 'w', keyCode('delete', {'option'}))
remapKey({'ctrl'}, 'd', keyCode('forwarddelete'))
remapKey({'ctrl'}, 'h', keyCode('delete'))
-- remapKey({'ctrl'}, 'i', keyCode('tab'))

-- remapKey({'ctrl'}, 'y', keyCode('v', {'cmd'}))
-- remapKey({'ctrl'}, '/', keyCode('z', {'cmd'}))

remapKey({'option'}, 'f', keyCode('right', {'option'}))
remapKey({'option'}, 'b', keyCode('left', {'option'}))
remapKey({'option'}, 'd', keyCode('forwarddelete', {'option'}))
-- remapKey({'option'}, 'h', keyCode('delete', {'option'}))
-- remapKey({'option', 'shift'}, ',', keyCode('home'))
-- remapKey({'option', 'shift'}, '.', keyCode('end'))

remapKey({'ctrl'}, 'v', keyCode('pagedown'))
remapKey({'option'}, 'v', keyCode('pageup'))
