#!/bin/bash
clear

wac-cli stop

sleep 10

rm -rf ~/.wac/blocks
rm -rf ~/.wac/database
rm -rf ~/.wac/chainstate
rm -rf ~/.wac/peers.dat

cp ~/.wac/wac.conf ~/.wac/wac.conf.backup
sed -i '/^addnode/d' ~/.wac/wac.conf
cat <<EOL >>  ~/.wac/wac.conf
EOL

wacd
