# オーケストレーション v2 設計

## 位置づけ
この文書は、採用済み運用構造の設計履歴/rationale である。現行運用ルールではない。現行正本は `docs/orchestration-process.md` である。

この文書が記述した自律オーケストレーション設計（Execution Lifecycle / Planning Engine / Optimization Principle / Continuous Verification / Goal Complete / Toolbox / Contract 群 / End-to-End Contract Matrix / Quality Gate / Success Criteria など）は、切替により `docs/orchestration-process.md` へ運用構造として採用済みである。以後、運用判断の根拠は `docs/orchestration-process.md` を参照する。この文書は採用に至った設計理由と検討履歴を残すために保持する。

以下の本文は、採用前の設計検討時点の記述である。採用済みの運用ルールとして読まず、設計履歴として扱う。特に §v1からv2への移行段階 と §v1計画フェーズと Preflight Routing Gate の Planning Engine 化実施方針 は、切替方針と矛盾するため各節の冒頭で無効であることを明記している。

## Mission
この設計の目的は、AI 駆動開発を「安全に実行するためのルール集」から「要求を満たす実装完了へ最短経路で到達する自律型 Software Architect の行動モデル」へ発展させることであった。

この設計は次を目指した。

- AI がゴールを理解し、必要タスクを抽出する。
- AI が依存関係を解析し、計画上並列可能な作業を発見する。
- AI が品質を維持しながら、最終的な完了時間が最小となる実行経路を選択する。
- AI が実行中の新しい情報、エラー、テスト結果、レビュー結果を使って計画を更新する。
- Contract / Constraints / Quality Gate / Toolbox を、ライフサイクルを支える構成要素として扱う。

## Execution Lifecycle
この設計が定義した実行ライフサイクルは、Requirement → Goal Definition → Planning → Dependency Analysis → Task Graph → Parallel Scheduling → Execution → Continuous Verification → Replan → Goal Complete である。

このライフサイクルは、Goal → Planning → Execution → Verification → Replan → Goal Complete の流れを中心に構成する。

各段階の責務は次のとおりである。

- Requirement: 要求を受け取り、明示された対象、範囲、制約、完了条件を識別する。
- Goal Definition: 要求を達成すべきゴールとして定義し、成功条件を明確にする。
- Planning: ゴール達成に必要なタスク、依存関係、優先順位、実行順序を設計する。
- Dependency Analysis: 各タスクの前提条件、依存先、計画上の並列可能性を解析する。
- Task Graph: タスクを有向グラフとして表現する。
- Parallel Scheduling: 依存関係のないタスクを計画上並列可能な作業として識別し、待ち時間を減らす実行順序候補を作る。
- Execution: 計画に従って実装、修正、確認を行う。
- Continuous Verification: 各段階で品質条件、制約、成果物、テスト結果を確認する。
- Replan: 新しい情報を入力として、実行と検証で得た観測事実を学習し、次の計画へ反映する。
- Goal Complete: 要求を満たし、品質基準を満たした状態を完了として扱う。

## Goal Definition
Goal Definition は、要求を実装完了へ向かう判断単位へ変換する段階である。

Goal は次を保持する。

- 達成すべき結果
- 対象
- 範囲
- 制約
- 完了条件
- 品質基準

AI は、明示されていない境界を補完してはならない。Goal に必要な境界が不足している場合、AI は不足項目を返す。

## Planning Engine
Planning Engine は、この設計の中心概念である。

Planning Engine は、AI が Software Architect として実装開始前に最適な実行計画を構築し、実行中も計画を更新するための機構である。

Planning Engine は次を行う。

- 要求の理解
- ゴールの明確化
- 完了条件の抽出
- タスク分解
- 依存関係解析
- 優先順位決定
- 計画上の並列可能性の判断
- 実行順序の決定
- Preflight Routing Gate 後の詳細計画見積もり
- 実行中の計画更新

Planning Engine は、単純な ToDo を作るだけではない。ゴール達成までの探索空間を整理し、品質を落とさずに最終的な完了時間を短くする経路を選択する。

## Optimization Principle
Optimization Principle は、Planning Engine が計画を最適化するときの優先順位である。

優先順位は次の順序とする。

1. Goal 達成
2. 品質維持
3. 実装時間短縮
4. 手戻り最小化
5. コンテキスト切替最小化

この設計では、単純に目先の作業時間が短い経路を選ばない。品質低下、手戻り、再確認、依存待ちを含めた最終的な完了時間が最小となる経路を選択する。

## Preflight Routing / Orchestration Cost Gate
Preflight Routing / Orchestration Cost Gate は、Plan SA を起動するかどうかの粗い判断と、Plan SA 起動後の詳細計画見積もりを分離する設計観点である。

中心判断は、作業規模だけでSA起動を決めないことである。Parent は Plan SA 起動前に Preflight Estimate / Routing Gate として粗い起動判断だけを行い、Plan SA は起動後に Detailed Planning / Detailed Estimate として詳細判断材料を整理する。

責務分離は次の2段階とする。

```text
Parent
  └─ Preflight Estimate / Routing Gate

Plan SA
  └─ Detailed Planning / Detailed Estimate
```

この設計観点は、現行運用ルールを置き換えるものとして書かれたものではない。現行運用では `docs/orchestration-process.md` を正本とし、実装、監査、レビュー、停止、完了判定はその正本に従う。

