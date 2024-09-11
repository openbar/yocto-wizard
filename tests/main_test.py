import logging

import pytest
import sh

logger = logging.getLogger(__name__)


def test_defconfig(create_project):
    project = create_project()
    assert not (project.root_dir / ".config").exists()
    project.make("hello_defconfig")
    assert (project.root_dir / ".config").exists()
    with pytest.raises(sh.ErrorReturnCode):
        project.make("invalid_defconfig")


def test_help(create_project):
    project = create_project(defconfig="main_defconfig")
    stdout = project.make("help")
    configured_index = stdout.index("Configured targets:")
    configuration_index = stdout.index("Configuration targets:")
    usefull_index = stdout.index("Usefull targets:")
    assert "* foo" in stdout[configured_index + 1 : configuration_index - 1]
    assert "* bar" in stdout[configured_index + 1 : configuration_index - 1]
    assert "  baz" in stdout[configured_index + 1 : configuration_index - 1]
    assert "  shell" in stdout[configured_index + 1 : configuration_index - 1]
    assert "  main_defconfig" in stdout[configuration_index + 1 : usefull_index - 1]


def test_all(create_project):
    project = create_project(defconfig="main_defconfig")
    stdout = project.make("all")
    assert stdout[1:] == ["Foo", "Bar"]
    stdout = project.make()
    assert stdout[1:] == ["Foo", "Bar"]
