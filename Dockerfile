ARG QUARTO_VERSION=1.3.450
ARG CTAN_REPO=https://www.texlive.info/tlnet-archive/2023/12/04/tlnet

FROM cgr.dev/chainguard/wolfi-base

RUN apk update && apk add bash ghostscript texinfo curl ca-certificates wget gpg python-3.10 py3.10-pip git brew pixi

ARG DEBIAN_FRONTEND=noninteractive

ARG BUILD_ON_IMAGE
ARG CODE_BUILTIN_EXTENSIONS_DIR
ARG QUARTO_VERSION
ARG CTAN_REPO
ARG BUILD_START

USER root

ENV QUARTO_VERSION=${QUARTO_VERSION} \
    CTAN_REPO=${CTAN_REPO} \
    BUILD_DATE=${BUILD_START}

ENV PATH=/opt/TinyTeX/bin/linux:/opt/quarto/bin:$PATH

WORKDIR /root

COPY . .

ENV dpkgArch="amd64"
# RUN ./download.sh
# RUN ./run.sh

