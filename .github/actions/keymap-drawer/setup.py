from setuptools import setup, find_packages

setup(
    name="keymap-drawer-local",
    version="0.17.0",
    packages=find_packages(),
    install_requires=[
        "pyyaml",
        "pydantic",
        "tree-sitter",
    ],
    entry_points={
        "console_scripts": [
            "keymap=keymap_drawer.__main__:main",
        ],
    },
)
