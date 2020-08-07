Executable files (or links to executable files) placed in this directory will be executed in lexical order, as root, with the image mounted, but not inside the chroot. The variable CHROOT is set in the environment with the location of the image mount.

These config fragments are executed against the image being created, right after applying the overlay but before running the chroot-hooks.
