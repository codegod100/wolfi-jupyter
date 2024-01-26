#!/bin/bash

/home/linuxbrew/.linuxbrew/bin/brew install code-server

## Install quarto
mkdir -p /opt/quarto
chmod +x install-unx.sh
tar -xzf quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz -C /opt/quarto --no-same-owner --strip-components=1
# rm quarto-${QUARTO_VERSION}-linux-${dpkgArch}.tar.gz
rm /opt/quarto/bin/tools/pandoc
ln -s /usr/bin/pandoc /opt/quarto/bin/tools/pandoc
## Admin-based install of TinyTeX
./install-unx.sh --admin --no-path
# mv ${HOME}/.TinyTeX /opt/TinyTeX
# sed -i "s|${HOME}/.TinyTeX|/opt/TinyTeX|g" /opt/TinyTeX/texmf-var/fonts/conf/texlive-fontconfig.conf
# ln -rs /opt/TinyTeX/bin/$(uname -m)-linux /opt/TinyTeX/bin/linux /opt/TinyTeX/bin/linux/tlmgr path add
/opt/TinyTeX/bin/x86_64-linux/tlmgr update --self
## TeX packages as requested by the community
/opt/TinyTeX/bin/x86_64-linux/tlmgr install $(cat pkgs-yihui.txt | tr '\n' ' ')
## TeX packages as in rocker/verse
/opt/TinyTeX/bin/x86_64-linux/tlmgr install context pdfcrop
## TeX packages as in jupyter/scipy-notebook
/opt/TinyTeX/bin/x86_64-linux/tlmgr install cm-super dvipng
## TeX packages specific for nbconvert
/opt/TinyTeX/bin/x86_64-linux/tlmgr install oberdiek titling
# /opt/TinyTeX/bin/x86_64-linux/tlmgr path add
# chown -R root:${NB_GID} /opt/TinyTeX
# chmod -R g+w /opt/TinyTeX
# chmod -R g+wx /opt/TinyTeX/bin
## Make the TeX Live fonts available as system fonts
cp /opt/TinyTeX/texmf-var/fonts/conf/texlive-fontconfig.conf /etc/fonts/conf.d/09-texlive.conf
fc-cache -fsv
## Install Python packages
export PIP_BREAK_SYSTEM_PACKAGES=1
pip install altair beautifulsoup4 bokeh bottleneck cloudpickle cython dask dill h5py ipympl ipywidgets matplotlib numba numexpr numpy pandas patsy protobuf scikit-image scikit-learn scipy seaborn sqlalchemy statsmodels sympy tables widgetsnbextension xlrd nbclassic
## Install facets
cd /tmp
git clone https://github.com/PAIR-code/facets.git
jupyter nbclassic-extension install facets/facets-dist/ --sys-prefix
cd /
## Install code-server extensions
code-server  --install-extension quarto.quarto
code-server  --install-extension James-Yu.latex-workshop
## Clean up
# rm -rf /tmp/*
# rm -rf /var/lib/apt/lists/*
# ${HOME}/.cache
# ${HOME}/.config
# ${HOME}/.local 
# ${HOME}/.wget-hsts