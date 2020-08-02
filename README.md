# rpi-image-builder
Build customized Raspberry Pi OS images

The image builder runs in a container, so it can run on macOS or Linux (and probably Windows, but untested). The actual ARM chroot image is being run and customized using binfmt/qemu, so the commands run during customization will be much slower than you are used to, and much slower than when it is run natively on the Pi.  

Executing create-image will first build the container image, then execute the container image. Inside that image, build-image will run, which will download a base ubuntu image, expand it to add space for customizing, copy the files from the overlay into the image, and execute each script from config-hooks. When that is finished, it will save the image and optionally compress it.  

Thre are two ways to customize the image:  
* The configuration hooks are executable fragments that live in config-hooks. Any executable file (or link to one) will be run, in lexical order. The hooks are run with root privileges in the context of the chroot.
* The overlay directory is an exact mapping ot the root filesystem in the image; any files you place here will be directly copied into the image in the same location.

This is currently setup to use Ubuntu 18.04 based images, but could be easily changed to create Rasbian images, or any other linux, by changing the default `BASE_IMAGE` in `build-image` and creating appropriate config-hooks for the distro.  

## Building images
1. Put the files of your choosing into the overlay, and create/customize config-hooks scripts.
2. Run `./create-image`. 
    * Optionally use environment variables to set node specific options, eg `HOSTNAME=rpi1 IP=192.168.0.11 CIDR=24 GATEWAY=192.168.0.1 DNS=192.168.0.1 USERNAME=myname PASSWORD=secret ./create-image`
    * Using `COMPRESS=1` will xz compress the image at the end, default is not to compress
    * Using `DOCKER=1` will import the image into a docker container as well, default is not to import
3. Use Etcher to copy `artifacts/custom-rpi.img` to a microSD card
4. Enjoy your pi
