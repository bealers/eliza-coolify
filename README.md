# ElizaOS Production Docker Deployment

**Production-ready Docker setup for ElizaOS with PM2, security hardening, and Coolify integration.**

## 🚀 Quick Start

### Option 1: With Internal PostgreSQL (Recommended for Testing)
```bash
# Clone and setup
git clone <your-repo-url>
cd eliza-coolify

# Configure environment
cp env.example .env
# Edit .env with your configuration

# Deploy with internal database
docker-compose up -d
```

### Option 2: With External PostgreSQL (Recommended for Production)
```bash
# Configure external database
cp env.example .env
# Set DATABASE_URL=postgresql://user:pass@host:5432/db

# Deploy slim version (no internal database)
docker-compose -f docker-compose.slim.yaml up -d
```

### Option 3: Coolify Deployment

**📖 Complete Guide**: See **[COOLIFY_DEPLOYMENT.md](COOLIFY_DEPLOYMENT.md)** for detailed step-by-step instructions.

**Quick Coolify Setup:**
1. Create PostgreSQL database in Coolify
2. Use `docker-compose.slim.yaml` as compose file
3. Set required environment variables: `OPENAI_API_KEY`, `DATABASE_URL`
4. Configure domain with automatic SSL
5. Deploy and verify health check

**Total deployment time: ~10-15 minutes** 🚀

## 🏗️ Architecture

### Core Components

- **ElizaOS API Server** - Built with `@elizaos/cli@1.0.9`
- **PM2 Process Manager** - Auto-restart, monitoring, logging
- **PostgreSQL Database** - Persistent data storage
- **Health Checks** - Container monitoring and auto-recovery
- **Security Hardening** - Non-root user, proper permissions

### Key Features

- ✅ **API-only mode** - Disable web UI in production (`ENABLE_WEB_UI=false`)
- ✅ **One agent per container** - Scalable architecture
- ✅ **External service integrations** - Discord, Telegram, Mattermost
- ✅ **Traefik integration** - Ready for Coolify deployment
- ✅ **Resource limits** - Memory and CPU constraints
- ✅ **Persistent storage** - Data and logs volumes
- ✅ **Comprehensive logging** - Structured logs with rotation

## 📋 Environment Configuration

### Required Variables
```bash
# AI Provider (choose one)
OPENAI_API_KEY=sk-your-key-here
ANTHROPIC_API_KEY=sk-ant-your-key-here
GEMINI_API_KEY=your-gemini-key

# Database (for external database deployments)
DATABASE_URL=postgresql://user:pass@host:5432/database
```

### Production Settings
```bash
# Core Configuration
NODE_ENV=production
API_PORT=3000
ENABLE_WEB_UI=false  # Disable UI in production
LOG_LEVEL=info

# Security
JWT_SECRET=your-jwt-secret-change-this
CORS_ORIGIN=https://yourdomain.com
```

### Integration Services
```bash
# Discord Bot
DISCORD_APPLICATION_ID=your-app-id
DISCORD_API_TOKEN=your-bot-token

# Telegram Bot
TELEGRAM_BOT_TOKEN=your-telegram-token

# Mattermost
MATTERMOST_URL=https://your-mattermost.com
MATTERMOST_TOKEN=your-token
```

See `env.example` for complete configuration options.

## 🗂️ Character Configuration

### Creating Custom Characters
```bash
# Create characters directory
mkdir -p characters

# Add your character file
cat > characters/my-agent.character.json << 'EOF'
{
  "name": "MyAgent",
  "bio": ["Your agent description"],
  "system": "Your system prompt",
  "clients": ["discord", "telegram"],
  "plugins": ["@elizaos/plugin-bootstrap"]
}
EOF
```

### Using Default Character
The included `production-agent.character.json` provides a professional baseline for production deployments.

## 🐳 Docker Configuration

### File Structure
```
eliza-coolify/
├── Dockerfile                    # Production container with PM2
├── docker-compose.yaml           # Full stack with PostgreSQL
├── docker-compose.slim.yaml      # External database only (Coolify)
├── ecosystem.config.js           # PM2 configuration
├── start.sh                      # Container startup script
├── healthcheck.js                # Health monitoring script
├── init-db.sql                   # PostgreSQL initialization
├── env.example                   # Environment template
├── scripts/                      # PM2 management scripts
│   ├── start-elizaos.sh         #   Start ElizaOS with PM2
│   ├── stop-elizaos.sh          #   Stop ElizaOS gracefully
│   └── status-elizaos.sh        #   Show comprehensive status
├── characters/                   # Agent configuration files
│   └── production-agent.character.json
└── COOLIFY_DEPLOYMENT.md         # Detailed Coolify deployment guide
```

### Container Features

- **Non-root user** - Security best practices
- **PM2 process management** - Auto-restart, monitoring
- **Health checks** - `/api/health` endpoint monitoring
- **Resource limits** - 4GB memory, 2 CPU cores max
- **Log rotation** - Prevents disk space issues
- **Signal handling** - Graceful shutdowns

## 🔧 PM2 Configuration

The `ecosystem.config.js` file configures:
- **Auto-restart** - On crashes and high memory usage
- **Log management** - Structured logging with timestamps
- **Health monitoring** - Fatal exception handling
- **Resource limits** - 2GB memory restart threshold

### PM2 Management Scripts

