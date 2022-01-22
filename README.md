[![Docker pulls](https://img.shields.io/docker/pulls/vreitech/ldc.svg)](https://hub.docker.com/r/vreitech/ldc/)
[![Docker Build](https://img.shields.io/docker/automated/vreitech/ldc.svg)](https://hub.docker.com/r/vreitech/ldc/)
[![Latest Tag](https://img.shields.io/github/tag/vreitech/docker-ldc.svg)](https://hub.docker.com/r/vreitech/ldc/)

# About this fork

This repository forked out of https://github.com/ctrecordings/docker-ldc and https://github.com/lindt/docker-ldc repos.

# docker-ldc

Docker Image for LLVM-based [D](http://dlang.org) Compiler.

## Motivation

Installation of a compiler sometimes is cumbersome. This Docker image should take this pain and allow you to easily switch between Versions of the same compiler and even different compilers.

In case a native installation is required, `curl -fsS https://dlang.org/install.sh | bash -s ldc` could be used.

## Other Compilers

Allows to use LDC compiler without installation.

| Compiler | Latest Tag |
| -------- | ---------- |
| LDC      | [![Latest Tag](https://img.shields.io/github/tag/vreitech/docker-ldc.svg)](https://hub.docker.com/r/vreitech/ldc/) |

## Usage

Place a `test.d` in your current directory.
Then execute
```
docker run --rm -ti -v $(pwd):/src vreitech/ldc ldc2 test.d
```
