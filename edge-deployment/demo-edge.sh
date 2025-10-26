#!/bin/bash
# ModelKit Edge Deployment Demo Script

set -e

echo "🎬 ModelKit Edge Deployment Demo"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show status
show_status() {
    echo -e "\n${BLUE}📊 Current Status:${NC}"
    if curl -f http://localhost:8000/health >/dev/null 2>&1; then
        VERSION=$(curl -s http://localhost:8000/version)
        HEALTH=$(curl -s http://localhost:8000/health)
        echo -e "   ${GREEN}✅ Service: Running${NC}"
        echo -e "   📋 Version: ${VERSION}"
        echo -e "   🏥 Health: ${HEALTH}"
    else
        echo -e "   ${RED}❌ Service: Not Running${NC}"
    fi
}

# Function to test API
test_api() {
    echo -e "\n${BLUE}🧪 Testing API:${NC}"
    echo "Health Check:"
    curl -s http://localhost:8000/health | jq . 2>/dev/null || curl -s http://localhost:8000/health
    echo ""
    echo "Version Check:"
    curl -s http://localhost:8000/version
    echo ""
    echo "Chat Test:"
    curl -s -X POST http://localhost:8000/chat \
        -H "Content-Type: application/json" \
        -d '{"message": "Hello from edge device!"}'
    echo ""
}

# Main demo flow
echo -e "\n${YELLOW}Step 1: Deploy Initial Version (v7)${NC}"
echo "Using Hub's Deploy command: jozu.ml/arnabchat2001/modelkit-demo:v7"
./deploy.sh v7
show_status
test_api

echo -e "\n${YELLOW}Step 2: Demonstrate Rollback to v3${NC}"
echo "Rollback: stop → swap to previous tag → start"
./rollback.sh v3
show_status
test_api

echo -e "\n${YELLOW}Step 3: Demonstrate kubectl-style Rollback${NC}"
echo "Alternative: Update environment and restart"
export MODELKIT_REF="jozu.ml/arnabchat2001/modelkit-demo:v2"
./start-service.sh
show_status
test_api

echo -e "\n${YELLOW}Step 4: Show Governance${NC}"
echo "Allowed tags from governance.conf:"
grep "ALLOWED_TAGS" governance.conf

echo -e "\n${YELLOW}Step 5: Cleanup${NC}"
./stop-service.sh

echo -e "\n${GREEN}🎉 Edge Deployment Demo Complete!${NC}"
echo ""
echo "Key Features Demonstrated:"
echo "✅ Hub's Deploy command integration"
echo "✅ Stop → Swap → Start rollback pattern"
echo "✅ Tag allowlist governance"
echo "✅ Systemd service management"
echo "✅ Docker Compose for development"
echo "✅ Health checks and monitoring"
