# Example Repo Context

このファイルは、適用先固有情報を overlay に隔離する例である。

## 対象
- repository: `example-product`
- primary language: TypeScript
- main roots: `src/`, `tests/`, `docs/`

## 参照文書
- overview: `README.md`
- architecture: `docs/architecture.md`
- domain rules: `docs/domain-rules.md`
- testing guide: `docs/testing.md`

## 変更境界の扱い
- 実装指示書に対象ファイル、範囲、完了条件が明示されている場合だけ実装SAを起動する。
- 関連仕様は、指示書または親エージェントの作業単位で明示された場合だけ監査SAへ渡す。
- 固有コマンドは、作業単位の `tests` に明示された場合だけ実行する。

## 出力言語
- ユーザーとの会話で使われている主要言語に合わせる。
- PR テンプレートがある場合は、適用先のテンプレート構成を優先する。

