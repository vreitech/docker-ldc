ARG arg_compiler=ldc2
ARG arg_compiler_version=1.37.0

FROM debian:bookworm-slim AS builder

ARG arg_compiler
ARG arg_compiler_version

ENV DEBIAN_FRONTEND=noninteractive \
  COMPILER=$arg_compiler \
  COMPILER_VERSION=$arg_compiler_version
RUN <<EOF bash
  set -xeuo pipefail
  apt-get -yqq -o=Dpkg::Use-Pty=0 update
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install apt-utils
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install ca-certificates libterm-readline-gnu-perl \
  curl xz-utils
  mkdir -p /dlang
  tar xJf <(curl -LfsS "https://github.com/ldc-developers/ldc/releases/download/v${COMPILER_VERSION}/${COMPILER}-${COMPILER_VERSION}-linux-x86_64.tar.xz") -C /dlang
  rm -rf /dlang/${COMPILER}-${COMPILER_VERSION}-linux-x86_64/lib32
EOF

FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="Stefan Rohe <think@hotmail.de>"
LABEL org.opencontainers.image.authors="Filipp Chertiev <f@fzfx.ru>"

ARG arg_compiler
ARG arg_compiler_version

WORKDIR /src

ENV DEBIAN_FRONTEND=noninteractive \
  COMPILER=$arg_compiler \
  COMPILER_VERSION=$arg_compiler_version
ENV COMPILER_BIN=${COMPILER} \
  PATH="/dlang/${COMPILER}-${COMPILER_VERSION}-linux-x86_64/bin:${PATH}" \
  LD_LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}-linux-x86_64/lib" \
  LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}-linux-x86_64/lib" \
  PS1="(${COMPILER}-${COMPILER_VERSION}) \\u@\\h:\\w\$" \
  DC=${COMPILER_BIN}
COPY --from=builder /dlang /dlang
RUN <<EOF bash
  set -xeuo pipefail
  apt-get -yqq -o=Dpkg::Use-Pty=0 update
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install apt-utils
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install ca-certificates libterm-readline-gnu-perl \
  curl binutils-gold gcc gcc-multilib libxml2-dev zlib1g-dev libssl-dev
  update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20
  update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10
  ldconfig
  rm -rf /var/lib/apt/lists/*
  rm -rf /var/cache/apt
  rm -rf /var/log/apt
  rm -f /var/log/alternatives.log /var/log/dpkg.log
EOF

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["${COMPILER_BIN}"]
