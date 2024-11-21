# System Requirements

One of OpenBar's objectives is to reduce project dependencies to the bare
minimum.

Here is the list of dependencies:

- [`git`][git]
- [`repo`][repo] (optional)
- [GNU `make`][gmake]
- [GNU `awk`][gawk]
- [`podman`][podman] and / or [`docker`][docker]

[git]: https://git-scm.com
[repo]: https://gerrit.googlesource.com/git-repo/
[gmake]: https://www.gnu.org/software/make/
[gawk]: https://www.gnu.org/software/awk/
[podman]: https://podman.io
[docker]: https://www.docker.com

---

Some of these dependencies can be installed using your distro's package manager.

```bash title="On Debian"
apt install git make gawk
```

## Install `repo`

You can configure you project to use [`repo`][repo]. In this case, you'll
need to install it.

Many distros include `repo`, so you might be able to install from there.

```bash title="On Debian"
apt install repo # (1)!
```

1.  The `contrib` component must be enabled.

You can also install it manually:

```bash title="Manual install"
curl "https://storage.googleapis.com/git-repo-downloads/repo" > /tmp/repo
install -D -m 755 /tmp/repo /usr/local/bin/repo

curl "https://gerrit.googlesource.com/git-repo/+/refs/heads/main/completion.bash?format=TEXT" | base64 -d > /tmp/repo.bash-completion
install -D -m 644 /tmp/repo.bash-completion /usr/local/share/bash-completion/completions/repo
```

## Install the container engine

To use OpenBar you need to have at least one container engine:
[`podman`][podman] and / or [`docker`][docker].

=== "Podman"

    [Podman installation instructions][podman-install]
    are available in the official documentation.

[podman-install]: https://podman.io/docs/installation

=== "Docker engine"

    [Docker engine installation instructions][docker-install]
    are available in the official documentation.

    Also don't forget the [post-installation steps on Linux][docker-postinstall].

[docker-install]: https://docs.docker.com/engine/install
[docker-postinstall]: https://docs.docker.com/engine/install/linux-postinstall
