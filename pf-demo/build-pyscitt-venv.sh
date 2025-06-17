#!/usr/bin/env bash
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

echo "Setting up python virtual environment."
if [ ! -f "venv/bin/activate" ]; then
    if command -v python &> /dev/null; then
        PYTHON=python
    elif command -v python3.12 &> /dev/null; then
        PYTHON=python3.12
    else
        echo "Neither python nor python3.12 is available. Please install one of them."
        exit 1
    fi
    $PYTHON -m venv "venv"
fi

source venv/bin/activate 
pip install --disable-pip-version-check -q -e /tmp/pyscitt