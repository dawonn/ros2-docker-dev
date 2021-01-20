#!/usr/bin/env bash
# Developer Scripts

# Abort on any failure
set -e

DOCKER_TAG="foxy"

usage() {
    BLUE=$(tput setaf 4)
    NONE=$(tput sgr0)

    echo "USAGE: $0 ${BLUE}command${NONE}
    ${BLUE}host_setup${NONE} - Install dependencies on host (sudo | root required)
    ${BLUE}build${NONE}      - Build the container
    ${BLUE}start${NONE}      - Start the container if not running and open a shell
    ${BLUE}stop${NONE}       - Stop the container
    ${BLUE}clean${NONE}      - Delete build artifacts
    "
}

host_setup() {
    # Docker - https://docs.docker.com/engine/install/ubuntu
    # Nvidia Container Toolkit - https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#setting-up-nvidia-container-toolkit

    apt-get update
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common \
        git

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    apt-key fingerprint 0EBFCD88
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

    apt-get update
    apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        nvidia-docker2

    systemctl restart docker

    # Test to make sure GPU is acessable
    docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
}

build() {
    docker build -t $DOCKER_TAG .
}

start() {
    # Start if not already running
    set +e
    PS=$(docker ps --filter "name=$DOCKER_TAG" | grep $DOCKER_TAG)
    set -e
    if [ -z "$PS" ] 
    then
        docker run -d -it --rm \
            --name $DOCKER_TAG \
            --mount type=bind,src="$(pwd)",dst=/app \
            -u "$(id -u)":"$(id -g)" \
            --runtime=nvidia \
            -e DISPLAY=$DISPLAY \
            -v /tmp/.X11-unix:/tmp/.X11-unix \
            -v $HOME/.Xauthority:/home/docker/.Xauthority \
            #--device /dev/serial/by-id/usb-FTDI_USB-RS232_Cable_FT1GUL07-if00-port0:/dev/vn100 \
            --group-add dialout \
            $DOCKER_TAG

        sleep 0.5
    fi

    # Attach to running container
    docker exec -it $DOCKER_TAG bash
}

stop() {
    docker stop $DOCKER_TAG
}

clean() {
    rm -rf build, log, install
}

# Command Selection
case $1 in
host_setup)
    host_setup
    ;;
build)
    build
    ;;
start)
    start
    ;;
stop)
    stop
    ;;
clean)
    clean
    ;;
*)
    usage
    ;;
esac