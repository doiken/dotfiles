hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.repos.doiken = {
   url = "https://github.com/doiken/Spoons",
   desc = "doiken's spoon repository",
}
spoon.SpoonInstall:andUse("PseudoNumKey", { repo = 'doiken', start = true })
spoon.SpoonInstall:andUse("LastKeyRepeat", {
  repo = 'doiken',
  config = {
    mapping = {
      { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'h' } },
      { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'l' } },
      { first = { key = 'g', mors = {'ctrl'} }, second = { key = 'k' } },
      { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'j' } },
    },
    appsDisable = { "iTerm2" }
  }
})
spoon.LastKeyRepeat:init():start()

spoon.SpoonInstall:andUse("SwitchableHotkey", {
  repo = 'doiken',
  config = {
    acceptOnly = {
      -- app name = { idx1, ... }
      ["iTerm2"] = {
        {{'ctrl'}, ']'},
      },
      ["Emacs"] = {},
      ["IntelliJ IDEA"] = {
        {{'ctrl'}, ']'},
        {{'ctrl'}, 'c'},
        {{'ctrl'}, 'n'},
        {{'ctrl'}, 'p'},
        {{'ctrl'}, 'm'},
        {{'ctrl'}, 'd'},
        {{'ctrl'}, 'h'},
      },
      ["PyCharm"] = {
        {{'ctrl'}, ']'},
        {{'ctrl'}, 'n'},
        {{'ctrl'}, 'p'},
        {{'ctrl'}, 'm'},
        {{'ctrl'}, 'd'},
        {{'ctrl'}, 'h'},
      },
      ["Code"] = {
        {{'ctrl'}, ']'},
        {{'ctrl'}, 'c'},
        {{'ctrl'}, 'n'},
        {{'ctrl'}, 'p'},
        {{'ctrl'}, 'm'},
        {{'ctrl'}, 'd'},
        {{'ctrl'}, 'h'},
      },
    }
  }
})

spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'f'}, {'right'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'b'}, {'left'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'n'}, {'down'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'p'}, {'up'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'e'}, {'right', {'cmd'}})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'a'}, {'left', {'cmd'}})
spoon.SwitchableHotkey:bindSpec({{'option'}, 'f'}, {'right', {'option'}})
spoon.SwitchableHotkey:bindSpec({{'option'}, 'b'}, {'left', {'option'}})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'v'}, {'pagedown'})
spoon.SwitchableHotkey:bindSpec({{'option'}, 'v'}, {'pageup'})

spoon.SwitchableHotkey:bindSpec({{'ctrl'}, ']'}, {'escape'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'c'}, {'escape'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'm'}, {'return'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'd'}, {'forwarddelete'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'h'}, {'delete'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'u'}, {'delete', {'cmd'}})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'k'}, {'right', {'shift', 'cmd'}}, {'forwarddelete'})
spoon.SwitchableHotkey:bindSpec({{'ctrl'}, 'w'}, {'delete', {'option'}})
spoon.SwitchableHotkey:bindSpec({{'option'}, 'd'}, {'forwarddelete', {'option'}})
-- SwitchableHotkey:bindSpec({{'option'}, 'h'}, {'delete', {'option'}))
--SwitchableHotkey:bindSpec({{'option', 'cmd'}, 'r'}, function () hs.reload() end)
spoon.SwitchableHotkey:init():start()

--
-- enhance fnutils
--
fnutils = require("hs.fnutils")
fnutils.foldLeft = function (tbl, func, val)
  for _, v in pairs(tbl) do
    val = func(val, v)
  end
  return val
end

fnutils.keys = function (tbl)
  local keys = {}
  for k, _ in pairs(tbl) do
    table.insert(keys, k)
  end
  return keys
end

--
-- require
--
keymaps = require("keymaps")

monitor = require("monitor")
monitor.start()

-- for cli use
require("hs.ipc")

