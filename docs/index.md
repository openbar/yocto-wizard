# OpenBar

## What is it?

Large projects can be complicated to configure, build and reproduce.

This often results in a single reference build machine, installed years ago,
which nobody remembers how, running a more or less clean home-made script.

A project with almost no reproducibility is very complicated to develop
and maintain. Moreover, if too many steps are required to obtain a simple
build, or if too many different build configurations exist, human error will
inevitably occur.

OpenBar is the result of these observations.

## Features

* Fetch project sources using [`git submodule`][git-submodule] or [`repo`][repo].

* Containerized environment using [`podman`][podman] or [`docker`][docker].

* Simple [`Makefile`][make] interface with `defconfig` files.

* [Low host requirements](getting-started/system-requirements.md).

* [Easy install wizard script](getting-started/easy-install.md).

[git-submodule]: https://www.git-scm.com/book/en/v2/Git-Tools-Submodules
[repo]: https://gerrit.googlesource.com/git-repo/
[podman]: https://podman.io
[docker]:https://www.docker.com
[make]: https://www.gnu.org/software/make/

## Why this name?

This project is intended to be a [FLOSS][floss], hence the `open` part.

The `bar` part comes from the famous `foo` and `bar` placeholder names, as this
is a generic project wrapper.

The word` openbar` adds the idea that you can use it without charge, and simply
enjoy the build.

And last but not least, the `openbar` namespace was available on GitHub.

[floss]: https://en.wikipedia.org/wiki/Free_and_open-source_software

## History

After my first [Yocto][yocto] builds, a coworker showed me that with
[`cqfd`][cqfd] (one of his projects) and a `build.sh` script he could solve the
reproducibility problem.

[`cqfd`][cqfd] was a good project, but I didn't like its configuration files.
And the `build.sh` script was very error-prone.

So I decided to create my own solution. My requirements were as follows:

* The technology used must be very common and widespread to minimize dependencies.

* The format of the configuration file used to specify build targets and recipes
  must be simple and sufficiently configurable.

* Docker containerization seemed a good solution.

The first version of OpenBar was a Makefile that ran [`cqfd`][cqfd] under the
hood. Then I added the configuration file as another `Makefile`, to run any
target in the containerized environment.

The next step was to remove `cqfd` to reduce the number of dependencies.
And [`podman`][podman] support was added as the default container engine.

The last step was to make the setup as easy as possible,
which is why the [wizard](getting-started/easy-install.md) was developed.

Despite having been created for Yocto, OpenBar is now generic enough
to support any type of projects:
[Yocto][yocto], [Buildroot][buildroot], [Zephyr][zephyr]...

[yocto]: https://www.yoctoproject.org
[cqfd]: https://github.com/savoirfairelinux/cqfd
[buildroot]: https://buildroot.org
[zephyr]: https://www.zephyrproject.org

## License

The OpenBar build system is released under the [MIT License][license].

[license]: https://github.com/openbar/openbar/blob/main/LICENSE.md

## Credits

Icon made by [flaticon][icon-flaticon] or [freepik][icon-freepik].

[icon-flaticon]: https://www.flaticon.com/free-icon/mai-thai_920539
[icon-freepik]: https://www.freepik.com/free-icon/mai-thai_15117327.htm
