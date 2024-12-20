#!/bin/bash

HOME_DIR=$(eval echo ~$USER)
cd ~/story
sudo systemctl stop story geth

rm story/story
wget -O storyfile $(curl -s https://api.github.com/repos/piplabs/story/releases/latest | jq -r '.assets[] | select(.name == "story-linux-amd64") | .browser_download_url')
mv storyfile story/story
chmod +x story/story

rm geth/geth
wget -O story-geth $(curl -s https://api.github.com/repos/piplabs/story-geth/releases/latest | jq -r '.assets[] | select(.name == "geth-linux-amd64") | .browser_download_url')

mv story-geth geth/geth
chmod +x geth/geth

sudo systemctl start story geth
