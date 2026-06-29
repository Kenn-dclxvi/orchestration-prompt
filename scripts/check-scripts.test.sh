#!/usr/bin/env bash
# fixtureテスト: check-adoption.sh と check-bundle-sync.sh の pass/fail 両経路を検証する。
# 各検証の期待終了コード/出力を assert し、1件でも不一致なら全体を fail とする。
set -uo pipefail
cd "$(dirname "$0")/.."

repo_root="$(pwd)"
pass=0
fail=0

# assert: 期待終了コード・期待出力片(OK/NG)を確認する。
# 引数: <説明> <期待終了コード> <期待出力片> <実際の終了コード> <実際の出力>
assert() {
  local desc="$1" want_code="$2" want_substr="$3" got_code="$4" got_out="$5"
  local ok=1
  if [ "$got_code" -ne "$want_code" ]; then ok=0; fi
  case "$got_out" in
    *"$want_substr"*) : ;;
    *) ok=0 ;;
  esac
  if [ "$ok" -eq 1 ]; then
    echo "PASS: ${desc} (exit=${got_code}, '${want_substr}' を含む)"
    pass=$((pass + 1))
  else
    echo "FAIL: ${desc} (期待 exit=${want_code} & '${want_substr}' / 実際 exit=${got_code} / 出力: ${got_out})"
    fail=$((fail + 1))
  fi
}

# ---- check-adoption.sh の fixture ----
# 標準構成の必要ファイルを一時ディレクトリに生成するヘルパ。
make_standard_fixture() {
  local dir="$1"
  mkdir -p "$dir/prompts" "$dir/docs"
  printf 'agents\n' > "$dir/AGENTS.md"
  printf 'plan\n' > "$dir/prompts/plan.md"
  printf 'implement\n' > "$dir/prompts/implement.md"
  printf 'audit\n' > "$dir/prompts/audit.md"
  printf 'review\n' > "$dir/prompts/review.md"
  printf 'process\n' > "$dir/docs/orchestration-process.md"
  printf 'guide\n' > "$dir/docs/prompt-guide.md"
}

# fixture 1: 標準構成が全て揃い固有情報なし → exit 0 / OK。
fx1="$(mktemp -d)"
make_standard_fixture "$fx1"
out1="$(bash "$repo_root/scripts/check-adoption.sh" "$fx1" 2>&1)"; code1=$?
assert "check-adoption: 完全な標準構成 → pass" 0 "OK" "$code1" "$out1"
rm -rf "$fx1"

# fixture 2: 必要ファイルを1つ欠く → exit 非0 / NG。
fx2="$(mktemp -d)"
make_standard_fixture "$fx2"
rm -f "$fx2/prompts/audit.md"
out2="$(bash "$repo_root/scripts/check-adoption.sh" "$fx2" 2>&1)"; code2=$?
if [ "$code2" -ne 0 ]; then code2_nonzero=1; else code2_nonzero=0; fi
assert "check-adoption: 必要ファイル欠落 → fail(終了コード)" 1 "NG" "$code2_nonzero" "$out2"
rm -rf "$fx2"

# fixture 3: 標準構成は揃うが汎用ファイルに /Users/... を含む → exit 非0 / NG。
fx3="$(mktemp -d)"
make_standard_fixture "$fx3"
printf 'see /Users/someone/secret\n' > "$fx3/docs/prompt-guide.md"
out3="$(bash "$repo_root/scripts/check-adoption.sh" "$fx3" 2>&1)"; code3=$?
if [ "$code3" -ne 0 ]; then code3_nonzero=1; else code3_nonzero=0; fi
assert "check-adoption: 固有情報リーク → fail(終了コード)" 1 "NG" "$code3_nonzero" "$out3"
rm -rf "$fx3"

# ---- check-bundle-sync.sh の検証 ----
bundle="$repo_root/AI_CHAT_BUNDLE.txt"
bundle_backup="$(mktemp)"
cp "$bundle" "$bundle_backup"
# どの終了経路でも AI_CHAT_BUNDLE.txt を原本へ復元する。
restore_bundle() {
  cp "$bundle_backup" "$bundle"
  rm -f "$bundle_backup"
}
trap restore_bundle EXIT

# 検証 1: 改変なしの状態 → exit 0 / OK。
out4="$(bash "$repo_root/scripts/check-bundle-sync.sh" 2>&1)"; code4=$?
assert "check-bundle-sync: 改変なし → pass" 0 "OK" "$code4" "$out4"

# 検証 1 後に原本がバイト一致で残っていること。
if cmp -s "$bundle" "$bundle_backup"; then
  echo "PASS: check-bundle-sync 実行後に AI_CHAT_BUNDLE.txt が原本とバイト一致"
  pass=$((pass + 1))
else
  echo "FAIL: check-bundle-sync 実行後に AI_CHAT_BUNDLE.txt が原本と不一致(非破壊違反)"
  fail=$((fail + 1))
fi

# 検証 2: ドリフト誘発(Generated: 行以外の本文に1行追加)→ exit 非0 / NG。
printf 'DRIFT-MARKER-FOR-TEST\n' >> "$bundle"
out5="$(bash "$repo_root/scripts/check-bundle-sync.sh" 2>&1)"; code5=$?
if [ "$code5" -ne 0 ]; then code5_nonzero=1; else code5_nonzero=0; fi
assert "check-bundle-sync: ドリフト → fail(終了コード)" 1 "NG" "$code5_nonzero" "$out5"
# 改変分を原本へ戻す(後続/trap の二重保険)。
cp "$bundle_backup" "$bundle"

# ---- 総括 ----
echo "----"
echo "結果: PASS=${pass} FAIL=${fail}"
if [ "$fail" -eq 0 ]; then
  echo "OK: 全 assert 成立。"
  exit 0
else
  echo "NG: ${fail} 件の assert が不成立。"
  exit 1
fi
