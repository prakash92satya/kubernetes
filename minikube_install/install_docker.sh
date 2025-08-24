#!/bin/bash

# Update Ubuntu
echo "1. Updating Ubuntu..."
sudo apt-get update -y

# Install Docker
echo "2. Installing Docker..."
sudo apt-get install docker.io -y
sudo usermod -aG docker $USER && newgrp docker