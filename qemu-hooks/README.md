Executable files (or links to executable files) placed in this directory will be executed in lexical order, as root, with the image mounted, but not inside the chroot. The variable CHROOT is set in the environment with the location of the image mount.

These config fragments are executed against a copy of the image to prepare it to be launched in qemu and booted up. These files should do any changes/fixes that the image needs to be able to boot in qemu vs. the actual device.
