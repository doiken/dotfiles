hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall.repos.doiken = {
   url = "https://github.com/doiken/Spoons",
   desc = "doiken's spoon repository",
   branch = "master",
}

-- Load lua files in spoon directory(not version controled)
-- for customization purpose
for file in hs.fs.dir(hs.configdir .. "/" .. "Spoons") do
    if (string.match(file, "%.lua$") and file ~= "init.lua") then require("Spoons/" .. string.sub(file, 1, -5)) end
end

--
-- 3rd party Spoons
--
--
-- my Spoons
--
spoon.SpoonInstall:andUse("Snippet", {
  repo = 'doiken',
  hotkeys = { toggle_snippet = { { "cmd", "shift" }, "b" } },
  config = {
    snippets = {
      {
        text = "join lines",
        action = "shell",
        contents = "/usr/bin/pbpaste | perl -pe 's/([^\\.])[\r\n]/\\$1 /g'",
      },
      {
        text = "redash iframe",
        action = "shell",
        contents = "/Users/doi_kenji/bin/redash_iframe",
      },
      {
        text = "hs: attend",
        action = "hs",
        contents = function () spoon.FoAttendance.regist("attend") end,
      },
      {
        text = "toggle attendance",
        action = "hs",
        contents = function () spoon.FoAttendance:toggle() end,
      },
      {
        text = "other",
        action = "nest",
        contents = {
          {
            text = "fo_attendance status",
            action = "hs",
            contents = function () spoon.FoAttendance:status() end
          },
          {
            text = "redash ymd query",
            action = "text",
            contents = ([[where
              |    year = {{year}}
              |and month = {{month}}
              |and day = {{day}}
              |and hour = {{hour}}]]):gsub(" +|", ""),
          },
          {
            text = "redmine table",
            action = "text",
            contents = "|_.  |_.  |_.  |\n|  |  |  |",
          },
          {
            text = "space2table textile",
            action = "shell",
            contents = "/usr/bin/pbpaste | /Users/doi_kenji/bin/space2table.pl textile",
          },
          {
            text = "space2table markdown",
            action = "shell",
            contents = "/usr/bin/pbpaste | /Users/doi_kenji/bin/space2table.pl markdown",
          },
        },
      },
    }
  },
  fn = function (mod) mod:init() end,
})

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
  },
  fn = function (mod) mod:init() end,
  start = true,
})

spoon.SpoonInstall:andUse("SwitchableHotkey", {
  repo = 'doiken',
  config = {
    acceptOnly = {
      -- app name = { idx1, ... }
      ["iTerm2"] = {
        {{'ctrl'}, ']'},
        {{'ctrl'}, 'n'},
        {{'ctrl'}, 'p'},
      },
      ["Emacs"] = {},
      ["Android Studio"] = {
        {{'ctrl'}, ']'},
        {{'ctrl'}, 'c'},
        {{'ctrl'}, 'n'},
        {{'ctrl'}, 'p'},
        {{'ctrl'}, 'm'},
        {{'ctrl'}, 'd'},
        {{'ctrl'}, 'h'},
      },
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
        {{'ctrl'}, 'c'},
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
        {{'ctrl'}, 'h'},
        {{'ctrl'}, 'd'},
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
-- hs.chooser が持つデフォルトのキーバインドによってSwitchableHotkeyのUp, Downが効かない
-- そのため chooser 立ち上げ時のglobalCallbackにて立ち上げ/終了時に
-- キーバインドの衝突を避ける
--
local returnFn = function () hs.eventtap.keyStroke({}, "return", 1000) end
local escapeFn = function () hs.eventtap.keyStroke({}, "escape", 1000) end
hotkeys = {
  hs.hotkey.new({"ctrl"}, "m", returnFn, nil, returnFn),
  hs.hotkey.new({"ctrl"}, "c", escapeFn, nil, escapeFn),
}
hs.chooser.globalCallback = function(whichChooser, state)
  if state == "willOpen" then
    spoon.SwitchableHotkey:stop()
    hs.fnutils.each(hotkeys, function(key) key:enable() end)
  elseif state == "didClose" then
    hs.fnutils.each(hotkeys, function(key) key:disable() end)
    spoon.SwitchableHotkey:start()
  end
  hs.chooser._defaultGlobalCallback(whichChooser, state)
end

--
-- require
--
Keymaps = require("keymaps")
DisableEisuuKana = require("DisableCodes")
DisableEisuuKana.start()

-- Monitor = require("monitor")
-- Monitor.start()

-- for cli use
require("hs.ipc")
