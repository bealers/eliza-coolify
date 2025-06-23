# ElizaOS Coolify Production Deployment

Production-ready ElizaOS deployment configuration for Coolify, Docker, and self-hosted environments.

---

## Quick Coolify Deployment

1. **Point Coolify** to this repository (public Github deploy)
2. **Build Pack** `Docker Compose`
3. **Use `docker-compose.yaml`** as compose file (includes PostgreSQL)
4. **Set environment variables using the UI**: e.g. `OPENAI_API_KEY`
5. **Coolify deploys**
6. **Manage** with `./scripts/status-elizaos.sh`

Assuming you already have wildcard DNS and SSL setup (via the built in proxy) you can set the URL to be https://eliza.yourcoolify.tld.com and 


### Required Environment Variables

```bash
# AI Provider (REQUIRED - choose one)
OPENAI_API_KEY=sk-your-openai-key-here
# OR ANTHROPIC_API_KEY=sk-ant-your-key
# OR GEMINI_API_KEY=your-gemini-key

# Database is auto-configured with internal PostgreSQL

# Production Settings (optional)
NODE_ENV=production
LOG_LEVEL=info
JWT_SECRET=your-secure-secret
```

---

## Troubleshooting: Local vs Coolify Deployment Differences

### Why It Worked Locally But Failed on Coolify

The main differences between local testing and Coolify deployment that can cause issues:

#### 1. **Bun Runtime Path Issues**
- **Local**: Docker Desktop may run containers with different user privileges
- **Coolify**: Stricter container security and user context
- **Fix**: Global bun symlink in Dockerfile (`ln -sf /root/.bun/bin/bun /usr/local/bin/bun`)

#### 2. **PM2 Interpreter Configuration**
- **Local**: May fall back to Node.js when bun path is incorrect
- **Coolify**: Stricter runtime environment
- **Fix**: Use `interpreter: 'bun'` in `ecosystem.config.js` instead of absolute paths

#### 3. **ElizaOS CLI Installation Method**
- **Local**: Might use global installations or different package resolution
- **Coolify**: Uses only local `node_modules/.bin/elizaos`
- **Fix**: Use `script: './node_modules/.bin/elizaos'` in PM2 config

#### 4. **Container Networking**
- **Local**: Docker networking may be more permissive
- **Coolify**: Stricter network policies and proxy configuration
- **Fix**: Ensure `HOST: '0.0.0.0'` in environment variables

### Common Error Patterns

**PM2 Process Errored (Status: errored, Restarts: 9+)**
```bash
# Symptoms: Empty logs, ECONNREFUSED health checks
# Cause: ElizaOS CLI not starting due to interpreter issues
# Fix: Check ecosystem.config.js uses correct bun path and elizaos binary
```

**ECONNREFUSED on Health Check**
```bash
# Symptoms: API not responding on port 3000
# Cause: Process not starting or binding to wrong interface
# Fix: Verify HOST=0.0.0.0 and process is actually running
```

**Bun Command Not Found**
```bash
# Symptoms: PM2 can't find bun interpreter
# Cause: Bun not in PATH for eliza user
# Fix: Global bun symlink in Dockerfile
```

### Quick Fixes

1. **Rebuild with Fixed Dockerfile**:
   ```bash
   # The Dockerfile now includes global bun symlink
   # Redeploy from Coolify will use the updated image
   ```

2. **Check PM2 Configuration**:
   ```javascript
   // ecosystem.config.js should use:
   interpreter: 'bun',
   script: './node_modules/.bin/elizaos',
   ```

3. **Verify Environment Variables**:
   ```bash
   # Ensure these are set in Coolify:
   NODE_ENV=production
   HOST=0.0.0.0
   API_PORT=3000
   ```

---

## Architecture

### Core Components
- **ElizaOS CLI** - Built with `@elizaos/cli@latest` (published package approach)
- **PM2 Process Manager** - Auto-restart, monitoring, resource limits  
- **PostgreSQL Database** - Internal database (auto-configured) or external
- **Health Monitoring** - API endpoints + PM2 status tracking
- **Security Hardening** - Non-root user, proper permissions, CORS

### Key Features
- **Production-ready** - Optimized for server deployment
- **One agent per container** - Scalable microservice architecture
- **Local package installation** - ElizaOS CLI installed locally, not globally as root

---

## Alternative Deployment Options

### Option 1: Advanced Coolify (External PostgreSQL)

For shared/existing PostgreSQL instances:
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

## Process Management

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

## Environment Configuration

### Required Variables
```bash
# Database (REQUIRED)
POSTGRES_URL=postgresql://username:password@hostname:5432/database_name

# AI Provider (REQUIRED - choose one or more)
OPENAI_API_KEY=sk-your-openai-api-key
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
GEMINI_API_KEY=your-gemini-key-here
```

### Production Settings
```bash
# Core Configuration
NODE_ENV=production
API_PORT=3000
HOST=0.0.0.0  # Essential for Docker networking
LOG_LEVEL=info
```

---

## Character Configuration

### Default Character
The included `characters/server-bod.character.json` provides a sample baseline for deployment testing.

---

## Scaling

### Horizontal Scaling
Deploy multiple instances with different configurations:

```bash
# Agent 1 - Discord
DISCORD_API_TOKEN=bot-1-token
docker-compose -f docker-compose.slim.yaml up -d

# Agent 2 - Telegram  
TELEGRAM_BOT_TOKEN=bot-2-token
docker-compose -f docker-compose.slim.yaml -p eliza-telegram up -d
```

---

## References

- [ElizaOS Documentation](https://eliza.how/docs/intro)
- [ElizaOS GitHub](https://github.com/elizaOS/eliza)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Coolify Documentation](https://coolify.io/docs)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)


