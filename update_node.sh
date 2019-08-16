#!/bin/bash

TARBALLURL="https://github.com/WarrantyChain/WAC/releases/download/v1.0.0.0/ubuntu16.04-daemon.zip"
TARBALLNAME="ubuntu16-daemon.zip"
WACVERSION="1.0.0.0"

clear
echo "This script will update your masternode to version $WACVERSION"
read -p "Press Ctrl-C to abort or any other key to continue. " -n1 -s
clear
echo "Please enter your password to enter administrator mode:"
sudo true
echo "Shutting down masternode..."
wac-cli stop
echo "Installing wac $WACVERSION"
mkdir ./wac-temp && cd ./wac-temp
wget $TARBALLURL
unzip $TARBALLNAME
sudo rm $TARBALLNAME
yes | sudo cp -rf wacd /usr/local/bin
yes | sudo cp -rf wac-cli /usr/local/bin
sudo chmod +x /usr/local/bin/wacd
sudo chmod +x /usr/local/bin/wac-cli
cd ..
sed -i '/^addnode/d' ~/.wac/wac.conf
cat <<EOL >>  ~/.wac/wac.conf
EOL
echo "Restarting wac daemon..."
wacd
clear
read -p "Please wait at least 5 minutes for the wallet to load, then press any key to continue." -n1 -s
clear
echo "Starting masternode..." # TODO: Need to wait for wallet to load before starting...
wac-cli masternode status
