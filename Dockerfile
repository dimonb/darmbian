FROM ubuntu:16.04

RUN apt update

RUN apt install -y --no-install-recommends ca-certificates qemu-system-arm bsdtar curl apt-utils

ENV ARCH=arm
ENV CROSS_COMPILE=arm-linux-gnueabi-
ENV QEMU_AUDIO_DRV=none

COPY config /rpi/.config
COPY armbian.patch /rpi

WORKDIR /rpi

RUN \
   apt install -y --no-install-recommends \
   bc device-tree-compiler ncurses-dev build-essential \
   gcc-arm-linux-gnueabi && \  
   curl -O https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-3.4.113.tar.gz \
   && bsdtar zxf linux-3.4.113.tar.gz && rm linux-3.4.113.tar.gz \
   && cd linux-3.4.113 && patch -p1 <../armbian.patch \
   && cp ../.config . && make oldconfig && make -j 4 all \
   && cp arch/arm/boot/zImage .. && cd .. && rm -rf linux-3.4.113 \
   && apt purge -y bc device-tree-compiler ncurses-dev build-essential gcc-arm-linux-gnueabi \
   && apt autoremove -y && apt clean
   
CMD qemu-system-arm -nographic -kernel zImage \
                    -m 512 -M vexpress-a9 -no-reboot \
                    -serial mon:stdio -sd armbian.img \
                    -append "root=/dev/mmcblk0p1 loglevel=10 console=ttyAMA0,115200  \
                            enforcing=0"
