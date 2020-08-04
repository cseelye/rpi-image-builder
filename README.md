# rpi-image-builder
Build customized Raspberry Pi OS images on your x86 desktop/laptop. The image builder runs in a container, so there is nothing else to install and it can run on macOS or Linux (and probably Windows, but untested). 

Executing create-image will first build the container image, then execute the container image. Inside that image, build-image will run, which will download a base ubuntu image, expand it to add space for customizing, copy the files from the overlay into the image, and execute each script from config-hooks in the image chroot. When that is finished, it will save the image and optionally compress it.  

There are two ways to customize the image:  
* The configuration hooks are executable fragments that live in config-hooks. Any executable file (or link to one) will be run, in lexical order. The hooks are run in the context of the chroot, with root privileges.
* The overlay directory is an exact mapping ot the root filesystem in the image; any files you place here will be directly copied into the image in the same location.

This is currently setup to use Ubuntu-based images, but could be easily changed to create Rasbian images, or any other linux, by changing the default `BASE_IMAGE` in `build-image` and creating appropriate config-hooks for the distro.  
The master branch is based on Ubuntu 18.04, switch to the ubuntu-20.04 branch to base on Ubuntu 20.04.  

## Building images
1. Put the files of your choosing into the overlay, and create/customize config-hooks scripts.
2. Run `./create-image`. 
    * Optionally use environment variables to set node specific options, eg `HOSTNAME=rpi1 IP=192.168.0.11 CIDR=24 GATEWAY=192.168.0.1 DNS=192.168.0.1 USERNAME=myname PASSWORD=secret ./create-image`
    * Using `COMPRESS=1` will xz compress the image at the end, default is not to compress.
    * Using `DOCKER=1` will import the image into a docker container as well, default is not to import.
3. Use [Etcher](https://www.balena.io/etcher/) to copy `artifacts/custom-rpi.img` to a microSD card.
4. Enjoy your pi!

## Mounting and exploring images
`explore-image <image-path>` will allow you to mount an image you have downloaded or created, to poke around and see what it looks like. If you mount the stock ubuntu image, be careful not to modify it, or delete it when you are done so that you have a known starting point for `create-image`.

## Frequently asked Questions
1. **Why it is so slow?**  
This is running the actual ARM image on your x86-based computer, using binfmt/qemu, so it is emulating another CPU type in real time.

2. **Why isn't my Pi booting?**  
The first time boot takes several minutes. If it still isn't responding, hook up a monitor and see where it's stuck.

3. **Why is it failing with 'exec format error' on Linux?**  
Make sure you have qemu-user and binfmt-support installed.

4. **Tell me more about this binfmt/qemu magic for seamlessly running ARM on x86?**  
This is a great description/walkthrough with experiments: https://ownyourbits.com/2018/06/13/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt_misc/  
Modern versions of Docker for Mac come with this set up for you.
