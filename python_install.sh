#!/bin/bash

python_adds () {
    sudo nala install python3-pylsp python3-autopep8 python3-mccabe python3-pycodestyle python3-pydocstyle python3-pyflakes python3-rope python3-yapf python3-venv flake8 pylint

    curl -sSL https://install.python-poetry.org | python3 -

    poetry completions bash >> ~/.bash_completion
}