Parent の Preflight Estimate / Routing Gate は、ユーザー要求の明確さ、変更対象の明示有無、修正規模の概算、リスク、情報分離価値、Plan SA を起動する価値、Audit / Review を分離する価値、並列SAが過剰かどうかだけを見る。判定対象は、この依頼を Plan SA に渡すべきか、軽量ルートでよいか、フルルートが必要かに限る。

Parent は Preflight Estimate / Routing Gate で、実装計画の詳細化、Task Graph の具体化、Done補完、Scope補完、テスト条件推定、実装判断を行わない。

Plan SA の Detailed Planning / Detailed Estimate は、Goal Definition、Dependency Planning、Task Graph 草案、Parallel Scheduling 草案、Replan条件、Quality Gate観点、後続SA構成案、テスト要求の整理を扱う。Plan SA も実行許可や境界は作らない。

Preflight Estimate / Routing Gate と Detailed Planning / Detailed Estimate は、次の順序で評価する。

1. Isolation Gate: Audit の情報遮断価値、Review の第三者視点価値、Plan の構造化価値を評価する。
2. Orchestration Cost Gate: Isolation Gate の結果を維持したまま、トークン効率、SA起動数、コンテキスト複製量、並列化オーバーヘッドを評価する。

Orchestration Cost Gate は Isolation Gate の後に評価する。分離価値が高い工程は、効率が悪くても維持する。

作業規模分類は次のとおりである。Parent は Preflight で粗い分類として扱い、Plan SA は起動後に詳細見積もりとして扱う。

- Small: 明示境界が狭く、変更対象が少なく、依存関係が少ない作業。
- Medium: 複数ファイル、複数工程、または限定的な依存関係を含む作業。
- Large: 広い範囲、複数コンポーネント、段階的実行、または複数の検証観点を含む作業。
- Risky: 公開API / 認証・権限 / データ永続化 / 課金 / 秘密情報・個人情報 / テスト信頼性 / AI制御文書など、失敗時の影響が大きい作業。Risky は Small / Medium / Large と併記できる。

Risky 分類は設計観点であり、v1 の多視点並列検証の閉じた起動条件を拡張しない。Small でも Risky なら分離を維持する。

トークン効率予測は、入力トークン、出力トークン、SA起動数、コンテキスト複製量、並列化オーバーヘッド、再修正確率を扱う。Parent は概算だけを扱い、Plan SA は起動後に詳細判断材料として扱う。

分離価値評価は次を扱う。

- Plan の構造化価値: 境界、依存関係、停止条件、テスト条件を実行前に整理する価値。
- Audit の情報遮断価値: 実装経緯や事前評価から切り離して、契約と成果物を照合する価値。
- Review の第三者視点価値: 監査結果本文に影響されず、品質、設計、テスト妥当性、周辺影響を確認する価値。

Plan SA は起動後、後続SA構成案として次を候補にしてよい。

- Implement SA を省略できる条件: 実装、修正、ファイル変更が不要な場合。変更が必要な場合、親の直接実装へ置き換えない。
- Audit SA を軽量化できる条件: 契約照合の観点を狭くできる場合。軽量化しても Audit Contract と必要な関連仕様だけを渡す情報分離は維持する。
- Review SA を省略できる条件: PRレビュー相当の品質確認対象となる差分がない場合、または正本が省略を明示している場合。v1 で監査SA通過後にレビューSAが必須の経路では省略しない。
- 並列SAを使う条件: 独立性基準または非破壊検証の起動条件を満たし、並列化オーバーヘッドより分離価値または手戻り削減効果が高い場合。

禁止事項は次のとおりである。

- 親が直接実装する抜け道にしない。
- Cost削減を理由に Audit / Review の情報分離を壊さない。
- Small 判定だけで軽量ルートへ流さない。
- Small でも Risky なら分離を維持する。
- Review 省略条件を正本より広げない。
- 並列化を理由に Contract、Constraints、Quality Gate を曖昧にしない。

### 軽量ルート型 / フルルート型の判断テンプレート
軽量ルート型とフルルート型の選択は、作業規模だけで決めない。作業規模、Isolation Gate（情報分離価値）、Risky 有無を併せて判断する。

軽量ルート型は、親の直接実装、監査省略、レビュー必須ゲートの省略、情報分離の緩和を意味しない。この判断テンプレートは、v1 正本 `docs/orchestration-process.md` L228 の「軽量ルートは、親の直接実装、監査省略、レビュー必須ゲートの省略、情報分離の緩和を意味しない」を核とする。

判断フローは次のとおりである。

| 判断項目 | 軽量ルート型選択の条件 | フルルート型の条件 |
|---|---|---|
| 作業規模 | Small | Medium / Large / Risky |
| Isolation Gate評価 | Plan構造化・Audit情報遮断・Review第三者視点はすべて必須 | 同上（必須） |
| Risky分類 | Small でも Risky なら分離を維持する | 必ず分離を維持する |
| 後続SA構成案 | Implement省略は実装・変更不要な場合のみ / Audit軽量化は監査観点と関連仕様の最小化に限り情報遮断は維持 / Review は必ず起動 / 並列化は独立性と Isolation Gate を優先 | 通常起動 |

各ルート型での情報分離確認項目は次のとおりである。

軽量ルート型でも確認する項目。

- Audit SA へ実装経緯・事前評価を渡していない。
- Review SA へ監査結果本文・監査SAの指摘内容を渡していない。
- Audit Contract / Review 入力の情報遮断が v1 正本 L351・L368 に準拠している。

フルルート型でも、情報分離は軽量ルート型と同等に確認する。

