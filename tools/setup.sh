#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Xiao Xiao Decomp Toolchain Setup
# Installs: FFDec, SWFTools, swfmill, Flasm, Ruffle, Haxe/OpenFL
# ═══════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "═══ Xiao Xiao Decomp Toolchain Setup ═══"
echo "Project root: $PROJECT_ROOT"
echo ""

# ── 1. JPEXS Free Flash Decompiler (FFDec) ──────────────────
# Java-based all-in-one decompiler, asset extractor, P-code editor
# https://github.com/jindrapetrik/jpexs-decompiler
FFDEC_VERSION="26.3.0"
FFDEC_DIR="$HOME/.local/share/ffdec"
if command -v ffdec &>/dev/null; then
    echo "[✓] FFDec already installed"
else
    echo "[+] Installing FFDec v${FFDEC_VERSION}..."
    mkdir -p "$FFDEC_DIR" "$HOME/.local/bin"
    wget -qO "$FFDEC_DIR/ffdec.zip" \
        "https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version${FFDEC_VERSION}/ffdec_${FFDEC_VERSION}.zip"
    unzip -qo "$FFDEC_DIR/ffdec.zip" -d "$FFDEC_DIR"
    cat > "$HOME/.local/bin/ffdec" << 'LAUNCHER'
#!/bin/bash
java -jar "$HOME/.local/share/ffdec/ffdec.jar" "$@"
LAUNCHER
    chmod +x "$HOME/.local/bin/ffdec"
    echo "[✓] FFDec installed to $FFDEC_DIR"
fi

# ── 2. SWFTools (swfdump, swfextract, swfrender) ───────────
# CLI tag inspector, asset extractor, frame rasterizer
# https://github.com/swftools/swftools
if command -v swfdump &>/dev/null; then
    echo "[✓] SWFTools already installed"
else
    echo "[+] Installing SWFTools..."
    sudo apt-get install -y swftools
    echo "[✓] SWFTools installed"
fi

# ── 3. swfmill (SWF ↔ XML bidirectional compiler) ──────────
# Essential for Tier 2 structural matching (tag-by-tag XML diff)
# https://github.com/djcsdy/swfmill
if command -v swfmill &>/dev/null; then
    echo "[✓] swfmill already installed"
else
    echo "[+] Installing swfmill..."
    sudo apt-get install -y swfmill 2>/dev/null || {
        echo "    swfmill not in apt, building from source..."
        git clone --depth 1 https://github.com/djcsdy/swfmill.git /tmp/swfmill-build
        (cd /tmp/swfmill-build && mkdir -p build && cd build && cmake .. && make -j"$(nproc)" && sudo make install)
        rm -rf /tmp/swfmill-build
    }
    echo "[✓] swfmill installed"
fi

# ── 4. Flasm (AVM1 ActionScript Disassembler / Assembler) ──
# Disassembles AS1 bytecode to .flm text, reassembles back
# Critical for bytecode-level matching verification
if command -v flasm &>/dev/null; then
    echo "[✓] Flasm already installed"
else
    echo "[+] Installing Flasm..."
    sudo apt-get install -y flasm 2>/dev/null || {
        echo "    Flasm not in apt, building from source..."
        wget -qO /tmp/flasm.tar.gz "https://github.com/nickshanks/flasm/archive/refs/heads/master.tar.gz"
        (cd /tmp && tar xzf flasm.tar.gz && cd flasm-master && make && sudo cp flasm /usr/local/bin/)
        rm -rf /tmp/flasm-master /tmp/flasm.tar.gz
    }
    echo "[✓] Flasm installed"
fi

# ── 5. Ruffle (Rust Flash Player / Emulator) ───────────────
# Reference player for visual testing & behavioral verification
# https://github.com/ruffle-rs/ruffle
if command -v ruffle &>/dev/null; then
    echo "[✓] Ruffle already installed"
else
    echo "[+] Installing Ruffle (latest nightly)..."
    mkdir -p "$HOME/.local/bin"
    RUFFLE_URL="https://github.com/ruffle-rs/ruffle/releases/latest/download/ruffle-nightly-linux-x86_64.tar.gz"
    wget -qO /tmp/ruffle.tar.gz "$RUFFLE_URL"
    tar xzf /tmp/ruffle.tar.gz -C "$HOME/.local/bin/"
    rm -f /tmp/ruffle.tar.gz
    echo "[✓] Ruffle installed"
fi

# ── 6. Haxe + OpenFL (Target language/engine) ──────────────
# https://haxe.org/ | https://www.openfl.org/
if command -v haxe &>/dev/null; then
    echo "[✓] Haxe already installed"
else
    echo "[+] Installing Haxe + OpenFL..."
    sudo add-apt-repository -y ppa:haxe/releases 2>/dev/null || true
    sudo apt-get update && sudo apt-get install -y haxe neko
    mkdir -p "$HOME/.haxelib"
    haxelib setup "$HOME/.haxelib"
    haxelib install openfl
    haxelib install lime
    haxelib install swf
    haxelib run openfl setup
    echo "[✓] Haxe + OpenFL installed"
fi

# ── 7. Utilities ───────────────────────────────────────────
echo "[+] Installing utilities (ImageMagick, jq, xmlstarlet)..."
sudo apt-get install -y imagemagick jq xmlstarlet 2>/dev/null || true
echo "[✓] Utilities installed"

# ── Summary ────────────────────────────────────────────────
echo ""
echo "═══ Toolchain Status ═══"
echo "  ffdec:     $(command -v ffdec && echo 'OK' || echo 'MISSING')"
echo "  swfdump:   $(command -v swfdump && echo 'OK' || echo 'MISSING')"
echo "  swfmill:   $(command -v swfmill && echo 'OK' || echo 'MISSING')"
echo "  flasm:     $(command -v flasm && echo 'OK' || echo 'MISSING')"
echo "  ruffle:    $(command -v ruffle && echo 'OK' || echo 'MISSING')"
echo "  haxe:      $(command -v haxe && echo 'OK' || echo 'MISSING')"
echo "  compare:   $(command -v compare && echo 'OK' || echo 'MISSING')"
echo "  jq:        $(command -v jq && echo 'OK' || echo 'MISSING')"
echo "  xmlstarlet:$(command -v xmlstarlet && echo 'OK' || echo 'MISSING')"
echo ""
echo "✅ Setup complete. Run: ./tools/extract.sh originals/xiao_xiao_4.swf"
