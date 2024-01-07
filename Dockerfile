ARG arg_compiler=ldc
ARG arg_compiler_version=1.36.0

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
  curl xz-utils gpg gpg-agent dirmngr
  bash <(curl -LfsS https://dlang.org/install.sh) -p /dlang install "${COMPILER}-${COMPILER_VERSION}"
  rm -rf /dlang/${COMPILER}-*/lib32
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
ENV COMPILER_BIN=${COMPILER}2 \
  PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/bin:${PATH}" \
  LD_LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/lib" \
  LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/lib" \
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
