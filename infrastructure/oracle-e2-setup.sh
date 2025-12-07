#!/bin/bash

# Oracle Cloud E2 Instance Setup Script
# Part of Aqmal's Hybrid Cloud Homelab Project
# Purpose: Automated setup of Docker, Docker Compose, and n8n

set -e  # Exit on any error

echo "🚀 Starting Oracle Cloud E2 Instance Setup..."

# Phase 1: System Update
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Phase 2: Install Dependencies
echo "🔧 Installing required dependencies..."
sudo apt install -y \
    curl \
    wget \
    ca-certificates \
    gnupg \
    lsb-release \
    git \
    vim

# Phase 3: Docker Installation
echo "🐳 Installing Docker Engine..."
# Remove existing installations
sudo apt remove -y docker docker-engine docker.io containerd runc
sudo apt autoremove -y

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Phase 4: Docker User Configuration
echo "👤 Configuring Docker user permissions..."
sudo usermod -aG docker ubuntu
newgrp docker

# Phase 5: Install Docker Compose (Standalone)
echo "🔗 Installing Docker Compose standalone..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Phase 6: Verify Installation
echo "✅ Verifying Docker installation..."
sudo systemctl enable docker
sudo systemctl start docker
docker --version
docker compose version

# Phase 7: Create n8n Directory
echo "📁 Creating n8n workspace..."
mkdir -p /home/ubuntu/n8n-homelab
cd /home/ubuntu/n8n-homelab

# Phase 8: Create Docker Compose Configuration
echo "📝 Creating Docker Compose configuration..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n-automation
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      # Note: Add authentication in production
      # - N8N_BASIC_AUTH_ACTIVE=true
      # - N8N_BASIC_AUTH_USER=admin
      # - N8N_BASIC_AUTH_PASSWORD=secure-password
    volumes:
      # Uncomment for data persistence
      # - n8n_data:/home/node/.n8n
    networks:
      - n8n-network

networks:
  n8n-network:
    driver: bridge

# Uncomment for data persistence
# volumes:
#   n8n_data:
EOF

# Phase 9: Launch n8n Service
echo "🚀 Starting n8n service..."
docker compose up -d

# Phase 10: Wait for Service to Start
echo "⏳ Waiting for n8n to start..."
sleep 30

# Phase 11: Verify Service Status
echo "🔍 Verifying service status..."
docker compose ps
docker compose logs n8n --tail=20

# Phase 12: Network Configuration
echo "🌐 Checking network connectivity..."
curl -I http://localhost:5678 || echo "⚠️ n8n not yet accessible, waiting..."
sleep 10
curl -I http://localhost:5678 && echo "✅ n8n is accessible!"

# Phase 13: Display Access Information
echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo "📊 Service Status:"
echo "   - Docker: $(docker --version)"
echo "   - Docker Compose: $(docker compose version)"
echo "   - n8n Container: $(docker ps --filter 'name=n8n-automation' --format 'table {{.Names}}\t{{.Status}}')"
echo ""
echo "🌐 Access Information:"
echo "   - Local: http://localhost:5678"
echo "   - Public: http://$(curl -s ifconfig.me):5678"
echo "   - Domain: http://n8n.aqmal.site:5678"
echo ""
echo "📝 Next Steps:"
echo "   1. Configure domain DNS to point to this instance"
echo "   2. Set up Oracle Cloud API credentials"
echo "   3. Create n8n workflow for ARM instance automation"
echo "   4. Implement security measures (authentication, HTTPS)"
echo ""
echo "🔧 Useful Commands:"
echo "   - View logs: docker compose logs -f n8n"
echo "   - Restart service: docker compose restart n8n"
echo "   - Stop service: docker compose down"
echo "   - Update n8n: docker compose pull && docker compose up -d"
echo ""

# Phase 14: Cleanup
echo "🧹 Cleaning up installation files..."
cd /home/ubuntu
rm -rf /tmp/docker-install*

echo "✅ Oracle Cloud E2 Instance Setup Complete!"
echo "🚀 Ready for n8n workflow automation!"