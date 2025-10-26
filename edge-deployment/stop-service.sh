#!/bin/bash
# ModelKit Edge Service Stop Script

set -e

echo "🛑 Stopping ModelKit Edge Service..."

CONTAINER_NAME="modelkit-edge"

# Stop the container
if docker ps -q --filter name=${CONTAINER_NAME} | grep -q .; then
    echo "📦 Stopping container: ${CONTAINER_NAME}"
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
    echo "✅ Container stopped and removed"
else
    echo "ℹ️  Container ${CONTAINER_NAME} is not running"
fi

# Clean up old images (keep last 3 versions)
echo "🧹 Cleaning up old images..."
docker images modelkit-edge --format "table {{.Tag}}\t{{.CreatedAt}}" | \
    tail -n +2 | sort -k2 -r | tail -n +4 | \
    awk '{print $1}' | xargs -r docker rmi modelkit-edge: 2>/dev/null || true

echo "🎉 ModelKit Edge Service stopped successfully!"
