#!/bin/bash

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
PINK='\033[1;35m'
NEXUS_HOME=$HOME/.nexus

show() {
    case $2 in
        "error")
            echo -e "${PINK}${BOLD}❌ $1${NORMAL}"
            ;;
        "progress")
            echo -e "${PINK}${BOLD}⏳ $1${NORMAL}"
            ;;
        *)
            echo -e "${PINK}${BOLD}✅ $1${NORMAL}"
            ;;
    esac
}

SERVICE_NAME="nexus"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

show "Installing Rust..." "progress"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
mkdir ~/.zfunc
rustup completions zsh > ~/.zfunc/_rustup


if ! command -v git &> /dev/null; then
    show "Git is not installed. Installing git..." "progress"
    if ! sudo apt install git protobuf-compiler -y; then
        show "Failed to install git." "error"
        exit 1
    fi
else
    show "Git is already installed."
fi

if [ -d "$HOME/network-api" ]; then
    show "Deleting existing repository..." "progress"
    rm -rf "$HOME/network-api"
fi

sleep 3

show "Cloning Nexus-XYZ network API repository..." "progress"
if ! git clone https://github.com/nexus-xyz/network-api.git "$HOME/network-api"; then
    show "Failed to clone the repository." "error"
    exit 1
fi

mkdir -p ~/.nexus
PROVER_ID=$(cat $NEXUS_HOME/prover-id 2>/dev/null)
if [ -z "$NONINTERACTIVE" ] && [ "${#PROVER_ID}" -ne "28" ]; then
    echo "\nTo receive credit for proving in Nexus testnets..."
    echo "\t1. Go to ${GREEN}https://beta.nexus.xyz${NC}"
    echo "\t2. On the bottom left hand corner, copy the ${ORANGE}prover id${NC}"
    echo "\t3. Paste the ${ORANGE}prover id${NC} here. Press Enter to continue.\n"
    read -p "Enter your Prover Id (optional)> " PROVER_ID </dev/tty
    while [ ! ${#PROVER_ID} -eq "0" ]; do
        if [ ${#PROVER_ID} -eq "28" ]; then
            if [ -f "$NEXUS_HOME/prover-id" ]; then
                echo Copying $NEXUS_HOME/prover-id to $NEXUS_HOME/prover-id.bak
                cp $NEXUS_HOME/prover-id $NEXUS_HOME/prover-id.bak
            fi
            echo "$PROVER_ID" > $NEXUS_HOME/prover-id
            echo Prover id saved to $NEXUS_HOME/prover-id.
            break;
        else
            echo Unable to validate $PROVER_ID. Please make sure the full prover id is copied.
        fi
        read -p "Prover Id (optional)> " PROVER_ID </dev/tty
    done
fi

cd $HOME/network-api/clients/cli

show "Installing required dependencies..." "progress"
if ! sudo apt install pkg-config libssl-dev -y; then
    show "Failed to install dependencies." "error"
    exit 1
fi

if systemctl is-active --quiet nexus.service; then
    show "nexus.service is currently running. Stopping and disabling it..."
    sudo systemctl stop nexus.service
    sudo systemctl disable nexus.service
else
    show "nexus.service is not running."
fi

show "Creating systemd service..." "progress"
if ! sudo bash -c "cat > $SERVICE_FILE <<EOF
[Unit]
Description=Nexus XYZ Prover Service
After=network.target

[Service]
User=$USER
WorkingDirectory=$HOME/network-api/clients/cli
Environment=NONINTERACTIVE=1
ExecStart=$HOME/.cargo/bin/cargo run --release --bin prover -- beta.orchestrator.nexus.xyz
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF"; then
    show "Failed to create the systemd service file." "error"
    exit 1
fi


show "Reloading systemd and starting the service..." "progress"
if ! sudo systemctl daemon-reload; then
    show "Failed to reload systemd." "error"
    exit 1
fi

if ! sudo systemctl start $SERVICE_NAME.service; then
    show "Failed to start the service." "error"
    exit 1
fi

if ! sudo systemctl enable $SERVICE_NAME.service; then
    show "Failed to enable the service." "error"
    exit 1
fi

show "Service status:" "progress"
if ! sudo systemctl status $SERVICE_NAME.service; then
    show "Failed to retrieve service status." "error"
fi

show "Nexus Prover installation and service setup complete!"
