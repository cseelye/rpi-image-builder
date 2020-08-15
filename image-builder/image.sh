#!/bin/bash
set -euo pipefail


function mount_image()
{
    local image_file="$1"
    if ! losetup --all --output NAME,BACK-FILE | grep -q "${image_file}"; then
        losetup --find --partscan "${image_file}"
    fi
    lodev=$(losetup --associated "${image_file}" --noheadings --output NAME)

    # Workaround udev not existing in container, so we need to create the partition devices manually
    major_min=$(lsblk --noheadings --output NAME,MAJ:MIN  --list ${lodev} | grep $(basename ${lodev})p1 | awk '{print $2}' | tr ':' ' ')
    mknod ${lodev}p1 b ${major_min}
    major_min=$(lsblk --noheadings --output NAME,MAJ:MIN  --list ${lodev} | grep $(basename ${lodev})p2 | awk '{print $2}' | tr ':' ' ')
    mknod ${lodev}p2 b ${major_min}

    echo -n "${lodev}"
}

function prepare_chroot()
{
    local chroot_mount="$1"
    local lodev=$2

    mount --options rw ${lodev}p2 "${chroot_mount}"
    mkdir --parents "${chroot_mount}"/boot/firmware
    mount --options rw ${lodev}p1 "${chroot_mount}"/boot/firmware

    mount --types proc proc "${chroot_mount}"/proc
    mount --rbind /dev "${chroot_mount}"/dev
    mount --rbind /sys "${chroot_mount}"/sys

    # Use the host resolver config so the chroot has connectivity
    rm --one-file-system --force "${chroot_mount}"/etc/resolv.conf
    cp --force /etc/resolv.conf "${chroot_mount}"/etc/resolv.conf

}

function set_chroot_resolver()
{
    local chroot_mount="$1"

    # Use the host resolver config so the chroot has connectivity
    rm --one-file-system --force "${chroot_mount}"/etc/resolv.conf
    cp --dereference --force /etc/resolv.conf "${chroot_mount}"/etc/resolv.conf
}

function restore_chroot_resolver()
{
    local chroot_mount="$1"

    # Fix resolv.conf in the chroot
    if [[ -e "${chroot_mount}"/etc ]]; then
        (
            cd "${chroot_mount}"/etc
            rm --one-file-system --force resolv.conf
            ln -s ../run/systemd/resolve/stub-resolv.conf resolv.conf
        )
    fi
}

function unmount_special()
{
    local chroot_mount="$1"

    for mnt in "${chroot_mount}"/dev/pts "${chroot_mount}"/dev "${chroot_mount}"/sys "${chroot_mount}"/proc; do
        while mountpoint --quiet "${mnt}" && ! umount --recursive "${mnt}"; do
            sleep 1
        done
    done
}

function unmount_chroot()
{
    local chroot_mount="$1"

    restore_chroot_resolver "${chroot_mount}"
    sync

    unmount_special "${chroot_mount}"
    for mnt in "${chroot_mount}"/boot/firmware "${chroot_mount}"; do
        while mountpoint --quiet "${mnt}" && ! umount --recursive "${mnt}"; do
            sleep 1
        done
    done
}

function unmount_image()
{
    local image_file="$1"

    lodev=$(losetup --associated "${image_file}" --noheadings --output NAME)
    if [[ -n "${lodev}" ]]; then
         losetup --detach ${lodev}
    fi
}

function _cleanup
{
    echo ">>> Cleanup image mount"
    local chroot_mount="$1"
    local lodev=$2

    set +eu
    unmount_chroot "${chroot_mount}"
    unmount_image ${lodev}
    rm --one-file-system --force --recursive "${chroot_mount}"
    exit
}

function explore_image()
{
    local image_file="$1"
    local chroot_location=/tmp/chroot

    trap "_cleanup ${chroot_location} ${image_file}" EXIT INT TERM HUP

    echo ">>> Mounting image"
    mkdir --parents "${chroot_location}"
    lodev=$(mount_image "${image_file}")
    echo ">>> Preparing chroot"
    prepare_chroot "${chroot_location}" ${lodev}
    echo ">>> Entering chroot"
    chroot "${chroot_location}" /bin/bash
}

