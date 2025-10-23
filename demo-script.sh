#!/bin/bash

# ModelKit Demo Script - Helm Rollback Demonstration
# This script helps demonstrate the rollback process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHART_PATH="./helm-chart"
RELEASE_NAME="modelkit-demo"
NAMESPACE="default"

echo -e "${BLUE}🚀 ModelKit Demo - Helm Rollback Demonstration${NC}"
echo "=================================================="

# Function to check if Helm is installed
check_helm() {
    if ! command -v helm &> /dev/null; then
        echo -e "${RED}❌ Helm is not installed. Please install Helm first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Helm is installed${NC}"
}

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl is not available. Please ensure kubectl is configured.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ kubectl is available${NC}"
}

# Function to deploy initial version (v1 - BAD)
deploy_bad_version() {
    echo -e "\n${YELLOW}📦 Deploying BAD version (v1) using values-prod.yaml${NC}"
    helm upgrade --install $RELEASE_NAME $CHART_PATH \
        -f $CHART_PATH/values-prod.yaml \
        --namespace $NAMESPACE \
        --wait --timeout=300s
    
    echo -e "${GREEN}✅ BAD version deployed${NC}"
}

# Function to check current status
check_status() {
    echo -e "\n${BLUE}🔍 Checking current status...${NC}"
    
    # Get pod status
    echo -e "\n${YELLOW}Pod Status:${NC}"
    kubectl get pods -l app.kubernetes.io/name=modelkit-demo
    
    # Get service info
    echo -e "\n${YELLOW}Service Status:${NC}"
    kubectl get svc -l app.kubernetes.io/name=modelkit-demo
    
    # Check if we can get the version
    echo -e "\n${YELLOW}Model Version Check:${NC}"
    POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=modelkit-demo -o jsonpath='{.items[0].metadata.name}')
    if [ ! -z "$POD_NAME" ]; then
        echo "Pod: $POD_NAME"
        kubectl exec $POD_NAME -- curl -s localhost:8000/version || echo "Service not ready yet"
        kubectl exec $POD_NAME -- curl -s localhost:8000/health || echo "Health check not ready yet"
    else
        echo "No pods found"
    fi
}

# Function to demonstrate Helm rollback
helm_rollback() {
    echo -e "\n${YELLOW}🔄 Performing Helm rollback to v0 (GOOD version)${NC}"
    helm upgrade $RELEASE_NAME $CHART_PATH \
        --set modelkitRef=jozu.ml/arnabchat2001/modelkit-demo:v0 \
        --namespace $NAMESPACE \
        --wait --timeout=300s
    
    echo -e "${GREEN}✅ Helm rollback completed${NC}"
}

# Function to demonstrate kubectl rollback
kubectl_rollback() {
    echo -e "\n${YELLOW}🔄 Performing kubectl rollback to v0 (GOOD version)${NC}"
    kubectl set env deployment/$RELEASE_NAME MODELKIT_REF=jozu.ml/arnabchat2001/modelkit-demo:v0
    
    echo -e "${GREEN}✅ kubectl rollback initiated${NC}"
    echo -e "${BLUE}⏳ Waiting for rollout to complete...${NC}"
    kubectl rollout status deployment/$RELEASE_NAME --timeout=300s
}

# Function to verify rollback
verify_rollback() {
    echo -e "\n${BLUE}🔍 Verifying rollback...${NC}"
    sleep 10  # Give pods time to restart
    
    POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=modelkit-demo -o jsonpath='{.items[0].metadata.name}')
    if [ ! -z "$POD_NAME" ]; then
        echo -e "\n${YELLOW}Model Version:${NC}"
        kubectl exec $POD_NAME -- curl -s localhost:8000/version || echo "Service not ready"
        
        echo -e "\n${YELLOW}Health Status:${NC}"
        kubectl exec $POD_NAME -- curl -s localhost:8000/health || echo "Health check not ready"
        
        echo -e "\n${YELLOW}Model Info:${NC}"
        kubectl exec $POD_NAME -- curl -s localhost:8000/model/info || echo "Model info not ready"
    fi
}

# Main menu
show_menu() {
    echo -e "\n${BLUE}Demo Options:${NC}"
    echo "1. Deploy BAD version (v1)"
    echo "2. Check current status"
    echo "3. Helm rollback to v0"
    echo "4. kubectl rollback to v0"
    echo "5. Verify rollback"
    echo "6. Full demo (deploy → check → rollback → verify)"
    echo "7. Exit"
    echo -n "Choose an option (1-7): "
}

# Full demo function
full_demo() {
    echo -e "\n${BLUE}🎬 Starting Full Demo...${NC}"
    
    check_helm
    check_kubectl
    
    deploy_bad_version
    check_status
    
    echo -e "\n${RED}🚨 INCIDENT DETECTED: Model version is BAD!${NC}"
    echo -e "${YELLOW}Performing emergency rollback...${NC}"
    
    helm_rollback
    verify_rollback
    
    echo -e "\n${GREEN}🎉 Demo completed successfully!${NC}"
}

# Main script
main() {
    check_helm
    check_kubectl
    
    while true; do
        show_menu
        read -r choice
        
        case $choice in
            1) deploy_bad_version ;;
            2) check_status ;;
            3) helm_rollback ;;
            4) kubectl_rollback ;;
            5) verify_rollback ;;
            6) full_demo ;;
            7) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please choose 1-7.${NC}" ;;
        esac
    done
}

# Run main function
main