- Audit SA へ実装経緯・事前評価を渡していない。
- Review SA へ監査結果本文・監査SAの指摘内容を渡していない。
- Audit Contract / Review 入力の情報遮断が v1 正本 L351・L368 に準拠している。

禁止事項は次のとおりである（v1 正本 L292-298 を継承する）。

- Small 判定だけを理由に監査、レビュー、情報分離を外さない。
- Small でも Risky なら分離を維持する。
- コスト削減を理由に Audit / Review の情報分離を壊さない。
- 親の直接実装を許す抜け道にしない。
- Review 省略条件を v1 正本より広げない。
- 並列化を理由に Contract、Constraints、Quality Gate を曖昧にしない。

本セクションの内容は、v1 正本 `docs/orchestration-process.md` L228（軽量ルート定義）、L276-279（後続SA構成案）、L292-298（禁止事項）に基づく。v1 正本 L388「SA起動判断では、作業規模だけで起動または省略を決めない」を強調する。ルート型は固定割り当てではなく、Orchestration Cost Gate は Isolation Gate の後に評価するという原則を上書きしない。

## Dependency Planning
Dependency Planning は、作業を有向グラフとして扱う設計である。

各タスクは次を保持する。

- 前提条件
- 完了条件
- 依存先
- 計画上の並列可能性

AI は、依存関係があるタスクを無理に並列化しない。依存関係がないタスクは、待ち時間、確認回数、手戻りを減らすために計画上の並列可能性として扱う。

Dependency Planning は、不要な確認、無駄な待ち時間、実装後の手戻りを最小化するために使う。

## Parallel Scheduling
Parallel Scheduling は、独立したタスクを物理的に同時実行する標準動作ではない。ここでは、依存関係上独立して扱える作業を計画上の並列可能性として識別することを指す。

AI は、逐次実行だけを前提にしない。依存関係がない作業は、速度向上のために、同時実行ではなく実行順序候補と分割候補の観点で扱う。

計画上並列可能な作業の例は次のとおりである。

- API実装
- UI修正
- テストコード作成
- ドキュメント更新

Parallel Scheduling は、Contract、Constraints、Quality Gate を満たす範囲で計画観点として扱う。並列可能性の整理によって境界が不明確になる場合、AI は並列可能扱いせず、必要な境界を返す。

## Execution
Execution は、Planning Engine が構築した計画に従って作業を進める段階である。

Execution は次を行う。

- 許可された対象への実装または更新
- 必要な読取、編集、検証の実行
- タスクグラフ上の完了状態の更新
- 実行中に得た情報の記録
- Replan が必要な変化の検出

Execution は、計画を固定的に消化する段階ではない。実行中の観測事実は Planning Engine へ戻され、計画更新の入力になる。

## Continuous Verification
Continuous Verification は、品質確認を終端処理ではなくライフサイクル全体に組み込む仕組みである。

Verification は次の段階で行う。

- Planning: 計画が Goal、Contract、Constraints と矛盾していないことを確認する。
- Execution: 作業が対象と範囲から逸脱していないことを確認する。
- Verification: 成果物、差分、テスト結果、仕様照合を確認する。
- Replan: 計画更新後も品質基準と制約を満たしていることを確認する。

Continuous Verification は、速度を下げるためではなく、後戻りを減らして最終的な完了時間を短くするために使う。

## Replan
Replan は、実装開始時の計画を固定せず、観測事実に応じて更新する段階である。

Replan の入力は次のとおりである。

- 新しい情報
- エラー
- テスト結果
- 監査結果
- レビュー結果
- 依存関係の変化
- 完了済みタスクの成果物
- 実行と検証から学習した観測事実

Replan は次を行う。

- 不要タスク削除
- 新規タスク追加
- 優先順位変更
- 並列可能性の再計算
- 実行順序更新
- 品質確認手順の更新

AI は、計画を維持することを目的にしない。常に Goal 達成までの最短経路へ計画を最適化する。

## Goal Complete
Goal Complete は、要求を満たし、品質基準を満たした状態である。

Goal Complete は、単に実装が終わった状態ではない。成果物、確認結果、テスト結果、制約照合によって、要求が満たされたことを説明できる状態である。

Goal Complete に到達できない場合、AI は未達の条件、停止理由、次に必要な判断を返す。

## Contract
Contract は、Planning Engine が最適化を行う際の制約条件である。

Contract は、計画を固定するものではない。Contract はゴール、制約、完了条件を保持し、Planning Engine はその範囲内でタスク構成、実行順序、計画上の並列可能性を決定する。

Contract は次を保持する。

- `goal`: 達成すべき結果
- `scope`: 対象と範囲
- `constraints`: 禁止、停止、除外操作
- `done`: 完了条件
- `quality_criteria`: 品質基準

Contract に未定義の境界を AI が補完してはならない。Contract が不足している場合、AI は不足項目を返す。

## Execution Contract
v1 の Plan→Execution 受け渡しでいう Execution Contract は、Plan 成果物を Execution が実行入力として消費するための契約である。これは v2 の Contract / Constraints / Task Graph / Parallel Scheduling / Replan / Quality Gate を、v1 の境界項目と矛盾しない範囲で写像したものであり、現行運用ルールを昇格または変更しない。

Execution Contract は次を保持する。

