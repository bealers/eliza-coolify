# ElizaOS Production Docker Deployment

Production-ready ElizaOS deployment tested on Coolify but should work on any Docker friendly set-up.

---

## Quick Coolify Deployment

1. **Point Coolify** to this repository (public Github deploy)
2. **Use `docker-compose.yaml`** as compose file (includes PostgreSQL)
3. **Set environment variables**: e.g. `OPENAI_API_KEY`
4. **Coolify deploys**
5. **Manage** with `./scripts/status-elizaos.sh`

### **Required Environment Variables:**
```bash
# AI Provider (REQUIRED - choose one)
OPENAI_API_KEY=sk-your-openai-key-here
# OR ANTHROPIC_API_KEY=sk-ant-your-key
# OR GEMINI_API_KEY=your-gemini-key

# Database is auto-configured with internal PostgreSQL

# Production Settings (optional)
NODE_ENV=production
ENABLE_WEB_UI=false
LOG_LEVEL=info
JWT_SECRET=your-secure-secret
```
---

## Architecture

### Core Components
- **ElizaOS CLI** - Built with `@elizaos/cli@latest` (published package approach)
- **PM2 Process Manager** - Auto-restart, monitoring, resource limits  
- **PostgreSQL Database** - External database (Coolify managed recommended)
- **Health Monitoring** - API endpoints + PM2 status tracking
- **Security Hardening** - Non-root user, proper permissions, CORS

### Key Features
- **API-only mode** - Web UI disabled for production (`ENABLE_WEB_UI=false`)
- **One agent per container** - Scalable microservice architecture

---

## Alternative Deployment Options

### Option 1: Advanced Coolify (External PostgreSQL)

**For shared/existing PostgreSQL instances:**
1. Create or use existing PostgreSQL database
2. Use `docker-compose.slim.yaml` as compose file  
3. Set required environment variables: `POSTGRES_URL`, `OPENAI_API_KEY`


### Option 2: Local Testing (Full Stack)

```bash
# Quick setup with internal PostgreSQL (same as Coolify quick deploy)
cp env.example .env
# Edit .env with your AI provider API key
docker-compose up -d
```

### Option 3: Production (External Database)

```bash
# External PostgreSQL deployment
cp env.example .env
# Set POSTGRES_URL and other production variables
docker-compose -f docker-compose.slim.yaml up -d
```

---

## 🔧 PM2 Management

### Management Scripts

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
docker exec <container> ./scripts/status-elizaos.sh

# Start/restart
docker exec <container> ./scripts/start-elizaos.sh

# Stop gracefully
docker exec <container> ./scripts/stop-elizaos.sh
```

### Direct PM2 Commands
```bash
# View status
docker exec <container> pm2 list

# View logs
docker exec <container> pm2 logs elizaos

# Restart application
docker exec <container> pm2 restart elizaos

# Monitor resources
docker exec <container> pm2 monit
```

---

## 📋 Environment Configuration

### Required Variables
```bash
# Database (REQUIRED)
POSTGRES_URL=postgresql://username:password@hostname:5432/database_name

# Inference Provider
OPENAI_API_KEY=sk-your-openai-api-key
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
GEMINI_API_KEY=your-gemini-key-here
```

### Production Settings
```bash
# Core Configuration
NODE_ENV=production
API_PORT=3000
ENABLE_WEB_UI=false  # UI disabled by default in production
LOG_LEVEL=info
```


---

## 🎭 Character Configuration

### Default Character
The included `production-agent.character.json` provides a sample baseline for deployment testing, 

---

## 🔄 Scaling

### Horizontal Scaling
Deploy multiple instances with different configurations:

```bash
# Agent 1 - Discord
DISCORD_API_TOKEN=bot-1-token
docker-compose -f docker-compose.slim.yaml up -d

# Agent 2 - Telegram  
TELEGRAM_BOT_TOKEN=bot-2-token
docker-compose -f docker-compose.slim.yaml -p eliza-telegram up -d

---

## 📚 References

- [ElizaOS Documentation](https://eliza.how/docs/intro)
- [ElizaOS GitHub](https://github.com/elizaOS/eliza)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Coolify Documentation](https://coolify.io/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)


