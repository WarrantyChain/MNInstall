#!/bin/bash

# Limit this script to being used as a root user.
if [[ $EUID -eq 0 ]]; then
  echo "This script must NOT be run as root" 1>&2
  exit 1
fi

# Set these to change the version of wac to install
TARBALLURL="https://github.com/WarrantyChain/WAC/releases/download/v1.0.0.0/ubuntu16.04-daemon.zip"
TARBALLNAME="ubuntu16.04-daemon.zip"
wacVERSION="1.0.0.0"
# Get our current IP
EXTERNALIP=$(curl -s4 api.ipify.org)
clear

STRING1="Make sure you double check before hitting enter! Only one shot at these!"
STRING2="If you found this helpful, please donate: "
STRING3="XHEUZuevQUEuoPoiJSfMsNtV9DCkqZJhGP in XDNA or 18E4Z14XmzK4ES4qTtgL1DaqCJFBWKnTs9 in BTC"
STRING4="Updating system and installing required packages."
STRING5="Switching to Aptitude"
STRING6="Some optional installs"
STRING7="Starting your masternode"
STRING8="Now, you need to finally start your masternode in the following order:"
STRING9="Go to your windows wallet and from the Control wallet Console please enter"
STRING10="startmasternode alias false <mymnalias>"
STRING11="where <mymnalias> is the name of your masternode alias (without brackets)"
STRING12="once completed please return to VPS and press the space bar"
STRING13=""
STRING14="Please Wait a minimum of 5 minutes before proceeding, the node wallet must be synced"

echo $STRING1

read -e -p "Masternode Private Key (e.g. 88slDBwobwx6u9NfBwjS6y7dL8f6Rtnv31wwj1qJPNALYNnLt8 # THE KEY YOU GENERATED EARLIER) : " key
read -e -p "Install Fail2ban? [Y/n] : " install_fail2ban
read -e -p "Install UFW and configure ports? [Y/n] : " UFW

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

# update package and upgrade Ubuntu
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y autoremove
sudo apt-get -y install wget nano htop
sudo apt-get -y install build-essential libtool bsdmainutils autotools-dev autoconf pkg-config automake python3 libssl-dev libgmp-dev libevent-dev libboost-all-dev libminiupnpc-dev libzmq3-dev
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev unzip
clear
echo $STRING5
sudo apt-get -y install aptitude

#Generating Random Passwords
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
password2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

echo $STRING6
if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
  cd ~
  sudo aptitude -y install fail2ban
  sudo service fail2ban restart
fi
if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
  sudo apt-get -y install ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh
  sudo ufw allow 29281/tcp
  sudo ufw enable -y
fi

#Install wac Daemon
wget $TARBALLURL
sudo unzip $TARBALLNAME
sudo rm $TARBALLNAME
sudo cp wacd /usr/local/bin
sudo cp wac-cli /usr/local/bin
cd /usr/local/bin
sudo chmod +x /usr/local/bin/wacd
sudo chmod +x /usr/local/bin/wac-cli
wacd -daemon
sleep 60
wac-cli stop
clear

#Setting up coin
clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10

#Create wac.conf
echo '
rpcuser='$password'
rpcpassword='$password2'
listen=1
server=1
daemon=1
logtimestamps=1
masternodeprivkey='$key'
masternode=1
' | sudo -E tee ~/.wac/wac.conf >/dev/null 2>&1
chmod 0600 ~/.wac/wac.conf

#Starting coin
(
  crontab -l 2>/dev/null
  echo '@reboot sleep 30 && wacd -daemon -shrinkdebugfile'
) | crontab
(
  crontab -l 2>/dev/null
  echo '@reboot sleep 60 && wac-cli startmasternode local false'
) | crontab
wacd -daemon

clear
echo $STRING2
echo $STRING13
echo $STRING3
echo $STRING13
echo $STRING4
sleep 10
echo $STRING7
echo $STRING13
echo $STRING8
echo $STRING13
echo $STRING9
echo $STRING13
echo $STRING10
echo $STRING13
echo $STRING11
echo $STRING13
echo $STRING12
echo $STRING14
sleep 5m

read -p "Press any key to continue... " -n1 -s
wac-cli startmasternode local false
wac-cli masternode status
