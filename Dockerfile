FROM cgr.dev/chainguard/wolfi-base
ARG QUARTO_VERSION=1.3.450
WORKDIR /home/user

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
COPY sudoers-rs /etc/sudoers-rs

RUN apk update && apk add bash ghostscript texinfo curl ca-certificates wget gpg git pixi coreutils posix-libc-utils sudo-rs brew
ARG DEBIAN_FRONTEND=noninteractive

ARG QUARTO_VERSION
ARG CTAN_REPO


ENV QUARTO_VERSION=${QUARTO_VERSION} \
    CTAN_REPO=${CTAN_REPO} \
    BUILD_DATE=${BUILD_START}

ENV PATH=$PATH:/home/user/.TinyTeX/bin/x86_64-linux:/opt/quarto/bin:/home/user/bin:/home/linuxbrew/.linuxbrew/bin
ENV dpkgArch="amd64"


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


RUN sed -i -e '/^user/s/\/bin\/ash/\/home\/linuxbrew\/\.linuxbrew\/bin\/zsh/' /etc/passwd




RUN sudo chown -R user /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew/bin
RUN chmod u+w /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew/bin

USER user
RUN brew install zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

COPY download.sh download.sh
COPY run.sh run.sh

COPY pixi.toml pixi.toml
COPY pixi.lock pixi.lock
COPY jupyter bin/jupyter

COPY code-server bin/code-server

USER root
RUN chmod +x bin/jupyter
RUN chmod +x bin/code-server

USER user
RUN ./download.sh
RUN ./run.sh

CMD pixi shell
# Update wsl.conf file
# RUN sed -i "s/root/$USERNAME/g" /etc/wsl.conf
# RUN chmod u+s /sbin/su-exec