**Inside Container:**
```bash
# Comprehensive status check
./scripts/status-elizaos.sh

# Start/restart ElizaOS
./scripts/start-elizaos.sh

# Stop ElizaOS gracefully
./scripts/stop-elizaos.sh
```

**Outside Container:**
```bash
# Status check
docker exec elizaos-prod ./scripts/status-elizaos.sh

# Start/restart
docker exec elizaos-prod ./scripts/start-elizaos.sh

# Stop gracefully
docker exec elizaos-prod ./scripts/stop-elizaos.sh
```

### Direct PM2 Commands
```bash
# View status
docker exec elizaos-prod pm2 list

# View logs
docker exec elizaos-prod pm2 logs elizaos

# Restart application
docker exec elizaos-prod pm2 restart elizaos

# Monitor resources
docker exec elizaos-prod pm2 monit
```

## 🛡️ Security Features

### Production Hardening
- **Non-root container user** - Reduces attack surface
- **Read-only character files** - Prevents modification
- **Environment-based secrets** - No hardcoded credentials
- **API-only mode** - Disables web UI when not needed
- **CORS configuration** - Restricts cross-origin requests
- **Rate limiting** - Prevents abuse

### Database Security
- **No external ports** - Database not exposed (full stack)
- **Strong passwords** - Configurable via environment
- **Connection encryption** - SSL/TLS ready
- **Schema separation** - Organized database structure

## 📊 Monitoring & Logging

### Health Checks
- **Container health** - Docker health check every 30s
- **Application health** - `/api/health` endpoint
- **Database health** - PostgreSQL connection check
- **PM2 monitoring** - Process-level health tracking

### Log Management
- **Application logs** - `/app/logs/` directory
- **PM2 logs** - Process management logs
- **Docker logs** - Container-level logging
- **Log rotation** - 10MB max, 3 files retention

### Monitoring Commands
```bash
# View container health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check application logs
docker logs elizaos-prod --tail 100 -f

# Monitor resources
docker stats elizaos-prod

# PM2 monitoring
docker exec elizaos-prod pm2 monit
```

## 🚀 Deployment Strategies

### Local Testing (Internal Database)
```bash
# Quick setup with internal PostgreSQL
cp env.example .env
# Edit .env with your AI provider API key
docker-compose up -d
```

### Production (External Database)
```bash
# Coolify or external PostgreSQL deployment
cp env.example .env
# Set DATABASE_URL and other production variables
docker-compose -f docker-compose.slim.yaml up -d
```

### Coolify Deployment
1. **Create PostgreSQL** database in Coolify
2. **Repository URL** - Point to this repo
3. **Compose File** - Select `docker-compose.slim.yaml`
4. **Environment Variables** - Set `DATABASE_URL`, `OPENAI_API_KEY`
5. **Domain** - Configure custom domain with automatic SSL
6. **Deploy** - Automatic Traefik integration

**See [COOLIFY_DEPLOYMENT.md](COOLIFY_DEPLOYMENT.md) for detailed steps.**

## 🔄 Scaling

### Horizontal Scaling
Deploy multiple instances with different configurations:

```bash
# Agent 1 - Discord
DISCORD_API_TOKEN=bot-1-token
docker-compose up -d

# Agent 2 - Telegram  
TELEGRAM_BOT_TOKEN=bot-2-token
docker-compose -p eliza-telegram up -d
```

### Load Balancing
Use Traefik or nginx for load balancing multiple ElizaOS instances.

## 🐛 Troubleshooting

### Common Issues

**Container won't start**
```bash
# Check logs
docker logs elizaos-prod

# Verify environment
docker exec elizaos-prod env | grep OPENAI

# Test configuration
docker exec elizaos-prod node -e "console.log(process.env.DATABASE_URL)"
```

**Database connection issues**
```bash
# Test database connectivity
docker exec elizaos-prod curl -f http://localhost:3000/api/health

# Check PostgreSQL
docker exec elizaos-db pg_isready -U eliza
```

**PM2 process issues**
```bash
# Restart PM2
docker exec elizaos-prod pm2 restart all

# Clear PM2 logs
docker exec elizaos-prod pm2 flush

# Reset PM2
docker exec elizaos-prod pm2 kill && pm2 start ecosystem.config.js
```

### Performance Tuning

**Memory optimization**
- Adjust `MAX_MEMORY_USAGE` in environment
- Monitor with `pm2 monit`
- Set Docker memory limits

**Database optimization**
- Use connection pooling
- Monitor query performance
- Regular maintenance

## 📚 References

- [ElizaOS Documentation](https://eliza.how/docs/intro)
- [ElizaOS GitHub](https://github.com/elizaOS/eliza)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Coolify Documentation](https://coolify.io/docs)

---

**Built for production deployment with security, scalability, and reliability in mind.**

---

## 🎯 Quick Deployment Guide

**For immediate Coolify deployment**, see: **[COOLIFY_DEPLOYMENT.md](COOLIFY_DEPLOYMENT.md)**

**TL;DR:**
1. Create PostgreSQL database in Coolify
2. Use `docker-compose.slim.yaml` in Coolify application
3. Set `DATABASE_URL` and `OPENAI_API_KEY` environment variables
4. Deploy with custom domain (SSL automatic)
5. Health check: `https://yourdomain.com/api/health`
6. Manage with: `./scripts/status-elizaos.sh`

**Total deployment time: ~10-15 minutes** 🚀



