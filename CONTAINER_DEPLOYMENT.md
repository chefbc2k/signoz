# Container App Deployment Guide

This guide explains how to build and deploy SigNoz Community Edition to container platforms.

## Quick Start

The easiest way to build SigNoz for container deployment:

```bash
./build.sh
```

This script will:
1. Build the frontend (JavaScript/React)
2. Build the backend (Go)
3. Create a Docker image: `signoz-community:latest`

## Manual Build (Alternative)

If you prefer to run the steps manually:

```bash
# 1. Build frontend
cd frontend
yarn install --frozen-lockfile
yarn build
cd ..

# 2. Build Go backend
make go-build-community

# 3. Build Docker image
docker build \
  --build-arg TARGETARCH="amd64" \
  -f cmd/community/Dockerfile \
  -t signoz-community:latest \
  .
```

## Platform-Specific Configurations

### Azure Container Apps / App Service
- Configuration file: `.azure/config.yaml`
- The platform should run `./build.sh` before deployment

### Render.com
- Configuration file: `render.yaml`
- Set `dockerCommand: ./build.sh`

### GitHub Actions (CI/CD)
- Workflow file: `.github/workflows/deploy-container-app.yaml`
- Customize with your registry and deployment details

### Other Platforms

Most container platforms support one of these approaches:

1. **Build script**: Configure your platform to run `./build.sh`
2. **Make command**: Use `make docker-build-community`
3. **Custom Dockerfile**: Request a self-contained Dockerfile

## Environment Variables

The container needs these environment variables:

```bash
# Required
SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN=tcp://clickhouse:9000
SIGNOZ_SQLSTORE_SQLITE_PATH=/var/lib/signoz/signoz.db
SIGNOZ_ALERTMANAGER_PROVIDER=signoz

# Optional (to disable web UI during development)
SIGNOZ_WEB_ENABLED=false
```

## Troubleshooting

### Error: "cannot access web directory"
This means the frontend wasn't built. Make sure:
- `./build.sh` completed successfully
- `frontend/build/` directory exists
- The Docker image includes `/etc/signoz/web/` with `index.html`

### Error: "cannot find binary"
The Go backend wasn't built. Ensure:
- `make go-build-community` completed successfully
- `target/linux-{arch}/signoz-community` exists

## Testing Locally

To test the build locally:

```bash
# Run the build script
./build.sh

# Start the container
docker run -p 8080:8080 \
  -e SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN=tcp://your-clickhouse:9000 \
  signoz-community:latest
```

## Need Help?

- Check that all dependencies are installed (Node 20+, Go 1.24+, Docker)
- Review the build logs for specific errors
- Ensure your platform supports pre-build scripts or custom build commands
