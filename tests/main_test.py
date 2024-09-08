import logging

import pytest
import sh

logger = logging.getLogger(__name__)


def test_defconfig(create_project):
    project = create_project()
    assert not (project.root_dir / ".config").exists()
    project.make("main_defconfig")
    assert (project.root_dir / ".config").exists()
    with pytest.raises(sh.ErrorReturnCode):
        project.make("invalid_defconfig")


def test_help(create_project):
    project = create_project(defconfig="main_defconfig")
    stdout = project.make("help")
    lines = stdout.splitlines()
    configured_index = lines.index("Configured targets:")
    configuration_index = lines.index("Configuration targets:")
    usefull_index = lines.index("Usefull targets:")
    assert "* hello" in lines[configured_index + 1 : configuration_index - 1]
    assert "  shell" in lines[configured_index + 1 : configuration_index - 1]
    assert "  main_defconfig" in lines[configuration_index + 1 : usefull_index - 1]


def test_all(create_project):
    project = create_project(defconfig="main_defconfig")
    stdout = project.make("all")
    assert stdout.strip() == "Hello"
    stdout = project.make()
    assert stdout.strip() == "Hello"
