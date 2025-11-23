# Dead Simple SigNoz Self-Hosting (Solo Dev Edition)

## For: Solo devs who need basic observability on a budget

**Cost:** $24/month (one 4GB Droplet)
**Time:** 15 minutes setup
**Management:** Maybe 30 min/month

---

## Setup

### 1. Create Digital Ocean Droplet

- Size: **Basic 4GB RAM / 2 vCPU** ($24/month)
- Image: **Ubuntu 24.04 LTS**
- Datacenter: Closest to you

### 2. SSH In and Install Docker

```bash
ssh root@your-droplet-ip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
apt install docker-compose-plugin -y
```

### 3. Clone and Run SigNoz

```bash
git clone https://github.com/SigNoz/signoz.git
cd signoz/deploy/docker

# Start everything
docker compose up -d

# Wait 2-3 minutes for services to start
docker compose ps
```

### 4. Access SigNoz

Open browser: `http://your-droplet-ip:3301`

Create your account - that's it!

### 5. Send Data to SigNoz

Point your app to: `http://your-droplet-ip:4318` (OTLP HTTP)

---

## That's It

**No ClickHouse management. No build steps. No App Platform. Just works.**

---

## When to Upgrade

- **>1000 daily active users:** Move to managed SigNoz Cloud
- **>10GB logs/day:** Add more Droplet RAM or split services
- **Getting revenue:** Pay for managed services, focus on product

---

## Cost Comparison

| Solution | Cost/Month | Setup Time | Monthly Maintenance |
|----------|------------|------------|---------------------|
| This (Droplet) | $24 | 15 min | 30 min |
| SigNoz Cloud | $0-30 | 5 min | 0 min |
| App Platform | $60+ | 2 hours | 2+ hours |

**Reality:** SigNoz Cloud free tier is probably perfect for you right now.
