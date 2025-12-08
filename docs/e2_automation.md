# 🌩️ Oracle Cloud E2 Automation Setup

## Project Overview

Creative solution to Oracle Cloud ARM instance capacity limitations using automated n8n workflow. This project demonstrates real-world problem-solving, cloud API integration, and persistent automation implementation.

### Problem Statement

Oracle Cloud Free Tier ARM instances (4 OCPU, 24GB RAM) are consistently "Out of Host Capacity" in Mumbai region, making manual provisioning attempts ineffective.

### Solution Implemented

Built an automated monitoring and provisioning system using:

- Oracle Cloud E2 instance as automation hub
- n8n workflow engine for continuous checking
- WhatsApp notifications for success alerts
- REST API integration with Oracle Cloud Infrastructure

---

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   n8n Workflow  │───►│ Oracle Cloud    │───►│ WhatsApp        │
│   (Every 3 min) │    │ REST API        │    │ Notification    │
│                 │    │                 │    │ (Success only)  │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │                 │
│ │ Bash Node   │ │    │ │ ARM Instance│ │    │                 │
│ │ + curl cmd  │ │    │ │ Creation    │ │    │                 │
│ └─────────────┘ │    │ └─────────────┘ │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │
         ▼                        ▼
┌─────────────────┐    ┌─────────────────┐
│ n8n.aqmal.site │    │ Oracle Cloud    │
│ (Web Interface) │    │ Console         │
└─────────────────┘    └─────────────────┘
```

---

## Step-by-Step Setup Guide

### Phase 1: Oracle Cloud Infrastructure

#### 1.1 Instance Creation

- **Region**: Mumbai (in-mum-1)
- **Instance Name**: e2
- **Shape**: VM.Standard.E2.1.Micro (1 OCPU, 1GB RAM)
- **OS**: Ubuntu 24.04.3 LTS
- **Storage**: 50GB Block Volume
- **SSH**: Default key pair authentication

#### 1.2 Network Configuration

- **Ingress Rules**:
  - Port 22 (SSH) - 0.0.0.0/0
  - Port 5678 (n8n) - 0.0.0.0/0
  - All other ports blocked by default

#### 1.3 Domain Setup

- **Domain**: aqmal.site (purchased from Namecheap)
- **DNS Configuration**: A record pointing to E2 public IP (80.255.218.255)
- **Subdomain**: n8n.aqmal.site for n8n interface

### Phase 2: Docker & n8n Installation

#### 2.1 System Update

```bash
sudo apt update && sudo apt upgrade -y
```

#### 2.2 Docker Installation

```bash
# Official Docker installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
```

#### 2.3 Docker Compose Setup

```bash
sudo apt install docker-compose-plugin -y
```

### Phase 3: n8n Deployment

#### 3.1 Docker Compose Configuration

Created `docker-compose.yml` with:

- n8n service on port 5678
- No authentication (public access)
- No data persistence volumes
- Auto-restart policy

#### 3.2 Service Launch

```bash
docker-compose up -d
```

#### 3.3 Access Verification

- **Direct IP**: http://80.255.218.255:5678
- **Domain**: http://n8n.aqmal.site:5678
- **Status**: ✅ Running and accessible

---

## n8n Workflow Implementation

### Workflow Architecture

- **Trigger**: Schedule (Every 3 minutes)
- **Processing**: JavaScript Code Node → Bash Execution Node
- **Logic**: Conditional branching based on API response
- **Notification**: WhatsApp integration for status updates

### Advanced Technical Implementation

#### Core Components

1. **Schedule Trigger**: Cron expression for 3-minute intervals
2. **JavaScript Code Node**: Generates cryptographically signed API requests
3. **Bash Execution Node**: Executes generated curl commands
4. **Conditional Logic**: Parses responses for success conditions
5. **WhatsApp Integration**: Dual-path notification system

#### Professional API Authentication

- **Method**: Oracle Cloud Infrastructure REST API v2
- **Authentication**: RSA-SHA256 cryptographic signatures
- **Security**: Proper request signing with private key
- **Compliance**: Official OCI API authentication standards

#### Cryptographic Implementation

The JavaScript workflow implements enterprise-grade authentication:

1. **Request Construction**: Builds proper OCI API request body
2. **Body Hashing**: SHA-256 hash of request payload
3. **Header Generation**: Creates signing headers with timestamps
4. **RSA Signature**: Cryptographic signing using private key
5. **cURL Generation**: Produces complete, authenticated API call

#### Advanced Features

- **Dynamic Instance Naming**: Timestamp-based unique identifiers
- **Proper JSON Formatting**: Compliant with OCI API specifications
- **Error Handling**: Comprehensive response parsing
- **Security Best Practices**: Implements official authentication methods

#### Notification System

- **Success Path**: WhatsApp notification on instance creation
- **Status Updates**: Regular updates for continued attempts
- **Error Handling**: Detailed error message reporting
- **Automation Transparency**: Full visibility into system status

---

## Security Considerations

### Current Implementation
⚠️ **Security Issues Identified**:
- **High Risk**: RSA private key embedded in JavaScript code
- **Exposure**: Public n8n interface without authentication
- **Credentials**: API configuration values hardcoded
- **Access**: Workflow accessible to anyone with domain access
- **Compliance**: Private key storage violates security best practices

✅ **Security Improvements Implemented**:
- **TLS/HTTPS**: Automatic HTTPS via Caddy reverse proxy
- **Certificates**: Let's Encrypt automatic certificate management
- **HTTP Redirect**: Automatic HTTP to HTTPS redirection
- **Security Headers**: HSTS, XSS protection, clickjacking prevention
- **Compression**: Zstandard + gzip compression enabled
- **Professional Setup**: Production-ready reverse proxy architecture

### Recommended Improvements

#### 1. Credential Management

```bash
# Environment variables instead of hardcoding
export OCI_API_KEY="your-api-key"
export OCI_USER_ID="your-user-id"
```

#### 2. n8n Security

```yaml
# Add basic authentication to docker-compose.yml
environment:
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_BASIC_AUTH_USER=admin
  - N8N_BASIC_AUTH_PASSWORD=secure-password
