#!/bin/bash

set -e

echo "Building Amazon Q DevContainer with Docker Compose..."

# .envファイルの存在確認
if [ ! -f "./q/.env" ]; then
    echo "Warning: .env file not found. Creating from .env.example..."
    if [ -f "./q/.env.example" ]; then
        cp ./q/.env.example ./q/.env
        echo "Please edit ./q/.env file with your settings before continuing."
        echo "Required settings:"
        echo "  - AMAZON_Q_START_URL"
        echo "  - AMAZON_Q_WORKSPACE"
        exit 1
    else
        echo "Error: .env.example not found. Please create .env file manually."
        exit 1
    fi
fi

# Docker Composeでビルド
cd q
docker compose build

echo "Build completed successfully!"
echo "Service: amazon-q"
echo ""
echo "To start the container:"
echo "  ./manage.sh start"
echo ""
echo "To use with DevContainer:"
echo "  Open in VS Code and use 'Dev Containers: Reopen in Container'"
