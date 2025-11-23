#!/bin/bash
# Verification script to test build before deploying to Digital Ocean

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "SigNoz Build Verification"
echo "======================================"
echo ""

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

# Check prerequisites
echo "Checking prerequisites..."
echo "--------------------------------------"

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_status 0 "Node.js installed: $NODE_VERSION"
else
    print_status 1 "Node.js not installed"
    echo "  Install from: https://nodejs.org/"
    exit 1
fi

# Check Yarn
if command -v yarn &> /dev/null; then
    YARN_VERSION=$(yarn --version)
    print_status 0 "Yarn installed: $YARN_VERSION"
else
    print_status 1 "Yarn not installed"
    echo "  Install: npm install -g yarn"
    exit 1
fi

# Check Go
if command -v go &> /dev/null; then
    GO_VERSION=$(go version | awk '{print $3}')
    print_status 0 "Go installed: $GO_VERSION"
else
    print_status 1 "Go not installed"
    echo "  Install from: https://golang.org/dl/"
    exit 1
fi

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
    print_status 0 "Docker installed: $DOCKER_VERSION"
else
    print_status 1 "Docker not installed"
    echo "  Install from: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check Make
if command -v make &> /dev/null; then
    print_status 0 "Make installed"
else
    print_status 1 "Make not installed"
    exit 1
fi

echo ""
echo "Running build test..."
echo "--------------------------------------"

# Test frontend build
echo "Testing frontend build..."
cd frontend
if yarn install --frozen-lockfile > /dev/null 2>&1; then
    print_status 0 "Frontend dependencies installed"
else
    print_status 1 "Frontend dependency installation failed"
    exit 1
fi

if yarn build > /dev/null 2>&1; then
    print_status 0 "Frontend build successful"
else
    print_status 1 "Frontend build failed"
    exit 1
fi

if [ -f "build/index.html" ]; then
    print_status 0 "Frontend build output verified (build/index.html exists)"
else
    print_status 1 "Frontend build output missing"
    exit 1
fi
cd ..

# Test Go build
echo ""
echo "Testing Go build..."
ARCH=$(uname -m | sed 's/x86_64/amd64/g' | sed 's/aarch64/arm64/g')
if make go-build-community > /dev/null 2>&1; then
    print_status 0 "Go build successful"
else
    print_status 1 "Go build failed"
    exit 1
fi

if [ -f "target/linux-${ARCH}/signoz-community" ]; then
    print_status 0 "Go binary verified (target/linux-${ARCH}/signoz-community exists)"
else
    print_status 1 "Go binary missing"
    exit 1
fi

# Test Docker build
echo ""
echo "Testing Docker build..."
if docker build \
    --build-arg TARGETARCH="${ARCH}" \
    -f cmd/community/Dockerfile \
    -t signoz-community:test \
    . > /dev/null 2>&1; then
    print_status 0 "Docker build successful"
else
    print_status 1 "Docker build failed"
    exit 1
fi

# Verify Docker image
echo ""
echo "Verifying Docker image..."
if docker run --rm signoz-community:test ls /etc/signoz/web/index.html > /dev/null 2>&1; then
    print_status 0 "Web files present in Docker image"
else
    print_status 1 "Web files missing in Docker image"
    exit 1
fi

if docker run --rm signoz-community:test ls /root/signoz > /dev/null 2>&1; then
    print_status 0 "Backend binary present in Docker image"
else
    print_status 1 "Backend binary missing in Docker image"
    exit 1
fi

# Cleanup test image
docker rmi signoz-community:test > /dev/null 2>&1

echo ""
echo "======================================"
echo -e "${GREEN}All checks passed!${NC}"
echo "======================================"
echo ""
echo "Your build is ready for deployment to Digital Ocean."
echo ""
echo "Next steps:"
echo "1. Update .do/app.yaml with your GitHub repo"
echo "2. Push to GitHub: git push origin main"
echo "3. Deploy via Digital Ocean App Platform"
echo ""
echo "See .do/QUICKSTART.md for detailed instructions."
