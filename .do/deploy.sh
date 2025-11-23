#!/bin/bash
# Digital Ocean App Platform deployment script

set -e

echo "======================================"
echo "Digital Ocean Deployment Script"
echo "======================================"

# Check if doctl is installed
if ! command -v doctl &> /dev/null; then
    echo "Error: doctl CLI not found. Install it from: https://docs.digitalocean.com/reference/doctl/how-to/install/"
    exit 1
fi

# Build the application
echo "Building application..."
chmod +x build.sh
./build.sh

# Tag the image for Digital Ocean Container Registry
echo ""
echo "Tagging image for Digital Ocean Container Registry..."
REGISTRY_NAME="${DO_REGISTRY_NAME:-signoz}"
docker tag signoz-community:latest registry.digitalocean.com/${REGISTRY_NAME}/signoz-community:latest

# Push to registry
echo ""
echo "Pushing to Digital Ocean Container Registry..."
doctl registry login
docker push registry.digitalocean.com/${REGISTRY_NAME}/signoz-community:latest

echo ""
echo "======================================"
echo "Deployment completed!"
echo "======================================"
echo "Image: registry.digitalocean.com/${REGISTRY_NAME}/signoz-community:latest"
echo ""
echo "Next steps:"
echo "1. Go to Digital Ocean App Platform console"
echo "2. Create or update your app to use this image"
echo "3. Configure environment variables"
echo "4. Deploy!"
