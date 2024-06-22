# Variables Glossary

[cli-w]: https://img.shields.io/badge/command_line-W-coral
    "Editable from a command line option"

[env-w]: https://img.shields.io/badge/environment-W-coral
    "Editable from an environment variable"

[config-r]: https://img.shields.io/badge/config-R-blue
    "Readable in the configuration file"

[config-w]: https://img.shields.io/badge/config-W-coral
    "Editable in the configuration file"

[config-rw]: https://img.shields.io/badge/config-RW-coral
    "Readable and editable in the configuration file"

[wizard-w1]: https://img.shields.io/badge/wizard-W1-purple
    "Configured only once during setup"

[bitbake-r]: https://img.shields.io/badge/bitbake-R-green
    "Readable in the Bitbake environment for Yocto projects"

## Global variables

var:OB_BUILD_DIR
:   ![][cli-w] ![][env-w] ![][config-r] ![][bitbake-r]

    The build directory where all the outputs will be generated.

    The default value is <code><var:OB_ROOT_DIR>/build</code>.

    The command line option `O=dir` can be used to set the value.

var:OB_DEFCONFIG_DIR
:   ![][wizard-w1] ![][config-r]

    The directory where all the `defconfig` files can be found.

var:OB_ROOT_DIR
:   ![][config-r] ![][bitbake-r]

    The base directory where the root `Makefile` is located.

var:OB_TYPE
:   ![][wizard-w1] ![][config-r]

    The project type. Either `standard` or `yocto`.

var:OB_VERBOSE
:   ![][cli-w] ![][env-w] ![][config-r] ![][bitbake-r]

    The build verbosity level.

    Either `0` (quiet) or `1` (verbose). By default quiet build are enabled.

    The command line option `V=0-1` can be used to set the value.

var:QUIET
:   ![][config-r]

    Helper variable to control process verbosity.

    The value is based on <var:OB_VERBOSE>.

    It is unset on verbose build else it is expanded to `> /dev/null`.

## Configuration layer variables

var:OB_CONFIG_EXPORT_VARIABLES
:   ![][env-w] ![][config-r]

    Allows environment variables to be made available in the
    [`.config`][config-file] file.

    For more information, see the
    [Exporting environment variable][export-variables] page.

[config-file]: ../getting-started/configuration.md
[export-variables]: ../getting-started/configuration.md#exporting-environment-variable

var:OB_ALL_TARGETS
:   ![][config-r]

    Extends to a list of all targets defined in the [`.config`][config-file]
    file, as well as the special [`shell`][shell-target] target.

[shell-target]: ../getting-started/usage.md#the-shell-target

var:OB_AUTO_TARGETS
:   ![][config-r]

    Extends to a list of all targets that are marked as automatic. In other
    words, the targets that will be executed when a `make` call is made without
    a specific target. It is automatically deduced from <var:OB_ALL_TARGETS>
    and <var:OB_MANUAL_TARGETS>.

var:OB_MANUAL_TARGETS
:   ![][config-rw]

    The list of all targets that are marked as manual. All targets which do not
    need to be executed automatically must be added to this variable.

    !!! example

        ``` make title=".config"
        auto-target:
        	do something

        OB_MANUAL_TARGETS += manual-target
        manual-target:
        	do something else
        ```

## Container layer variables

var:OB_CONTAINER
:   ![][env-w] ![][config-w]

    The name of the directory containing the container file.

    The default value is `default`.

var:OB_CONTAINER_BUILD_EXTRA_ARGS
:   ![][env-w] ![][config-w]

    Additional argument to be given during the container `build` command,
    for both `podman` and `docker` engine.

var:OB_CONTAINER_CONTEXT
:   ![][env-w] ![][config-w]

    The context directory used during the container `build` command.

    The default value is <code><var:OB_CONTAINER_DIR>/<var:OB_CONTAINER></code>.

var:OB_CONTAINER_DIR
:   ![][wizard-w1] ![][config-r]

    The directory where all the container files can be found.

var:OB_CONTAINER_ENGINE
:   ![][env-w] ![][config-w]

    The container engine to use.

    Either `podman` or `docker`. By default `podman` is used.

    !!! info

        For permanent configuration, this parameter can be set in the
        user's `.bashrc` or equivalent.

        ``` bash title=".bashrc"
        export OB_CONTAINER_ENGINE="docker"
        ```

var:OB_CONTAINER_EXPORT_VARIABLES
:   ![][env-w] ![][config-w]

    Allows environment variables to be made available inside the container.

    For more information, see the
    [Exporting environment variable][export-variables] page.

var:OB_CONTAINER_FILE
:   ![][env-w] ![][config-w]

    The full path to the container file.

    The default value is <code><var:OB_CONTAINER_CONTEXT>/<var:OB_CONTAINER_FILENAME></code>.

var:OB_CONTAINER_FILENAME
:   ![][env-w] ![][config-w]

    The name of the container file.

    The default value is `Dockerfile`.

var:OB_CONTAINER_HOME
:   ![][config-r]

    Convenient variable that points to the user's home inside the container.

    The value is set to `/home/container`.

var:OB_CONTAINER_RUN_EXTRA_ARGS
:   ![][env-w] ![][config-w]

    Additional argument to be given during the container `run` command,
    for both `podman` and `docker` engine.

