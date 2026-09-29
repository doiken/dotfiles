-- ホームディレクトリ名はマシンによって異なるので環境変数から取得する
local HOME = os.getenv("HOME")

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.use_syncinstall = true
spoon.SpoonInstall.repos.doiken = {
  url = "https://github.com/doiken/Spoons",
  desc = "doiken's spoon repository",
  branch = "master",
}
-- spoon.SpoonInstall.repos.doiken2 = {
--   url = "https://github.com/doiken/Spoons-1",
--   desc = "doiken's spoon repository2",
--   branch = "fix/brewinfo-configurable-brew-path",
-- }
-- spoon.SpoonInstall:andUse("BrewInfo", {
--   repo = 'doiken2',
--   config = { brew_path = '/opt/homebrew/bin/brew' },
-- })

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
  branch = 'lang_in_shell',
  hotkeys = { toggle_snippet = { { "cmd", "shift" }, "b" } },
  config = {
    lang_in_shell = "ja_JP.UTF-8",
    snippets = {
      {
        text = "join lines",
        action = "shell",
        contents = "/usr/bin/pbpaste | perl -pe 's/([^\\.])[\r\n]/$1 /g'",
      },
      {
        text = "redmine table",
        action = "text",
        contents = "{background:#E6E6E6}. |_.  |_.  |_.  |\n|  |  |  |",
      },
      {
        text = "space2table textile",
        action = "shell",
        contents = "/usr/bin/pbpaste | " .. HOME .. "/bin/space2table.pl textile",
      },
      {
        text = "space2table markdown",
        action = "shell",
        contents = "/usr/bin/pbpaste | " .. HOME .. "/bin/space2table.pl markdown",
      },
      {
        text = "other",
        action = "nest",
        contents = {
          {
            text = "redash ymd query",
            action = "text",
            contents = ([[where
              |    year = {{year}}
              |and month = {{month}}
              |and day = {{day}}
              |and hour = {{hour}}]]):gsub(" +|", ""),
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
      { first = { key = 'g', mods = {'ctrl'} }, second = { key = 'k' } },
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
      ["Warp"] = {
        {{'ctrl'}, ']'},
        {{'ctrl'}, 'n'},
        {{'ctrl'}, 'p'},
      },
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
DisableEisuuKana = require("DisableCodes")
DisableEisuuKana.start()

-- for cli use
require("hs.ipc")


