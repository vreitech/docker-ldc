# v1.34.0

- ldc compiler version bumped to v1.34.0
- dub package manager version bumped to v1.33.1
- ld.gold (v1.16) setted up as default linker instead of ld.bfd (v2.40)
- `Dockerfile` refactored: size of the image slightly decreased (using multistage for building final image, removal of unnecessary packages)