var:OB_CONTAINER_VOLUMES
:   ![][env-w] ![][config-w]

    Mount additional directories in the container.

    The format is a space-separated list of mount arguments. Each mount
    argument consists of fields separated by colons, which can take one
    of three formats:

    1. `<host path>`

        Mount the host path (file or directory) in the container using the
        same path.

    2. `<host path>:<container path>`

        Mount the host path in the container using the path specified in
        the second field.

    3. `<host path>:<container path>:<mount option>`

        Same as above, but this format allows you to add mount options
        supported by the container engine.

    The last two formats are those supported by the `--volume` option in
    [docker][docker-volume] and [podman][podman-volume].

    By default <code><var:OB_ROOT_DIR></code> and
    <code><var:OB_BUILD_DIR></code> are already mounted.

[docker-volume]: https://docs.docker.com/storage/volumes
[podman-volume]: https://docs.podman.io/en/latest/markdown/podman-run.1.html#volume-v-source-volume-host-dir-container-dir-options

### Podman layer variables

var:OB_PODMAN_BUILD_EXTRA_ARGS
:   ![][env-w] ![][config-w]

    Additional argument to be given during the `podman build` command.

var:OB_PODMAN_RUN_EXTRA_ARGS
:   ![][env-w] ![][config-w]

    Additional argument to be given during the `podman run` command.

### Docker layer variables

var:OB_DOCKER_BUILD_EXTRA_ARGS
:   ![][env-w] ![][config-w]

    Additional argument to be given during the `docker build` command.

var:OB_DOCKER_RUN_EXTRA_ARGS
:   ![][env-w] ![][config-w]

    Additional argument to be given during the `docker run` command.

## Yocto layer variables

var:OB_BB_EXPORT_LIST_VARIABLE
:   ![][env-w] ![][config-w]

    The name of the variable used to export external environment variables into
    Bitbake's scope.

    The default value is `BB_ENV_PASSTHROUGH_ADDITIONS`.

    See [BB_ENV_PASSTHROUGH_ADDITIONS][bitbake-BB_ENV_PASSTHROUGH_ADDITIONS] on
    the Bitbake project documentation.

    !!! note

        Before the *kirkstone* release, the variable was called
        `BB_ENV_EXTRAWHITE`. So if you're using an old version, you must add
        this to your `.config` file.

        ``` make title=".config"
        OB_BB_EXPORT_LIST_VARIABLE := BB_ENV_EXTRAWHITE
        ```

[bitbake-BB_ENV_PASSTHROUGH_ADDITIONS]: https://docs.yoctoproject.org/bitbake/bitbake-user-manual/bitbake-user-manual-ref-variables.html#term-BB_ENV_PASSTHROUGH_ADDITIONS

var:OB_BB_EXPORT_VARIABLES
:   ![][env-w] ![][config-w]

    Allows environment variables to be made available inside bitbake.

    For more information, see the
    [Exporting environment variable][export-variables] page.

var:OB_BB_INIT_BUILD_ENV
:   ![][wizard-w1] ![][config-r]

    The path to the environment setup script.

    The default Yocto script is named `oe-init-build-env`.

var:OB_BB_LAYERS
:   ![][env-w] ![][config-w]

    Allows you to configure the required bitbake layers for each configuration
    file, by specifying a space-separated list of layer paths.

    There are several ways of configuring the required bitbake layers.
    One example is the use of a `bblayers.conf.sample` file, which is a
    relatively static solution.

    This variable enables a more dynamic method by calling the
    `bitbake-layers add-layer` command at each invocation. On the downside,
    it slows down the process.

### Yocto environment variables

var:DEPLOY_DIR
:   ![][env-w] ![][config-w] ![][bitbake-r]

    The directory where Yocto deploys images, packages, SDKs...

    See [DEPLOY_DIR][yocto-DEPLOY_DIR] on the Yocto project documentation.

var:DISTRO
:   ![][env-w] ![][config-w] ![][bitbake-r]

    The short name of the Yocto distribution.

    See [DISTRO][yocto-DISTRO] on the Yocto project documentation.

var:DL_DIR
:   ![][env-w] ![][config-w] ![][bitbake-r]

    The directory where Yocto stores downloads.

    See [DL_DIR][yocto-DL_DIR] on the Yocto project documentation.

    !!! info

        For permanent configuration, this parameter can be set in the
        user's `.bashrc` or equivalent.

        ``` bash title=".bashrc"
        export DL_DIR="${HOME}/.yocto/downloads"
        ```

var:MACHINE
:   ![][env-w] ![][config-w] ![][bitbake-r]

    The Yocto target device for which the image is built.

    See [MACHINE][yocto-MACHINE] on the Yocto project documentation.

var:SSTATE_DIR
:   ![][env-w] ![][config-w] ![][bitbake-r]

    The directory where Yocto stores the shared state cache.

    See [SSTATE_DIR][yocto-SSTATE_DIR] on the Yocto project documentation.

    !!! info

        For permanent configuration, this parameter can be set in the
        user's `.bashrc` or equivalent.

        ``` bash title=".bashrc"
        export SSTATE_DIR="${HOME}/.yocto/sstate-cache"
        ```

[yocto-DEPLOY_DIR]: https://docs.yoctoproject.org/ref-manual/variables.html#term-DEPLOY_DIR
[yocto-DISTRO]: https://docs.yoctoproject.org/ref-manual/variables.html#term-DISTRO
[yocto-DL_DIR]: https://docs.yoctoproject.org/ref-manual/variables.html#term-DL_DIR
[yocto-MACHINE]: https://docs.yoctoproject.org/ref-manual/variables.html#term-MACHINE
[yocto-SSTATE_DIR]: https://docs.yoctoproject.org/ref-manual/variables.html#term-SSTATE_DIR
