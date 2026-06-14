# オーケストレーション用プロンプトセット

このリポジトリは、エージェントベースの実装ワークフロー向け汎用プロンプトセットである。

責務を以下の4つに分離する。

- 親エージェント: 承認済み作業を整理し、ロールエージェントを起動し、結果を管理する。
- プランエージェント: 実行許可を生成せず、実装指示書の草案を作る。
- 実装エージェント: 承認済みの対象、範囲、完了条件だけを変更する。
- 監査エージェントとレビューエージェント: それぞれ別の分類体系で、結果を非破壊に確認する。

## 構成

```text
AGENTS.md
AI_APPLY_GUIDE.md
prompts/
  plan.md
  implement.md
  audit.md
  review.md
docs/
  orchestration-process.md
  prompt-guide.md
templates/
  launch-plan-sa.md
  launch-implement-sa.md
  launch-audit-sa.md
  launch-review-sa.md
overlays/
  example/
    repo-context.md
```

## 使い方

1. `AI_APPLY_GUIDE.md` を読む。
2. 対象リポジトリ向けのプロジェクト固有オーバーレイを作る。
3. `AGENTS.md`、`prompts/`、必要なテンプレートを対象リポジトリへコピーまたは適用する。
4. プロジェクト固有のパス、コマンド、正本文書は、この汎用プロンプトセットではなく、オーバーレイまたは対象リポジトリ側に置く。
5. `docs/orchestration-process.md` をプロセス仕様、`docs/prompt-guide.md` を設計ガイドとして使う。

## 契約

このプロンプトセット自体は実行許可を与えない。実行許可は、現在のユーザー指示または対象リポジトリ内の承認済み実装指示書から与えられる必要がある。

現在のユーザー指示で明示許可されていない限り、コミット、プッシュ、デプロイ、本番接続、外部送信、範囲拡張を行わない。
