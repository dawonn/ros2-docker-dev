FROM ros:foxy

# Add runtime user
# https://github.com/boxboat/fixuid
ARG USER=docker
ARG GROUP=docker

RUN apt-get update \
    && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common \
        git \
        sudo \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup --gid 1000 $USER && \
    adduser --uid 1000 --ingroup $GROUP --disabled-password --gecos "" $USER

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

COPY ros_entrypoint.sh /

# Enable sudo
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Source ROS Base install and application workspace
RUN echo source /opt/ros/${ROS_DISTRO}/setup.bash >> /home/$USER/.bashrc \
 && echo source /app/install/setup.bash >> /home/$USER/.bashrc

# ROS Packages
RUN apt-get update \
 && apt-get install -y \
 ros-foxy-rviz2 \
 ros-foxy-rqt \
 && rm -rf /var/lib/apt/lists/*

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics
    
# Development User
USER $USER:$GROUP
WORKDIR /app