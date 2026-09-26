# Xiao Xiao (Flash Decomp & Recreation)

Decompilação estruturada e recreação da série clássica **Xiao Xiao** (小小) de Zhu Zhiqiang (朱志强) — preservação de jogos Flash (SWF Flash 4/5, ActionScript 1.0).

## Objetivo

1. **Extrair** todos os assets originais (vetores SVG, áudio WAV/MP3, bitmaps, fontes)
2. **Decompor** o ActionScript 1.0 bytecode com matching verification
3. **Recriar** os jogos em **Haxe + OpenFL** com assets originais
4. **Verificar** matching Tier 2 (structural match tag-by-tag via swfmill XML diff)

## Jogos Interativos

| Arquivo | Jogo | Tipo | Flash |
|:---|:---|:---|:---|
| `xiao_xiao_2.swf` | Xiao Xiao No. 2 (过关斩将) | Minigames de reflexo | Flash 4 |
| `xiao_xiao_4.swf` | Xiao Xiao No. 4 (小小特警) | Rail shooter (Virtua Cop) | Flash 5 |
| `xiao_xiao_6.swf` | Xiao Xiao No. 6 (小小6号) | Filme interativo | Flash 5 |
| `xiao_xiao_9.swf` | Xiao Xiao No. 9 (过关斩将II) | Beat'em up (Final Fight) | Flash 5 |

### Animações
| `xiao_xiao_5.swf` | Xiao Xiao No. 5 (小小5号) | Animação de luta | Flash 5 |

### Spin-offs
| `the_way_of_the_exploding_stick.swf` | The Way of the Exploding Stick | Combate stickman | Flash 5 |

## Estrutura do Projeto

```
xiaoxiao/
├── originals/          # SWFs originais (read-only, imutáveis)
├── decomp/             # Decompilação por SWF (tags XML, bytecode, assets)
├── recreation/         # Projeto Haxe/OpenFL
├── tools/              # Scripts de automação (extract, diff, verify)
└── docs/               # Documentação e ADRs
```

## Quick Start

```bash
# 1. Instalar ferramentas
./tools/setup.sh

# 2. Extrair assets do SWF alvo
./tools/extract.sh originals/xiao_xiao_4.swf

# 3. Verificar matching (quando tiver um rebuild)
./tools/verify_match.sh decomp/xiao_xiao_4/ rebuilt.swf
```

## Ferramentas

- **JPEXS FFDec** v26.3.0 — Decompiler & asset extractor
- **SWFTools** — `swfdump`, `swfextract`, `swfrender`
- **swfmill** — SWF↔XML (structural matching)
- **Flasm** — AVM1 bytecode disassembler/assembler
- **Ruffle** — Flash emulator open-source em Rust
- **Haxe + OpenFL** — Engine de recreação

## Licença

Os SWFs originais são criações de Zhu Zhiqiang (朱志强).
Este projeto é para **estudo, preservação e aprendizado pessoal**.
