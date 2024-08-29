#!/bin/bash

mkdir -p ~/story/geth
mkdir -p ~/story/story

cd ~/story

wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar --strip-components=1 -xzf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz -C geth
rm geth-linux-amd64-0.9.2-ea9f0d2.tar.gz

wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz
tar --strip-components=1 -xzf story-linux-amd64-0.9.11-2a25df1.tar.gz -C story
rm story-linux-amd64-0.9.11-2a25df1.tar.gz

sudo apt update
sudo apt install -y tmux

read -p "Enter your node name:  " MONKIER
~/story/story/story init --network iliad  --moniker $MONKIER

echo "Скрипт завершен. Воспользуйтесь следующими командами"
