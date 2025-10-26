#!/bin/bash
# ModelKit Edge Deployment Script using Hub's Deploy Command

set -e

echo "🚀 ModelKit Edge Deployment using Hub Deploy"

# Configuration
NAMESPACE="arnabchat2001"
KIT_NAME="modelkit-demo"
TAG=${1:-"v7"}  # Default to v7 if no argument provided
RUNTIME="python"
FULL_REF="jozu.ml/${NAMESPACE}/${KIT_NAME}:${TAG}"

# Validate tag against allowlist
source governance.conf
if [[ ! " ${ALLOWED_TAGS[@]} " =~ " ${TAG} " ]]; then
    echo "❌ Error: Tag '${TAG}' is not in the allowed list: ${ALLOWED_TAGS[*]}"
    echo "Usage: $0 <tag>"
    echo "Example: $0 v7"
    exit 1
fi

echo "📋 Deploying: ${FULL_REF}"
echo "🏷️  Tag: ${TAG}"
echo "📦 Runtime: ${RUNTIME}"

# Method 1: Direct Docker Hub Deploy (simulated)
echo "📦 Pulling from Hub..."
docker pull ${FULL_REF} || {
    echo "⚠️  Image not found in Hub, building locally..."
    docker build -t ${FULL_REF} .
}

# Method 2: Using KitOps CLI
echo "🔧 Using KitOps CLI..."
kitops pull ${FULL_REF} --output /tmp/modelkit-deploy

# Deploy the service
echo "🚀 Deploying service..."
export MODELKIT_REF=${FULL_REF}
./start-service.sh

# Verify deployment
echo "🔍 Verifying deployment..."
sleep 10
VERSION=$(curl -s http://localhost:8000/version)
HEALTH=$(curl -s http://localhost:8000/health)

echo "📊 Deployment Status:"
echo "   Version: ${VERSION}"
echo "   Health: ${HEALTH}"

if curl -f http://localhost:8000/health >/dev/null 2>&1; then
    echo "✅ Deployment successful!"
else
    echo "❌ Deployment failed!"
    exit 1
fi

echo "🎉 ModelKit Edge deployment completed!"
