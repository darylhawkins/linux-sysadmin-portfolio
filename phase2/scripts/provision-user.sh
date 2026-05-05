#!/bin/bash
set -euo pipefail

# Usage: ./provision-user.sh USERNAME PUBLIC_KEY_FILE [GROUP]
# Example: ./provision-user.sh alice ~/.ssh/alice.pub webteam

USERNAME="${1:?Usage: $0 USERNAME PUBLIC_KEY_FILE [GROUP]}"
KEY_FILE="${2:?Provide a public key file}"
GROUP="${3:-}"

[[ -f "$KEY_FILE" ]] || { echo "ERROR: Key file not found: $KEY_FILE"; exit 1; }

echo "Creating user: $USERNAME"
sudo useradd -m -s /bin/bash "$USERNAME"

echo "Setting up SSH directory"
sudo mkdir -p /home/$USERNAME/.ssh
sudo cp "$KEY_FILE" /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys

[[ -n "$GROUP" ]] && sudo usermod -aG "$GROUP" "$USERNAME"

echo "Done. $USERNAME can now log in with: ssh $USERNAME@$(hostname -I | cut -d' ' -f1)"
