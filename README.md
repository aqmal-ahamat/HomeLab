# 🏠 Hybrid Cloud Homelab Project

---

## 🎯 Project Vision

Creating a hybrid cloud homelab that combines on-premises hardware with public cloud resources, orchestrated through Kubernetes. This project serves as both a learning platform and a portfolio piece demonstrating enterprise-level infrastructure and security skills.

## 🌐 Architecture Overview

```
Local Cloud (Asus + Victus)    ←→    Public Cloud (Oracle + Azure)
         │                                   │
    ┌───▼───┐                           ┌───▼───┐
    │ Services  │                           │ Services  │
    │ Docker/K8s│                           │ Automation│
    └─────────┘                           └─────────┘
```

## 🏗️ Core Components

- **Local Infrastructure**: Docker, Kubernetes, networking
- **Cloud Resources**: Oracle Cloud E2 + ARM, Azure integration
- **Automation**: n8n workflows, API integrations
- **Security**: TLS/HTTPS, monitoring, access control
- **Documentation**: Live journaling + GitHub portfolio

## 🏗️ Implementation Status

### ✅ Completed

- Oracle Cloud E2 instance with n8n automation
- Caddy reverse proxy with automatic HTTPS/TLS
- Professional documentation structure
- Machine-based file organization

### 🔄 Next Phase

- Network configuration and hybrid architecture
- Local infrastructure setup (Asus + Victus)
- Kubernetes cluster deployment

## 📁 Project Structure

```
homelab/
├── README.md              # Project overview (static)
├── docs/                   # Portfolio documentation
├── infrastructure/           # Setup scripts & configs
├── scripts/                 # Automation scripts
├── monitoring/              # Dashboards & alerts
├── security/               # Security policies & tools
└── notion/                 # Live journaling workspace
```

## 🎓 Learning Journey

This project is a continuous learning experience in:

- **Cloud Engineering**: Multi-cloud architecture and automation
- **Infrastructure as Code**: Docker, Kubernetes, automation
- **Security**: Zero Trust, TLS implementation, monitoring
- **Problem Solving**: Creative solutions to real-world constraints
- **Documentation**: Technical writing and knowledge sharing

## 🏆 Career Impact

Building practical skills for **Cloud Security Engineer** role:

- Enterprise-grade system design
- Production-ready security implementation
- Automation and orchestration expertise
- Multi-cloud platform experience
- Professional documentation practices

---

*Part of Aqmal's Cloud Engineering Journey* 🏠☁️

*Project Start: November 30, 2025*  
*Final Overview: December 8, 2025*