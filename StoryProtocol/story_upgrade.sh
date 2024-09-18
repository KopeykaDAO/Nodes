#!/bin/bash

HOME_DIR=$(eval echo ~$USER)
cd ~/story
sudo systemctl stop story

rm story/story
wget -O story.tar.gz $(curl -s https://api.github.com/repos/piplabs/story/releases/latest | jq .body | grep -oP '(?<=\[Linux 64-Bit Intel AMD \(x86_64\)\]\().*?(?=\))')
tar --strip-components=1 -xzf story.tar.gz -C story
rm story.tar.gz
sudo systemctl start story
