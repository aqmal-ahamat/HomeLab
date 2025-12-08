# 🚀 Oracle Cloud E2 Instance Setup Guide

## Overview

Complete setup guide for Oracle Cloud Free Tier E2 instance to serve as automation hub for ARM instance provisioning. This instance runs Docker, n8n, and custom JavaScript workflows with proper Oracle Cloud API authentication.

## Prerequisites

- Oracle Cloud Free Tier account with API keys generated
- SSH key pair configured for instance access
- Domain name (optional, for n8n web interface)
- Basic Linux command line knowledge

---

## Step-by-Step Setup

### Phase 1: Oracle Cloud Instance Creation

#### 1.1 Instance Configuration
- **Region**: Mumbai (in-mum-1) - closest to your location
- **Instance Name**: e2
- **Shape**: VM.Standard.E2.1.Micro (1 OCPU, 1GB RAM)
- **Operating System**: Ubuntu 24.04.3 LTS
- **Storage**: 50GB Block Volume
- **Networking**: Default VCN with public IP

#### 1.2 Security Rules Configuration
In Oracle Cloud Console → Networking → Security Lists:
```bash
# Ingress Rules to Add:
Port 22   | TCP | Source: 0.0.0.0/0  | SSH Access
Port 5678 | TCP | Source: 0.0.0.0/0  | n8n Web Interface
```

#### 1.3 SSH Access Setup
```bash
# Connect to your instance
ssh -i ~/.ssh/your-key.pem ubuntu@<public-ip>

# Update system immediately
sudo apt update && sudo apt upgrade -y
```

### Phase 2: Docker Installation

#### 2.1 Install Docker Engine
```bash
# Remove existing Docker installations
sudo apt remove -y docker docker-engine docker.io containerd runc

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### 2.2 Configure Docker Permissions
```bash
# Add user to docker group
sudo usermod -aG docker ubuntu

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Test Docker installation
docker --version
docker compose version
```

### Phase 3: n8n Deployment

#### 3.1 Create Project Directory
```bash
mkdir -p /home/ubuntu/n8n-homelab
cd /home/ubuntu/n8n-homelab
```

#### 3.2 Docker Compose Configuration
Create `docker-compose.yml`:
```yaml
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n-automation-hub
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_EXECUTIONS_DATA_SAVE_ON_ERROR=all
      - N8N_EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
      - N8N_METRICS=true
    networks:
      - n8n-network

networks:
  n8n-network:
    driver: bridge
```

#### 3.3 Launch n8n Service
```bash
# Start n8n container
docker compose up -d

# Verify service status
docker compose ps
docker compose logs n8n --tail=10

# Wait for service to be ready
sleep 30
curl -I http://localhost:5678
```

### Phase 4: Domain Configuration (Optional)

#### 4.1 Domain Setup
- **Domain Provider**: Namecheap
- **Domain**: aqmal.site
- **DNS Record**: A record pointing to E2 public IP
- **Subdomain**: n8n.aqmal.site → E2 public IP

#### 4.2 Access Verification
```bash
# Test domain resolution
nslookup n8n.aqmal.site

