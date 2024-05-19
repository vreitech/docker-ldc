# 2-v1.35.0
- Build 2nd epoch image with ldc2 v1.35.0, based on master branch from 19.05.2024

# v1.38.0

- Change LDC version to 1.38.0
- Change dub package manager version to 1.37.0
- Added building of images for aarch64 architecture in addition to x86_64.

# v1.37.0

- Change LDC version to 1.37.0
- Change dub package manager version to 1.36.0
- Removed packages related to GPG (not needed since removed `gosu` usage)

# v1.36.0

- [Change LDC version to 1.36.0](https://github.com/vreitech/docker-ldc/commit/c2ab662a240f41da1cd337461c49deaccb91690b)
- [switch from gosu to setpriv](https://github.com/vreitech/docker-ldc/commit/8fbe0e287661d0f67e65f8d6be53ae6addc3e2a1)
- [change RUNs in Dockerfile into heredoc format](https://github.com/vreitech/docker-ldc/commit/b5ddf33af0198a0c11016391f1e8cb52ed690b1b)
- Change dub package manager version to 1.35.1

# v1.35.0

- Change LDC version to 1.35.0
- Change dub package manager version to 1.34.0
- Change libssl library version to 3.0.11

# v1.34.0

- Change LDC version to 1.34.0
- Change dub package manager version to 1.33.1
- ld.gold (v1.16) setted up as default linker instead of ld.bfd (v2.40)
- `Dockerfile` refactored: size of the image slightly decreased (using multistage for building final image, removal of unnecessary packages)

