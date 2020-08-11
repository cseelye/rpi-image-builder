# rpi-image-builder
Build and test customized Raspberry Pi OS images on your x86 desktop/laptop. Most of the work runs in a container, so there is nothing else to install and it can run on macOS or Linux (and probably Windows Docker/WSL2, but untested). This repo contains tools to create images, mount and explore an image, and test an image by booting it up using qemu.  

This is currently setup to use Ubuntu-based server images, but could be changed to create Rasbian images, or any other linux, by changing the default `BASE_IMAGE` in `build-image` and creating appropriate hooks for the distro.  
The main branch is based on Ubuntu 20.04.1, switch to the ubuntu-18.04 branch to base on Ubuntu 18.04.4.  

## Building images
Quick start:
1. Put the files of your choosing into the overlay, and create/customize outer-hooks and chroot-hooks scripts.
2. Add/remove/customize the hooks in outer-hooks and chroot-hooks. Only executable files will be run, so chmod -x will cause a hook to be skipped.
3. Run `./create-image <image name>`. 
    * Optionally use environment variables to set node specific options, eg `HOSTNAME=rpi1 IP=192.168.0.11 CIDR=24 GATEWAY=192.168.0.1 DNS=192.168.0.1 USERNAME=myname PASSWORD=secret ./create-image <image name>`
    * Using `COMPRESS=1` will xz compress the image at the end (default is do not compress).
    * Using `DOCKER=1` will import the image into a docker container as well (default is do not import).
4. Use [Etcher](https://www.balena.io/etcher/) to copy `artifacts/<image name>` to a microSD card.
5. Enjoy your pi!

Executing create-image will first build the helper container, then execute that container image. Inside that contaienr, build-image will run, which will download a base ubuntu image, expand it to add space for customizing, mount the image, copy the files from the overlay into the image, execute each script from outer-hooks, and execute each script from chroot-hooks in the image chroot. Outer hooks run in the context of the container with access to the mounted image, chroot hooks run inside the context of the mounted image chroot. When the configuration process is finished, it will save the image and optionally compress it or import it as a docker image on the local system.  

There are three ways to customize the image:  
* The overlay directory is an exact mapping to the root filesystem in the image; any files you place here will be directly copied into the image in the same location.
* The outer configuration hooks are executable fragments that live in outer-hooks. Any executable file (or link to one) will be run, in lexical order. The hooks are run outside the context of the chroot, with root privileges.
* The chroot configuration hooks are executable fragments that live in chroot-hooks. Any executable file (or link to one) will be run, in lexical order. The hooks are run in the context of the chroot, with root privileges.

## Mounting and exploring images
`explore-image <image-path>` will allow you to mount an image you have downloaded or created, to poke around and see what it looks like. If you mount the stock ubuntu image, be careful not to modify it, or delete it when you are done so that you have a known starting point for `create-image`.

## Running images in QEMU
`boot-image <image-path>` will boot up a copy of your image in QEMU, allowing you to test it before deploying to your Pi. This allows you to try out your customizations and first-boot configs without wearing out your SD cards or connecting a monitor to your Pi. You must have qemu installed for your host system before running this script. `brew install qemu` or `apt-get install qemu` etc.  

The boot process works by making a copy of your image, customizing it slightly to work in qemu instead of on a hardware Pi (running the hooks in the qemu-hooks directory), and then booting it as a virtual machine in qemu. The VM console is connected to the terminal that `boot-image` was launched from, or if you have SSH enabled the SSH port is forwarded to host port 5522, so you can SSH to your running image with `ssh -p 5522 <username>@localhost`. If you set your image to use a static IP, then you will also need to pass the IP and CIDR environmemnt variables to this script for it to setup the qemu user network correctly, eg `IP=192.168.0.11 CIDR=24 ./boot-image artifacts/custom-rpi.img`.  

Notes:
* This is booting an ephemeral copy of the image, not the original, so any modifications you make will be lost. This is done to preserve first-boot customizing that you want to happen on the Pi itself, not in the emulator.
* qemu is currently implemented to use a single CPU when emulating ARM, and using the -smp option tends to make the image not boot correctly.
* Depending on the speed of your machine, you might see some services timeout and fail during boot.

## Frequently asked Questions
1. **Why it is so slow?**  
This is running the actual ARM image on your x86-based computer, using binfmt/qemu, so it is emulating another CPU type in real time.

2. **Why isn't my Pi booting?**  
The first time boot takes several minutes. If it still isn't responding, hook up a monitor and see where it's stuck. Don't forget to try it first out with `boot-image` before putting it on your Pi.

3. **Why is it failing with 'exec format error' on Linux?**  
Make sure you have qemu-user and binfmt-support installed.

4. **Tell me more about this binfmt/qemu magic for seamlessly running ARM containers on x86?**  
This is a great description/walkthrough with experiments: https://ownyourbits.com/2018/06/13/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt_misc/  
Modern versions of Docker for Mac come with this set up for you.
