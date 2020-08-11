FROM ubuntu:20.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --yes \
        qemu-system-arm
ENTRYPOINT ["/usr/bin/qemu-system-aarch64"]