- Goal: 明示された達成結果。
- Scope: 明示された対象と範囲。
- Constraints: 禁止、停止、除外操作、制約。
- Completion Criteria: 完了条件と品質基準。
- Task Graph: 前提条件、依存先、独立性を持つ作業要素。
- 実行順序
- 並列可能性: 物理並列ではなく計画上の独立性。
- 停止条件
- Replan条件
- テスト要求

Execution が判断してよい範囲は、実装方法の詳細、ファイル編集順、Contract 範囲内で実装に直接必要な軽微なリファクタリング、Toolbox 選択に限る。Goal変更、Scope変更、Contract違反、大きな設計変更、新しい依存関係の発見は、Execution が補完せず Replan へ戻す観測事実として扱う。

## Audit Contract
v1 の Execution→Audit 受け渡しでいう Audit Contract は、Execution の成果物を Audit が契約照合対象として消費するための契約である。これは v2 の Verification / Quality Gate を、v1 の監査境界と矛盾しない範囲で写像したものであり、現行運用ルールを昇格または変更しない。

Audit Contract は次を保持する。

- 実装指示書
- Execution Contract
- `target / scope / done / tests / stop`
- 変更ファイル
- 差分
- テスト結果
- 停止理由
- Replan条件に該当する観測事実
- 監査観点

Audit は、計画や実装を良くする工程ではなく、Audit Contract と成果物が一致しているかを見る工程である。再設計、実装改善、品質改善レビュー、計画更新は Audit Contract の責務に含めない。

必要な関連仕様は、Audit Contract と成果物の一致確認に必要な補助入力であり、Audit の責務を広げない。監査観点も照合範囲を絞るための項目であり、再設計、実装改善、品質改善レビュー、計画更新の根拠にしない。

Replan条件に該当する観測事実は、Audit が再計画するための入力ではない。Audit は、その観測事実が Execution Contract、`target / scope / done / tests / stop`、差分、テスト結果、停止理由と矛盾していないかだけを照合する。

## Review Contract
v1 の §レビューSA入力 で定義されるレビューSA起動入力の v2 写像である。

Review は、監査SAの停止指摘0件という起動ゲート事実を起動ゲートとして、非破壊の PRレビュー相当品質確認だけを行う工程である。親エージェントは Review 入力を次に限定する。

- `review.md` の本文または要約
- 承認済み実装指示書
- 差分
- テスト結果
- 必要な関連仕様。AI制御文書が変更対象の場合、変更後の当該文書全体を必要な関連仕様として扱う。
- レビュー観点
- 監査SAの停止指摘0件という起動ゲート事実

レビューSA入力に含めてはならない:

- 実装経緯
- 事前評価
- 監査結果本文
- 監査SAの指摘内容
- 判断理由
- 個別評価

親エージェントは完了判定、Quality Gate 管理、自動修正可否判断のために監査結果を保持するが、それは Review へ渡す入力ではない。Review は監査成果物を消費しない。この情報遮断は Orchestration Cost Gate より優先される。

## Replan Contract
v1 の §Execution が Plan へ戻すべき観測事実でいう Replan Contract は、Execution が実行中に得た観測事実を Plan SA へ戻すための受け渡し契約である。これは v2 の Replan / Continuous Verification を、v1 の Replan条件と矛盾しない範囲で写像したものであり、現行運用ルールを昇格または変更しない。

Execution は、以下を観測した場合、自力で Contract を更新せず、Plan へ戻すべき観測事実として停止理由に含める。

- Scope変更が必要である。
- Goal変更が必要である。
- Contract違反がある。
- 大きな設計変更が必要である。
- 新しい依存関係を発見した。

Scope変更が必要か、Goal変更が必要かは、Execution が観測事実として返すだけである。Execution / Audit / Review は再計画の判断を下さない。作業単位化し直すか、Plan SA へ戻すかの判断は親エージェントが保持する。

Replan条件に該当する観測事実は、監査SAが再計画するための入力ではない。監査SAは、その観測事実が Execution Contract、`target / scope / done / tests / stop`、差分、テスト結果、停止理由と矛盾していないかだけを照合する。監査SAとレビューSAは自己再計画しない。この情報遮断は Orchestration Cost Gate より優先される。

停止指摘または重大指摘が承認済み範囲内で最小修正可能なら、親エージェントは作業単位化し直して実装SAへ渡す。自動修正の回数制御は v1 正本 §自動修正ループ に従い、Replan Contract は回数制御の再定義、拡張、条件追加を含めない。

Replan へ戻す観測事実は、Goal 達成までの計画更新に必要な入力である。新しい情報、エラー、テスト結果、監査結果、レビュー結果、依存関係の変化を含む。ライフサイクル上の位置づけは v2 §Replan 節に従う。

## End-to-End Contract Matrix
この Matrix は、Parent → Plan → Execution → Audit → Review → Parent および Any → Replan の受け渡し地点における契約要素を、実装の流れに沿って1枚で参照できるように集約したものである。各セルは対応する契約節（v1 「§Parent→Plan の受け渡し契約」「§各工程の確認範囲」「§親エージェント」、v2「Execution Contract」「Audit Contract」「Review Contract」「Replan Contract」）に完全に従う。Matrix は要約であり、詳細およびルールの正本は各契約節である。情報分離（Execution→Audit で実装経緯・事前評価を除外、Audit→Review で監査結果本文・指摘内容・判断理由・個別評価を除外）は情報遮断価値の核であり、この Matrix でも厳格に維持される。v1 のレビュー必須ゲート・停止条件・完了判定の効力は Matrix の追加によって弱められない。

