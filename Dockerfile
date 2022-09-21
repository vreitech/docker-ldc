FROM ubuntu:20.04

LABEL org.opencontainers.image.authors="Stefan Rohe <think@hotmail.de>"
LABEL org.opencontainers.image.authors="Filipp Chertiev <f@fzfx.ru>"

ENV \
  COMPILER=ldc \
  COMPILER_BIN=${COMPILER}2 \
  COMPILER_VERSION=1.30.0-beta1

RUN apt-get -yq update && apt-get install -yq apt-utils

RUN apt-get install -yq curl libcurl4 build-essential \
  && curl -fsS -o /tmp/install.sh https://dlang.org/install.sh \
  && bash /tmp/install.sh -p /dlang install "${COMPILER}-${COMPILER_VERSION}" \
  && rm /tmp/install.sh \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends gcc gcc-multilib cmake git \
  && rm -rf /dlang/${COMPILER}-*/lib32
  
ENV \
  PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/bin:${PATH}" \
  LD_LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/lib" \
  LIBRARY_PATH="/dlang/${COMPILER}-${COMPILER_VERSION}/lib" \
  PS1="(${COMPILER}-${COMPILER_VERSION}) \\u@\\h:\\w\$" \
  DC=${COMPILER_BIN}

RUN ldconfig

RUN cd /tmp \
 && echo 'void main() {import std.stdio; stdout.writeln("it works"); }' > test.d \
 && ldc2 test.d \
 && ./test && rm -f test*

WORKDIR /src

ENV GOSU_VERSION 1.14
RUN apt-get install -yq ca-certificates wget gpg \
  && wget --no-verbose -O /usr/local/bin/gosu \
        "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
  && wget --no-verbose -O /usr/local/bin/gosu.asc \
        "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture | awk -F- '{ print $NF }').asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apt-get auto-remove -yq wget curl build-essential gpg git cmake \
  && apt-get install -yq libxml2-dev zlib1g-dev libssl-dev \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/apt

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["${COMPILER_BIN}"]
