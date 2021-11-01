#!/usr/bin/env bash

powershell -Command "New-Item -Path .\client\shared -ItemType SymbolicLink -Value .\shared"
powershell -Command "New-Item -Path .\server\shared -ItemType SymbolicLink -Value .\shared"