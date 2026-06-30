#!/usr/bin/env bash
# AI_CHAT_BUNDLE.txt 生成スクリプト。
# リポジトリのプロンプトセットを1つのテキストへ束ね、AIチャットへ渡せる形にする。
# Included Files は curated な明示リスト。人間向けの習熟文書(docs/AIエージェント活用指針.md)は
# AI制御セットではないため、原典の束ねと同じく含めない。
set -euo pipefail
cd "$(dirname "$0")/.."
out="AI_CHAT_BUNDLE.txt"

files=(
  README.md
  "docs/AI 適用ガイド.md"
  AGENTS.md
  .gitignore
  docs/orchestration-process.md
  docs/orchestration-v2.md
  docs/prompt-guide.md
  prompts/plan.md
  prompts/implement.md
  prompts/audit.md
  prompts/review.md
  templates/launch-plan-sa.md
  templates/launch-implement-sa.md
  templates/launch-audit-sa.md
  templates/launch-review-sa.md
  overlays/example/repo-context.md
  overlays/the-caption/README.md
  overlays/the-caption/repo-context.md
  overlays/the-caption/files/AGENTS.md
  overlays/the-caption/files/prompts/plan.md
  overlays/the-caption/files/prompts/implement.md
  overlays/the-caption/files/prompts/audit.md
  overlays/the-caption/files/prompts/review.md
)

# 存在しないファイルがあれば停止する(束ねの取りこぼしを成果物で検出する)。
missing=0
for f in "${files[@]}"; do
  if [ ! -f "$f" ]; then echo "NG: 対象ファイルが存在しない: $f" >&2; missing=1; fi
done
[ "$missing" -eq 0 ] || exit 1

{
  printf '# AI Chat Bundle: orchestration-prompt\n\n'
  printf 'Generated: %s\n\n' "$(date +%Y-%m-%d)"
  printf 'This file merges the repository prompt set into one text file for passing to an AI chat.\n\n'
  printf '## Included Files\n\n'
  for f in "${files[@]}"; do printf -- '- %s\n' "$f"; done

  for f in "${files[@]}"; do
    printf '\n===== BEGIN %s =====\n\n' "$f"
    # 末尾の空行を落とし、END マーカー前の空行を常に1つにそろえる。
    awk '{ a[NR]=$0 } END{ n=NR; while (n>0 && a[n]=="") n--; for (i=1;i<=n;i++) print a[i] }' "$f"
    printf '\n===== END %s =====\n' "$f"
  done
} > "$out"

echo "OK: $out を生成(${#files[@]}ファイル, $(wc -l < "$out")行)。"
