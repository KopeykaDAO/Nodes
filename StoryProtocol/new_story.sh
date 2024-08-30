#!/bin/bash

HOME_DIR=$(eval echo ~$USER)

mkdir -p ~/story/geth
mkdir -p ~/story/story

cd ~/story

check_service_status() {
    local SERVICE_NAME=$1
    local SERVICE_STATUS=$(systemctl is-active $SERVICE_NAME)
    NO_COLOR='\033[0m'

    if [ "$SERVICE_STATUS" == "active" ]; then
        echo -e "\033[0;32mСлужба $SERVICE_NAME запущена и работает.${NO_COLOR}"
    elif [ "$SERVICE_STATUS" == "inactive" ]; then
        echo -e "\033[0;31mСлужба $SERVICE_NAME остановлена.${NO_COLOR}"
    elif [ "$SERVICE_STATUS" == "failed" ]; then
        echo -e "\033[0;31mСлужба $SERVICE_NAME завершилась с ошибкой.${NO_COLOR}"
    else
        echo -e "\033[0;31mСлужба $SERVICE_NAME находится в неизвестном состоянии: $SERVICE_STATUS${NO_COLOR}"
    fi
}


wget -O story-geth.tar.gz $(curl -s https://api.github.com/repos/piplabs/story-geth/releases/latest | jq .body | grep -oP '(?<=\[Linux 64-Bit Intel AMD \(x86_64\)\]\().*?(?=\))')
tar --strip-components=1 -xzf story-geth.tar.gz -C geth
rm story-geth.tar.gz

sudo tee /etc/systemd/system/geth.service > /dev/null <<EOF
[Unit]
Description=Geth Client
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=$HOME_DIR/story/geth/geth --iliad --syncmode full
Restart=always
RestartSec=3
LimitNOFILE=infinity
LimitNPROC=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable geth.service
sleep 2
sudo systemctl restart geth.service
check_service_status "geth.service"



wget -O story.tar.gz $(curl -s https://api.github.com/repos/piplabs/story/releases/latest | jq .body | grep -oP '(?<=\[Linux 64-Bit Intel AMD \(x86_64\)\]\().*?(?=\))')
tar --strip-components=1 -xzf story.tar.gz -C story
rm story.tar.gz

read -p "Enter your node name:  " MONKIER
~/story/story/story init --network iliad --moniker $MONKIER

sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Client
After=network.target

[Service]
User=$USER
Type=simple
WorkingDirectory=$HOME_DIR/.story/story
ExecStart=$HOME_DIR/story/story/story run
Restart=always
RestartSec=3
LimitNOFILE=infinity
LimitNPROC=infinity

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable story
sleep 2
sudo systemctl restart story
check_service_status "story.service"


sudo systemctl stop story
sudo systemctl stop geth
sudo apt-get install wget lz4 aria2 pv -y


cd $HOME
if curl -s --head https://vps5.josephtran.xyz/Story/Geth_snapshot.lz4 | head -n 1 | grep "200" > /dev/null; then
    echo "Snapshot found, downloading..."
    aria2c -x 16 -s 16 https://vps5.josephtran.xyz/Story/Geth_snapshot.lz4 -o Geth_snapshot.lz4
else
    echo "No snapshot found."
fi


cd $HOME
if curl -s --head https://vps5.josephtran.xyz/Story/Story_snapshot.lz4 | head -n 1 | grep "200" > /dev/null; then
    echo "Snapshot found, downloading..."
    aria2c -x 16 -s 16 https://vps5.josephtran.xyz/Story/Story_snapshot.lz4 -o Story_snapshot.lz4
else
    echo "No snapshot found."
fi

rm -rf ~/.story/story/data
rm -rf ~/.story/geth/iliad/geth/chaindata

mkdir -p ~/.story/story/data
lz4 -d Story_snapshot.lz4 | pv | sudo tar xv -C ~/.story/story/
mkdir -p ~/.story/geth/iliad/geth/chaindata
lz4 -d Geth_snapshot.lz4 | pv | sudo tar xv -C ~/.story/geth/iliad/geth/


sudo systemctl start story
sudo systemctl start geth
