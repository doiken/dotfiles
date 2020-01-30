hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall.repos.doiken = {
   url = "https://github.com/doiken/Spoons",
   desc = "doiken's spoon repository",
}

-- Load lua files in spoon directory(not version controled)
-- for customization purpose
for file in hs.fs.dir(hs.configdir .. "/" .. "Spoons") do
    if (string.match(file, "%.lua$") and file ~= "init.lua") then require("Spoons/" .. string.sub(file, 1, -5)) end
end

--
-- 3rd party Spoons
--
spoon.SpoonInstall:andUse("TextClipboardHistory", {
  config = {
    paste_on_select = true,
    show_in_menubar = false,
    frequency = 0.5,
  },
  hotkeys = {
    toggle_clipboard = { { "cmd", "shift" }, "v" }
  },
  start = true,
})

--
-- my Spoons
--
spoon.SpoonInstall:andUse("Snippet", {
  repo = 'doiken',
  hotkeys = { toggle_snippet = { { "cmd", "shift" }, "b" } },
  config = {
    snippets = {
      {
        text = "redmine collapse(short)",
        action = "text",
        contents = string.gsub([[{{collapse(表示)
            |
        |}}]], " +|", ""),
      },
      {
        text = "redash iframe",
        action = "shell",
        contents = "/Users/doi_kenji/bin/redash_iframe",
      },
      {
        text = "redmine short link",
        action = "shell",
        contents = "pbpaste | perl -pe 's/.*issues\\//#/g'",
      },
      {
        text = "redmine collapse(long)",
        action = "text",
        contents = [[{{collapse(表示)
<pre><code class="">

</code></pre>
}}]],
      },
      {
        text = "redash ymd",
        action = "hs",
        contents = function ()
          local format = string.gsub([[where
            |    year = %Y
            |and month = %m
            |and day = %d
            |and hour = %H
          |]], " +|", "")
          return os.date(format, os.time()-24*60*60)
        end,
      },
      {
        text = "github details",
        action = "text",
        contents = string.gsub([[<details>
          |<summary>詳細</summary>
          |
          |```
          |
          |```
          |</details>
        |]], " +|", ""),
      },
      {
        text = "toggle attendance",
        action = "hs",
        contents = function () spoon.FoAttendance:toggle() end,
      },
      {
        text = "reload config",
        action = "hs",
        contents = function () hs.reload() end,
      },
      {
        text = "other",
        action = "nest",
        contents = {
          {
            text = "task status slack",
            action = "shell",
            contents = ". ~/.zshrc.d/work.zsh;/Users/doi_kenji/Repositories/fout_sandbox/bin/task_status.rb slack",
          },
          {
            text = "task status qiita",
            action = "shell",
            contents = ". ~/.zshrc.d/work.zsh;/Users/doi_kenji/Repositories/fout_sandbox/bin/task_status.rb qiita",
          },
          {
            text = "fo_attendance status",
            action = "hs",
            contents = function ()
              local isStarted = (spoon.FoAttendance._isStarted or false) and 1 or 0
              local timer = spoon.FoAttendance._timer
              local next = timer ~= nil
                and math.floor(timer:nextTrigger() / 3600) .. "時間後"
                or "none"
              local info = ("isStarted: %d nextTrigger: %s"):format(isStarted, next)
              hs.notify.show("FoAttendance", "", info)
            end
          },
          {
            text = "qiita detail",
            action = "text",
            contents = string.gsub([[<details><summary></summary><div>
              |``` 
              |```
              |</div></details>
            |]], " +|", ""),
          },
          {
            text = "redash ymd query",
            action = "text",
            contents = string.gsub([[where
              |    year = {{year}}
              |and month = {{month}}
              |and day = {{day}}
              |and hour = {{hour}}]], " +|", ""
            ),
          },
          {
            text = "redmine table",
            action = "text",
            contents = "|_.  |_.  |_.  |\n|  |  |  |",
          },
          {
            text = "redash unnest",
            action = "text",
            contents = [[CROSS JOIN UNNEST(split(bid_candidates,',')) AS c (candidate_bid_id)]],
          },
          {
            text = "IAM ROLE",
            action = "text",
            contents = [[arn:aws:iam::723941195937:role/AmazonSageMaker-ExecutionRole]],
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
keymaps = require("keymaps")

monitor = require("monitor")
monitor.start()

-- for cli use
require("hs.ipc")

