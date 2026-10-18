# claude-team-pack

Claude Code で、**マネージャー・作業者・レビュー役の3役**でタスクを進める `/team` スキル一式です。

## 構成

| 役 | ファイル | モデル | 権限 |
|---|---|---|---|
| マネージャー | `skills/team/SKILL.md`（`/team` を打ったセッション自身） | Sonnet | コードを書かない。計画と進行管理だけ |
| 作業者 | `agents/team-worker.md` | Sonnet | Read / Write / Edit / Glob / Grep / Bash |
| レビュー役 | `agents/team-reviewer.md` | Opus | Read / Grep / Glob / Bash（ファイルを変更しない） |

3ファイルはセットです。スキルは `team-worker` と `team-reviewer` を名前で呼ぶので、1つでも欠けると動きません。

## 流れ

```
/team <依頼>
  1. 計画を立てる（マネージャー）
  2. 計画レビュー    team-reviewer (mode: plan)  最大2回  GO / 条件付きGO / NO-GO
  3. 実装            team-worker
  4. 成果物レビュー  team-reviewer (mode: code)  最大2回  OK / 要修正
  5. 最終報告（変更ファイル、テスト結果、レビュー経過、見送った指摘と理由）
```

設計上のポイント:
- レビュー役は、計画も実装も書いていない第三者として、ファイルを読んだ結果や実行結果を根拠に判定する。依頼や仕様にない堅牢性・性能は Nit 止まり。
- レビューの回数には上限があり、無限ループにならない。
- サブエージェントは会話を知らないので、マネージャーが毎回、依頼文の原文・計画・参照ファイルのパスを渡す。
- データから構造・分類・閾値を導くタスクでは、目的と無関係な属性（拠点・ロットなど）との一致、最初の構造への飛びつき（循環）、固定値の閾値を、計画・実装・レビューの各段で確かめる。

## インストール

Windows（PowerShell）:
```powershell
git clone https://github.com/AkihisaHasebe/claude_skills_team.git
cd claude_skills_team
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Linux / macOS:
```bash
git clone https://github.com/AkihisaHasebe/claude_skills_team.git
cd claude_skills_team
bash install.sh
```

どちらも `~/.claude/skills/team/` と `~/.claude/agents/` にコピーします。既存のファイルは `~/.claude/backups/team-<日時>/` に退避します。
特定のプロジェクトだけで使う場合は、3ファイルを `<プロジェクト>/.claude/skills/team/` と `<プロジェクト>/.claude/agents/` に手で置いてください。

条件:
- Claude Code であること。
- `sonnet` / `opus` の別名が使えるプランであること。Opus が使えない場合は、`team-reviewer.md` の `model:` を変更する。

## 使い方

人が実行する場合:
```
/team TASK.md のタスクを実行してください
/team src/foo.py に〇〇機能を追加して。仕様は SPEC.md
```

管理者エージェント（タスク管理表を回すメインセッション）が使う場合は、`/team` を呼べません（`disable-model-invocation: true`）。管理者の `CLAUDE.md` に [manager-snippet.md](manager-snippet.md) の文面を追記し、管理者に手順を直接実行させます。管理者がサブエージェントだと、さらにサブエージェントを呼べないので、管理者はメインセッションにしてください。
計画も担当に任せ、管理者を依頼の確認と進行に専念させたい場合は、[manager-5roles.md](manager-5roles.md)（5役の版、未検証）を使います。

インストール後の確認:
1. `/team` と打って、補完候補に出るか確認する。
2. 小さな依頼を投げ、最終報告に計画レビューと成果物レビューの回数と判定が出るか確認する。

## 検証の状況

| 対象 | 結果 |
|---|---|
| 仕様書を読んで実装する課題（版番号ライブラリ） | 隠しテスト全件合格（`/team` 化する前に、同じ3役の流れを手動のモデル切り替えで実行した結果） |
| データを分析して分類器を作る課題（合成データ、2回） | **不安定。運用上は NO-GO**。1回目は見かけの差（製造ロット）を劣化と取り違え、レビュー役も止めなかった。2回目は正しい構造を見つけたが、境界を固定値にして未知データで取りこぼした |

2回目の結果を受けて、分析タスク向けの確認（上の「設計上のポイント」の最後の項目）を3ファイルに追加しました（2026-10-18）。**この追加の効果は、まだ検証していません。**

それまでの運用ルール: `/team` に分析・分類させた結果は、そのまま使わず、人が次を確認してから使う。
- 結果が、拠点・ロット・担当者など目的と関係のない属性と一致していないか（クロス集計を見る）
- 使った特徴が、目的に合ったものか
- 境界や閾値が、そのデータだけに合わせた固定値になっていないか

## 変更履歴
- 2026-10-18: 分析タスク向けの確認を追加。レビュー指摘を採用しない場合は理由を残す。成果物レビューの OK のあとに許す修正を、挙動を変えないものに限定。
- 2026-10-17: 初版。
