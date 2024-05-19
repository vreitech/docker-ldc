ARG compiler=ldc2
ARG compiler_version=1.33.0

FROM docker.io/debian:bookworm-slim AS builder

ARG compiler
ARG compiler_version
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
  COMPILER=$compiler \
  COMPILER_VERSION=$compiler_version
RUN <<-EOF bash
  set -euxo pipefail
  apt-get -yqq -o=Dpkg::Use-Pty=0 update
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install apt-utils
  apt-get -yqq -o=Dpkg::Use-Pty=0 --no-install-recommends install ca-certificates libterm-readline-gnu-perl curl xz-utils
  mkdir -p /dlang
  case ${TARGETARCH} in
    x86_64|amd64)
      tar xJf <(curl -LfsS "https://github.com/ldc-developers/ldc/releases/download/v${COMPILER_VERSION}/${COMPILER}-${COMPILER_VERSION}-linux-x86_64.tar.xz") -C /dlang
      mv "/dlang/${COMPILER}-${COMPILER_VERSION}-linux-x86_64" "/dlang/${COMPILER}-${COMPILER_VERSION}"
      ;;
    aarch64|arm64)
      tar xJf <(curl -LfsS "https://github.com/ldc-developers/ldc/releases/download/v${COMPILER_VERSION}/${COMPILER}-${COMPILER_VERSION}-linux-aarch64.tar.xz") -C /dlang
      mv "/dlang/${COMPILER}-${COMPILER_VERSION}-linux-aarch64" "/dlang/${COMPILER}-${COMPILER_VERSION}"
      ;;
    *)
      >&2 "Architecture '${TARGETARCH}' is not supported."
      exit 1
      ;;
  esac
  rm -rf "/dlang/${COMPILER}-${COMPILER_VERSION}/lib32"
EOF

FROM docker.io/debian:bookworm-slim

LABEL org.opencontainers.image.authors "Stefan Rohe <think@hotmail.de>"
LABEL org.opencontainers.image.authors "Ethan Reker <ethanepr@hotmail.com>"
LABEL org.opencontainers.image.authors "Filipp Chertiev <f@fzfx.ru>"
LABEL org.opencontainers.image.description "Docker image for LLVM-based D Compiler"

ARG compiler
ARG compiler_version

WORKDIR /src

ENV DEBIAN_FRONTEND=noninteractive \
  COMPILER=$compiler \
  COMPILER_VERSION=$compiler_version
ENV COMPILER_BIN=${COMPILER} \
  PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/bin:${PATH}" \
  LD_LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/lib" \
  LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/lib" \
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
