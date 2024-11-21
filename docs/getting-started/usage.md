# Usage

Once [you have created your project](easy-install.md), you will be able to
fetch the sources, configure and build it.

## Fetch the sources

The way to fetch sources can be either` git submodule` or `repo`, depending on
the chosen layout.

=== "Git Submodule"

    Simply use the `--recurse-submodules` while cloning:

    ```bash
    git clone --recurse-submodules <project url>
    ```

    Or use the `submodule` command after clonning:

    ```bash
    git clone <project url>

    git submodule init
    git submodule update
    ```

    More details in the [official documentation][git-submodule-doc].

[git-submodule-doc]: https://git-scm.com/book/en/v2/Git-Tools-Submodules#_cloning_submodules

=== "Repo"

    First, initialize the project:

    ```bash
    mkdir example-project
    cd example-project

    repo init -u <project url> # (1)!
    ```

    1. The git repository pointed to by the `<project url>` must contain
       the `default.xml` manifest file.

    Then synchronize it:

    ```bash
    repo sync
    ```

    More details in the [official documentation][repo-doc].

[repo-doc]: https://source.android.com/docs/setup/reference/repo

## Configure the build

As soon as the sources have been fetched, `make` is ready to accept commands or
as `make` calls them: *targets*. But you will need to configure the build before
you can do anything else.

It is pretty simple, just do:

```bash
make example_defconfig # (1)!
```

1. Assuming `example_defconfig` is one of your project's *defconfig files*.

These targets will create a `.config` file at the root of the project. This file
determines whether the project is configured or not.

The project can be reconfigured at any time by running a new *defconfig target*.

## Build the project

When configured, additional targets are available. They can be run with:

```bash
make [target]
```

Calling `make` alone will execute each of these targets one by one. Unless
some of these targets have been added to the <var:OB_MANUAL_TARGETS> variable.

## The `help` target

At any time, you can run the `help` target to get more information about the
current status:

```
Generic targets:
  all                  - Build all targets marked with [*]

Configured targets:
* build
  clean
  shell

Configuration targets:
  example_defconfig

Usefull targets:
  help                 - Display this help
  foreach [targets]    - Build targets for each configuration

Command line options:
  make V=0-1 [targets] 0 => quiet build (default)
                       1 => verbose build
  make O=dir [targets] Use the specified build directory (default: build)
```

## The `all` target

The `all` target is the one that is automatically executed when no explicit
target is given as argument. Its purpose is to execute all *automatic* targets
marked with an `*`. By default, all targets defined in the `.config` file are
executed automatically, unless they have been added to the
<var:OB_MANUAL_TARGETS> variable.

## Debug mode

To debug OpenBar the `V` variable can be used to enable verbose build:

```bash
make [target] V=1
```

By activating the debug mode, all commands executed by make will be printed.
Also the variables <var:OB_VERBOSE> and <var:QUIET>, that can be used in the
`.config` file, will be updated according to the desired mode.

## The `shell` target

If you need manual access to the build environment, you can use the `shell`
target. It will open a new interactive shell inside the configured container,
allowing you to execute the desired commands.

To exit the shell, simply hit <kbd>CTRL</kbd> + <kbd>d</kbd> or execute
the `exit` command.

## The `foreach` target

When the project contains multiple *defconfig files*, the `foreach` target can
be used to execute a target for each *defconfig file*.

```bash
make foreach [target]
```
