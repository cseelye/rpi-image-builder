FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive  apt-get install --yes \
        build-essential \
        cmake \
        git \
        g++-aarch64-linux-gnu \
        gcc-aarch64-linux-gnu \
        binutils-aarch64-linux-gnu \
        pkg-config-aarch64-linux-gnu
