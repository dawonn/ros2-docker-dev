FROM osrf/ros:foxy-desktop@sha256:026bfcc35cade78021fa257ca9b91361e1eb0ba80b3ff2f49f39f87eca0299e0 AS foxy-desktop

# Add runtime user & group
# https://github.com/boxboat/fixuid
RUN addgroup --gid 1000 docker && \
    adduser --uid 1000 --ingroup docker --disabled-password --gecos "" docker

RUN USER=docker && \
    GROUP=docker && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.5/fixuid-0.5-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

COPY ros_entrypoint.sh /

USER docker:docker

