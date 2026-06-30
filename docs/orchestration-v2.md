# オーケストレーション v2 設計

## 位置づけ
この文書は、要求から実装完了までを最短時間で達成するための自律オーケストレーション設計を記述する。

v1 の現行安定版の正本は `docs/orchestration-process.md` である。この文書は現行運用ルールではなく、v2化に向けた準備中の設計である。

v2 は、v1 の手順を置き換える文書ではない。v1 が定義している承認済み実装指示書、作業単位化、実装、監査、レビュー、停止、完了判定の運用は、v2 が採用されるまで v1 に従う。

## Mission
v2 の目的は、AI 駆動開発を「安全に実行するためのルール集」から「要求を満たす実装完了へ最短経路で到達する自律型 Software Architect の行動モデル」へ発展させることである。

v2 は次を目指す。

- AI がゴールを理解し、必要タスクを抽出する。
- AI が依存関係を解析し、並列化可能な作業を発見する。
- AI が品質を維持しながら、最終的な完了時間が最小となる実行経路を選択する。
- AI が実行中の新しい情報、エラー、テスト結果、レビュー結果を使って計画を更新する。
- Contract / Constraints / Quality Gate / Toolbox を、ライフサイクルを支える構成要素として扱う。

## Execution Lifecycle
v2 の実行ライフサイクルは、Requirement → Goal Definition → Planning → Dependency Analysis → Task Graph → Parallel Scheduling → Execution → Continuous Verification → Replan → Goal Complete である。

このライフサイクルは、Goal → Planning → Execution → Verification → Replan → Goal Complete の流れを中心に構成する。

各段階の責務は次のとおりである。

- Requirement: 要求を受け取り、明示された対象、範囲、制約、完了条件を識別する。
- Goal Definition: 要求を達成すべきゴールとして定義し、成功条件を明確にする。
- Planning: ゴール達成に必要なタスク、依存関係、優先順位、実行順序を設計する。
- Dependency Analysis: 各タスクの前提条件、依存先、並列実行可否を解析する。
- Task Graph: タスクを有向グラフとして表現する。
- Parallel Scheduling: 依存関係のないタスクを並列化し、待ち時間を最小化する。
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
Planning Engine は、v2 の中心概念である。

Planning Engine は、AI が Software Architect として実装開始前に最適な実行計画を構築し、実行中も計画を更新するための機構である。

Planning Engine は次を行う。

- 要求の理解
- ゴールの明確化
- 完了条件の抽出
- タスク分解
- 依存関係解析
- 優先順位決定
- 並列実行可能性の判断
- 実行順序の決定
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

v2 は、単純に目先の作業時間が短い経路を選ばない。品質低下、手戻り、再確認、依存待ちを含めた最終的な完了時間が最小となる経路を選択する。

## Dependency Planning
Dependency Planning は、作業を有向グラフとして扱う設計である。

各タスクは次を保持する。

- 前提条件
- 完了条件
- 依存先
- 並列実行可否

AI は、依存関係があるタスクを無理に並列化しない。依存関係がないタスクは、待ち時間、確認回数、手戻りを減らすために積極的に並列化する。

Dependency Planning は、不要な確認、無駄な待ち時間、実装後の手戻りを最小化するために使う。

## Parallel Execution
Parallel Execution は、独立したタスクを同時進行させる標準動作である。

AI は、逐次実行を前提にしない。依存関係がない作業は、速度向上のために並列化を検討する。

並列化できる作業の例は次のとおりである。

- API実装
- UI修正
- テストコード作成
- ドキュメント更新

Parallel Execution は、Contract、Constraints、Quality Gate を満たす範囲で行う。並列化によって境界が不明確になる場合、AI は並列化せず、必要な境界を返す。

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
- 並列化再計算
- 実行順序更新
- 品質確認手順の更新

AI は、計画を維持することを目的にしない。常に Goal 達成までの最短経路へ計画を最適化する。

## Goal Complete
Goal Complete は、要求を満たし、品質基準を満たした状態である。

Goal Complete は、単に実装が終わった状態ではない。成果物、確認結果、テスト結果、制約照合によって、要求が満たされたことを説明できる状態である。

Goal Complete に到達できない場合、AI は未達の条件、停止理由、次に必要な判断を返す。

## Contract
Contract は、Planning Engine が最適化を行う際の制約条件である。

Contract は、計画を固定するものではない。Contract はゴール、制約、完了条件を保持し、Planning Engine はその範囲内でタスク構成、実行順序、並列化を決定する。

Contract は次を保持する。

- `goal`: 達成すべき結果
- `constraints`: 禁止、停止、除外操作
- `done`: 完了条件

Contract に未定義の境界を AI が補完してはならない。Contract が不足している場合、AI は不足項目を返す。

## Constraints
Constraints は、Planning Engine と Execution が越えてはならない境界である。

v2 の Constraints は次を含む。

- AI は対象、範囲、完了条件、品質基準、実行許可を補完しない。
- 現行運用ルールを変更する場合は、v1 の正本を明示対象に含める。
- `commit` / `push` / `deploy` / 外部送信は、Contract で明示許可された場合だけ行う。
- テスト期待値の変更、skip、xfail、assertion 緩和、失敗パスの握りつぶしを完了の近道にしない。
- 便乗リファクタ、命名変更、移動、削除、構成変更を Contract 外で行わない。
- 原因不明の探索的修正を行わない。
- v2 文書を、採用前に現行運用ルールとして扱わない。

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

v2 設計中の SSOT は次の関係を持つ。

- 現行運用ルールの SSOT は `docs/orchestration-process.md` である。
- 設計理由と書き味の SSOT は `docs/prompt-guide.md` である。
- v2 の自律オーケストレーション設計の SSOT は、この文書である。

矛盾がある場合、現行運用では `docs/orchestration-process.md` を優先する。この文書は、v1 の正本を変更しない。

## AIへ委譲する判断
AIへ委譲する判断は、Contract の範囲内で完結する仮決定に限る。

AI は次を判断してよい。

- Goal 達成に必要なタスク分解
- タスク間の依存関係
- 並列化可能な作業
- 実行順序と優先順位
- Toolbox から使う道具
- 実行中の計画更新
- 明示されたテスト条件に基づく実行と結果整理
- 差分、テスト結果、仕様の照合
- Constraints に抵触した場合の停止
- 不足している Contract 項目の列挙

AI は、委譲された判断を Contract の拡張に変換してはならない。

## 人間が保持する判断
人間が保持する判断は、作業境界とリスク受容に関わる決定である。

人間は次を保持する。

- 目的、対象、範囲、完了条件、品質基準、実行許可の確定
- SSOT の採用、変更、優先順位の決定
- v2 を現行運用へ昇格する判断
- Contract 外の仕様変更、構成変更、対象拡張の判断
- `commit` / `push` / `deploy` / 外部送信の許可
- テスト条件が不足している場合の追加定義
- 停止後に作業を続けるかどうかの判断

AI は、人間が保持する判断を推定で代替しない。

## Success Criteria
v2 の成功条件は、単に実装が完了したことではない。

v2 の成功条件は、最小時間で要求を満たし、品質基準を満たした状態に到達することである。

成功には次を含む。

- Goal が達成されている。
- Contract と Constraints から逸脱していない。
- Quality Gate を満たしている。
- 依存待ち、不要確認、手戻り、コンテキスト切替が最小化されている。
- 成果物と確認結果によって完了を説明できる。

品質と速度を両立することが、v2 のオーケストレーションの責務である。

## v1からv2への移行段階
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
