import logging

import pytest

logger = logging.getLogger(__name__)

pytestmark = pytest.mark.parametrize(
    "container",
    [
        "alpine",
        "archlinux",
        "debian",
        "fedora",
        "opensuse",
        "rockylinux",
        "ubuntu",
    ],
)


@pytest.fixture
def project_config(project_config, container):
    project_config["env"] = {"OB_CONTAINER": container}
    return project_config


def test_hello(create_project):
    project = create_project(defconfig="hello_defconfig")
    stdout = project.make()
    assert stdout[-1] == "Hello"
