---
name: oss-contribute
description: |
  OSSへのコントリビュートを段階的に支援する。
  候補リポジトリ・issue選定 → 再現確認 → 修正 → PR文章作成 の流れで進める。
  各ステップで報告し、ユーザー確認を挟む。PR の自動作成は行わない。
argument-hint: "[言語やライブラリのヒント（例: 'Python scikit-learn系'）]"
allowed-tools:
  - Agent
  - Bash
  - Read
  - Edit
  - Write
  - Grep
  - Glob
  - WebFetch
  - AskUserQuestion
---

# OSS Contribute

OSSへのコントリビュート（主にバグ修正PR）を段階的に支援するスキル。
各ステップでユーザーに報告・確認を取りながら進める。

## 原則

- **PR の自動作成（`gh pr create`）は絶対に行わない**。PR文章のドラフトまでが範囲
- **各ステップの完了時に必ず報告し、次に進む前にユーザー確認を取る**
- コミットもユーザーの明示的な指示があるまで行わない
- fork 操作は確認の上で実施する（fork 先は `doiken/REPO_NAME`）
- **既存ユーザーの動作を壊す破壊的変更は避ける**。修正はあくまで既存の振る舞いを維持した上でのバグ修正や機能追加に留めること
- **コードの修正を伴う**ものとする。document やコメント、テストのみの修正は対象外
- **コンテキスト肥大を防ぐため、調査は subagent に委譲する**
- **Bash の承認回数を最小化する**。venv の python フルパス（例: `/var/tmp/osc/REPO/.venv/bin/python`）を使い、`cd` や `source activate` を不要にする。`&&` チェーンも避け、各コマンドを独立して実行する
- **代替手段がある場合は `cd` を使わない**。git 操作は `git -C /var/tmp/osc/REPO_NAME` で、その他のコマンドもフルパス指定で実行する
- **Bash コマンドでリダイレクト文字 `>` を使わない**。`>` を含むコマンドは `Bash(gh search *)` 等の allow ルールにマッチしないバグがある（[claude-code#13137](https://github.com/anthropics/claude-code/issues/13137)）。日付フィルタは `--created ">2026-01-01"` ではなく `--created "2026-01-01..2026-12-31"` の**レンジ形式**を使う。Stars フィルタも `--stars ">100"` ではなく `--stars "100..999999"` とする。`2>&1` も付けない
- **経験を蓄積・参照・ブラッシュアップする**。保存先は `~/.claude/skills/oss-contribute/experience/` 内。詳細は各ステップの「経験」項を参照

## 候補の品質チェックリスト

| # | チェック項目 | 実施タイミング | 確認方法 |
|---|------------|-------------|---------|
| 0 | issue 本文に traceback or 再現コードがある | Step 1 (subagent) | `gh issue view` で目視（なければスキップ） |
| 1 | 既存 PR がない（open AND closed） | Step 1 (subagent) | `gh pr list --search "ISSUE_NUMBER" --state all` |
| 2 | issue 作成者・コメント者が PR 意欲を示していない | Step 1 (subagent) | `gh issue view` + コメント全件確認 |
| 3 | 最新 HEAD でバグが再現する | Step 2 | clone → 再現スクリプト実行 |
| 4 | 修正が既存の動作を変えない | Step 2 | クラッシュ→正常動作の修正が最も安全 |
| 5 | 修正方針が一意に定まる | Step 2 | コード読解で判断 |
| 6 | 10人の開発者全員が納得する修正か | Step 2 | 仕様・RFC等の根拠確認 |

不合格時の対応: いずれも即除外（チェック4のみリスク明記で続行可能な場合あり）

## ステップ

### Step 1: 候補の選定（subagent で GitHub グローバル検索）

Agent ツールで subagent を起動。**clone や再現確認は行わない**。
**issue → リポジトリの逆引き**で候補を探す（リポジトリを先に決めない）。

subagent への指示テンプレート:

```
以下の条件で OSS コントリビュートの候補 issue を探してください。
**GitHub API 調査のみ行い、clone や再現確認は行わないでください。**
**リポジトリを先に決めるのではなく、GitHub グローバル検索で条件に合う issue を直接探してください。**

## ユーザーの条件
- 言語/技術領域: $ARGUMENTS（ユーザー入力がなければ AskUserQuestion で確認）

## 検索方法
GitHub グローバル検索で issue を横断検索する:
```
gh search issues --language python --label bug --state open \
  --created "YYYY-MM-DD..YYYY-MM-DD" -- "traceback" "TypeError OR ValueError OR AttributeError"
```
- 作成日: 直近4週間以内（レンジ形式で指定。`>` は使わない）
- 追加フィルタ: `--stars "100..999999"` など適宜調整（`>` は使わない）
- 検索キーワードは traceback、エラー名を組み合わせる
- 結果が少なければラベルを `help wanted` などに変えて再検索。 `good first issue` は本当の初心者向けなので譲る。

## 選定フィルタ（コストの低い順に適用）

### フィルタ0: issue 本文に traceback or 再現コードがあるか（読むだけ）
`gh issue view` で確認。再現情報がなければスキップ（再現スクリプト自作のコストが高い）。

### チェック1: 既存 PR がない
`gh pr list --repo OWNER/REPO --search "ISSUE_NUMBER" --state all` を実行。
open でも closed でも PR が1件でもあれば除外。

### チェック2: PR 意欲を示していない
`gh issue view --repo OWNER/REPO ISSUE_NUMBER` で本文確認。
`gh api repos/OWNER/REPO/issues/ISSUE_NUMBER/comments` でコメント全件確認。
「PR出します」「取り組み中」「I'll submit a PR」「working on it」等があれば除外。

## リポジトリの最低条件
- Stars 100 以上（メンテ放置リスク回避）
- pip install + pytest で環境構築が完結（Docker 不要）
- PR フローがシンプル（CLA 不要 or 簡易）
- **コードの修正を伴う** issue であること（docs/lint/test のみは対象外）

## 出力フォーマット（3〜5件）
各候補について:
- リポジトリ名（owner/repo）、Stars数
- Issue番号、タイトル、URL
- バグの概要（何がクラッシュ/例外するか）
- 再現手順（issue から抜粋した最小コード or traceback）
- ✅/❌ フィルタ0: 再現情報あり — [有無]
- ✅/❌ チェック1: 既存PRなし — [確認結果]
- ✅/❌ チェック2: PR意欲なし — [コメント要約]
- 修正難易度（低/中/高）
- マージ確率（高/中/低）

不合格だった issue も、どのチェックで落ちたか簡潔に報告。
```

**報告**: 候補一覧を表形式でユーザーに提示。

**経験（Step 1）**:
- **開始時**: `~/.claude/skills/oss-contribute/experience/search.md` を Read。過去に有効だったクエリ・棄却パターンを参考に検索戦略を立てる
- **終了時**: 以下を同ファイルに追記（なければ新規作成）
  - 有効だった検索クエリとヒット率の所感
  - 無駄だったアプローチ（例: 特定ラベルの組み合わせが空振り）
  - 棄却理由のパターン（例: 「○○系リポジトリは CLA 必須が多い」）
- **ブラッシュアップ**: 蓄積が増えてきたら古い・重複する記述を整理統合する

### Step 2: 再現確認 + 修正範囲見積もり

ユーザーが選んだ issue について、以下を実行する。

**コマンド実行の原則**: venv の python フルパスを使い、`cd` / `source activate` / `&&` チェーンを避ける。

```
# 例: clone & setup（各コマンドを個別に実行）
git clone --depth 1 REPO_URL /var/tmp/osc/REPO_NAME
uv venv --python 3.11 -p /var/tmp/osc/REPO_NAME/.venv
/var/tmp/osc/REPO_NAME/.venv/bin/pip install -e /var/tmp/osc/REPO_NAME

# 例: 再現スクリプト実行（フルパスで直接実行）
/var/tmp/osc/REPO_NAME/.venv/bin/python /var/tmp/osc/reproduce_REPO_ISSUE.py

# 例: テスト実行
/var/tmp/osc/REPO_NAME/.venv/bin/python -m pytest /var/tmp/osc/REPO_NAME/tests/ -x -q -k "keyword"
```

手順:
1. リポジトリを `/var/tmp/osc/REPO_NAME` に clone
2. venv 作成・依存インストール
3. 再現スクリプトを Write ツールで `/var/tmp/osc/reproduce_{REPO}_{ISSUE}.py` に作成
4. フルパス python で再現スクリプトを実行
5. 結果を確認し、チェック3〜6を評価
6. **ユーザーに報告**:
   - 再現結果（成功/失敗）
   - 修正対象ファイルとコード箇所（コードは Read ツールで確認）
   - 想定される変更行数
   - チェック4〜6の評価結果
   - 設計判断が絡むリスクの有無

**経験（Step 2）**:
- **開始時**: `~/.claude/skills/oss-contribute/experience/reproduce.md` を Read。再現・環境構築で過去に詰まったポイントを確認
- **終了時**: 新たな知見があれば同ファイルに追記
  - 環境構築の罠（例: 「○○は `pip install -e .[dev]` が必要」）
  - 再現が難しかったケースとその原因
- **ブラッシュアップ**: 古い・重複する記述を整理統合する

### Step 3: 修正

コマンド実行は Step 2 と同様にフルパス python を使用する。

1. ユーザーの fork リポジトリをクローン（`git clone`）
2. 修正ブランチを作成
3. コードを修正（Edit ツール使用）
4. 修正後に再現スクリプトで解消を確認
   - `/var/tmp/osc/REPO_NAME/.venv/bin/python /var/tmp/osc/reproduce_{REPO_NAME}_{ISSUE_NUMBER}.py`
5. 既存テスト全パスを確認
   - `/var/tmp/osc/REPO_NAME/.venv/bin/python -m pytest ...`
6. 必要に応じてテストケースを追加
7. **ユーザーに報告**:
   - diff の全体像
   - テスト結果
   - 修正の説明（リポジトリ概要、issue内容とURL、修正内容、再現スクリプトの実行コマンドを簡潔に）

**経験（Step 3）**:
- **開始時**: `~/.claude/skills/oss-contribute/experience/coding.md` を Read。過去のユーザー指摘・修正パターンを確認し、同じ指摘を繰り返さない
- **ユーザーフィードバック受領時**: 指摘内容を同ファイルに即座に記録
  - コードスタイルへの指摘（例: 「テストは最小限に」「不要なコメントを入れない」）
  - 修正方針への指摘（例: 「破壊的変更を避けるべきだった」）
  - メンテナの傾向（例: 「davidism は LLM 利用の PR に厳しい」）
- **ブラッシュアップ**: 同種の指摘が複数あれば一般化してルールに昇格させる

### Step 4: コミット & PR文章作成

1. `<プロジェクトルート>/worktrees/pr-$ARGUMENTS` にシンボリックリンクを作成する（IDE参照用）
2. ユーザーの確認後、コミット（メッセージは内容を表す1行のみ。リポジトリの慣例に合わせる。共著表記は省略）
3. PR の Title と Body をドラフトとして提示
4. **プッシュ・PR作成はユーザーの手動操作に任せる**

PR Body テンプレート:
```
## Summary
- [1行で問題を説明]
- [1行で修正内容を説明]

## Test plan
- [追加したテストの説明]
- [既存テスト全パスの確認]

Closes #ISSUE_NUMBER
```

## ワークフロー設計

https://qiita.com/uno_ha07/items/5820d195510861b5be71#1-plan-mode-defaultplanモードを基本とする

### 5. エレガントさを追求する（バランスよく）
- 重要な変更をする前に「もっとエレガントな方法はないか？」と一度立ち止まる
- ハック的な修正に感じたら「今知っていることをすべて踏まえて、エレガントな解決策を実装する」
- シンプルで明白な修正にはこのプロセスをスキップする（過剰設計しない）
- 提示する前に自分の作業に自問自答する