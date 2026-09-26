#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Verify Tier 2 Structural Match between original and rebuilt SWF
# Usage: ./tools/verify_match.sh <decomp_dir> <rebuilt.swf>
# Example: ./tools/verify_match.sh decomp/xiao_xiao_4/ rebuilt.swf
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

if [ $# -lt 2 ]; then
    echo "Usage: $0 <decomp_dir> <rebuilt.swf>"
    echo "Example: $0 decomp/xiao_xiao_4/ tmp/rebuilt_xx4.swf"
    exit 1
fi

DECOMP_DIR="$1"
REBUILT_SWF="$2"
MATCH_DIR="$DECOMP_DIR/match"
ORIGINAL_XML="$MATCH_DIR/original.xml"
SWF_NAME="$(basename "$DECOMP_DIR")"
ORIG_SWF="originals/${SWF_NAME}.swf"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

echo "═══════════════════════════════════════════════════════"
echo "  TIER 2 STRUCTURAL MATCH VERIFICATION"
echo "  Original:  $ORIG_SWF"
echo "  Rebuilt:   $REBUILT_SWF"
echo "  Decomp:    $DECOMP_DIR"
echo "═══════════════════════════════════════════════════════"
echo ""

mkdir -p "$MATCH_DIR/frames"/{original,rebuilt,diff}

# ── Layer 1: Tag-by-Tag XML Structural Diff ────────────────
echo "[1/3] XML Structural Diff (swfmill)..."
if command -v swfmill &>/dev/null && [ -f "$ORIGINAL_XML" ]; then
    swfmill swf2xml "$REBUILT_SWF" "$MATCH_DIR/rebuilt.xml" 2>/dev/null
    if diff -u "$ORIGINAL_XML" "$MATCH_DIR/rebuilt.xml" > "$MATCH_DIR/structural.diff" 2>&1; then
        echo "  ✅ PASS: Tag structure IDENTICAL"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        DIFF_LINES=$(wc -l < "$MATCH_DIR/structural.diff")
        echo "  ❌ FAIL: $DIFF_LINES lines of structural differences"
        echo "           See: $MATCH_DIR/structural.diff"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "  ⏭ SKIP: swfmill or original.xml not available"
    SKIP_COUNT=$((SKIP_COUNT + 1))
fi

# ── Layer 2: Bytecode P-code Diff (Flasm) ──────────────────
echo "[2/3] Bytecode P-code Diff (Flasm)..."
ORIG_BYTECODE="$DECOMP_DIR/bytecode/root_timeline.flm"
if command -v flasm &>/dev/null && [ -f "$ORIG_BYTECODE" ]; then
    flasm -d "$REBUILT_SWF" > "$MATCH_DIR/rebuilt_bytecode.flm" 2>/dev/null || true
    if diff -u "$ORIG_BYTECODE" "$MATCH_DIR/rebuilt_bytecode.flm" > "$MATCH_DIR/bytecode.diff" 2>&1; then
        echo "  ✅ PASS: Bytecode IDENTICAL"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        DIFF_LINES=$(wc -l < "$MATCH_DIR/bytecode.diff")
        echo "  ❌ FAIL: $DIFF_LINES lines of bytecode differences"
        echo "           See: $MATCH_DIR/bytecode.diff"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "  ⏭ SKIP: Flasm or original bytecode not available"
    SKIP_COUNT=$((SKIP_COUNT + 1))
fi

# ── Layer 3: Visual Frame Comparison (swfrender + ImageMagick) ──
echo "[3/3] Visual Frame Comparison (swfrender)..."
if command -v swfrender &>/dev/null && command -v compare &>/dev/null && [ -f "$ORIG_SWF" ]; then
    echo "  Rendering original frames..."
    swfrender "$ORIG_SWF" -o "$MATCH_DIR/frames/original/frame_%04d.png" 2>/dev/null || true
    echo "  Rendering rebuilt frames..."
    swfrender "$REBUILT_SWF" -o "$MATCH_DIR/frames/rebuilt/frame_%04d.png" 2>/dev/null || true

    TOTAL=0
    VISUAL_PASS=0
    VISUAL_FAIL=0
    for orig_frame in "$MATCH_DIR/frames/original/"*.png; do
        [ -f "$orig_frame" ] || continue
        fname=$(basename "$orig_frame")
        rebuilt_frame="$MATCH_DIR/frames/rebuilt/$fname"
        [ -f "$rebuilt_frame" ] || continue
        TOTAL=$((TOTAL + 1))
        DIFF_PIXELS=$(compare -metric AE "$orig_frame" "$rebuilt_frame" \
            "$MATCH_DIR/frames/diff/$fname" 2>&1 || true)
        if [ "$DIFF_PIXELS" = "0" ]; then
            VISUAL_PASS=$((VISUAL_PASS + 1))
        else
            VISUAL_FAIL=$((VISUAL_FAIL + 1))
        fi
    done

    if [ "$TOTAL" -gt 0 ]; then
        echo "  Visual: $VISUAL_PASS/$TOTAL frames match pixel-perfect ($VISUAL_FAIL mismatches)"
        if [ "$VISUAL_FAIL" -eq 0 ]; then
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo "  ⏭ No frames rendered for comparison"
        SKIP_COUNT=$((SKIP_COUNT + 1))
    fi
else
    echo "  ⏭ SKIP: swfrender or ImageMagick compare not available"
    SKIP_COUNT=$((SKIP_COUNT + 1))
fi

# ── Summary ────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  VERIFICATION SUMMARY"
echo "  ✅ Pass: $PASS_COUNT  ❌ Fail: $FAIL_COUNT  ⏭ Skip: $SKIP_COUNT"
if [ "$FAIL_COUNT" -eq 0 ] && [ "$SKIP_COUNT" -eq 0 ]; then
    echo "  🎉 ALL CHECKS PASSED — TIER 2 STRUCTURAL MATCH!"
elif [ "$FAIL_COUNT" -eq 0 ]; then
    echo "  ⚠ Passed available checks (some skipped)"
else
    echo "  ⚠ MATCHING INCOMPLETE — review diffs above"
fi
echo "═══════════════════════════════════════════════════════"

exit "$FAIL_COUNT"
