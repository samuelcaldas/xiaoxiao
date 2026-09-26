#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Disassemble AVM1 ActionScript bytecode via Flasm
# Usage: ./tools/dump_bytecode.sh <swf_file> [output.flm]
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <swf_file> [output.flm]"
    exit 1
fi

SWF_FILE="$1"
OUTPUT="${2:-$(basename "$SWF_FILE" .swf)_bytecode.flm}"

if ! command -v flasm &>/dev/null; then
    echo "Error: flasm not installed. Run ./tools/setup.sh first."
    exit 1
fi

flasm -d "$SWF_FILE" > "$OUTPUT" 2>/dev/null
echo "✅ Bytecode disassembled to $OUTPUT ($(wc -l < "$OUTPUT") lines)"
