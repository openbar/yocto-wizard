import logging

import pytest
import sh

logger = logging.getLogger(__name__)


def test_gnu_make():
    version = sh.make("--version")
    logger.debug(version.splitlines()[0])
    assert str(version).startswith("GNU Make")


def test_gnu_awk():
    version = sh.awk("--version")
    logger.debug(version.splitlines()[0])
    assert str(version).startswith("GNU Awk")


@pytest.mark.docker
def test_docker():
    version = sh.docker("--version")
    logger.debug(version.splitlines()[0])
    assert str(version).startswith("Docker")


@pytest.mark.podman
def test_podman():
    version = sh.podman("--version")
    logger.debug(version.splitlines()[0])
    assert str(version).startswith("podman")
