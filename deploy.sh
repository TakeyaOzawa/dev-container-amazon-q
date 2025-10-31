#!/bin/bash

set -e

echo "Deploying Amazon Q DevContainer with Docker Compose..."

# .envファイルの存在確認
if [ ! -f "./q/.env" ]; then
    echo "Warning: .env file not found. Creating from .env.example..."
    if [ -f "./q/.env.example" ]; then
        cp ./q/.env.example ./q/.env
        echo "Please edit .env file with your settings before continuing."
        exit 1
    else
        echo "Error: .env.example not found. Please create .env file manually."
        exit 1
    fi
fi

# 環境変数の確認
source ./q/.env 2>/dev/null || true

if [ -z "$AMAZON_Q_WORKSPACE" ]; then
    echo "Error: AMAZON_Q_WORKSPACE not set in .env file"
    exit 1
fi

# ワークスペースパスの存在確認
if [ ! -d "$AMAZON_Q_WORKSPACE" ]; then
    echo "Error: Workspace directory does not exist: $AMAZON_Q_WORKSPACE"
    echo "Please create the directory or update AMAZON_Q_WORKSPACE in .env file"
    exit 1
fi

echo "Workspace path: $AMAZON_Q_WORKSPACE"

TARGET_WORKSPACE=${1:-${AMAZON_Q_WORKSPACE}}
PROJECT_NAME=$(basename "$TARGET_WORKSPACE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')
WORK_HASH=$(echo "${TARGET_WORKSPACE}_$(date +%Y%m%d)" | md5sum | cut -c1-4)

export AMAZON_Q_WORKSPACE="$TARGET_WORKSPACE"
export COMPOSE_PROJECT_NAME="q-${PROJECT_NAME}-${WORK_HASH}"

# コンテナ起動
echo "Starting containers..."
cd q
docker compose up -d

# 起動確認
if docker ps | grep "$COMPOSE_PROJECT_NAME" | grep -q "Up"; then
    echo ""
    echo "✅ Container started successfully!"
    echo ""
    echo "Amazon Q CLI Container Manager"
    echo ""
    echo "Usage: ./manage.sh {start|stop|down|clean|list|restart|shell|auth|chat|status|logs|ps|build|config}"
    echo ""
    echo "Commands:"
    echo "  start      - Deploy and start containers"
    echo "  stop       - Stop Amazon Q containers (or specific: stop <container_name>)"
    echo "  down       - Stop and remove Amazon Q containers"
    echo "  clean      - Complete cleanup: stop, remove containers and images"
    echo "  list       - List all Amazon Q containers"
    echo "  restart    - Restart containers"
    echo "  shell      - Enter container shell"
    echo "  auth       - Run Amazon Q authentication"
    echo "  chat       - Start Amazon Q chat"
    echo "  status     - Check authentication status"
    echo "  logs       - Show container logs (follow mode)"
    echo "  ps         - Show container status"
    echo "  build      - Build container images"
    echo "  config     - Show Docker Compose configuration"
    echo ""
    echo "DevContainer Usage:"
    echo "  Open this folder in VS Code and use 'Dev Containers: Reopen in Container'"
else
    echo "❌ Failed to start container"
    echo "Check logs with: docker compose logs"
    exit 1
fi
