#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Extract assets, tags, and bytecode from an SWF file
# Usage: ./tools/extract.sh originals/xiao_xiao_4.swf
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <swf_file>"
    exit 1
fi

SWF_FILE="$1"
SWF_NAME="$(basename "$SWF_FILE" .swf)"
OUT_DIR="decomp/$SWF_NAME"

if [ ! -f "$SWF_FILE" ]; then
    echo "Error: SWF file not found: $SWF_FILE"
    exit 1
fi

mkdir -p "$OUT_DIR"/{assets/{shapes,sounds,images,fonts,sprites},bytecode/sprites,scripts,display_list,match/frames}

echo "═══════════════════════════════════════════════════════"
echo "  Extracting: $SWF_FILE"
echo "  Output:     $OUT_DIR/"
echo "═══════════════════════════════════════════════════════"
echo ""

# ── 1/5: Extract assets via FFDec CLI ──────────────────────
echo "[1/5] Extracting assets via FFDec..."
if command -v ffdec &>/dev/null; then
    ffdec -export shape  "$OUT_DIR/assets/shapes"  "$SWF_FILE" 2>/dev/null || echo "  ⚠ Shape export had warnings"
    ffdec -export sound  "$OUT_DIR/assets/sounds"  "$SWF_FILE" 2>/dev/null || echo "  ⚠ Sound export had warnings"
    ffdec -export image  "$OUT_DIR/assets/images"  "$SWF_FILE" 2>/dev/null || echo "  ⚠ Image export had warnings"
    ffdec -export font   "$OUT_DIR/assets/fonts"   "$SWF_FILE" 2>/dev/null || echo "  ⚠ Font export had warnings"
    ffdec -export script "$OUT_DIR/scripts"         "$SWF_FILE" 2>/dev/null || echo "  ⚠ Script export had warnings"
    echo "  ✅ Assets extracted"
else
    echo "  ⏭ FFDec not found, skipping asset extraction"
fi

# ── 2/5: Dump tag structure via swfmill ────────────────────
echo "[2/5] Dumping tag structure via swfmill..."
if command -v swfmill &>/dev/null; then
    swfmill swf2xml "$SWF_FILE" "$OUT_DIR/tags.xml"
    cp "$OUT_DIR/tags.xml" "$OUT_DIR/match/original.xml"
    echo "  ✅ Tag XML dumped ($(wc -l < "$OUT_DIR/tags.xml") lines)"
else
    echo "  ⏭ swfmill not found, skipping tag dump"
fi

# ── 3/5: Dump tag summary via swfdump ──────────────────────
echo "[3/5] Dumping tag summary via swfdump..."
if command -v swfdump &>/dev/null; then
    swfdump "$SWF_FILE" > "$OUT_DIR/swfdump_full.txt" 2>/dev/null || true
    swfdump -a "$SWF_FILE" > "$OUT_DIR/swfdump_actions.txt" 2>/dev/null || true
    swfdump -s "$SWF_FILE" > "$OUT_DIR/swfdump_shapes.txt" 2>/dev/null || true
    echo "  ✅ swfdump output saved"
else
    echo "  ⏭ swfdump not found, skipping"
fi

# ── 4/5: Disassemble bytecode via Flasm ────────────────────
echo "[4/5] Disassembling bytecode via Flasm..."
if command -v flasm &>/dev/null; then
    flasm -d "$SWF_FILE" > "$OUT_DIR/bytecode/root_timeline.flm" 2>/dev/null || true
    echo "  ✅ Bytecode disassembled ($(wc -l < "$OUT_DIR/bytecode/root_timeline.flm" 2>/dev/null || echo 0) lines)"
else
    echo "  ⏭ Flasm not found, skipping bytecode disassembly"
fi

# ── 5/5: Generate metadata ─────────────────────────────────
echo "[5/5] Generating metadata..."
python3 << 'PYEOF'
import json
import struct
import sys
import os

swf_file = sys.argv[1] if len(sys.argv) > 1 else os.environ.get('SWF_FILE', '')
if not swf_file:
    swf_file = "$SWF_FILE"

try:
    with open(swf_file, 'rb') as f:
        sig = f.read(3).decode('ascii')
        ver = struct.unpack('B', f.read(1))[0]
        size = struct.unpack('<I', f.read(4))[0]

        # Read RECT for stage dimensions
        rect_byte = struct.unpack('B', f.read(1))[0]
        nbits = rect_byte >> 3

    meta = {
        'file': os.path.basename(swf_file).replace('.swf', ''),
        'source': swf_file,
        'signature': sig,
        'version': ver,
        'file_size_bytes': size,
        'compressed': sig != 'FWS',
        'compression': {
            'FWS': 'none',
            'CWS': 'zlib',
            'ZWS': 'lzma'
        }.get(sig, 'unknown'),
        'avm': 'AVM1' if ver <= 8 else 'AVM2',
        'actionscript_version': '1.0' if ver <= 5 else ('2.0' if ver <= 8 else '3.0'),
    }

    out_dir = os.path.dirname(swf_file).replace('originals', 'decomp')
    if 'originals' not in swf_file:
        out_dir = f"decomp/{meta['file']}"
    else:
        out_dir = f"decomp/{meta['file']}"

    os.makedirs(out_dir, exist_ok=True)
    with open(f"{out_dir}/metadata.json", 'w') as out:
        json.dump(meta, out, indent=2)
    print(f"  ✅ Metadata saved to {out_dir}/metadata.json")
    print(f"     SWF v{ver} ({sig}), {meta['avm']}, AS {meta['actionscript_version']}")
    print(f"     File size: {size:,} bytes ({size/1024:.1f} KB)")

except Exception as e:
    print(f"  ⚠ Metadata generation failed: {e}")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  ✅ Extraction complete: $OUT_DIR/"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Asset counts:"
for subdir in shapes sounds images fonts sprites; do
    count=$(find "$OUT_DIR/assets/$subdir" -type f 2>/dev/null | wc -l)
    echo "  $subdir: $count files"
done
script_count=$(find "$OUT_DIR/scripts" -type f 2>/dev/null | wc -l)
echo "  scripts: $script_count files"
