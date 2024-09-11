import logging

import pytest
import sh

logger = logging.getLogger(__name__)


def test_not_configured(create_project):
    project = create_project()
    with pytest.raises(sh.ErrorReturnCode) as exc:
        project.make(_return_cmd=True)
    assert exc.value.stderr.strip().endswith(
        b"*** Configuration file not found.  Stop."
    )
    assert exc.value.stdout.strip().startswith(
        b"Please use one of the following configuration targets:"
    )


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


def test_defconfig(create_project):
    project = create_project()
    assert not (project.root_dir / ".config").exists()
    stdout = project.make("hello_defconfig")
    assert stdout[0] == "Build configured for hello_defconfig"
    assert (project.root_dir / ".config").exists()
    with pytest.raises(sh.ErrorReturnCode):
        project.make("invalid_defconfig")


def test_all(create_project):
    project = create_project(defconfig="main_defconfig")
    stdout = project.make("all")
    assert stdout[1:] == ["Foo", "Bar"]
    stdout = project.make()
    assert stdout[1:] == ["Foo", "Bar"]


def test_verbose(create_project):
    project = create_project(defconfig="main_defconfig")

    def check_container_build(data):
        return data.startswith(f"{project.container_engine} build")

    def check_container_run(data):
        return data.startswith(f"{project.container_engine} run")

    stdout = project.make("foo")
    assert not any(map(check_container_build, stdout))
    assert not any(map(check_container_run, stdout))
    assert "echo Foo" not in stdout

    stdout = project.make("foo", cli={"V": 0})
    assert not any(map(check_container_build, stdout))
    assert not any(map(check_container_run, stdout))
    assert "echo Foo" not in stdout

    stdout = project.make("foo", cli={"V": 1})
    assert any(map(check_container_build, stdout))
    assert any(map(check_container_run, stdout))
    assert "echo Foo" in stdout

    stdout = project.make("foo", env={"OB_VERBOSE": 0})
    assert not any(map(check_container_build, stdout))
    assert not any(map(check_container_run, stdout))
    assert "echo Foo" not in stdout

    stdout = project.make("foo", env={"OB_VERBOSE": 1})
    assert any(map(check_container_build, stdout))
    assert any(map(check_container_run, stdout))
    assert "echo Foo" in stdout


def test_build_dir(create_project):
    project = create_project(defconfig="main_defconfig")

    stdout = project.make("env")
    assert f"OB_BUILD_DIR={project.root_dir}/build" in stdout

    stdout = project.make("env", cli={"O": "relative_dir"})
    assert f"OB_BUILD_DIR={project.root_dir}/relative_dir" in stdout

    stdout = project.make("env", cli={"O": "/tmp/absolute_dir"})
    assert "OB_BUILD_DIR=/tmp/absolute_dir" in stdout

    with pytest.raises(sh.ErrorReturnCode) as exc:
        project.make("env", env={"OB_BUILD_DIR": "relative_dir"})
    assert b"absolute" in exc.value.stderr

    stdout = project.make("env", env={"OB_BUILD_DIR": "/tmp/absolute_dir"})
    assert "OB_BUILD_DIR=/tmp/absolute_dir" in stdout


def test_foreach(project_config, create_project):
    project = create_project(defconfig_dir=project_config["defconfig_dir"] / "foreach")
    stdout = project.make("foreach")
    for index, name in enumerate(["bar", "baz", "foo"]):
        assert stdout[3 * index + 0] == f"Build configured for {name}_defconfig"
        assert stdout[3 * index + 2] == f"Hello {name}"
    stdout = project.make("foreach", "goodbye")
    for index, name in enumerate(["bar", "baz", "foo"]):
        assert stdout[3 * index + 0] == f"Build configured for {name}_defconfig"
        assert stdout[3 * index + 2] == f"Goodbye {name}"
