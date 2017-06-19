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
RUN export tar='bsdtar'

WORKDIR /rpi
RUN curl -O https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-3.4.113.tar.gz \
   && tar zxf linux-3.4.113.tar.gz && rm linux-3.4.113.tar.gz \
   && cd linux-3.4.113 && patch -p1 <../armbian.patch \
   && cp ../.config . && make oldconfig && make -j 4 all \
   && cp arch/arm/boot/zImage .. && cd .. && rm -rf linux-3.4.113
   
EXPOSE 22
EXPOSE 3333
EXPOSE 4444

CMD qemu-system-arm -nographic -kernel zImage \
                    -initrd initrd.gz -m 512 -M vexpress-a9  -no-reboot \
                    -serial mon:stdio -serial file:serial1.log -serial file:serial2.log \
                    -serial file:serial3.log  -sd kkt.qcow2 -net nic \
                    -net user,hostfwd=tcp::22-:22,hostfwd=tcp::3333-:3333,hostfwd=tcp::4444-:4444 \
                    -append "root=/dev/vg/root loglevel=10 console=ttyAMA0,115200  \
                            console=ttyAMA0 enforcing=0 lvmwait=/dev/vg/root \
                            lvmwait=/dev/vg/data rd.luks.crypttab=yes luks.crypttab=no"
