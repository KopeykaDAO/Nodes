#!/bin/bash

HOME_DIR=$(eval echo ~$USER)

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
