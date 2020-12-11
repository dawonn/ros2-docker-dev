#!/usr/bin/env bash
# System Startup Script
#

DOCKER_TAG="foxy"

# Start if not already running
PS=$(docker ps --filter "name=$DOCKER_TAG" | grep $DOCKER_TAG)
if [ -z "$PS" ] 
then
    docker run -d -it --rm \
        --name $DOCKER_TAG \
        --mount type=bind,src="$(pwd)",dst=/app \
        -u "$(id -u)":"$(id -g)" \
        $DOCKER_TAG

    sleep 0.5
fi

# Attach to running container
docker exec -it $DOCKER_TAG bash