| 受け渡し地点 | 入力 | 出力 | 渡してよい情報 | 渡してはいけない情報 | 生成してはいけないもの | 停止条件 |
|---|---|---|---|---|---|---|
| **Parent→Plan** | Parent→Plan Contract（ユーザー要求・明示された対象・明示された範囲・制約・実行許可の有無・既定テスト定義・条件付き事前承認・SSOT・Preflight Routing Gate 結果。詳細は v1 §Parent→Plan の受け渡し契約） | 実装指示書草案 / 不足項目 | 明示入力と正本参照（SSOT・参照可能範囲・参照条件） | 推定による境界項目の補完・Contract 外の対象追加（v1 §Parent→Plan の受け渡し契約：実行許可を生成せず未定義の境界項目を補完しない） | 実行許可・未定義の境界項目の補完（v1 §Parent→Plan の受け渡し契約） | 対象・範囲・完了条件・品質基準・実行許可のいずれかが未定義。補完に推定が必要。参照文書から未指定の境界を補完する必要がある。 |
| **Plan→Execution** | Execution Contract（Goal / Scope / Constraints / Completion Criteria / Task Graph / 実行順序 / 並列可能性 / 停止条件 / Replan条件 / テスト要求。詳細は v2 § Execution Contract） | 実装成果物・差分・テスト結果・停止理由 | 実装指示書・関連仕様・テスト条件（Execution Contract と `target / scope / done / tests / stop` の範囲内） | Contract に未定義の境界を補完する内容（v2 § Constraints：AI は対象・範囲・完了条件・品質基準・実行許可を補完しない） | 自力での Contract 更新・Scope 外判断（v2 § Execution Contract：Goal変更・Scope変更・Contract違反・大きな設計変更・新しい依存関係は補完せず Replan へ戻す観測事実として扱う） | Scope変更・Goal変更・Contract違反・大きな設計変更・新しい依存関係の発見を要する場合は実装せず Replan条件に該当する観測事実として停止理由にする（v2 § Execution Contract）。 |
| **Execution→Audit** | Audit Contract（実装指示書・Execution Contract・`target / scope / done / tests / stop`・変更ファイル・差分・テスト結果・停止理由・Replan条件に該当する観測事実・監査観点。詳細は v2 § Audit Contract） | 停止指摘・任意指摘・範囲外指摘（v1 §指摘分類） | 必要な関連仕様（Audit Contract と成果物の一致確認に必要な補助入力。v2 § Audit Contract） | 実装経緯・事前評価（v1 §親エージェント：監査SAへ実装経緯・事前評価を渡さない。v2 § Audit Contract に準拠） | 再設計・実装改善・品質改善レビュー・計画更新（v2 § Audit Contract：Audit の責務に含めない） | 実装経緯・事前評価が渡される場合。関連仕様が明示なく同期確認が必要な場合。Audit Contract と成果物が一致しない場合。 |
| **Audit→Review** | Review Contract（承認済み実装指示書・差分・テスト結果・必要な関連仕様・レビュー観点・監査SAの停止指摘0件という起動ゲート事実。詳細は v2 § Review Contract） | 重大指摘・改善指摘・補足・範囲外指摘（v1 §指摘分類） | 必要な関連仕様（AI制御文書が変更対象の場合は変更後の当該文書全体。v2 § Review Contract） | 実装経緯・事前評価・監査結果本文・監査SAの指摘内容・判断理由・個別評価（v2 § Review Contract：レビューSA入力に含めてはならない） | 契約準拠の再判定・監査指摘分類の変更・修正指示（Review は非破壊の PRレビュー相当品質確認のみ。v2 § Review Contract） | 監査結果本文・監査SAの指摘内容・判断理由・個別評価が渡される場合。監査SAの停止指摘0件という起動ゲート事実が確認できない場合。 |
| **Review→Parent** | レビューSA成果物（重大指摘・改善指摘・補足・範囲外指摘の4分類。v1 §指摘分類） | 完了判定・自動修正可否判断・マージ可否判定の入力（v1 §親エージェント） | 監査SAの停止指摘0件という起動ゲート事実（v1 §親エージェント） | 監査結果本文・監査SAの指摘内容・判断理由・個別評価（v1 §親エージェント：レビューSA入力・レビューSAの分類へ移さない） | 契約準拠の再判定・新規ルールの追加（判定・関所管理は親エージェントが保持。v1 §親エージェント） | 重大指摘が存在し承認済み範囲内で最小修正できない場合は停止（v1 §自動修正ループ）。改善指摘・補足・範囲外指摘は自動修正対象にしない（v1 §指摘分類）。 |
| **Any→Replan** | Execution / Audit / Review から Plan へ戻される観測事実（v2 § Replan Contract） | 再計画入力・Plan 更新トリガー（新しい情報・エラー・テスト結果・監査結果・レビュー結果・依存関係の変化。v2 § Replan Contract） | Scope変更・Goal変更・Contract違反・大きな設計変更・新しい依存関係の発見という観測事実そのもの（v2 § Replan Contract） | Plan へ戻す前に自力で更新した Contract 修正案・再計画の判断そのもの（v2 § Replan Contract：Execution / Audit / Review は再計画の判断を下さない） | 再計画の判断・計画修正提案（作業単位化し直すか Plan SA へ戻すかの判断は親エージェントが保持。v2 § Replan Contract） | 観測事実が Scope変更・Goal変更・Contract違反・大きな設計変更・新しい依存関係のいずれにも該当しない場合。必要性を推定で判断する場合。 |

