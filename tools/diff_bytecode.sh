#!/usr/bin/env bash
set -euo pipefail
if [ $# -lt 2 ]; then
    echo "Usage: $0 <original.swf> <rebuilt.swf>"
    exit 1
fi
ORIGINAL="$1"
REBUILT="$2"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

flasm -d "$ORIGINAL" 2>/dev/null | grep -a -v "^Parsing '" > "$TMP_DIR/original.flm"
flasm -d "$REBUILT" 2>/dev/null | grep -a -v "^Parsing '" > "$TMP_DIR/rebuilt.flm"

if diff -u "$TMP_DIR/original.flm" "$TMP_DIR/rebuilt.flm" > "$TMP_DIR/bytecode.diff"; then
    echo "✅ Bytecode IDENTICAL"
else
    DIFF_COUNT=$(wc -l < "$TMP_DIR/bytecode.diff")
    echo "❌ Bytecode differences found ($DIFF_COUNT lines)"
    cat "$TMP_DIR/bytecode.diff" | head -n 30
    exit 1
fi
