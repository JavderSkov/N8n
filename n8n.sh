#!/bin/bash

# Exit on any error
set -e

echo "Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "Adding Docker's official GPG key..."
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Starting and enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to the docker group so sudo isn't needed for docker commands
sudo usermod -aG docker "$USER"

echo "Setting up n8n..."
# Create a Docker volume for n8n data persistence
sudo docker volume create n8n_data

# Run the n8n container
echo "Starting n8n container..."
sudo docker run -d \
  --name n8n \
  --restart unless-stopped \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  docker.n8n.io/n8nio/n8n

echo "================================================================================"
echo "Installation complete!"
echo "Docker and n8n have been successfully installed and started."
echo ""
echo "You can access n8n in your browser at: http://<your-server-ip>:5678"
echo "If running locally, use: http://localhost:5678"
echo ""
echo "Note: To use Docker without sudo in the future, please log out and log back in."
echo "================================================================================"
