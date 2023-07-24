FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="Stefan Rohe <think@hotmail.de>"
LABEL org.opencontainers.image.authors="Filipp Chertiev <f@fzfx.ru>"

ENV DEBIAN_FRONTEND=noninteractive
ENV \
  COMPILER=ldc \
  COMPILER_BIN=${COMPILER}2 \
  COMPILER_VERSION=1.33.0

RUN apt-get -yqq -o=Dpkg::Use-Pty=0 update && apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install apt-utils

RUN apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install binutils-gold gcc gcc-multilib \
  libxml2-dev zlib1g-dev libssl-dev \
  ca-certificates libterm-readline-gnu-perl \
  wget curl xz-utils gpg gpg-agent git dirmngr \
  && curl -fsS -o /tmp/install.sh https://dlang.org/install.sh \
  && bash /tmp/install.sh -p /dlang install "${COMPILER}-${COMPILER_VERSION}" \
  && rm /tmp/install.sh \
  && rm -rf /dlang/${COMPILER}-*/lib32
  
ENV \
  PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/bin:${PATH}" \
  LD_LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/lib" \
  LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/lib" \
  PS1="(${COMPILER}-${COMPILER_VERSION}) \\u@\\h:\\w\$" \
  DC=${COMPILER_BIN}

RUN ldconfig

WORKDIR /src

ENV GOSU_VERSION 1.14
RUN wget --no-verbose -O /usr/local/bin/gosu \
        "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget --no-verbose -O /usr/local/bin/gosu.asc \
        "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }').asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apt-get -yqq -o=Dpkg::Use-Pty=0 auto-remove wget curl xz-utils gpg gpg-agent wget dirmngr \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/apt \
  && rm -rf /var/log/apt \
  && rm -f /var/log/alternatives.log /var/log/dpkg.log

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["${COMPILER_BIN}"]
