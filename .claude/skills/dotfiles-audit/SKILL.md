---
name: dotfiles-audit
description: dotfiles の総点検。壊れた設定・非推奨ツール・改善候補をサブエージェント並列調査で洗い出し、承認を得て修正・検証する。「dotfiles 見直し」「環境の棚卸し」「壊れてる設定ない?」といった依頼で使用。Claude Code 設定・利用実績の振り返りは retro を使う(対象が異なる)。
user-invocable: true
argument-hint: "[zsh | git | bin | brew など領域指定 | 省略で全体]"
---

# dotfiles 総点検

引数で領域を絞れる。省略時は全体。各ステップは報告して承認を得てから次へ進む。

## Step 1: 構成把握と並列調査

`git ls-files` で構成を掴み、領域別に読み取り専用サブエージェントを並列起動する
(例: zsh / git・tmux・vim / bin スクリプト / Hammerspoon・setup・Brewfile)。

各エージェントの調査観点:
- **実在確認**: 参照先のパス・コマンドを which / ls / readlink で必ず実機確認
  (Intel→ARM 移行残骸 /usr/local、formula 名変更、削除済みファイルへの参照)
- **typo・デッドコード**: 後勝ちで無効化された設定、常に偽の条件分岐、export 漏れ
- **非推奨**: アーカイブ済みツール(hub, zplug 等)、廃止 tap/cask、deprecated オプション
  (git は実行して警告実測、tmux はバージョンと突き合わせ)
- **$HOME リンク整合**: setup スクリプトのリンク対象とリポジトリ実ファイルの差分、壊れたリンク
- **起動速度**: サブシェル呼び出し(brew --prefix 等)、compinit、毎起動の外部コマンド

## Step 2: 分類報告と承認

「壊れている(実行時エラー)/ 死に設定(無害だが無意味)/ 非推奨 / 改善候補」に分類し、
ファイル:行番号と根拠付きで報告。対応方針を**通し番号の選択肢**で提示し承認を待つ。

## Step 3: 修正

- Edit/Write で直せるものは直接。**rm・git rm は permission で拒否されやすい**ので、
  拒否されたら即座にユーザー実行用コマンドをまとめて提示する(絶対パス・複数一括)
- ツール入替は brew install/uninstall とセットで。Brewfile と実環境の両方を更新する

## Step 4: 検証

- zsh: `zsh -n <file>`(構文)と `zsh -ic '...'`(実挙動: alias / bindkey / which)
- git: `git config --get alias.xxx` で新 alias の引用符エスケープを確認
- **稼働中デーモンに注意**: tmux サーバ等は起動時の設定を保持し続けるため、設定ファイル
  修正+依存ツール uninstall の組合せで既存プロセスが壊れる。`tmux set -gu <option>` の
  ような稼働側の追従措置まで行う

## Step 5: 最終レビュー

全変更をコミットする前に、意図した変更リストを添えてサブエージェントに
`git diff` 全体を再点検させる(漏れ / 誤り / 想定外変更 / 削除ファイルへの参照残り)。

## 注意

- push 済みコミットの amend は pull --rebase 時に自分自身と衝突する。修正は別コミットを案内
- 作業ツリーが突然巻き戻って見えたら、ユーザーの並行 git 操作(rebase 途中で停止等)を疑い、
  `git status` と reflog を確認してから動く
