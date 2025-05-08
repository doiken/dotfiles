spoon.SpoonInstall:andUse("TextExpansion", {
  repo = 'doiken',
  loglevel = "warning",
  config = {
    keywords = {
      mtg = function ()
        local meetings = {
          ["1"] = "- tech manager 定例",
          ["4"] = "- Science 定例\n- core定例\n- tech weekly\n- log定例",
          ["5"] = "- Red PM MTG\n- tech weekly",
        }
        local week = hs.execute("date +%w"):gsub("%s+", "")
        return meetings[week]
          and (meetings[week] .. "\n\n@clipboard")
          or ""
      end,
      ymd = function ()
          local format = ([[select *
            |from parquet_jp.ad
            |where
            |    year = %Y
            |and month = %m
            |and day = %d
            |and hour = %H
          |]]):gsub(" +|", "")
          return os.date(format, os.time()-24*60*60)
      end,
      collapse = function ()
        code = hs.execute("env LANG=ja_JP.UTF-8 /usr/bin/pbpaste | ~/bin/wrap_code_with_language.pl")
        return '{{collapse(表示)\n' .. code .. '\n}}'
      end,
      values = ([[select * from (
          |    values
          |        (1, 'a'),
          |        (2, 'b'),
          |        (3, 'c')
          |) as t (id, name)]]):gsub(" +|", ""),
      code = function ()
        return hs.execute("env LANG=ja_JP.UTF-8 /usr/bin/pbpaste | ~/bin/wrap_code_with_language.pl")
      end,
      details = ([[<details>
          |<summary>詳細</summary>
          |
          |```
          |@clipboard
          |```
          |</details>
        |]]):gsub(" +|", ""),
      task = function ()
        return hs.execute(". ~/.zshrc.d/work.zsh;/Users/doi_kenji/Repositories/fout_sandbox/bin/task_status.rb qiita 10")
      end,
      aligned = "\\begin{aligned}\n\\end{aligned}",
      tex = ([[katex で次の条件で式を書いて。
        |- コピーできる
        |- イコールの位置を aligned で揃える
        |- 一つの式ごとに数式の改行 "\\" と文字の改行 "\n" を与える
        |
        |例:
        |```
        |\begin{aligned}
        |x &= 1 \\
        |
        |y &= 2 \\
        |\end{aligned}
        |```
        |
        |@clipboard
        |]]):gsub(" +|", ""),
    },
  },
  start = true
})
