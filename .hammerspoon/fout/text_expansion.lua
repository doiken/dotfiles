spoon.SpoonInstall:andUse("TextExpansion", {
  repo = 'doiken',
  loglevel = "warning",
  config = {
    keywords = {
      mtg = function ()
        local meetings = {
          ["1"] = "- weekly朝会",
          ["2"] = "- Science 定例\n- 分析基盤定例",
          ["4"] = "- core定例\n- tech weekly\n- log定例",
          ["5"] = "- tech weekly",
        }
        local week = hs.execute("date +%w"):gsub("%s+", "")
        return meetings[week]
          and ('MTG\n\n' .. meetings[week] .. "\n\n@clipboard")
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
      collapse = '{{collapse(表示)\n<pre><code class="bash">\n@clipboard\n</code></pre>\n}}',
      code = '<pre><code class="bash">\n@clipboard\n</code></pre>\n',
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
      help = function ()
        local keyset={}
        local n=0

        for k,v in pairs(spoon.TextExpansion.keywords) do
          n=n+1
          keyset[n]=spoon.TextExpansion.prefix .. k
        end
        return table.concat(keyset, "\n")
      end,
    },
  },
  start = true
})
