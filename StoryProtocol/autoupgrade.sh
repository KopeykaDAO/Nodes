#!/bin/bash

echo -e "\n\n \033[0;35m=====Installing cosmovisor by KopeykaDAO=====\033[0m \n\n"

cd ~/
wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.profile
if [ -e ".zshrc" ] || [ -x ".zshrc" ]; then
        if ! grep -q "source .profile" ".zshrc"; then
                echo "source .profile" >> ".zshrc"
        fi
fi

rm go1.23.2.linux-amd64.tar.gz

source $HOME/.profile

go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest

echo "export DAEMON_NAME=story" >> $HOME/.profile
echo "export DAEMON_HOME=~/.story/story" >> $HOME/.profile
echo "export DAEMON_DATA_BACKUP_DIR=~/.story/story/cosmovisor/backup" >> $HOME/.profile
source $HOME/.profile

sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Client
After=network.target

[Service]
User=vpsuser
Type=simple
WorkingDirectory=/home/vpsuser/.story/story
ExecStart=/home/vpsuser/story/story/story run
Restart=always
RestartSec=3
LimitNOFILE=infinity
LimitNPROC=infinity
Environment="DAEMON_NAME=story"
Environment="DAEMON_HOME=$HOME/.story/story"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=true"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_DATA_BACKUP_DIR=$HOME/.story/story/cosmovisor/backup"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload 
sudo systemctl restart story

cosmovisor init $HOME/story/story/story
mkdir -p $HOME/.story/story/cosmovisor/upgrades
mkdir -p $HOME/.story/story/cosmovisor/backup

echo -e "\n\n \033[0;32m===============Version of your node===============\033[0m"

cosmovisor run version

echo -e "\n\n"

mkdir ~/story/story/upgrade
wget -O story.tar.gz $(curl -s https://api.github.com/repos/piplabs/story/releases/latest | jq .body | grep -oP '(?<=\[Linux 64-Bit Intel AMD \(x86_64\)\]\().*?(?=\))')
tar --strip-components=1 -xzf story.tar.gz -C ~/story/story/upgrade
rm story.tar.gz

cosmovisor add-upgrade v0.11.0 $HOME/story/story/upgrade/story --upgrade-height 1325860 --force
