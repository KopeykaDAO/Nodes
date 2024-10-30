#!/bin/bash

HOME_DIR=$(eval echo ~$USER)
cd ~/story
sudo systemctl stop story geth

rm story/story
wget -O story.tar.gz $(curl -s https://github.com/piplabs/story/archive/refs/tags/v0.12.0.tar.gz | jq .body | grep -oP '(?<=\[Linux 64-Bit Intel AMD \(x86_64\)\]\().*?(?=\))')
tar --strip-components=1 -xzf story.tar.gz -C story
rm story.tar.gz

rm geth/geth
wget -O story-geth $(curl -s https://api.github.com/repos/piplabs/story-geth/releases/latest | jq -r '.assets[] | select(.name == "geth-linux-amd64") | .browser_download_url')
mv story-geth geth/geth
chmod +x geth/geth

sudo systemctl start story geth
