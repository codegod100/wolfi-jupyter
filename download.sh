#!/bin/bash
#grab files to cache
wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz"
wget "https://yihui.org/tinytex/install-unx.sh"
wget "https://yihui.org/gh/tinytex/tools/pkgs-yihui.txt"