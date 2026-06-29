# 導入ランブック

この文書は、汎用プロンプトセットを対象リポジトリへ導入する人間向けの手順である。AI向けの適用手順は `docs/AI 適用ガイド.md` にあり、本文はその人間向け対応物である。用語の意味は `docs/glossary.md` を参照する。

## 1. 配置するファイルと配置先

標準構成として、次を対象リポジトリ相対パスで配置する。

- `AGENTS.md`
- `prompts/plan.md`
- `prompts/implement.md`
- `prompts/audit.md`
- `prompts/review.md`
- `docs/orchestration-process.md`
- `docs/prompt-guide.md`

加えて、対象リポジトリ固有の上書きが必要な場合は、雛形 `overlays/_template/` をコピーして使う(後述)。共通ファイルを先に配置し、オーバーレイの `files/` がある場合はその後に重ねる。

## 2. AGENTS.md への build/test の書き方

対象リポジトリのビルド/テスト実行コマンドは `AGENTS.md` に簡潔に書く。実コマンドはこの汎用セットでは発明せず、対象リポジトリの実際のコマンドを記入欄へ書く。記入欄の形は次のとおりとする。

```text
ビルド: <ビルドコマンド>
テスト: <テストコマンド>
```

`<ビルドコマンド>` `<テストコマンド>` は対象リポジトリの実コマンドに置き換える。固有コマンドは汎用ファイルへ混ぜず、対象リポジトリ側または `overlays/<name>/repo-context.md` に置く。

## 3. CLAUDE.md シンボリックリンクの張り方

`README.md` §構成のとおり、`CLAUDE.md` は `AGENTS.md` へのシンボリックリンク(`CLAUDE.md -> AGENTS.md`)である。これにより Claude Code がセッション開始時の統治を自動ロードする。対象リポジトリでも `AGENTS.md` を正本とし、`CLAUDE.md` をそのシンボリックリンクにする。

```text
ln -s AGENTS.md CLAUDE.md
```

シンボリックリンクは束ね(`AI_CHAT_BUNDLE.txt`)には含めない。

## 4. 適用の正しさの確認方法

`README.md` §スクリプトに記載済みの `scripts/check-placement.sh` で、root と overlay の `AGENTS.md` の配置規律を検査する。

```text
bash scripts/check-placement.sh
```

このスクリプトは、構成項目の逐語列挙が `AGENTS.md` 本文へ再混入していないかを検出する。規律の根拠は `docs/prompt-guide.md` §配置規律にある。

## 5. 雛形 overlays/_template/ の使い方

`overlays/_template/` は固有値を空欄化したオーバーレイ雛形である。`README.md` §オーバーレイと `docs/AI 適用ガイド.md` の手順に沿って、次のように使う。

1. `overlays/_template/` を `overlays/<name>/` へコピーする。
2. `repo-context.md` のプレースホルダ(`<...>`)へ、対象リポジトリ名・パス・参照文書名・コマンドなどの固有値を記入する。
3. `files/` 配下の各ファイルの記入欄へ、対象リポジトリ固有の上書き内容を記入する。固有情報を汎用ファイルへ混ぜない。
4. 共通ファイルを先に配置し、その後に `overlays/<name>/files/` を対象リポジトリ相対パスとして重ねる。
