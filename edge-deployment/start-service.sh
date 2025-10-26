#!/bin/bash
# ModelKit Edge Service Start Script

set -e

echo "🚀 Starting ModelKit Edge Service..."

# Configuration
CONTAINER_NAME="modelkit-edge"
IMAGE_NAME="modelkit-edge"
CURRENT_TAG=${MODELKIT_REF##*:}  # Extract tag from MODELKIT_REF
FULL_IMAGE="${IMAGE_NAME}:${CURRENT_TAG}"

# Create directories
mkdir -p /var/lib/modelkit/{model,app}
mkdir -p /opt/modelkit-edge/logs

# Pull the image
echo "📦 Pulling image: ${FULL_IMAGE}"
docker pull ${FULL_IMAGE} || {
    echo "⚠️  Image not found, building locally..."
    docker build -t ${FULL_IMAGE} .
}

# Stop existing container if running
docker stop ${CONTAINER_NAME} 2>/dev/null || true
docker rm ${CONTAINER_NAME} 2>/dev/null || true

# Start the container
echo "🌐 Starting container: ${CONTAINER_NAME}"
docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p 8000:8000 \
    -e MODELKIT_REF=${MODELKIT_REF} \
    -e MODEL_PATH=${MODEL_PATH} \
    -v /var/lib/modelkit/model:/model \
    -v /var/lib/modelkit/app:/app \
    -v /opt/modelkit-edge/logs:/var/log \
    ${FULL_IMAGE}

# Wait for service to be ready
echo "⏳ Waiting for service to be ready..."
for i in {1..30}; do
    if curl -f http://localhost:8000/health >/dev/null 2>&1; then
        echo "✅ Service is ready!"
        break
    fi
    echo "   Attempt $i/30..."
    sleep 2
done

# Show status
echo "📊 Service Status:"
docker ps --filter name=${CONTAINER_NAME}
echo ""
echo "🔍 Health Check:"
curl -s http://localhost:8000/health | jq . 2>/dev/null || curl -s http://localhost:8000/health
echo ""
echo "📋 Version:"
curl -s http://localhost:8000/version
echo ""

echo "🎉 ModelKit Edge Service started successfully!"
