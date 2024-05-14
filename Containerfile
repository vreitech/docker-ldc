ARG compiler=ldc2
ARG compiler_ver=1.38.0

FROM debian:bookworm-slim AS builder

ARG compiler
ARG compiler_ver
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
  COMPILER=$compiler \
  COMPILER_VER=$compiler_ver \
  env_arch=$TARGETARCH
RUN <<-EOF bash
  set -euxo pipefail
  apt-get -yqq -o=Dpkg::Use-Pty=0 update
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install apt-utils
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install ca-certificates libterm-readline-gnu-perl curl xz-utils
  mkdir -p /dlang
  case ${env_arch} in
    x86_64|amd64)
      tar xJf <(curl -LfsS "https://github.com/ldc-developers/ldc/releases/download/v${COMPILER_VER}/${COMPILER}-${COMPILER_VER}-linux-x86_64.tar.xz") -C /dlang
      mv "/dlang/${COMPILER}-${COMPILER_VER}-linux-x86_64" "/dlang/${COMPILER}-${COMPILER_VER}"
      ;;
    aarch64|arm64)
      tar xJf <(curl -LfsS "https://github.com/ldc-developers/ldc/releases/download/v${COMPILER_VER}/${COMPILER}-${COMPILER_VER}-linux-aarch64.tar.xz") -C /dlang
      mv "/dlang/${COMPILER}-${COMPILER_VER}-linux-aarch64" "/dlang/${COMPILER}-${COMPILER_VER}"
      ;;
    *)
      >&2 "Architecture '${env_arch} is not supported."
      exit 1
      ;;
  esac
  rm -rf "/dlang/${COMPILER}-${COMPILER_VER}/lib32"
EOF

FROM debian:bookworm-slim

LABEL org.opencontainers.image.authors="Stefan Rohe <think@hotmail.de>"
LABEL org.opencontainers.image.authors="Ethan Reker <ethanepr@hotmail.com>"
LABEL org.opencontainers.image.authors="Filipp Chertiev <f@fzfx.ru>"

ARG compiler
ARG compiler_ver

WORKDIR /src

ENV DEBIAN_FRONTEND=noninteractive \
  COMPILER=$compiler \
  COMPILER_VER=$compiler_ver
ENV COMPILER_BIN=${COMPILER} \
  PATH="/dlang/${COMPILER}-${COMPILER_VER}/bin:${PATH}" \
  LD_LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VER}/lib" \
  LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VER}/lib" \
  DC=${COMPILER_BIN}
COPY --from=builder /dlang /dlang
RUN <<-EOF bash
  set -euxo pipefail
  apt-get -yqq -o=Dpkg::Use-Pty=0 update
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install apt-utils
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install ca-certificates libterm-readline-gnu-perl \
  curl binutils-gold gcc libxml2-dev zlib1g-dev libssl-dev
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
