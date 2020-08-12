FROM ubuntu:20.04

# Setup locale
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends locales && \
    locale-gen en_US && \
    locale-gen en_US.UTF-8 && \
    set -x \
    localedef -i en_US -c -f UTF-8 en_US.UTF-8 && \
    update-locale && \
    apt-get autoremove --yes && apt-get clean && rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Docker binaries
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        lsb-release \
        software-properties-common && \
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) edge" > /etc/apt/sources.list.d/docker.list && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends docker-ce && \
    apt-get autoremove --yes && apt-get clean && rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes --no-install-recommends \
        curl \
        gettext-base \
        ipcalc \
        mount \
        parted \
        pixz \
        python3 \
        python3-pip \
        qemu-system-arm \
        rsync \
        udev \
        && \
    pip3 install --upgrade pip && \
    apt-get autoremove --yes && apt-get clean && rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Python libraries
RUN pip3 install pylint ruamel.yaml

