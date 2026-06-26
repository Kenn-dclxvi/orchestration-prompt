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
AI_CHAT_BUNDLE.txt              # 生成物: AI制御セットを束ねたテキスト
prompts/
  plan.md
  implement.md
  audit.md
  review.md
docs/
  AIエージェント活用指針.md      # 人間向け: 段階0–4の習熟の道筋
  AI 適用ガイド.md               # AI向け: 別リポジトリへの適用手順
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
  the-caption/
    README.md
    repo-context.md
    files/
      AGENTS.md
      prompts/
        plan.md
        implement.md
        audit.md
        review.md
scripts/
  build-bundle.sh               # AI_CHAT_BUNDLE.txt を生成する
  check-placement.sh            # root と overlay の AGENTS.md の配置規律を検査する
```

## 2つのガイド

- `docs/AIエージェント活用指針.md` は人間向けの習熟文書である。段階0–4の道筋でエージェント活用を広げる考え方を示す。AI制御セットではないため束ね（`AI_CHAT_BUNDLE.txt`）には含めない。
- `docs/AI 適用ガイド.md` は AI向けの適用手順である。AI にこのプロンプトセットを別リポジトリへ展開させるときに渡す。

## 使い方

1. 導入の考え方を理解するには `docs/AIエージェント活用指針.md` を読む。
2. AI に別リポジトリへ適用させるには `docs/AI 適用ガイド.md` を渡す。
3. 対象リポジトリ向けのプロジェクト固有オーバーレイを作る。
4. `AGENTS.md`、`prompts/`、必要なテンプレートを対象リポジトリへコピーまたは適用する。
5. `overlays/<name>/files/` がある場合は、対象リポジトリ相対パスとして共通ファイルの後に重ねる。
6. プロジェクト固有のパス、コマンド、正本文書は、この汎用プロンプトセットではなく、オーバーレイまたは対象リポジトリ側に置く。
7. `docs/orchestration-process.md` をプロセス仕様、`docs/prompt-guide.md` を設計ガイドとして使う。

## オーバーレイ

`overlays/<name>/repo-context.md` は、適用先固有の参照文書、配置先、出力言語、運用制約を記録する。

`overlays/<name>/files/` は、対象リポジトリへ重ねるファイルを対象リポジトリ相対パスで置く。共通ファイルを配置した後にこのディレクトリの内容を適用することで、共通プロンプトと適用先固有ルールを分離する。

THE-CAPTION 用の現在形は `overlays/the-caption/` に置く。

## スクリプト

- `scripts/build-bundle.sh` は AI制御セット（README・`AGENTS.md`・`prompts/`・`templates/`・`docs/`・`overlays/`）を `AI_CHAT_BUNDLE.txt` へ束ねる。AIチャットへまとめて渡すときに使う。対象ファイルが欠けていれば停止する。
- `scripts/check-placement.sh` は、構成項目の逐語列挙が root と overlay の `AGENTS.md` 本文へ再混入していないか（配置規律）を検査する。規律の根拠は `docs/prompt-guide.md`。

## 契約

このプロンプトセット自体は実行許可を与えない。実行許可は、現在のユーザー指示または対象リポジトリ内の承認済み実装指示書から与えられる必要がある。

現在のユーザー指示で明示許可されていない限り、コミット、プッシュ、デプロイ、本番接続、外部送信、範囲拡張を行わない。
