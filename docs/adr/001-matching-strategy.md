# ADR 001: Matching Strategy for SWF Decompilation

## Status

Accepted

## Context

We need to define what "matching" means for Flash SWF decompilation.
Unlike console ROM decomps (N64, GBA) where byte-identical binaries are the goal,
SWF files have unique challenges:

- Macromedia Flash 4/5 compiler heuristics are not reproducible
- Character ID ordering depends on internal FLA document traversal
- Zlib compressed payloads vary by deflate implementation
- ActionScript constant pool ordering is compiler-specific

## Decision

**Tier 2: Structural Match** via `swfmill` XML diff.

### What this means:
1. All SWF tags must appear in identical order with identical tag codes
2. All Character IDs must match the original
3. All display list operations (PlaceObject2, RemoveObject2) must match depth, matrix, and color transforms
4. All ActionScript bytecodes must be identical opcode-by-opcode (verified via Flasm)
5. Compressed payloads (DefineBitsLossless zlib) may differ in encoding but must decompress to identical raw data

### Verification pipeline:
1. `swfmill swf2xml` both SWFs → `diff -u`
2. `flasm -d` both SWFs → `diff -u`
3. `swfrender` both SWFs → `compare -metric AE` (ImageMagick)

## Consequences

- SHA-256 hash of full SWF binary will NOT match (acceptable)
- Tag structure and bytecode WILL match (required)
- Visual output WILL match pixel-perfect (required)
