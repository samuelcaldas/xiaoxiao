# ═══════════════════════════════════════════════════════════════
# Xiao Xiao Decomp Toolchain Container
# Contains: FFDec, SWFTools, swfmill, Flasm, ImageMagick
# ═══════════════════════════════════════════════════════════════
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

RUN apt-get update && apt-get install -y \
    openjdk-21-jre-headless \
    swftools \
    swfmill \
    flasm \
    imagemagick \
    jq \
    xmlstarlet \
    wget \
    unzip \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install FFDec
ARG FFDEC_VERSION=26.3.0
RUN mkdir -p /opt/ffdec && \
    wget -qO /tmp/ffdec.zip \
    "https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version${FFDEC_VERSION}/ffdec_${FFDEC_VERSION}.zip" && \
    unzip -qo /tmp/ffdec.zip -d /opt/ffdec && \
    rm /tmp/ffdec.zip && \
    echo '#!/bin/bash\njava -jar /opt/ffdec/ffdec.jar "$@"' > /usr/local/bin/ffdec && \
    chmod +x /usr/local/bin/ffdec

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]