```

#### 3. Oracle Cloud Vault

- Store API keys in OCI Vault
- Use dynamic credential injection
- Implement key rotation policies

#### 4. Network Security

- IP whitelisting for n8n access
- VPN requirement for workflow management
- SSL/TLS certificate implementation

---

## Development Journey

### Debugging Process

- **Total Debugging Sessions**: ~20 iterations
- **Primary Issues**:
  - Oracle Cloud API authentication errors
  - Bash script syntax problems
  - curl parameter configuration
  - Response parsing logic

### Problem Resolution

1. **Authentication**: Fixed API key format and request headers
2. **Syntax**: Corrected bash quoting and variable expansion
3. **API Integration**: Properly formatted JSON request body
4. **Error Handling**: Added response validation logic

### Tools Used

- **AI Assistant**: Gemini for cryptographic implementation
- **Original Source**: Medium article concept conversion
- **Authentication**: Custom JavaScript with Node.js crypto module
- **API Method**: Oracle Cloud Infrastructure REST API v2
- **Testing**: Direct SSH execution before n8n integration
- **Monitoring**: n8n execution history and comprehensive logs

---

## Current Status & Performance

### Runtime Statistics

- **Start Date**: 4 days ago
- **Execution Frequency**: Every 3 minutes (480 times per day)
- **Total Executions**: ~1,920 attempts
- **Success Rate**: 0% (still awaiting capacity)
- **Uptime**: 100% (no service interruptions)

### Resource Utilization

- **CPU Usage**: Minimal (background automation)
- **Memory Usage**: Low (n8n + bash processes)
- **Network**: Regular API calls every 3 minutes
- **Storage**: 50GB allocated, minimal usage

### Capacity Patterns

- **Observation Period**: 4 days
- **Pattern Analysis**: No clear availability patterns detected
- **Geographic**: Mumbai region consistently at capacity
- **Time-based**: No specific time windows with availability

---

## Lessons Learned

### Technical Insights

1. **Cloud Capacity**: Free tier resources require persistent automation
2. **API Integration**: REST APIs provide reliable automation interfaces
3. **Error Handling**: Robust error handling essential for long-running processes
4. **Monitoring**: Continuous monitoring provides valuable operational data

### Problem-Solving Skills

1. **Creative Thinking**: Converted capacity limitation into automation opportunity
2. **Persistence**: 20 debugging sessions demonstrate commitment
3. **Resource Optimization**: Leveraged existing tools (n8n) effectively
4. **Documentation**: Systematic approach to problem resolution

### Security Awareness

1. **Credential Management**: Identified security vulnerabilities in implementation
2. **Access Control**: Recognized need for authentication and authorization
3. **Risk Assessment**: Understanding of public service exposure

---

## Future Enhancements

### Immediate Improvements

1. **Security Hardening**: Implement recommended security measures
2. **Monitoring Enhancement**: Add detailed logging and metrics
3. **Notification Expansion**: Multiple notification channels
4. **Regional Testing**: Test other Oracle Cloud regions

### Long-term Goals

1. **Multi-Cloud**: Expand to other cloud providers (AWS, Azure, GCP)
2. **Machine Learning**: Predict capacity availability patterns
3. **Cost Optimization**: Automated resource management and cleanup
4. **Portfolio Integration**: Showcase as part of cloud engineering portfolio

---

## Technical Specifications

### Oracle Cloud E2 Instance

- **Shape**: VM.Standard.E2.1.Micro
- **CPU**: 1 OCPU
- **Memory**: 1GB RAM
- **Storage**: 50GB Block Volume
- **Network**: 10 Gbps
- **Region**: in-mum-1 (Mumbai)

### Software Stack
- **Operating System**: Ubuntu 24.04.3 LTS
- **Container Runtime**: Docker Engine
- **Orchestration**: Docker Compose
- **Automation**: n8n workflow engine with JavaScript execution
- **Cryptography**: Node.js crypto module for RSA-SHA256 signatures
- **API Integration**: Oracle Cloud Infrastructure REST API v2
- **Authentication**: Enterprise-grade cryptographic request signing
- **Reverse Proxy**: Caddy 2 with automatic HTTPS/TLS
- **Certificates**: Let's Encrypt automatic certificate management
- **Security**: Production-ready TLS termination and security headers

### Network Configuration

- **Public IP**: 80.255.218.255
- **Domain**: n8n.aqmal.site:5678
- **Firewall**: Ports 22, 5678 open
- **DNS**: Namecheap managed

---

## Conclusion

This project demonstrates advanced cloud engineering skills through creative problem-solving and persistent automation. While the primary goal (ARM instance provisioning) remains pending due to capacity constraints, the journey has yielded valuable experience in:

- Cloud API integration and automation
- Workflow design and implementation
- Security vulnerability identification
- Systematic debugging and troubleshooting
- Documentation and knowledge sharing

The automation system continues to run successfully, ready to provision resources when capacity becomes available, while serving as an impressive portfolio piece demonstrating real-world cloud engineering capabilities.

## 🛡️ Security Implementation with Caddy

### TLS/HTTPS Setup
- **Automatic Certificates**: Let's Encrypt integration through Caddy
- **HTTPS Only**: Automatic HTTP to HTTPS redirection
- **Professional Security**: Production-ready TLS termination
- **Security Headers**: HSTS, XSS protection, clickjacking prevention
- **Compression**: Zstandard + gzip for performance

### Architecture Benefits
- **Reverse Proxy**: Caddy handles TLS/termination
- **Load Balancing**: Ready for multiple backend services
- **Certificate Management**: Automatic renewal and rotation
- **Monitoring**: Built-in logging and metrics
- **Scalability**: Easy to add additional services

This implementation transforms the setup from development-grade to enterprise-ready production system with automatic security and certificate management.

---

*Last Updated: December 7, 2025*  
*Part of Aqmal's Hybrid Cloud Homelab Project* 🏠☁️