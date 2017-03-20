# LoRa-Box

Just a script to setup your own LoRaWAN network.

## CONTENTS OF THIS FILE

1. [Introduction](#introduction)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Troubleshooting](troubleshooting)
6. [FAQ](#faq)
7. [Maintainers](#maintainers)

### 1. Introduction <a name="introduction"></a>

This script configures a system to be a LoRaWAN system running in the same hardware, it's based on the [The Things Network: iC880a-based gateway](https://github.com/ttn-zh/ic880a-gateway/) and [LoRaServer.io](https://www.loraserver.io). The mix of these two components are useful to create a self-contained box with all the requirements to setup a private LoRaWAN network. If you just want to create a gateway to be used with The Things Network, you have to switch to [ttn branch](https://github.com/rnicolas/lora-box/tree/ttn) and use that code.

### 2. Requirements <a name="requirements"></a>

In order to create a functional system you must have a RPi2/3 with Raspbian Jessie Lite installed with internet/intranet connection (it doesn't matter if it's by Ethernet or Wi-Fi or 3G) and updated, with the `git` package installed. An [iC880A - LoRaWAN Concentrator](https://wireless-solutions.de/products/radiomodules/ic880a.html) and RPi to iC880A interface, the three options considered by [ttn-zh](https://github.com/ttn-zh) are the following:

* Simple backplane: [Tindie](https://www.tindie.com/products/gnz/imst-ic880a-lorawan-backplane/)
* Advanced backplane: [pcbs.io](https://pcbs.io/share/zvoQ4)
* 7x Dual female jumper wires <sup>1</sup>

<sup>[1]</sup> Using any of the backplane boards listed instead of jumper wires is strongly recommended. Jumper wires can cause interference, and even thou the software will handle it, the performance of your gateway will be sub-optimal.

### 3. Installation <a name="installation"></a>

To install the LoRa-Box just clone this repository and start the installation:

	$ git clone https://github.com/rnicolas/lora-box.git ~/lora-box
	$ cd ~/lora-box
	$ chmod +x install.sh
	$ sudo ./install.sh

### 4. Configuration <a name="configuration"></a>

After the installation is completed and the system rebooted, you can go to https://IpOfTheBox:8080 and set your new LoRaWAN network. For more information, please visit [LoRa App Server](https://docs.loraserver.io/lora-app-server/).

### 5. Troubleshooting <a name="troubleshooting"></a>

For anything related on how LoRa Server (or its components) work, ask on [loraserver.io](https://www.loraserver.io) webpage. If you want to ask, request, find a bug, anything related with the script, just create a new issue.

### 6. FAQ <a name="faq"></a>

There aren't any FAQs yet.

### 7. Maintainers <a name="maintainers"></a>

Current maintainer:
* [Roger Nicolàs](https://github.com/rnicolas/)
