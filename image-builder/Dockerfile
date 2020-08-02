FROM ubuntu:18.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        apt-transport-https \
        binfmt-support \
        ca-certificates \
        curl \
        gnupg2 \
        lsb-release \
        mount \
        qemu-user-static \
        parted \
        pixz \
        rsync \
        udev \
        xz-utils && \
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) edge" > /etc/apt/sources.list.d/docker.list && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes docker-ce && \
    apt-get autoremove --yes && \
    apt-get clean && \
    rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*
