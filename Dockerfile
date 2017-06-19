FROM ubuntu:16.04
RUN apt-get update
#RUN apt-get install -y gcc-aarch64-linux-gnu  
#RUN apt-get install -y 
RUN apt-get install -y \
   bc device-tree-compiler qemu-system-arm ncurses-dev build-essential \
   gcc-arm-linux-gnueabi curl

ENV ARCH=arm
ENV CROSS_COMPILE=arm-linux-gnueabi-

COPY config /rpi/.config
COPY armbian.patch /rpi

RUN apt-get install -y --no-install-recommends bsdtar

WORKDIR /rpi
RUN curl -O https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-3.4.113.tar.gz \
   && bsdtar zxf linux-3.4.113.tar.gz && rm linux-3.4.113.tar.gz \
   && cd linux-3.4.113 && patch -p1 <../armbian.patch \
   && cp ../.config . && make oldconfig && make -j 4 all \
   && cp arch/arm/boot/zImage .. && cd .. && rm -rf linux-3.4.113
   
EXPOSE 22
EXPOSE 3333
EXPOSE 4444

CMD qemu-system-arm -nographic -kernel zImage \
                    -m 512 -M vexpress-a9 -no-reboot \
                    -serial mon:stdio -sd armbian.img \
                    -append "root=/dev/mmcblk0p1 loglevel=10 console=ttyAMA0,115200  \
                            enforcing=0"
