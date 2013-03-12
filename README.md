#Raspberry Pi Bluetooth Audio Player (Wheezy 2.9.2013)
## KNOWN ISSUE

According to the bluez-dev team, there is an issue with the kernel (at this time Linux raspberrypi 3.6.11+)
with bluez-4.99 ([info here](http://thread.gmane.org/gmane.linux.bluez.kernel/34375)) that causes some freezing.
To cause this, successfully pair, then disconnect via the device, then attempt to reconnect...the rPi is now frozen.
The code that **should** work gracefully is commented out in connect.sh and replaced with a dirty # reboot command (hence the dirty branch).

This will be fixed eventually, but the code works as is here; the side effect being a reboot of a the Raspberry Pi if the device disconnects.

##Prerequisites:
1. Packages:
  * `bluez pulseaudio-module-bluetooth python-gobject python-gobject-2`
  * `bluez-tools qdbus`
1. Install:
  * all files in /root/bluetoothradio
  * `cp bluetoothradio/bluetooth-server /etc/init.d`
  * `chmod 755 /etc/init.d/bluetooth-server && chmod +x /etc/init.d/bluetooth-server`
  * `update-rc.d bluetooth-server defaults`
  * `reboot`
1. Requirements:
  * **/etc/bluetooth/audio.conf**
    ```[General] Enable=Source,Sink,Media,Socket```
  * **/etc/pulse/daemon.conf**
    ```resample-method = trivial```
