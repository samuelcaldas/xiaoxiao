#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Compare XML tag structure between two SWFs
# Usage: ./tools/diff_structural.sh <original.swf> <rebuilt.swf>
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <original.swf> <rebuilt.swf>"
    exit 1
fi

ORIGINAL="$1"
REBUILT="$2"
TMP_DIR=$(mktemp -d)

trap 'rm -rf "$TMP_DIR"' EXIT

swfmill swf2xml "$ORIGINAL" "$TMP_DIR/original.xml"
swfmill swf2xml "$REBUILT" "$TMP_DIR/rebuilt.xml"

if diff -u "$TMP_DIR/original.xml" "$TMP_DIR/rebuilt.xml"; then
    echo "✅ Tag structure IDENTICAL"
else
    echo "❌ Structural differences found (see above)"
    exit 1
fi
