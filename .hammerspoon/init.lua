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
spoon.SpoonInstall:andUse("TextClipboardHistory", {
  config = {
    paste_on_select = true,
    show_in_menubar = false,
    frequency = 0.5,
    hist_size = 500,
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
        text = "redash iframe",
        action = "shell",
        contents = "/Users/doi_kenji/bin/redash_iframe",
      },
      {
        text = "redmine collapse(long)(;collapse)",
        action = "text",
        contents = ([[{{collapse(表示)
          |<pre><code class="">
          |
          |</code></pre>
          |}}]]):gsub(" +|", "")
      },
      {
        text = "redash ymd(;ymd)",
        action = "hs",
        contents = function ()
          local format = ([[where
            |    year = %Y
            |and month = %m
            |and day = %d
            |and hour = %H
          |]]):gsub(" +|", "")
          return os.date(format, os.time()-24*60*60)
        end,
      },
      {
        text = "markdown details(;details)",
        action = "text",
        contents = ([[<details>
          |<summary>詳細</summary>
          |
          |```
          |
          |```
          |</details>
        |]]):gsub(" +|", ""),
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
        text = "task status(;task)",
        action = "shell",
        contents = ". ~/.zshrc.d/work.zsh;/Users/doi_kenji/Repositories/fout_sandbox/bin/task_status.rb qiita 10",
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

-- snippet の contents を other から取得
--   GetContents('some_text', )
GetContents = function (text, isHs) 
  local snippet = spoon.Snippet
  local e = hs.fnutils.find(snippet.snippets, function (e) return e.text == text end)
  return isHs
    and spoon.Snippet._contentsMap[e.contents]
    or  e.contents
end

spoon.SpoonInstall:andUse("TextExpansion", {
  repo = 'doiken',
  loglevel = "warning",
  config = {
    keywords = {
      mtg = function ()
        local meetings = {
          ["2"] = "- Science 定例\n- 粗利率自動調整",
          ["4"] = "- core定例\n- tech weekly",
          ["5"] = "- tech weekly",
        }
        local week = hs.execute("date +%w"):gsub("%s+", "")
        return meetings[week]
          and ('MTG\n\n' .. meetings[week])
          or ""
      end,
      ymd = GetContents("redash ymd(;ymd)", true),
      collapse = '{{collapse(表示)\n}}',
      ["+collapse"] = function ()
        local txt = hs.pasteboard.getContents()
        return '{{collapse(表示)\n<pre><code class="text">\n' .. txt .. '\n</code></pre>\n}}'
      end,
      details = '<details>\n<summary>詳細</summary>\n\n</details>',
      task = function () return hs.execute(GetContents("task status(;task)")) end,
      aligned = "\\begin{aligned}\n\\end{aligned}",
    },
  },
  start = true
})
