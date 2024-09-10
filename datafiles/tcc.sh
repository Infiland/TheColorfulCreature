#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export LD_LIBRARY_PATH="./assets/:$LD_LIBRARY_PATH:/usr/lib"
"${SCRIPT_DIR}/../TheColorfulCreature"