# Edge-optimized Dockerfile for ModelKit Demo
FROM python:3.11-slim

# Set environment variables
ENV MODELKIT_REF=jozu.ml/arnabchat2001/modelkit-demo:v7
ENV MODEL_PATH=/model
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Create directories
RUN mkdir -p /model /app /opt/kitops

# Install KitOps CLI
RUN wget -O /opt/kitops/kitops https://github.com/kitops-ml/kitops/releases/latest/download/kitops-linux-amd64 \
    && chmod +x /opt/kitops/kitops \
    && ln -s /opt/kitops/kitops /usr/local/bin/kitops

# Copy application code
COPY src/ /app/src/
COPY model/ /model/model/

# Install Python dependencies
RUN pip install --no-cache-dir fastapi uvicorn

# Create startup script
RUN cat > /app/start.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 Starting ModelKit Edge Service..."

# Pull model and code using KitOps
echo "📦 Pulling model and code from $MODELKIT_REF..."
kitops pull $MODELKIT_REF --filter model --output /model
kitops pull $MODELKIT_REF --filter code --output /app

# Start the FastAPI application
echo "🌐 Starting FastAPI server..."
cd /app && uvicorn src.app:app --host 0.0.0.0 --port 8000
EOF

RUN chmod +x /app/start.sh

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Start the application
CMD ["/app/start.sh"]
