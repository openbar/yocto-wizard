import logging

import pytest
import sh

logger = logging.getLogger(__name__)


@pytest.mark.no_container_engine
def test_gnu_make():
    version = sh.make("--version")
    logger.info(version.splitlines()[0])
    assert str(version).startswith("GNU Make")


@pytest.mark.no_container_engine
def test_gnu_awk():
    version = sh.awk("--version")
    logger.info(version.splitlines()[0])
    assert str(version).startswith("GNU Awk")


@pytest.mark.docker
def test_docker():
    version = sh.docker("--version")
    logger.info(version.splitlines()[0])
    assert str(version).startswith("Docker")


@pytest.mark.podman
def test_podman():
    version = sh.podman("--version")
    logger.info(version.splitlines()[0])
    assert str(version).startswith("podman")


@pytest.mark.no_container_engine
def test_project_fixture(create_project):
    # Project creation
    project = create_project(
        defconfig="hello_defconfig",
        cli={"FOO": "create/cli", "BAR": "create/cli"},
        env={"FOO": "create/env", "BAZ": "create/env"},
    )
    assert (project.root_dir / "Makefile").exists()
    assert (project.root_dir / ".config").exists()

    # Simple command
    stdout = project.run("env")
    assert "FOO=create/cli" in stdout.splitlines()
    assert "BAR=create/cli" in stdout.splitlines()
    assert "BAZ=create/env" in stdout.splitlines()

    # Command arguments
    stdout = project.run("env", "-C", project.root_dir, "pwd")
    assert stdout.strip() == str(project.root_dir)

    # Override command line / environment variables
    stdout = project.run(
        "env",
        cli={"FOO": "run/cli", "BAR": "run/cli"},
        env={"FOO": "run/env", "BAZ": "run/env"},
    )
    assert "FOO=run/cli" in stdout.splitlines()
    assert "BAR=run/cli" in stdout.splitlines()
    assert "BAZ=run/env" in stdout.splitlines()

    # Failing command (pytest)
    with pytest.raises(sh.ErrorReturnCode_1):
        project.run("false")

    # Failing command (sh)
    project.run("false", _ok_code=(0, 1))

    # Make command
    project.make("help")
