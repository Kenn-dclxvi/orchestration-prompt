#!/usr/bin/env bash
# AGENTS.md 配置規律チェック。
# 構成項目の逐語列挙が AGENTS.md 本文(root / overlay)へ再混入していないかを grep で検出する。
# 規律の根拠は docs/prompt-guide.md の「配置規律」。
set -euo pipefail
cd "$(dirname "$0")/.."

# 検査対象: root の AGENTS.md と、配備される全 overlay の AGENTS.md。
# glob 不一致時にリテラルが混ざらないよう [ -f ] でガードする。
targets=(AGENTS.md)
for o in overlays/*/files/AGENTS.md; do
  if [ -f "$o" ]; then
    targets+=("$o")
  fi
done

fail=0
for f in "${targets[@]}"; do
  file_fail=0

  # 1. 境界項目の逐語列挙(末尾「範囲・完了条件・品質基準・実行許可」)は冒頭の用語定義1箇所のみ。
  n=$(grep -c '範囲・完了条件・品質基準・実行許可' "$f" || true)
  if [ "$n" -gt 1 ]; then
    echo "NG: ${f}: 境界項目の逐語列挙が ${n} 行に出現。用語定義1箇所へ畳み、本文は「境界項目」で参照すること。"
    grep -n '範囲・完了条件・品質基準・実行許可' "$f"
    file_fail=1
  fi

  # 2. テンプレート構成項目の逐語列挙(「品質基準・実行許可・除外操作」)は正本のみ。AGENTS.md 本文には置かない。
  if grep -nq '品質基準[、・]実行許可[、・]除外操作' "$f"; then
    echo "NG: ${f}: テンプレート構成項目の逐語列挙が AGENTS.md にある。docs/orchestration-process.md に集約すること。"
    grep -n '品質基準[、・]実行許可[、・]除外操作' "$f"
    file_fail=1
  fi

  if [ "$file_fail" -eq 0 ]; then
    echo "OK: ${f} は配置規律に適合。"
  else
    fail=1
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "OK: 全 AGENTS.md(${#targets[@]}件) は配置規律に適合。"
fi
exit "$fail"
