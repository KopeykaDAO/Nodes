#!/bin/bash

SCRIPT_NAME="request_gaia.py"

GITHUB_URL="https://raw.githubusercontent.com/KopeykaDAO/Nodes/main/gaianet/request_gaia.py"

echo "Downloading script from GitHub..."
curl -o $SCRIPT_NAME $GITHUB_URL

if [ ! -f $SCRIPT_NAME ]; then
    echo "Failed to download script."
    exit 1
fi

read -p "Enter the ADDRESS: " ADDRESS

NODE_URL="https://$ADDRESS.us.gaianet.network/v1/chat/completions"

echo "Updating NODE_URL in the script..."
sed -i "s|NODE_URL = .*|NODE_URL = \"$NODE_URL\"|" $SCRIPT_NAME

if ! grep -q "$USER_NODE_URL" "$SCRIPT_NAME"; then
    echo "Failed to update NODE_URL in the script."
    exit 1
fi

curl -o Dockerfile https://raw.githubusercontent.com/KopeykaDAO/Nodes/main/gaianet/Dockerfile


echo "Building Docker image..."
docker build -t script_runner .

echo "Running Docker container..."
docker run --name gaianet_chat --restart unless-stopped  -d script_runner

sleep 5
docker exec -it gaianet_chat tail -f -n 20 chat_log.txt
