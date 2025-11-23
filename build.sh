#!/bin/bash
set -e

echo "======================================"
echo "Building SigNoz Community Edition"
echo "======================================"

# Detect architecture
ARCH=$(uname -m | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g')
echo "Detected architecture: $ARCH"

# Step 1: Build frontend
echo ""
echo "Step 1/3: Building frontend..."
echo "--------------------------------------"
cd frontend
yarn install --frozen-lockfile
yarn build
cd ..

# Step 2: Build Go backend
echo ""
echo "Step 2/3: Building Go backend..."
echo "--------------------------------------"
make go-build-community

# Step 3: Build Docker image
echo ""
echo "Step 3/3: Building Docker image..."
echo "--------------------------------------"
docker build \
  --build-arg TARGETARCH="${ARCH}" \
  -f cmd/community/Dockerfile \
  -t signoz-community:latest \
  .

echo ""
echo "======================================"
echo "Build completed successfully!"
echo "======================================"
echo "Docker image: signoz-community:latest"
