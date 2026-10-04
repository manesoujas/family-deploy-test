#!/bin/bash

set -e

echo "🚀 Starting deployment..."

echo "📥 Pulling latest code..."
git pull origin main

echo "🐳 Building Docker image..."
docker build -t deploy-test:latest .

echo "🛑 Stopping old container..."
docker rm -f deploy-test 2>/dev/null || true

echo "▶️ Starting new container..."
docker run -d \
  --name deploy-test \
  --network server-net \
  deploy-test:latest

echo "⏳ Waiting for application..."
sleep 3

echo "🔍 Running health check..."

if docker exec deploy-test wget -qO- http://127.0.0.1:80 > /dev/null; then
    echo "✅ Health check passed!"
    echo "✅ Deployment completed!"
else
    echo "❌ Health check failed!"
    echo "❌ Deployment failed."
    exit 1
fi
