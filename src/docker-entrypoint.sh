#!/bin/bash

set -ex
echo "[INFO] Params received :: $@"

if [[ "$#" == 0 ]]; then
  python3 -u main.py "$MYSQL_DATABASE"
else
  python3 -u main.py "$@"
fi
