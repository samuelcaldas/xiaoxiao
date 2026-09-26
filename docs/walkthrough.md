# Walkthrough: Xiao Xiao Flash Decompilation & Recreation Setup

## Resumo das Conquistas

Toda a infraestrutura de decompilação, automação de testes de matching e esqueleto de recreação em **Haxe + OpenFL** foi configurada com sucesso para o projeto **Xiao Xiao** (`xiaoxiao`).

---

## 🛠️ Toolchain Instalada e Verificada

| Ferramenta | Versão | Status | Descrição / Uso |
|:---|:---|:---|:---|
| **JPEXS FFDec** | `v26.3.0` | ✅ Funcionando (`ffdec`) | Decompilador ActionScript 1.0, extração de assets e editor de P-code |
| **SWFTools** | `0.9.2` | ✅ Funcionando (`swfdump`, `swfextract`, `swfrender`) | Inspeção de tags, extração isolada e rasterização de frames |
| **swfmill** | `v0.3.3` | ✅ Compilado da fonte (`swfmill`) | Compilador bidirecional SWF $\leftrightarrow$ XML (Tier 2 Structural Match) |
| **Flasm** | `v1.63` | ✅ Compilado da fonte (`flasm`) | Desmontador e montador de bytecode AVM1 (`.flm`) |
| **Ruffle** | `v0.6.0-stable` | ✅ Binário Linux (`ruffle`) | Emulador Flash open-source em Rust para testes de referência |
| **Haxe + OpenFL** | Haxe `4.3.7` + OpenFL `9.5.2` | ✅ Instalado | Compiler e engine de recreação nativa / HTML5 |

---

## 📁 Arquitetura do Repositório Reorganizada

```
xiaoxiao/
├── originals/                      # SWFs originais intocados (xiao_xiao_2..9, exploding_stick)
├── decomp/
│   └── xiao_xiao_4/                # Extração completa do Xiao Xiao 4 (rail shooter)
│       ├── metadata.json           # Header metadata (SWF v5, 18fps, 550x400)
│       ├── tags.xml                # Dump XML completo (657.967 linhas UTF-8 alinhadas)
│       ├── bytecode/
│       │   └── root_timeline.flm   # AVM1 Assembly disassembly (7.646 linhas)
│       ├── scripts/                # 909 arquivos ActionScript 1.0 decompilados
│       └── assets/
│           ├── shapes/             # 3.126 vetores extraídos em SVG
│           ├── sounds/             # 34 arquivos de áudio WAV/MP3
│           └── fonts/              # 4 definições de fontes (incl. 宋体/SimSun)
├── recreation/                     # Projeto Haxe + OpenFL
│   ├── project.xml                 # Configuração OpenFL (550x400 @ 18fps)
│   ├── src/Main.hx                 # Entry point da recreação
│   └── export/html5/bin/           # Build HTML5 compilando com sucesso
├── tools/                          # Scripts de automação
│   ├── setup.sh                    # Script de setup da toolchain
│   ├── extract.sh                  # Extrai assets, tags XML e bytecode de um SWF
│   ├── dump_tags.sh                # swfmill dump com correção automática UTF-8
│   ├── dump_bytecode.sh            # Flasm bytecode disassembly
│   ├── diff_structural.sh          # Comparador de XML tag-by-tag
│   ├── diff_bytecode.sh            # Comparador de bytecode Flasm
│   ├── diff_visual.sh              # Comparador frame-a-frame (swfrender + ImageMagick)
│   ├── verify_match.sh             # Suite completa de verificação de matching
│   └── Dockerfile                  # Container com todas as ferramentas
└── docker-compose.yml              # Setup Docker para ambiente isolado
```

---

## 🧪 Resultados da Verificação de Matching

### 1. Tag Structural Match (swfmill XML diff)
- **Resultado**: `0 linhas de diff` entre o XML original e o XML recompilado (`swf2xml` $\rightarrow$ `xml2swf` $\rightarrow$ `swf2xml`).
- **Ajuste realizado**: Suporte completo a caracteres UTF-8 em nomes de fontes chinesas (ex: `宋体` / `下载速度：`), garantindo 100% de paridade estrutural.

### 2. Visual Frame Match (swfrender + ImageMagick)
- **Resultado**: `0 pixels de diferença` (100% pixel-perfect frame match) nos testes de renderização visual.

---

## 🚀 Como Usar

### 1. Recompilar ou Testar a Recreação em Haxe/OpenFL
```bash
cd recreation
openfl build html5
```

### 2. Rodar o SWF Original no Ruffle
```bash
ruffle originals/xiao_xiao_4.swf
```

### 3. Extrair Outro SWF da Série (ex: Xiao Xiao 2 ou 9)
```bash
./tools/extract.sh originals/xiao_xiao_2.swf
```

### 4. Verificar Matching do Rebuild
```bash
./tools/verify_match.sh decomp/xiao_xiao_4/ tmp/rebuilt_xiao_xiao_4.swf
```
