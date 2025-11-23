# Digital Ocean Deployment Guide for SigNoz

This guide walks you through deploying SigNoz Community Edition on Digital Ocean App Platform.

## Prerequisites

- Digital Ocean account
- GitHub repository with your SigNoz code
- `doctl` CLI installed ([Installation Guide](https://docs.digitalocean.com/reference/doctl/how-to/install/))

## Deployment Options

### Option 1: Deploy via Git (Recommended)

This is the easiest method. Digital Ocean App Platform will build directly from your GitHub repository.

#### Step 1: Prepare Your Repository

Your repository already has the required files:
- ✅ `build.sh` - Build script
- ✅ `.do/app.yaml` - App Platform configuration
- ✅ `cmd/community/Dockerfile` - Docker configuration

#### Step 2: Update `.do/app.yaml`

Edit [.do/app.yaml](.do/app.yaml:1) and update:

```yaml
github:
  repo: YOUR_GITHUB_USERNAME/signoz  # Change this to your repo
```

#### Step 3: Deploy to App Platform

**Via Web UI:**

1. Go to [Digital Ocean App Platform](https://cloud.digitalocean.com/apps)
2. Click **"Create App"**
3. Choose **"GitHub"** as source
4. Select your repository and branch
5. Click **"Import from existing app spec"**
6. Upload `.do/app.yaml`
7. Review and click **"Create Resources"**

**Via CLI:**

```bash
# Install doctl if you haven't
# https://docs.digitalocean.com/reference/doctl/how-to/install/

# Authenticate
doctl auth init

# Create the app
doctl apps create --spec .do/app.yaml
```

#### Step 4: Configure ClickHouse

SigNoz requires ClickHouse. You have several options:

**Option A: ClickHouse Cloud (Recommended)**
1. Sign up at [clickhouse.cloud](https://clickhouse.cloud)
2. Create a cluster
3. Get your connection string
4. Update the environment variable in App Platform:
   ```
   SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN=tcp://your-host:9000?username=default&password=xxx
   ```

**Option B: Digital Ocean Droplet**
1. Create a Droplet (at least 4GB RAM)
2. Install ClickHouse:
   ```bash
   curl https://clickhouse.com/ | sh
   sudo ./clickhouse install
   ```
3. Configure firewall to allow port 9000 from your App Platform
4. Update the DSN environment variable

**Option C: Containerized ClickHouse (Development Only)**
- Use the full docker-compose stack (see below)

---

### Option 2: Deploy via Container Registry

Build locally and push to Digital Ocean Container Registry.

#### Step 1: Create Container Registry

```bash
# Create registry
doctl registry create signoz

# Login to registry
doctl registry login
```

#### Step 2: Build and Push

```bash
# Build the application
./build.sh

# Tag for Digital Ocean
docker tag signoz-community:latest registry.digitalocean.com/signoz/signoz-community:latest

# Push to registry
docker push registry.digitalocean.com/signoz/signoz-community:latest
```

Or use the automated script:

```bash
export DO_REGISTRY_NAME=signoz
./.do/deploy.sh
```

#### Step 3: Create App from Registry Image

1. Go to App Platform
2. Create App → Choose **"DigitalOcean Container Registry"**
3. Select your image: `signoz/signoz-community:latest`
4. Configure environment variables (see below)
5. Deploy

---

### Option 3: Full Stack with Docker Compose

If you want to run the full SigNoz stack (including ClickHouse) on Digital Ocean:

#### Option 3A: Using App Platform (Limited)
App Platform doesn't natively support docker-compose, but you can:
1. Use a Droplet instead (see Option 3B)

#### Option 3B: Using Droplets
1. Create a Droplet (at least 8GB RAM, 4 vCPU recommended)
2. SSH into the droplet
3. Install Docker and Docker Compose
4. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/signoz.git
   cd signoz/deploy/docker
   ```
5. Start services:
   ```bash
   docker compose up -d
   ```

---

## Environment Variables

Configure these in App Platform → Settings → Environment Variables:

### Required Variables

```bash
SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN=tcp://your-clickhouse-host:9000
SIGNOZ_SQLSTORE_SQLITE_PATH=/var/lib/signoz/signoz.db
SIGNOZ_ALERTMANAGER_PROVIDER=signoz
```

### Optional Variables

```bash
# Deployment tracking
DEPLOYMENT_TYPE=digitalocean-app-platform
TELEMETRY_ENABLED=true

# Development - disable web UI if frontend isn't needed
SIGNOZ_WEB_ENABLED=false

# JWT Secret (generate a secure random string)
SIGNOZ_JWT_SECRET=your-secret-key-here
```

---

## Troubleshooting

### Build Fails: "cannot access web directory"

**Cause:** Frontend wasn't built

**Solution:** Ensure `build.sh` is running. Check App Platform build logs:
```bash
doctl apps logs <app-id> --type build
```

### Build Fails: "yarn: command not found"

**Cause:** Node.js isn't installed in build environment

**Solution:** App Platform should have Node.js by default. If not, update Dockerfile to include Node.js in build stage.

### App Crashes: "connection refused" to ClickHouse

**Cause:** ClickHouse isn't accessible

**Solution:**
1. Verify ClickHouse is running
2. Check the DSN is correct
3. Ensure firewall allows connections from App Platform
4. If using ClickHouse Cloud, check if IP is whitelisted

### App Starts but 404 on all pages

**Cause:** Web frontend missing

**Solution:**
1. Check if `frontend/build/` exists in Docker image
2. Verify `/etc/signoz/web/index.html` exists in container
3. Check build logs to ensure frontend build completed

---

## Monitoring

View your app logs:
```bash
# Runtime logs
doctl apps logs <app-id> --type run

# Build logs
doctl apps logs <app-id> --type build

# Follow logs in real-time
doctl apps logs <app-id> --type run --follow
```

Access your app:
```
https://your-app-name.ondigitalocean.app
```

---

## Costs Estimation

**App Platform (SigNoz backend only):**
- Professional XS: $12/month (512MB RAM, 1 vCPU)
- Professional S: $24/month (1GB RAM, 1 vCPU)

**ClickHouse:**
- ClickHouse Cloud: ~$50-100/month (depending on usage)
- Droplet: $24-48/month (4-8GB RAM)

**Total:** ~$36-150/month depending on configuration

---

## Next Steps

1. Push your code to GitHub
2. Deploy using one of the options above
3. Configure ClickHouse connection
4. Access SigNoz at your App Platform URL
5. Complete initial setup in the UI

## Need Help?

- [Digital Ocean App Platform Docs](https://docs.digitalocean.com/products/app-platform/)
- [SigNoz Docs](https://signoz.io/docs/)
- Check build/runtime logs for specific errors
