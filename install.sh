#!/bin/bash

# Stop on the first sign of trouble
set -e

if [ $UID != 0 ]; then
    echo "ERROR: Operation not permitted. Forgot sudo?"
    exit 1
fi

if [[ $1 != "" ]]; then VERSION=$1; fi

echo "LoRa Box installer"
echo
# Update the gateway installer to the correct branch
echo "Updating installer files..."
OLD_HEAD=$(git rev-parse HEAD)
git fetch
git checkout
git pull
NEW_HEAD=$(git rev-parse HEAD)
if [[ $OLD_HEAD != $NEW_HEAD ]]; then
    echo "New installer found. Restarting process..."
    exec "./install.sh" "$VERSION"
fi
# Disabling Blank Screen and PowerDown when Pi is not active.
echo "Disabling blank screen after 30 minutes of inactivity"
pushd /etc/kbd/
sed -i -e 's/BLANK_TIME=30/BLANK_TIME=0/g' ./config
echo "Disabling Automatic Power Off after 30 minutes of inactivity"
sed -i -e 's/POWERDOWN_TIME=30/POWERDOWN_TIME=0/g' ./config
popd
# Check dependencies
echo "Updating OS..."
apt-get update
apt-get -y upgrade
echo

echo "Activating SPI port on Raspberry PI"

pushd /boot
sed -i -e 's/#dtparam=spi=on/dtparam=spi=on/g' ./config.txt
popd

echo "Adding a script to power off RPi using pin 26"

pushd /usr/local/bin
if [ ! -f powerBtn.py ]
then
	wget https://raw.githubusercontent.com/rnicolas/Simple-Raspberry-Pi-Shutdown-Button/master/powerBtn.py
	sed -i -e '$i \python /usr/local/bin/powerBtn.py &\n' /etc/rc.local
fi

popd

# Request gateway configuration data
# There are two ways to do it, manually specify everything
# or rely on the gateway EUI and retrieve settings files from remote (recommended)
echo "Gateway configuration:"

# Try to get gateway ID from MAC address
# First try eth0, if that does not exist, try wlan0 (for RPi Zero)
GATEWAY_EUI_NIC="eth0"
if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
    GATEWAY_EUI_NIC="wlan0"
fi

if [[ `grep "$GATEWAY_EUI_NIC" /proc/net/dev` == "" ]]; then
    echo "ERROR: No network interface found. Cannot set gateway ID."
    exit 1
fi

GATEWAY_EUI=$(ip link show $GATEWAY_EUI_NIC | awk '/ether/ {print $2}' | awk -F\: '{print $1$2$3"FFFE"$4$5$6}')
GATEWAY_EUI=${GATEWAY_EUI^^} # toupper

echo "Detected EUI $GATEWAY_EUI from $GATEWAY_EUI_NIC"

# Setting personal configuration of LoRaWAN Gateway
printf "       Host name [lora-box]:"
read NEW_HOSTNAME
if [[ $NEW_HOSTNAME == "" ]]; then NEW_HOSTNAME="lora-box"; fi

printf "       Descriptive name [RPi-iC880A]:"
read GATEWAY_NAME
if [[ $GATEWAY_NAME == "" ]]; then GATEWAY_NAME="RPi-iC880A"; fi

printf "       Contact email: "
read GATEWAY_EMAIL

printf "       Latitude [0]: "
read GATEWAY_LAT
if [[ $GATEWAY_LAT == "" ]]; then GATEWAY_LAT=0; fi

printf "       Longitude [0]: "
read GATEWAY_LON
if [[ $GATEWAY_LON == "" ]]; then GATEWAY_LON=0; fi

printf "       Altitude [0]: "
read GATEWAY_ALT
if [[ $GATEWAY_ALT == "" ]]; then GATEWAY_ALT=0; fi

# Change hostname if needed
CURRENT_HOSTNAME=$(hostname)

if [[ $NEW_HOSTNAME != $CURRENT_HOSTNAME ]]; then
    echo "Updating hostname to '$NEW_HOSTNAME'..."
    hostname $NEW_HOSTNAME
    echo $NEW_HOSTNAME > /etc/hostname
    sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/" /etc/hosts
fi

# Install LoRaWAN packet forwarder repositories
INSTALL_DIR="/opt/lora-box"
if [ ! -d "$INSTALL_DIR" ]; then mkdir $INSTALL_DIR; fi
pushd $INSTALL_DIR

# Build LoRa gateway app
if [ ! -d lora_gateway ]; then
    git clone https://github.com/Lora-net/lora_gateway.git
    pushd lora_gateway
else
    pushd lora_gateway
    git reset --hard
    git pull
fi
make

popd

# Build packet forwarder
if [ ! -d packet_forwarder ]; then
    git clone https://github.com/Lora-net/packet_forwarder.git
    pushd packet_forwarder
else
    pushd packet_forwarder
    git pull
    git reset --hard
fi
make

popd
