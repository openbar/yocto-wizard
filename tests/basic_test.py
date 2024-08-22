import logging

logger = logging.getLogger(__name__)


def test_hello(create_project):
    project = create_project(defconfig="hello_defconfig")
    stdout = project.make()
    assert stdout.splitlines()[-1] == "Hello"
