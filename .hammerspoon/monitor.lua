function screenwatcher()
    if string.match(hs.screen.primaryScreen():name(), 'DELL') then
      hs.timer.doAfter(4, function () hs.brightness.set(0) end)
    end
end

appWatcher = hs.screen.watcher.new(screenwatcher)
appWatcher:start()
