#!/bin/bash
set -e

source /opt/ros/humble/setup.bash

git config --global --add safe.directory '*'

export DISPLAY=${DISPLAY:-:0}
export GZ_SIM_RESOURCE_PATH=/gz_models:$GZ_SIM_RESOURCE_PATH

exec "$@"
