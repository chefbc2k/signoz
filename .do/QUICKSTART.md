# Digital Ocean Quick Start Checklist

Follow these steps to deploy SigNoz on Digital Ocean App Platform.

## ✅ Pre-Deployment Checklist

- [ ] Push your code to GitHub
- [ ] Update `.do/app.yaml` with your GitHub username/repo
- [ ] Decide on ClickHouse deployment option (Cloud, Droplet, or managed)
- [ ] Have your ClickHouse connection string ready

## 🚀 Deployment Steps

### Quick Deploy (5 minutes)

1. **Update configuration**
   ```bash
   # Edit .do/app.yaml and change YOUR_GITHUB_USERNAME to your actual username
   nano .do/app.yaml
   ```

2. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Add Digital Ocean deployment configuration"
   git push origin main
   ```

3. **Deploy via Web UI**
   - Go to https://cloud.digitalocean.com/apps
   - Click "Create App"
   - Select your GitHub repository
   - Choose "Import from existing app spec"
   - Upload `.do/app.yaml`
   - Click "Create Resources"

4. **Configure ClickHouse**
   - While app is building, set up ClickHouse (see options below)
   - Update environment variable `SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN`

5. **Deploy!**
   - App Platform will build and deploy automatically
   - Access at: `https://your-app-name.ondigitalocean.app`

## 🗄️ ClickHouse Setup Options

### Option 1: ClickHouse Cloud (Easiest)
1. Go to https://clickhouse.cloud
2. Create free trial account
3. Create a service
4. Copy connection string
5. Add to App Platform env vars:
   ```
   SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN=tcp://xxx.clickhouse.cloud:9440?secure=true&username=default&password=xxx
   ```

### Option 2: Digital Ocean Droplet (Full Control)
1. Create Droplet (4GB RAM minimum)
2. Install ClickHouse:
   ```bash
   curl https://clickhouse.com/ | sh
   sudo ./clickhouse install
   ```
3. Configure firewall
4. Add DSN to App Platform

## 🔍 Verify Deployment

```bash
# Check if app is running
curl https://your-app-name.ondigitalocean.app/api/v1/health

# Expected response:
# {"status":"ok"}
```

## 📊 Monitor Build

```bash
# Install doctl CLI
brew install doctl  # macOS
# or download from https://docs.digitalocean.com/reference/doctl/how-to/install/

# View build logs
doctl apps list
doctl apps logs <app-id> --type build --follow
```

## ❗ Common Issues

| Issue | Solution |
|-------|----------|
| Build fails: "cannot access web directory" | Ensure `build.sh` runs before Docker build |
| App crashes on start | Check ClickHouse DSN is correct |
| 404 on all pages | Frontend didn't build - check build logs |
| Out of memory during build | Increase instance size to Professional S |

## 💰 Cost Estimate

- **App Platform**: $12-24/month
- **ClickHouse Cloud**: $0-50/month (free tier available)
- **Total**: ~$12-75/month

## 📚 Full Documentation

See [DIGITALOCEAN_DEPLOYMENT.md](DIGITALOCEAN_DEPLOYMENT.md) for complete guide.
