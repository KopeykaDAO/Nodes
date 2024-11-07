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

sudo systemctl stop story geth

# backup priv_validator_state.json
cp $HOME/.story/story/data/priv_validator_state.json $HOME/.story/story/priv_validator_state.json.backup

# remove old data and unpack Story snapshot
rm -rf $HOME/.story/story/data
curl https://server-1.itrocket.net/testnet/story/story_2024-11-07_375285_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/story

# restore priv_validator_state.json
mv $HOME/.story/story/priv_validator_state.json.backup $HOME/.story/story/data/priv_validator_state.json

# delete geth data and unpack Geth snapshot
rm -rf $HOME/.story/geth/odyssey/geth/chaindata
curl https://server-1.itrocket.net/testnet/story/geth_story_2024-11-07_375285_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.story/geth/odyssey/geth

# restart node and check logs
sudo systemctl restart story geth
sudo journalctl -u geth -u story -f
