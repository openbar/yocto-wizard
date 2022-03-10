# OpenBar build system

The `openbar` build system is used to enhance reproducible builds for your
project by providing deterministic and immutable environments.

## Features

* The configuration and build are performed with a minimal and unambiguous
  number of actions to eliminate any possible errors:

  ```bash
  make myconfig_defconfig
  make
  ```

* The project environment is containerized to ensure better reproducibility and
  sustainability:

  * No dependencies on host distribution.

  * Configurable container using a `Dockerfile`.

  * Configurable container environment variables and mount points at runtime.

  * The generated files are stored in the local file system and belong to the
    local user.

  * The local SSH configuration is used to be able to fetch private
    repositories.

* Although the final user interface is quite restrictive, the project
  configuration is very flexible and has some powerful features:

  * Configurable project type (standard, yocto).

  * Configurable project path (defconfig files, docker files, poky).

  * Config files use a makefile syntax that allows to easily use some
    features like target dependencies, file inclusion, default variable
    assignment, etc ...

  * Developers can easily access the build environment with the `make shell`
    command.

## Further Reading

For more information about the OpenBar project, the specifications of
the `openbar` build system, and to discover some examples, please visit
the project documentation:

> https://openbar.github.io

## License

The `openbar` build system is released under the [MIT License](LICENSE.md).
