#!/usr/bin/env bash
# 適用後検証: コミット済み AI_CHAT_BUNDLE.txt が scripts/build-bundle.sh の現出力と
# 同期しているか(束ねのドリフト)を検査する。
# 比較は Generated: で始まる行を両側から除外して行う(生成日差での誤検出を防ぐ)。
# 非破壊: build-bundle.sh は再生成で AI_CHAT_BUNDLE.txt を上書きするため、
# 現ファイルを一時退避し、trap でいかなる終了経路でもバイト一致で復元する。
set -euo pipefail
cd "$(dirname "$0")/.."

out="AI_CHAT_BUNDLE.txt"

if [ ! -f "$out" ]; then
  echo "NG: ${out} が存在しない。" >&2
  exit 1
fi

# 一時退避(原本のバイト列をそのまま保持)。
saved="$(mktemp)"
regen="$(mktemp)"
cp "$out" "$saved"

# どの終了経路でも原本を復元し、一時生成物を後始末する。
restore() {
  cp "$saved" "$out"
  rm -f "$saved" "$regen"
}
trap restore EXIT

# 現出力を再生成(build-bundle.sh は $out を上書きする)。
bash scripts/build-bundle.sh >/dev/null
cp "$out" "$regen"

# Generated: 行を両側から除外して比較する。
if diff <(grep -v '^Generated:' "$saved") <(grep -v '^Generated:' "$regen") >/dev/null; then
  echo "OK: ${out} は build-bundle.sh の現出力と同期している(Generated行除外比較)。"
  exit 0
else
  echo "NG: ${out} が build-bundle.sh の現出力とドリフトしている(Generated行除外比較)。ソース変更後に再生成すること。"
  exit 1
fi
