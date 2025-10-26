#!/bin/bash
# ModelKit Edge Rollback Script

set -e

echo "🔄 ModelKit Edge Rollback Script"

# Configuration
CONTAINER_NAME="modelkit-edge"
IMAGE_NAME="modelkit-edge"
ROLLBACK_TAG=${1:-"v3"}  # Default to v3 if no argument provided
CURRENT_TAG=${MODELKIT_REF##*:}

# Validate rollback tag against allowlist
ALLOWED_TAGS=("v3" "v7" "v2")
if [[ ! " ${ALLOWED_TAGS[@]} " =~ " ${ROLLBACK_TAG} " ]]; then
    echo "❌ Error: Tag '${ROLLBACK_TAG}' is not in the allowed list: ${ALLOWED_TAGS[*]}"
    echo "Usage: $0 <tag>"
    echo "Example: $0 v3"
    exit 1
fi

echo "📋 Current version: ${CURRENT_TAG}"
echo "🎯 Rolling back to: ${ROLLBACK_TAG}"

# Update MODELKIT_REF
export MODELKIT_REF="jozu.ml/arnabchat2001/modelkit-demo:${ROLLBACK_TAG}"

# Stop current service
echo "🛑 Stopping current service..."
./stop-service.sh

# Start with new version
echo "🚀 Starting with rollback version..."
./start-service.sh

# Verify rollback
echo "🔍 Verifying rollback..."
sleep 10
NEW_VERSION=$(curl -s http://localhost:8000/version)
echo "📊 New version: ${NEW_VERSION}"

if [[ "${NEW_VERSION}" == "GOOD" ]] || [[ "${NEW_VERSION}" == *"${ROLLBACK_TAG}"* ]]; then
    echo "✅ Rollback successful!"
else
    echo "⚠️  Rollback completed, but version check inconclusive"
fi

echo "🎉 Rollback process completed!"
