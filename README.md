# オーケストレーション用プロンプトセット

このリポジトリは、エージェントベースの実装ワークフロー向け汎用プロンプトセットである。

責務を以下の4つに分離する。

- 親エージェント: 承認済み作業を整理し、ロールエージェントを起動し、結果を管理する。
- プランエージェント: 実行許可を生成せず、指示書作成依頼または境界未確定の変更依頼から実装指示書の草案を作る。
- 実装エージェント: 承認済みの対象、範囲、完了条件だけを変更する。
- 監査エージェントとレビューエージェント: それぞれ別の分類体系で、結果を非破壊に確認する。

## 構成

```text
AGENTS.md
CLAUDE.md                       # AGENTS.md へのシンボリックリンク: Claude Code にセッション開始時の統治を自動ロードさせる。束ねには含めない
AI_CHAT_BUNDLE.txt              # 生成物: AI制御セットを束ねたテキスト
prompts/
  plan.md
  implement.md
  audit.md
  review.md
docs/
  AIエージェント活用指針.md      # 人間向け: 初学者向けに平易化した段階0–4の習熟文書
  AI 適用ガイド.md               # AI向け: 別リポジトリへの適用手順
  adoption.md                    # 人間向け: 導入ランブック
  glossary.md                    # 人間向け: 用語集
  orchestration-process.md       # 依存順に整理されたプロセス仕様
  orchestration-v2.md            # 設計履歴/rationale: 採用済み運用構造の設計理由
  prompt-guide.md
  walkthrough.md                 # 人間向け: 1サイクルの具体例
templates/
  launch-plan-sa.md
  launch-implement-sa.md
  launch-audit-sa.md
  launch-review-sa.md
overlays/
  _template/
    repo-context.md
    files/
      AGENTS.md
      prompts/
        plan.md
        implement.md
        audit.md
        review.md
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
  check-adoption.sh             # 適用先の標準構成と固有情報混入を検査する
  check-bundle-sync.sh          # AI_CHAT_BUNDLE.txt と生成スクリプト出力の同期を検査する
  check-placement.sh            # root と overlay の AGENTS.md の配置規律を検査する
  check-scripts.test.sh         # 検査スクリプト群の回帰テスト
```

## ガイドと補助文書

- `docs/AIエージェント活用指針.md` は人間向けの習熟文書である。新人エンジニアにも読みやすい平易な文体で、段階0–4の道筋を示す。AI制御セットではないため束ね（`AI_CHAT_BUNDLE.txt`）には含めない。
- `docs/AI 適用ガイド.md` は AI向けの適用手順である。AI にこのプロンプトセットを別リポジトリへ展開させるときに渡す。
- `docs/adoption.md` は人間向けの導入ランブックである。標準構成、`CLAUDE.md` のシンボリックリンク、適用後検証、`overlays/_template/` の使い方を示す。
- `docs/glossary.md` は用語集である。手続きの正本を複製せず、用語の意味と出典を集約する。
- `docs/orchestration-process.md` は現行運用ルールの正本である。運用構造は Execution Lifecycle / Planning Engine / Contract / Toolbox として整理されている。`docs/orchestration-v2.md` は、その運用構造の設計履歴/rationale であり、現行運用ルールではない。
- `docs/walkthrough.md` は plan→implement→audit→review→完了判定 の1サイクルを具体例で示す読み物である。

## 使い方

1. 導入の考え方を理解するには `docs/AIエージェント活用指針.md` を読む。
2. AI に別リポジトリへ適用させるには `docs/AI 適用ガイド.md` を渡す。
3. 対象リポジトリ向けのプロジェクト固有オーバーレイを作る。
4. `AGENTS.md`、`prompts/`、必要なテンプレートを対象リポジトリへコピーまたは適用する。
5. `overlays/<name>/files/` がある場合は、対象リポジトリ相対パスとして共通ファイルの後に重ねる。
6. プロジェクト固有のパス、コマンド、正本文書は、この汎用プロンプトセットではなく、オーバーレイまたは対象リポジトリ側に置く。
7. `docs/orchestration-process.md` を現行運用ルールのプロセス仕様の正本、`docs/prompt-guide.md` を設計ガイドとして使う。採用済み運用構造の設計理由は `docs/orchestration-v2.md` を参照する。

実装・変更の意図はあるが対象・範囲・完了条件・品質基準・実行許可を推定なしで確定できない依頼では、プランエージェントが非拘束の草案を作る。草案は実行許可ではない。

## オーバーレイ

`overlays/<name>/repo-context.md` は、適用先固有の参照文書、配置先、出力言語、運用制約を記録する。

`overlays/<name>/files/` は、対象リポジトリへ重ねるファイルを対象リポジトリ相対パスで置く。共通ファイルを配置した後にこのディレクトリの内容を適用することで、共通プロンプトと適用先固有ルールを分離する。

THE-CAPTION 用の現在形は `overlays/the-caption/` に置く。

`overlays/_template/` は、固有値を空欄化したオーバーレイ雛形である。新しい適用先のオーバーレイを作るときは、この雛形を `overlays/<name>/` へコピーして使う。

## スクリプト

- `scripts/build-bundle.sh` は curated な AI制御セット（README・AI向け適用ガイド・`AGENTS.md`・`.gitignore`・プロセス/設計文書・`prompts/`・`templates/`・明示対象の `overlays/`）を `AI_CHAT_BUNDLE.txt` へ束ねる。人間向けの習熟・移植補助文書（`docs/AIエージェント活用指針.md`、`docs/adoption.md`、`docs/glossary.md`、`docs/walkthrough.md`）や検査スクリプト、`overlays/_template/` は束ねに含めない。対象ファイルが欠けていれば停止する。
- `scripts/check-adoption.sh` は、適用先に標準構成の必要ファイルが揃っているか、汎用ファイルに固有情報が混入していないかを検査する。
- `scripts/check-bundle-sync.sh` は、`AI_CHAT_BUNDLE.txt` が `scripts/build-bundle.sh` の現出力と同期しているかを検査する。
- `scripts/check-placement.sh` は、構成項目の逐語列挙が root と overlay の `AGENTS.md` 本文へ再混入していないか（配置規律）を検査する。規律の根拠は `docs/prompt-guide.md`。
- `scripts/check-scripts.test.sh` は、検査スクリプト群の回帰テストを実行する。

## 契約

このプロンプトセット自体は実行許可を与えない。実行許可は、現在のユーザー指示または対象リポジトリ内の承認済み実装指示書から与えられる必要がある。

現在のユーザー指示で明示許可されていない限り、コミット、プッシュ、デプロイ、本番接続、外部送信、範囲拡張を行わない。
