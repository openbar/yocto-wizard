# Software Architecture

```
- make
  \_ make -f <root_dir>/platform/openbar/core/podman.mk
    \_ podman run ...
      \_ make -f <root_dir>/platform/openbar/core/bitbake-init-build-env.mk
        \_ make -f <root_dir>/platform/openbar/core/bitbake-layers.mk
          \_ make -f <root_dir>/platform/openbar/core/config.mk
            \_ python3 <root_dir>/platform/poky/bitbake/bin/bitbake core-image-minimal
```
