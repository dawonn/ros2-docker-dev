#!/bin/bash
set -e

# Fix UID/GID to match Host (Development Only) 
eval $( fixuid )

# setup ros2 environment
source "/opt/ros/$ROS_DISTRO/setup.bash"
exec "$@"
