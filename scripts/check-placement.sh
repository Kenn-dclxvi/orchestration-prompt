#!/usr/bin/env bash
# AGENTS.md 配置規律チェック。
# 構成項目の逐語列挙が AGENTS.md 本文へ再混入していないかを grep で検出する。
# 規律の根拠は docs/prompt-guide.md の「配置規律」。
set -euo pipefail
cd "$(dirname "$0")/.."
f="AGENTS.md"
fail=0

# 1. 境界項目の逐語列挙(末尾「範囲・完了条件・品質基準・実行許可」)は冒頭の用語定義1箇所のみ。
n=$(grep -c '範囲・完了条件・品質基準・実行許可' "$f" || true)
if [ "$n" -gt 1 ]; then
  echo "NG: 境界項目の逐語列挙が ${n} 行に出現。用語定義1箇所へ畳み、本文は「境界項目」で参照すること。"
  grep -n '範囲・完了条件・品質基準・実行許可' "$f"
  fail=1
fi

# 2. テンプレート構成項目の逐語列挙(「品質基準・実行許可・除外操作」)は正本のみ。AGENTS.md 本文には置かない。
if grep -nq '品質基準[、・]実行許可[、・]除外操作' "$f"; then
  echo "NG: テンプレート構成項目の逐語列挙が AGENTS.md にある。docs/orchestration-process.md に集約すること。"
  grep -n '品質基準[、・]実行許可[、・]除外操作' "$f"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "OK: AGENTS.md は配置規律に適合。"
fi
exit "$fail"
