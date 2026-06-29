#!/usr/bin/env bash
# 適用後検証: 標準構成の必要ファイル存在と、汎用ファイルへの固有情報リークを検査する。
# 必要ファイルの根拠は docs/AI 適用ガイド.md の「前提」。
set -euo pipefail

# 対象ディレクトリ。省略時はリポジトリルートを対象にする。
if [ "$#" -ge 1 ]; then
  target_dir="$1"
else
  target_dir="$(cd "$(dirname "$0")/.." && pwd)"
fi

# 標準構成(必要ファイル)。
required=(
  AGENTS.md
  prompts/plan.md
  prompts/implement.md
  prompts/audit.md
  prompts/review.md
  docs/orchestration-process.md
  docs/prompt-guide.md
)

fail=0

# 検査1: 必要ファイルの存在。
for f in "${required[@]}"; do
  if [ -f "$target_dir/$f" ]; then
    echo "OK: ${f} が存在。"
  else
    echo "NG: ${f} が存在しない。"
    fail=1
  fi
done

# 検査2: 存在する汎用ファイルへの固有情報(絶対パス /Users/ または /home/)リーク。
for f in "${required[@]}"; do
  if [ -f "$target_dir/$f" ]; then
    if grep -qE '/Users/|/home/' "$target_dir/$f"; then
      echo "NG: ${f} に固有情報(絶対パス /Users/ または /home/)が混入。汎用ファイルへの固有情報リーク。"
      fail=1
    fi
  fi
done

if [ "$fail" -eq 0 ]; then
  echo "OK: ${target_dir} は標準構成・固有情報リークの両方に適合。"
fi
exit "$fail"
