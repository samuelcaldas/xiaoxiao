#!/usr/bin/env bash
set -euo pipefail
if [ $# -lt 1 ]; then
    echo "Usage: $0 <swf_file> [output.xml]"
    exit 1
fi
SWF_FILE="$1"
OUTPUT="${2:-$(basename "$SWF_FILE" .swf)_tags.xml}"

swfmill swf2xml "$SWF_FILE" "$OUTPUT"

# Ensure XML is valid UTF-8 (handling legacy Chinese/Shift-JIS font names)
python3 -c "
with open('$OUTPUT', 'rb') as f:
    content = f.read()
try:
    content.decode('utf-8')
except UnicodeDecodeError:
    text = content.decode('gbk', errors='replace')
    with open('$OUTPUT', 'w', encoding='utf-8') as f:
        f.write(text)
"
echo "✅ Tags dumped to $OUTPUT ($(wc -l < "$OUTPUT") lines)"
