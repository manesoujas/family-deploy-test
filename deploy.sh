#!/bin/bash

set -e

APP_NAME="deploy-test"
NEW_CONTAINER="${APP_NAME}-new"
IMAGE_NAME="${APP_NAME}:latest"

echo "🚀 Starting safe deployment..."

echo "📥 Pulling latest code..."
git pull origin main

echo "🐳 Building new Docker image..."
docker build -t "$IMAGE_NAME" .

echo "🧹 Removing previous temporary container..."
docker rm -f "$NEW_CONTAINER" 2>/dev/null || true

echo "▶️ Starting new container..."
docker run -d \
  --name "$NEW_CONTAINER" \
  --network server-net \
  "$IMAGE_NAME"

echo "⏳ Waiting for application..."
sleep 3

echo "🔍 Running health check..."

if docker exec "$NEW_CONTAINER" wget -qO- http://127.0.0.1:80 > /dev/null; then

    echo "✅ New version passed health check!"

    echo "🛑 Removing old container..."
    docker rm -f "$APP_NAME" 2>/dev/null || true

    echo "🔄 Renaming new container..."
    docker rename "$NEW_CONTAINER" "$APP_NAME"

    echo "🎉 Deployment completed successfully!"

else

    echo "❌ New version failed health check!"
    echo "↩️ Keeping the existing application."

    docker rm -f "$NEW_CONTAINER" 2>/dev/null || true

    exit 1
fi
