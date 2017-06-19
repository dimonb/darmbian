# Docker container with qemu emulator for armbian
This container include linux kernel build configuration and qemu for arm

To run emulation you will need armbian image: https://www.armbian.com/orange-pi-zero/

```bash
run -ti -v <path to armbian image>:/rpi/armbian.img kkt
```