## Constraints
Constraints は、Planning Engine と Execution が越えてはならない境界である。

この設計の Constraints は次を含む。

- AI は対象、範囲、完了条件、品質基準、実行許可を補完しない。
- 現行運用ルールを変更する場合は、現行正本 `docs/orchestration-process.md` を明示対象に含める。
- `commit` / `push` / `deploy` / 外部送信は、Contract で明示許可された場合だけ行う。
- テスト期待値の変更、skip、xfail、assertion 緩和、失敗パスの握りつぶしを完了の近道にしない。
- 便乗リファクタ、命名変更、移動、削除、構成変更を Contract 外で行わない。
- 原因不明の探索的修正を行わない。
- この設計文書自体を現行運用ルールとして扱わない。
- 情報遮断は Orchestration Cost Gate より優先される。Audit / Review の情報分離がコスト削減、並列化、軽量化より優先される。

Constraints に抵触する場合、AI は作業を停止し、抵触した境界を返す。

## Quality Gate
Quality Gate は、Planning / Execution / Verification / Replan の各段階で継続的に品質を確認する仕組みである。

Quality Gate は、終端処理だけではない。計画が正しくても実行が逸脱する場合があり、実行が正しくても新しい情報によって計画更新が必要になる場合がある。Quality Gate は、それぞれの段階で品質と制約を確認する。

Quality Gate は次を確認する。

- Goal と Contract から逸脱していない。
- Constraints に抵触していない。
- 明示されたテスト条件が扱われている。
- テスト期待値、停止条件、禁止操作が変更されていない。
- SSOT と矛盾していない。
- 成果物と確認結果で完了扱いを支えられる。

Quality Gate を満たせない場合、作業は Goal Complete として扱わない。

## Toolbox
Toolbox は、Planning Engine が選択できる手段の集合である。

Toolbox は実行主体ではない。Planning Engine が、Contract、Constraints、Quality Gate、依存関係、最終的な完了時間を踏まえて、最適なツール、最適な AI、最適な実行方法を選択する。

Toolbox は次の種類を持つ。

- 読取: 対象ファイル、差分、仕様、ログ、テスト出力の確認
- 編集: Contract で許可された対象への変更
- 検証: 明示されたテスト、静的確認、差分照合、仕様照合
- 監査: Contract と成果物の非破壊照合
- レビュー: 品質、周辺影響、テスト妥当性の非破壊確認
- 報告: 実施内容、変更ファイル、確認結果、停止理由の返却

Toolbox の利用は、権限ではなく条件付き能力である。道具が利用可能でも、Contract が許可しない操作は行わない。

## SSOT
SSOT は、判断の根拠として優先する正本である。

SSOT は次の関係を持つ。

- 現行運用ルールの SSOT は `docs/orchestration-process.md` である。
- 設計理由と書き味の SSOT は `docs/prompt-guide.md` である。
- 本文書へ採用された運用構造の設計履歴/rationale は `docs/orchestration-v2.md`（この文書）である。現行運用ルールではない。

矛盾がある場合、現行運用では `docs/orchestration-process.md` を優先する。この文書は現行の正本を変更しない。

## AIへ委譲する判断
AIへ委譲する判断は、Contract の範囲内で完結する仮決定に限る。

AI は次を判断してよい。

- Goal 達成に必要なタスク分解
- タスク間の依存関係
- 計画上並列可能な作業
- 実行順序と優先順位
- Toolbox から使う道具
- 実行中の計画更新
- 明示されたテスト条件に基づく実行と結果整理
- 差分、テスト結果、仕様の照合
- Constraints に抵触した場合の停止
- 不足している Contract 項目の列挙

AI は、委譲された判断を Contract の拡張に変換してはならない。

Execution 単体へ委譲する判断は、実装方法の詳細、ファイル編集順、Contract 範囲内で実装に直接必要な軽微なリファクタリング、Toolbox 選択に限る。Goal変更、Scope変更、Contract違反、大きな設計変更、新しい依存関係の発見は、Replan へ戻す。

## 人間が保持する判断
人間が保持する判断は、作業境界とリスク受容に関わる決定である。

人間は次を保持する。

- 目的、対象、範囲、完了条件、品質基準、実行許可の確定
- SSOT の採用、変更、優先順位の決定
- Contract 外の仕様変更、構成変更、対象拡張の判断
- `commit` / `push` / `deploy` / 外部送信の許可
- テスト条件が不足している場合の追加定義
- 停止後に作業を続けるかどうかの判断

AI は、人間が保持する判断を推定で代替しない。

## Success Criteria
この設計が定義した成功条件は、単に実装が完了したことではない。

この設計が定義した成功条件は、最小時間で要求を満たし、品質基準を満たした状態に到達することである。

成功には次を含む。

- Goal が達成されている。
- Contract と Constraints から逸脱していない。
- Quality Gate を満たしている。
- 依存待ち、不要確認、手戻り、コンテキスト切替が最小化されている。
- 成果物と確認結果によって完了を説明できる。

品質と速度を両立することが、この設計におけるオーケストレーションの責務である。

## v1からv2への移行段階
この節は採用済み（切替）により無効な歴史的記述である。移行は段階移行ではなく切替で実施され、この節の段階0-4・昇格前の確認基準・昇格判断の手順は現行運用ルールではない。当時の確認基準（全受け渡し契約の定義完結 / v1安全性指標の非低下 / 情報分離 / 人間保持判断の境界）は、現行正本 `docs/orchestration-process.md` の各契約節・§Quality Gate・§完了条件・§人間が保持する判断で満たされている。以下は設計検討時点の記述として残す。

