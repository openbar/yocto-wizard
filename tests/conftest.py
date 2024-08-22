import logging
import os
from shlex import quote
from textwrap import dedent

import pytest
import sh

logger = logging.getLogger(__name__)

logging.getLogger("sh").setLevel(logging.WARNING)


@pytest.fixture(autouse=True)
def _check_container_engine(request):
    markers = [m.name for m in request.node.iter_markers()]

    def check_command(name):
        try:
            sh.Command(name)
            return True
        except sh.CommandNotFound:
            if name in markers:
                pytest.skip(f"The command '{name}' is not available")
            return False

    docker_available = check_command("docker")
    podman_available = check_command("podman")

    if not docker_available and not podman_available:
        raise RuntimeError("No container engine available")


@pytest.fixture
def project_config(request, tmp_path):
    openbar_dir = request.config.rootpath
    return {
        "type": "simple",
        "root_dir": tmp_path,
        "openbar_dir": openbar_dir,
        "data_dir": openbar_dir / "tests/data",
        "defconfig_dir": openbar_dir / "tests/data",
        "container_dir": openbar_dir / "tests/data/container",
    }


class Project:
    def __init__(self, project_config, **kwargs):
        self.__config = {**project_config, **kwargs}

        self.generate_makefile()

        defconfig = self.get("defconfig")
        config = self.get("config")

        if defconfig is not None:
            self.make(defconfig)
        elif config is not None:
            self.write_file(".config", config)

    def __getattr__(self, name):
        return self.__config[name]

    def get(self, name, default=None):
        return self.__config.get(name, default)

    def generate_makefile(self):
        data = f"""
            export OB_TYPE          := {self.type}
            export OB_DEFCONFIG_DIR := {self.defconfig_dir}
            export OB_CONTAINER_DIR := {self.container_dir}
            include {self.openbar_dir}/core/main.mk
        """

        self.write_file("Makefile", data)

    def write_file(self, file, data):
        path = self.root_dir / file
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, "w", encoding="utf-8") as stream:
            stream.write(dedent(data))

    def make(self, *args, **kwargs):
        cli = kwargs.get("cli", self.get("cli", {}))
        env = kwargs.get("env", self.get("env", {}))

        make_args = [
            "--no-print-directory",
            "-C",
            self.root_dir,
            *args,
            *[f"{str(k).upper()}={quote(str(v))}" for k, v in cli.items()],
        ]

        make_env = {**os.environ, **{str(k): str(v) for k, v in env.items()}}

        return sh.make(*make_args, _env=make_env)


@pytest.fixture
def create_project(project_config):
    def _create_project(**kwargs):
        return Project(project_config=project_config, **kwargs)

    return _create_project
