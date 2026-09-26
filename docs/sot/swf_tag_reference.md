# SWF Tag Reference (Flash 4 & Flash 5)

Quick reference for the SWF tag types found in the Xiao Xiao series.

## Header Structure

| Field | Type | Size | Description |
|:---|:---|:---|:---|
| Signature | ASCII[3] | 3 bytes | `FWS` = Uncompressed, `CWS` = Zlib, `ZWS` = LZMA |
| Version | UI8 | 1 byte | `0x04` = Flash 4, `0x05` = Flash 5 |
| FileLength | UI32 LE | 4 bytes | Total uncompressed file size |
| FrameSize | RECT | Variable | Stage bounding box in twips (1px = 20 twips) |
| FrameRate | UI16 LE | 2 bytes | 8.8 fixed-point (e.g. 0x0012 = 18.0 fps) |
| FrameCount | UI16 LE | 2 bytes | Total root timeline frames |

## Definition Tags (Dictionary)

| Tag | Code | Purpose | Xiao Xiao Usage |
|:---|:---|:---|:---|
| DefineShape | 2 | Vector shape (RGB fills) | Stickman bodies, backgrounds |
| DefineShape2 | 22 | Extended shape (>255 styles) | Complex scenes |
| DefineShape3 | 32 | Shape with RGBA alpha | Transparency effects |
| DefineMorphShape | 46 | Morph tween shape pair | Smooth transitions |
| DefineSprite | 39 | Movie clip (sub-timeline) | Game objects, enemies, HUD |
| DefineButton2 | 34 | Interactive button | Menu, play buttons |
| DefineSound | 14 | Event sound (MP3/ADPCM) | SFX, music |
| DefineFont/Font2 | 10/48 | Embedded font glyphs | Score display, text |
| DefineText/Text2 | 11/33 | Static text | Labels, credits |
| DefineEditText | 37 | Dynamic/input text | Score, health, variables |
| DefineBits* | 6/20/21/35/36 | Bitmap images | Textures, backgrounds |

## Display List Tags

| Tag | Code | Purpose |
|:---|:---|:---|
| PlaceObject2 | 26 | Place/move/replace character at depth |
| RemoveObject2 | 28 | Remove character from depth |
| ShowFrame | 1 | Render current frame, advance playhead |

### PlaceObject2 Flags

| Bit | Flag | Effect |
|:---|:---|:---|
| 0 | Move | Update existing character at depth |
| 1 | HasCharacter | Place new character (CharacterID) |
| 2 | HasMatrix | Set 2D affine transform |
| 3 | HasColorTransform | Set color multiply/offset |
| 4 | HasRatio | Morph tween ratio (0..65535) |
| 5 | HasName | Instance name for AS targeting |
| 6 | HasClipDepth | Clipping mask depth |
| 7 | HasClipActions | Flash 5+ event scripts (onClipEvent) |

## Action Tags

| Tag | Code | Purpose |
|:---|:---|:---|
| DoAction | 12 | Frame ActionScript bytecode |

## Control Tags

| Tag | Code | Purpose |
|:---|:---|:---|
| SetBackgroundColor | 9 | Stage background RGB |
| FrameLabel | 43 | Named frame for gotoAndPlay |
| SoundStreamHead2 | 45 | Streaming audio config |
| SoundStreamBlock | 19 | Per-frame audio chunk |
| StartSound | 15 | Trigger event sound |
| End | 0 | Terminate tag stream |

## AVM1 Key Opcodes (Flash 4/5)

### Flash 4 Baseline

| Opcode | Name | Description |
|:---|:---|:---|
| 0x06 | ActionPlay | Play timeline |
| 0x07 | ActionStop | Stop timeline |
| 0x81 | ActionGotoFrame | Jump to frame number |
| 0x8C | ActionGoToLabel | Jump to named frame |
| 0x96 | ActionPush | Push value(s) onto stack |
| 0x1C | ActionGetVariable | Read variable by name |
| 0x1D | ActionSetVariable | Write variable by name |
| 0x99 | ActionJump | Unconditional branch (SI16 offset) |
| 0x9D | ActionIf | Conditional branch (SI16 offset) |

### Flash 5 Additions (ECMAScript)

| Opcode | Name | Description |
|:---|:---|:---|
| 0x88 | ActionConstantPool | String constants table |
| 0x3D | ActionCallFunction | Call function by name |
| 0x52 | ActionCallMethod | Call method on object |
| 0x40 | ActionNewObject | Construct new object |
| 0x4E | ActionGetMember | Get object property |
| 0x4F | ActionSetMember | Set object property |
| 0x47 | ActionAdd2 | ECMA addition (string or number) |
| 0x49 | ActionEquals2 | ECMA equality test |
| 0x9B | ActionDefineFunction | Define named function |

## ActionPush Type Codes

| Type | Name | Size | Description |
|:---|:---|:---|:---|
| 0 | String | Variable | Null-terminated string |
| 1 | Float | 4 bytes | 32-bit IEEE 754 |
| 4 | Register | 1 byte | Register index (0..3 in Flash 5) |
| 5 | Boolean | 1 byte | 0=false, 1=true |
| 6 | Double | 8 bytes | 64-bit IEEE 754 |
| 7 | Integer | 4 bytes | 32-bit signed integer |
| 8 | Constant8 | 1 byte | Index into ConstantPool (0..255) |
| 9 | Constant16 | 2 bytes | Index into ConstantPool (0..65535) |