v1からv2への移行は、現行安定版を壊さず段階的に行う。

### 段階0: v1維持
`docs/orchestration-process.md` を現行運用ルールとして維持する。v2 は設計文書として扱い、運用へ適用しない。

### 段階1: ライフサイクル整理
v1 の作業単位、停止条件、完了判定を Goal → Planning → Execution → Verification → Replan → Goal Complete の語彙で写像する。写像は v1 の意味を変えない。

### 段階2: Planning Engine 整理
既存の実装、監査、レビュー、確認、報告を Planning Engine が選択できる Toolbox として整理する。整理は、担当、順序、並列数、分割方法を固定するために使わない。

### 段階3: 依存計画の試行
限定された作業で、Contract を制約条件として扱い、Planning Engine が Task Graph と Parallel Scheduling を設計する形を試行する。試行中も現行運用上の正本は v1 とする。

### 段階4: 採用判断
v2 の自律オーケストレーション設計が v1 の安全性を下げずに運用できると確認された場合だけ、現行運用ルールへの昇格を人間が判断する。

#### 昇格前の確認基準
v2 を現行運用へ昇格するためには、以下の確認基準を満たすことを人間が確認する。AI は昇格判断そのものを行わず、確認基準の達成状況と観測事実を返すだけである。

##### 1. 全受け渡し契約の定義完結
v2 のライフサイクルを支えるすべての受け渡し契約が、v1 の境界項目と矛盾しない範囲で定義されていることを確認する。

- Parent→Plan の受け渡し契約: ユーザー要求・明示された対象・範囲・制約・実行許可・既定テスト定義を分離して渡す（v1 L133-147）。
- Plan→Execution の受け渡し契約（Execution Contract）: Goal / Scope / Constraints / Completion Criteria / Task Graph / 実行順序 / 並列可能性 / 停止条件 / Replan条件 / テスト要求を包含する（v1 L301-319）。
- Execution→Audit の受け渡し契約（Audit Contract）: 実装指示書 / Execution Contract / `target / scope / done / tests / stop` / 変更ファイル / 差分 / テスト結果 / 停止理由 / Replan条件に該当する観測事実 / 監査観点を包含し、実装経緯・事前評価は除外する（v1 L336-356）。
- Audit→Review の受け渡し契約（Review Contract）: Review 入力が実装指示書 / 差分 / テスト結果 / 必要な関連仕様 / レビュー観点 / 監査SA停止指摘0件という起動ゲート事実に限定され、監査結果本文・監査SAの指摘内容・判断理由・個別評価は除外する（v1 L357-369）。
- Execution→Plan への Replan 契約: 観測事実が Goal / Scope / Contract違反 / 大きな設計変更 / 新しい依存関係に限定され、自力で Contract を更新しない（v1 L328-335）。

##### 2. v1 の安全性指標が下がっていないことの確認
v1 が定義する停止条件・完了判定・レビュー必須ゲート・情報分離が、v2 運用下で維持またはより厳格化されていることを確認する。

停止条件の維持（v1 L444-449）。

- Execution が Contract違反・Scope変更・Goal変更・大きな設計変更・新しい依存関係を観測した場合、自力で補完せず Plan へ戻す。
- 監査SA が完了偽装（テスト期待値変更・skip・xfail・assertion 緩和・失敗パスの握りつぶし）を検出した場合、停止指摘とする。

完了判定の維持（v1 L227-233）。

- Goal / Contract / Constraints から逸脱していないことを Quality Gate で確認する（v2 L347-361）。
- テスト結果と差分で完了を説明できることを確認する。
- v2「Goal Complete」（成果物と確認結果で要求が満たされたことを説明できる状態）がスキップされていない。

レビュー必須ゲートの維持（v1 L485）。

- 監査SA の停止指摘0件後、必ず Review SA を起動する。
- Review SA を省略する条件を v1 正本より広げない（省略可は「差分がない場合」または「正本で明示された場合」だけ）。

情報分離の維持（v1 L351, L368, L388）。

- Audit SA への入力は Audit Contract と必要な関連仕様に限定し、実装経緯・事前評価は除外する。
- Review SA への入力は Review Contract に限定し、監査結果本文・監査SAの指摘内容・判断理由・個別評価は除外する。
- Orchestration Cost Gate の結果は、Isolation Gate で必要とされた分離を弱める根拠にしない。

##### 3. 限定作業（段階3）での v1 安全性実装例の確認
段階3で試行された限定された作業が、以下の条件を満たすことを確認する（v2 §段階3: 依存計画の試行 を前提とする）。

- テスト改竄がない（v1 L438）: `# noqa`・skip・xfail 追加、失敗パスの mock 握りつぶし、assertion 緩和が検出されない。
- 完了偽装がない（v1 L436-437）: テスト期待値変更・テスト条件未充足・実装不足が検出されない。
- 情報漏洩がない: Audit SA へ実装経緯が、Review SA へ監査結果が渡されていないことが検証されている。
- コスト削減による分離破壊がない（v1 L388）: Small 判定・SA 省略・並列化を理由に Audit / Review の情報分離が弱められていない。

段階3での実装例がない場合、段階4への昇格判断は保留する。

##### 4. 人間が保持する判断の境界が確立されていることの確認
v2「人間が保持する判断」（L410-423）が v1「親エージェント」の責務と一致し、AI が推定で代替していないことを確認する。

