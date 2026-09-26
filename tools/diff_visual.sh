#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Frame-by-frame visual diff via swfrender + ImageMagick
# Usage: ./tools/diff_visual.sh <original.swf> <rebuilt.swf> [output_dir]
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <original.swf> <rebuilt.swf> [output_dir]"
    exit 1
fi

ORIGINAL="$1"
REBUILT="$2"
OUT_DIR="${3:-tmp/visual_diff}"

mkdir -p "$OUT_DIR"/{original,rebuilt,diff}

echo "Rendering original frames..."
swfrender "$ORIGINAL" -o "$OUT_DIR/original/frame_%04d.png" 2>/dev/null || true

echo "Rendering rebuilt frames..."
swfrender "$REBUILT" -o "$OUT_DIR/rebuilt/frame_%04d.png" 2>/dev/null || true

TOTAL=0
PASS=0
FAIL=0

for orig_frame in "$OUT_DIR/original/"*.png; do
    [ -f "$orig_frame" ] || continue
    fname=$(basename "$orig_frame")
    rebuilt_frame="$OUT_DIR/rebuilt/$fname"
    [ -f "$rebuilt_frame" ] || continue
    TOTAL=$((TOTAL + 1))
    DIFF_PIXELS=$(compare -metric AE "$orig_frame" "$rebuilt_frame" \
        "$OUT_DIR/diff/$fname" 2>&1 || true)
    if [ "$DIFF_PIXELS" = "0" ]; then
        PASS=$((PASS + 1))
    else
        echo "  Frame $fname: $DIFF_PIXELS pixels differ"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "Visual comparison: $PASS/$TOTAL frames match ($FAIL mismatches)"
echo "Diff images saved to: $OUT_DIR/diff/"

[ "$FAIL" -eq 0 ] && echo "✅ All frames match pixel-perfect" || exit 1
