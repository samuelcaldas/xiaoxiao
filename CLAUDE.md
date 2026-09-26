# Xiao Xiao Flash Decomp & Recreation

## Project Overview

Decomp + recreation of classic Xiao Xiao Flash games (Flash 4/5, AVM1/AS1.0).
Target: Haxe + OpenFL. Matching level: Tier 2 Structural Match.

## Key Commands

```bash
# Install all required tools
./tools/setup.sh

# Extract assets & bytecode from an SWF
./tools/extract.sh originals/<file>.swf

# Verify structural match between original and rebuilt SWF
./tools/verify_match.sh decomp/<name>/ <rebuilt.swf>

# Individual diff tools
./tools/diff_structural.sh <original.swf> <rebuilt.swf>
./tools/diff_bytecode.sh <original.swf> <rebuilt.swf>
./tools/diff_visual.sh <original.swf> <rebuilt.swf>

# Build & test Haxe recreation
cd recreation && openfl test html5
```

## Matching Rules

- All tag IDs, depths, frames must match original (swfmill XML diff)
- All AS1 bytecodes must match (Flasm P-code diff)
- Visual frames must be pixel-identical (swfrender + ImageMagick compare)

## Architecture

- `originals/` — Untouched original SWFs (NEVER modify)
- `decomp/` — Decompilation work per SWF
- `recreation/` — Haxe/OpenFL recreation project
- `tools/` — Automation scripts & setup
- `docs/` — Documentation & ADRs

## Current Focus

- Primary target: `xiao_xiao_4.swf` (Xiao Xiao No. 4 — rail shooter)
- Flash 5, AVM1, ActionScript 1.0
- 484 DefineSprite MovieClips, 910 action blocks
- 550x400 @ 18fps

## Toolchain

| Tool | Purpose |
|:---|:---|
| FFDec v26.3.0 | Decompiler, asset extractor, P-code editor |
| SWFTools 0.9.2 | swfdump, swfextract, swfrender |
| swfmill | SWF↔XML for structural matching |
| Flasm | AVM1 bytecode disassembler/assembler |
| Ruffle | Flash emulator for reference testing |
| Haxe + OpenFL | Target language/engine for recreation |