# Test web interface
curl -I http://n8n.aqmal.site:5678
```

### Phase 5: Oracle Cloud API Setup

#### 5.1 Generate API Keys
In Oracle Cloud Console → Identity → Users → API Keys:
1. Click "Add API Key"
2. Download private key file
3. Copy configuration details
4. Save fingerprint and user ID

#### 5.2 Required Configuration Values
```bash
# You will need these values for the JavaScript workflow:
- Tenancy OCID
- User OCID  
- Key Fingerprint
- Private Key (PEM format)
- Region identifier
- Availability Domain
- Compartment OCID
- Subnet OCID
- Image OCID (for ARM instances)
- SSH Public Key
```

#### 5.3 Security Considerations
⚠️ **Important**: Store API credentials securely:
```bash
# Use environment variables instead of hardcoding
export OCI_TENANCY_ID="ocid1.tenancy.oc1..aaaa..."
export OCI_USER_ID="ocid1.user.oc1..aaaa..."
export OCI_PRIVATE_KEY_FILE="/path/to/private.key"
export OCI_FINGERPRINT="79:81:11:00:42:a1:4a:25:b5:78:7a:38:8c:96:1f:a1"
```

### Phase 6: JavaScript Workflow Integration

#### 6.1 Node.js Dependencies
```bash
# Install Node.js in n8n container (if needed)
docker exec -it n8n-automation-hub bash
npm install crypto
```

#### 6.2 Import JavaScript Workflow
1. Access n8n web interface: http://n8n.aqmal.site:5678
2. Create new workflow
3. Add "Execute Command" node
4. Paste JavaScript code with proper OCI API authentication
5. Set schedule trigger for every 3 minutes
6. Test workflow execution

#### 6.3 Advanced Authentication Method
The JavaScript implements proper Oracle Cloud API authentication:
- **RSA-SHA256 cryptographic signatures**
- **Request signing with private key**
- **Proper header generation**
- **Body hash calculation**
- **Timestamp-based authentication**

---

## Verification Commands

### Service Status Checks
```bash
# Check Docker containers
docker ps

# Check n8n logs
docker compose logs -f n8n

# Check system resources
free -h
df -h
top

# Check network connectivity
curl -I http://localhost:5678
curl -I http://n8n.aqmal.site:5678
```

### Oracle Cloud API Test
```bash
# Test API connectivity from instance
curl -I https://iaas.ap-mumbai-1.oraclecloud.com

# Verify DNS resolution
nslookup iaas.ap-mumbai-1.oraclecloud.com
```

---

## Troubleshooting

### Common Issues

#### Docker Issues
```bash
# Permission denied
sudo usermod -aG docker ubuntu
# Log out and log back in

# Port already in use
sudo lsof -i :5678
sudo kill -9 <PID>
```

#### n8n Issues
```bash
# Container not starting
docker compose logs n8n

# Access denied
check firewall rules in Oracle Cloud console
```

#### Oracle Cloud API Issues
```bash
# Authentication errors
- Verify API key format
- Check system time synchronization
- Validate request signature method

# Network issues
- Verify region endpoint
- Check security list rules
- Test network connectivity
```

---

## Performance Optimization

### System Tuning
```bash
# Optimize for container workloads
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Set up log rotation
sudo apt install logrotate
```

### Docker Optimization
```bash
# Clean up unused resources
docker system prune -f
docker image prune -f

# Monitor resource usage
docker stats
```

---

## Security Hardening

### Immediate Actions
```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Configure firewall (ufw)
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 5678

# Secure SSH access
sudo vim /etc/ssh/sshd_config
# Add: PermitRootLogin no, PasswordAuthentication no
sudo systemctl restart ssh
```

### n8n Security
```yaml
# Add to docker-compose.yml:
environment:
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_BASIC_AUTH_USER=admin
  - N8N_BASIC_AUTH_PASSWORD=secure-password
```

### Oracle Cloud Security
- Use OCI Vault for credential management
- Implement least privilege access
- Regular key rotation
- Monitor API usage and logs

---

## Maintenance

### Regular Tasks
```bash
# Weekly system updates
sudo apt update && sudo apt upgrade -y

# Monthly Docker cleanup
docker system prune -f

# Log rotation
sudo logrotate /etc/logrotate.conf
```

### Monitoring
```bash
# Set up basic monitoring
docker run -d \
  --name=cadvisor \
  -p 8080:8080 \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:ro \
  -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  gcr.io/cadvisor/cadvisor:latest
```

---

## Next Steps

1. **Implement proper credential management** (OCI Vault, environment variables)
2. **Add SSL/TLS encryption** for n8n web interface
3. **Set up monitoring and alerting** for the automation workflow
4. **Create backup and disaster recovery** procedures
5. **Document API rate limits** and implement retry logic
6. **Add logging and metrics** for workflow performance

---

*Last Updated: December 7, 2025*  
*Part of Aqmal's Hybrid Cloud Homelab Project* 🏠☁️