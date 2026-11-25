#!/usr/bin/env bash
# Test runner (M1-8). Usage: bash tests/run_tests.sh ./pizza
#
#   tests/lexer/NAME.pz    token dump must equal tests/lexer/NAME.tokens;
#                          exit status must be 1 for err_*.pz, else 0
#   tests/valid/*.pz       must parse (exit 0)
#   tests/invalid/*.pz     must fail (exit 1)

BIN=${1:-./pizza}
DIR=$(cd "$(dirname "$0")" && pwd)
pass=0
fail=0

ok()  { pass=$((pass + 1)); }
bad() { fail=$((fail + 1)); echo "FAIL: $1"; }

shopt -s nullglob

for src in "$DIR"/lexer/*.pz; do
    name=$(basename "$src" .pz)
    expected="$DIR/lexer/$name.tokens"
    if [ ! -f "$expected" ]; then bad "lexer/$name (missing $name.tokens)"; continue; fi
    actual=$("$BIN" --tokens "$src" 2>&1); status=$?
    want=0; case "$name" in err_*) want=1 ;; esac
    if [ "$status" -ne "$want" ]; then
        bad "lexer/$name (exit $status, expected $want)"
    elif ! diff -u "$expected" <(printf '%s\n' "$actual") > /dev/null; then
        bad "lexer/$name (token stream differs)"
        diff -u "$expected" <(printf '%s\n' "$actual") | head -20
    else
        ok
    fi
done

for src in "$DIR"/valid/*.pz; do
    if "$BIN" "$src" > /dev/null 2>&1; then ok; else bad "valid/$(basename "$src") (rejected)"; fi
done

for src in "$DIR"/invalid/*.pz; do
    "$BIN" "$src" > /dev/null 2>&1; status=$?
    if [ "$status" -eq 1 ]; then ok; else bad "invalid/$(basename "$src") (exit $status, expected 1)"; fi
done

echo "passed: $pass, failed: $fail"
[ "$fail" -eq 0 ]
