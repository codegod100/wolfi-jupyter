FROM cgr.dev/chainguard/wolfi-base
ARG QUARTO_VERSION=1.3.450
WORKDIR /root

# Create user
ARG USERNAME=${username:-user}
ARG PASSWORD=${password:-user}
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN addgroup -g $GROUP_ID $USERNAME && \
    adduser -D -u $USER_ID -G $USERNAME $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    mkdir -p /etc/sudoers.d && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

RUN apk update && apk add bash ghostscript texinfo curl ca-certificates wget gpg git  pixi coreutils posix-libc-utils

ARG DEBIAN_FRONTEND=noninteractive

ARG QUARTO_VERSION
ARG CTAN_REPO

USER root

ENV QUARTO_VERSION=${QUARTO_VERSION} \
    CTAN_REPO=${CTAN_REPO} \
    BUILD_DATE=${BUILD_START}

ENV PATH=/opt/TinyTeX/bin/linux:/opt/quarto/bin:$PATH


# Install extra packages
COPY wsl-files/extra-packages /
RUN apk update && \
    apk upgrade && \
    grep -v '^#' /extra-packages | xargs apk add
RUN rm /extra-packages

# Add systemd symlink to init
RUN ln -s /usr/lib/systemd/systemd /sbin/init

# Add wsl.conf file
COPY wsl-files/wsl.conf /etc/wsl.conf







COPY download.sh download.sh
COPY run.sh run.sh
COPY pixi.toml pixi.toml
COPY pixi.lock pixi.lock

ENV dpkgArch="amd64"
RUN ./download.sh
RUN ./run.sh

# Copy bashrc file to user
RUN cp /root/.bashrc /home/$USERNAME/.bashrc && \
    chown $USERNAME:$USERNAME /home/$USERNAME/.bashrc && \
    ln -s /home/$USERNAME/.bashrc /home/$USERNAME/.profile

# Update wsl.conf file
RUN sed -i "s/root/$USERNAME/g" /etc/wsl.conf

# Fix su-exec permissions
RUN chmod u+s /sbin/su-exec

