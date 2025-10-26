# ModelKit Edge Deployment - Playbook C

This directory contains the edge/single host deployment solution for ModelKit, demonstrating how to deploy and rollback ML models on edge devices.

## 🏗️ Architecture

- **Docker-based deployment** for consistency across edge devices
- **Hub's Deploy command** integration for model distribution
- **Systemd service management** for production edge devices
- **Tag allowlist governance** for security and compliance
- **Stop → Swap → Start** rollback pattern

## 📁 Files Overview

### Core Files
- `Dockerfile` - Edge-optimized container image
- `docker-compose.yml` - Development and testing
- `modelkit-edge.service` - Systemd service template

### Management Scripts
- `deploy.sh` - Deploy using Hub's Deploy command
- `start-service.sh` - Start the edge service
- `stop-service.sh` - Stop the edge service
- `rollback.sh` - Rollback to previous version
- `demo-edge.sh` - Complete demonstration script

### Configuration
- `governance.conf` - Tag allowlist and policies

## 🚀 Quick Start

### Prerequisites
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install KitOps CLI
wget -O /usr/local/bin/kitops https://github.com/kitops-ml/kitops/releases/latest/download/kitops-linux-amd64
chmod +x /usr/local/bin/kitops
```

### Deploy Initial Version
```bash
# Deploy v7 (current production)
./deploy.sh v7

# Check status
curl http://localhost:8000/health
curl http://localhost:8000/version
```

### Rollback to Previous Version
```bash
# Rollback to v3 (good version)
./rollback.sh v3

# Verify rollback
curl http://localhost:8000/version
```

## 🎯 Rollback Methods

### Method 1: Stop → Swap → Start
```bash
# Stop current service
./stop-service.sh

# Update MODELKIT_REF environment
export MODELKIT_REF="jozu.ml/arnabchat2001/modelkit-demo:v3"

# Start with new version
./start-service.sh
```

### Method 2: Direct Rollback Script
```bash
# Automated rollback
./rollback.sh v3
```

### Method 3: Systemd Service Management
```bash
# Install service
sudo cp modelkit-edge.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable modelkit-edge

# Start service
sudo systemctl start modelkit-edge

# Rollback (reload with new config)
sudo systemctl reload modelkit-edge
```

## 🔒 Governance

### Tag Allowlist
The `governance.conf` file defines allowed tags:
```bash
ALLOWED_TAGS=(
    "v3"    # Good/stable version
    "v7"    # Current production version
    "v2"    # Previous stable version
)
```

### Security Policies
- Only allowlisted tags can be deployed
- Signature verification (configurable)
- Local build restrictions
- Image age limits

## 🧪 Testing

### Run Complete Demo
```bash
./demo-edge.sh
```

### Manual Testing
```bash
# Test health endpoint
curl http://localhost:8000/health

# Test version endpoint
curl http://localhost:8000/version

# Test chat API
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello from edge!"}'

# Test model info
curl http://localhost:8000/model/info
```

## 🏭 Production Deployment

### Systemd Service Setup
```bash
# Create user and directories
sudo useradd -r -s /bin/false modelkit
sudo mkdir -p /var/lib/modelkit/{model,app}
sudo mkdir -p /opt/modelkit-edge/logs
sudo chown -R modelkit:modelkit /var/lib/modelkit /opt/modelkit-edge

# Install service
sudo cp modelkit-edge.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable modelkit-edge
sudo systemctl start modelkit-edge
```

### Docker Compose (Development)
```bash
# Start with docker-compose
docker-compose up -d

# Check logs
docker-compose logs -f

# Stop
docker-compose down
```

## 🔧 Troubleshooting

### Service Not Starting
```bash
# Check container logs
docker logs modelkit-edge

# Check systemd logs
sudo journalctl -u modelkit-edge -f

# Check health
curl http://localhost:8000/health
```

### Rollback Issues
```bash
# Check allowed tags
grep ALLOWED_TAGS governance.conf

# Manual rollback
docker stop modelkit-edge
docker rm modelkit-edge
export MODELKIT_REF="jozu.ml/arnabchat2001/modelkit-demo:v3"
./start-service.sh
```

### Network Issues
```bash
# Check port binding
docker ps | grep modelkit-edge

# Test local connectivity
curl http://localhost:8000/health

# Check firewall
sudo ufw status
```

## 📊 Monitoring

### Health Checks
- Built-in health check endpoint: `/health`
- Docker health check every 30 seconds
- Systemd service monitoring

### Logs
- Application logs: `/opt/modelkit-edge/logs/`
- Docker logs: `docker logs modelkit-edge`
- Systemd logs: `journalctl -u modelkit-edge`

### Metrics
- Service uptime
- Model version tracking
- Health check success rate
- Rollback frequency

## 🎉 Key Features

✅ **Hub Integration**: Uses `jozu.ml/<ns>/<kit>/<runtime>:<tag>` format  
✅ **Stop → Swap → Start**: Simple rollback pattern  
✅ **Tag Governance**: Allowlist of blessed tags  
✅ **Systemd Support**: Production service management  
✅ **Docker Compose**: Development environment  
✅ **Health Monitoring**: Built-in health checks  
✅ **Security**: Restricted deployments and policies  
✅ **Edge Optimized**: Minimal resource footprint  

This edge deployment solution provides a robust, secure, and manageable way to deploy ML models on edge devices with reliable rollback capabilities.
