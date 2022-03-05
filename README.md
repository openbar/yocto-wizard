# OpenBar build system for Yocto projects

The `yocto-openbar` is an implementation of the OpenBar build system for Yocto
projects. It follows the guidelines specified by the OpenBar project to build
a Yocto project in an easy, repeatable and unambiguous way.

## Features

* The configuration and build are performed with a minimum number of actions to
  eliminate any possible errors:

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

  * Configurable project path (defconfig files, docker files, poky).

  * Configuration files use a makefile syntax that allows to easily use some
    features like target dependencies, file inclusion, default variable
    assignment, etc ...

  * Developers can easily access the Yocto environment with the `make shell`
    command.

## Further Reading

For more information about the OpenBar project, the use and specifications of
the `yocto-openbar`, to discover other project templates and examples, please
visit the project documentation:

> https://openbar.github.io

## License

The `yocto-openbar` is released under the [MIT License](LICENSE.md).
