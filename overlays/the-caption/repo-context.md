# THE-CAPTION リポジトリコンテキスト

このファイルは、`THE-CAPTION-DEV` 固有の情報を汎用プロンプトセットから分離するためのオーバーレイである。

## 対象

- リポジトリ: `THE-CAPTION-DEV`
- 想定パス: `/Users/kenn/repos/THE-CAPTION-DEV`
- 親エージェント制御: `AGENTS.md`
- ロールプロンプト配置先: `prompts/`

## 配置対応

- `AGENTS.md` -> `AGENTS.md`
- `prompts/plan.md` -> `prompts/plan.md`
- `prompts/implement.md` -> `prompts/implement.md`
- `prompts/audit.md` -> `prompts/audit.md`
- `prompts/review.md` -> `prompts/review.md`
- `docs/orchestration-process.md` -> `docs/orchestration-process.md`
- `docs/prompt-guide.md` -> `docs/prompt-guide.md`

## 参照文書

- 概要: `README.md`
- システム仕様: `docs/reference/system.md`
- ロジック仕様: `docs/reference/logic.md`
- プロジェクトコンテキスト: `docs/reference/project-contexts/the-caption.txt`
- エージェント運用仕様: `docs/orchestration-process.md`
- プロンプトガイド: `docs/prompt-guide.md`

## 固有ルール

- コード変更を含む監査では、`docs/reference/system.md` と `docs/reference/logic.md` を読む。
- AI制御文書は `AGENTS.md` / `prompts/*.md` / `docs/orchestration-process.md` / `docs/prompt-guide.md` として扱う。
- PR のタイトル、本文、見出しは日本語で書く。
- 英語の定型見出し（Summary / Why / Impact / Checks など）は使わない。
- 適用先固有ルールは汎用プロンプトへ直接混ぜず、このオーバーレイまたは対象リポジトリ側に置く。