- 人間は「目的、対象、範囲、完了条件、品質基準、実行許可の確定」を保持している（v2 L415）。
- AI は「対象、範囲、完了条件、品質基準、実行許可を補完しない」という原則を守っている（v1 L69, L158）。
- v2 運用中に「作業単位化し直すか、Plan SA へ戻すかの判断」が親エージェント（人間）に委ねられている（v2 L323）。
- Contract 外の仕様変更・構成変更・対象拡張の判断が人間にのみ属している（v2 L418）。

#### 昇格判断の実行
上記4つの確認基準が満たされていることを人間が確認した場合のみ、「v2 を現行運用へ昇格する」という判断を下す。昇格判断前には以下を確認する。

1. 段階1・2・3 での試行結果レポートを入手し、各段階での学習と課題を整理する（v2 §段階1: ライフサイクル整理 / §段階2: Planning Engine 整理 / §段階3: 依存計画の試行）。
2. 限定作業の監査・レビュー結果から、v1 安全性指標（停止指摘数・重大指摘数・テスト改竄の検出数・情報分離違反の検出数）を集計する。
3. v2 語彙の適用範囲が「Plan 起動前 Preflight と Plan フェーズだけ」に留まっていることを確認する（v2 L466）。
4. 実装、監査、レビュー、停止、完了判定の v1 手順が変更されていないことを確認する（v2 L476, L486）。
5. `AGENTS.md`・`prompts/*.md`・`docs/orchestration-process.md` の正本が編集されていないことを確認する（v2 L489）。

これらの確認が完了した場合、人間は `docs/orchestration-process.md` への昇格手続きを行う。

## v1計画フェーズと Preflight Routing Gate の Planning Engine 化実施方針
この節は採用済み（切替）により無効な歴史的記述である。ここで「次PR」として計画された段階的追加は、切替により全面採用へ超越された。現行運用ルールは現行正本 `docs/orchestration-process.md` の §Planning Engine・§Preflight Routing / Orchestration Cost Gate 要件・§Parent→Plan の受け渡し契約 に統合済みである。以下は設計検討時点の記述として残す。

この方針は、次PRで v1 の Plan 起動前 Preflight と Plan フェーズに v2 Planning Engine の観点を追加するための実施方針である。v2 は v1 を置き換えるものではなく、Preflight と Plan 段階で使う追加観点として扱う。

### 作成対象
- 実施方針
- プラン作成指示書

### 範囲
- v1 の現行運用ルールを維持したまま、Plan 起動前 Preflight と Plan フェーズだけを移行対象にする。
- Parent の Preflight Estimate / Routing Gate と Plan SA の Detailed Planning / Detailed Estimate を分離する。
- Plan フェーズに追加する計画観点を整理する。
- 追加観点は Goal Definition / Dependency Planning / Task Graph / Parallel Scheduling / Replan条件 / Quality Gate とする。
- Preflight Routing / Orchestration Cost Gate は、Parent の粗い起動判断と Plan SA 起動後の詳細見積もりを分ける判断材料として追加する。
- 次PRで、Plan フェーズの本文修正に進むための作業計画を作成できる状態にする。
- Parallel Scheduling は、物理的な同時実行ではなく、計画上の並列可能性と依存関係上独立して扱える作業の識別として表現する。

### 非対象
- v1 の全面置き換え
- 実装、監査、レビュー、停止、完了判定の手順変更
- DSL の意味変更
- `commit` / `push` / `deploy` / 外部送信などの実行許可変更
- Plan 起動前 Preflight と Plan フェーズ以外への v2 語彙の適用
- Parent による実装計画の詳細化、Task Graph 具体化、Done補完、Scope補完、テスト条件推定、実装判断
- コスト削減を理由にした Audit / Review の情報分離変更
- Review 省略条件を v1 の正本より広げる変更

### 維持する前提
- 現行運用ルールの正本は `docs/orchestration-process.md` のままとする。
- 実装、監査、レビュー、停止、完了判定は v1 準拠のままとする。
- v2 語彙は、v1 を置き換える語彙ではなく、Preflight と Plan 段階の追加観点としてだけ使う。
- Orchestration Cost Gate は Isolation Gate の後に評価し、分離価値が高い工程は効率が悪くても維持する。
- `docs/orchestration-v2.md` は、採用判断前の現行運用ルールとして扱わない。

### 次PRの作業計画に含める観点
- Goal Definition: Plan フェーズで、明示された目的、対象、範囲、完了条件、品質基準を整理する。
- Dependency Planning: 作業間の前提条件、依存先、独立性を整理する。
- Task Graph: 作業単位を依存関係つきの計画要素として表現する。
- Parallel Scheduling: 物理並列ではなく、依存関係上独立して扱える作業と実行順序候補を識別する。
- Replan条件: 計画更新が必要になる観測事実や停止条件を整理する。
- Quality Gate: Plan フェーズの計画が v1 の境界項目と矛盾していないことを確認する。
- Preflight Routing / Orchestration Cost Gate: Parent の粗い作業規模分類、Plan SA 起動価値、軽量ルート / フルルート候補、Plan SA 起動後の詳細見積もり、禁止事項を整理する。

次PRの計画は、上記観点を `prompts/plan.md` と `docs/orchestration-process.md` の Preflight と Plan フェーズへ反映するための作業単位として整理する。反映時も、実装、監査、レビュー、停止、完了判定の v1 手順は変更しない。
