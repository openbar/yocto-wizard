# Getting Started

## Prerequisites

Ensure all the requirements are installed on your system.

For this example you just need: `git`, `make`, `awk` and `podman`

!!! info

    See the page [System Requirements](system-requirements.md) for more details.

## Create a new project

First, you need to create a new project. You can do this using the wizard.

Run the following curl command and wait for the prompt:

``` sh
curl -sSf https://openbar.github.io/openbar/wizard | sh
```

Give your project a name and select a `yocto` project using `submodule`.
Then use the default answer for each of the following questions.

!!! info

    See the page [Easy Install](easy-install.md) for more details.

## Build the project

Now that you have a project, you can `cd` into it, configure it and build it.

``` sh
cd example # (1)!
make example_defconfig #(2)!
make # (3)!
```

1.  Assuming `example` is the name of the project you chose.

2.  Again, assuming `example` is the name of your project.

3.  And that's it! :clap: :partying_face:

    You've just started a build of a Yocto project in a reproducible environment.

    Now, relax and enjoy a cocktail or two. :tropical_drink:

!!! info

    See the page [Usage](usage.md) for more details.

## What's next?

* [Make sure you have all the necessary programs installed](system-requirements.md)
* [Discover the layouts available for your project](easy-install.md).
* [Learn how to use OpenBar](usage.md)
* [Create and customize your configuration files](configuration.md).
