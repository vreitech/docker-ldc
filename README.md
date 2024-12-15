[![Docker Image CI publish](https://github.com/vreitech/docker-ldc/actions/workflows/docker-image.yml/badge.svg)](https://hub.docker.com/r/vreitech/docker-ldc/)
[![GHCR Latest Tag](https://ghcr-badge.egpl.dev/vreitech/docker-ldc/latest_tag)](https://github.com/vreitech/docker-ldc/pkgs/container/docker-ldc)
[![GHCR Images Size](https://ghcr-badge.egpl.dev/vreitech/docker-ldc/size)](https://github.com/vreitech/docker-ldc/pkgs/container/docker-ldc)

# About this fork

This repository forked out of https://github.com/ctrecordings/docker-ldc and https://github.com/lindt/docker-ldc repos.

Relevant contributors listed at:
- https://github.com/lindt/docker-ldc/graphs/contributors
- https://github.com/ctrecordings/docker-ldc/graphs/contributors
- https://github.com/vreitech/docker-ldc/graphs/contributors

# docker-ldc

Docker image for [LLVM-based](https://github.com/ldc-developers/ldc) [D](https://dlang.org/) compiler (also known as LDC2 or LDC).

## Motivation

Installation of a compiler sometimes is cumbersome. This Docker image should take this pain and allow you to easily switch between a versions of the compiler.

In case a native installation is required, `curl -fsS https://dlang.org/install.sh | bash -s ldc` could be used. You may also visit [LLVM-based compiler Releases page](https://github.com/ldc-developers/ldc/releases/) on GitHub.

Docker image allows to use LDC compiler and [dub package manager](https://github.com/dlang/dub) without installation.

## Includes (latest version)

- Debian 12 (bookworm) environment
- ldc2 compiler v1.40.0
- ld.gold linker
- ld.bfd linker
- dub package manager
- libxml2 library
- libz (zlib)
- libssl library

## Epochs

Epoch 1 images naming starts with `v` prefix. It's kind of "legacy" images which based on master branch at the moment of LDC2 verions release, and keeps unchanged (except for bugfixes).

Epoch 2 images naming starts with `2-v` prefix. Epoch 2 images based on master branch from 19.05.2024, and contains all changes did in master branch till the date, including using `setpriv` instead of `gosu`, and `aarch64` architecture support in addition to `x86_64` (except for `2-v1.33.0` image).

## Usage

Place a `test.d` (for example with the contents of `import std.stdio; void main() { writeln("It works!"); }`) in your current directory.
Then execute
```
docker run --rm -it -v "$(pwd):/src" docker.io/vreitech/docker-ldc:latest ldc2 test.d
```
or
```
docker run --rm -it -v "$(pwd):/src" ghcr.io/vreitech/docker-ldc:latest ldc2 test.d
```

