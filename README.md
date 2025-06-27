# elizaOS Production Deployment

Production-ready Docker deployment for elizaOS agents. Deploy anywhere Docker Compose is supported.

## Quick Start (3 Steps)

1. **Fork this repository** or download the deployment files
2. **Add your character** - Place your `.character.json` file in `config/characters/`
3. **Deploy** - Set your AI API key and run `docker-compose up -d`

Your elizaOS agent is now running at `http://localhost:3000`

---

## Platform Deployment

### Coolify (Recommended)

**One-click deployment with built-in SSL and domain management**

1. **New Project** → **Git Repository**
2. **Repository URL**: `https://github.com/yourusername/your-fork`
3. **Build Pack**: Docker Compose
4. **Compose File**: `docker-compose.yaml`
5. **Environment Variables**:
   ```bash
   OPENAI_API_KEY=sk-your-key-here
   CHARACTER_FILE=/app/config/characters/your-character.character.json
   ```
6. **Domain**: Set your desired subdomain
7. **Deploy**

**Health Check**: Visit your domain to access the web UI

### Local Development

```bash
# Clone and setup
git clone https://github.com/yourusername/your-fork
cd your-fork
cp env.example .env

# Edit .env with your API key
nano .env

# Deploy with internal PostgreSQL
docker-compose up -d

# Check status
docker-compose logs -f eliza
```

### Digital Ocean App Platform

```bash
# Use docker-compose.slim.yaml for external database
# Set environment variables in DO dashboard:
POSTGRES_URL=your-managed-postgres-url
OPENAI_API_KEY=your-api-key
CHARACTER_FILE=/app/config/characters/your-character.character.json
```

### Railway

```bash
# Deploy docker-compose.yaml
# Add environment variables in Railway dashboard
# Railway provides PostgreSQL addon
```

---

## Character Configuration

### Using Your Character

1. **Create your character file** following the [elizaOS character schema](https://eliza.how/docs/core/characterfile)
2. **Save as** `config/characters/your-agent.character.json`
3. **Set environment variable**:
   ```bash
   CHARACTER_FILE=/app/config/characters/your-agent.character.json
   ```
4. **Restart deployment**

### Character File Structure

```json
{
  "name": "YourAgent",
  "bio": [
    "Your agent's background",
    "Personality description"
  ],
  "lore": [
    "Context and knowledge",
    "Behavioral guidelines"
  ],
  "messageExamples": [
    [
      {
        "user": "{{user1}}",
        "content": {"text": "Hello!"}
      },
      {
        "user": "YourAgent", 
        "content": {"text": "Hi there! How can I help you today?"}
      }
    ]
  ],
  "postExamples": [],
  "topics": ["ai", "assistance", "conversation"],
  "style": {
    "all": ["Be helpful", "Stay in character"],
    "chat": ["Conversational tone"],
    "post": ["Professional tone"]
  },
  "adjectives": ["helpful", "knowledgeable", "friendly"]
}
```

### Default Character

The included `server-bod.character.json` serves as a deployment testing baseline and reference example.

---

## Environment Configuration

### Required Variables

```bash
# AI Provider (choose one or more)
OPENAI_API_KEY=sk-your-openai-key
# OR
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key
# OR  
GEMINI_API_KEY=your-gemini-key

# Character Configuration
CHARACTER_FILE=/app/config/characters/your-character.character.json
```

### Database Options

**Option 1: Internal PostgreSQL (Default)**
```bash
# Uses docker-compose.yaml
# No additional configuration needed
```

**Option 2: External PostgreSQL**
```bash
# Use docker-compose.slim.yaml
POSTGRES_URL=postgresql://user:password@host:5432/database
```

### Production Settings

```bash
# Environment
NODE_ENV=production
LOG_LEVEL=info
API_PORT=3000
HOST=0.0.0.0

# Security
JWT_SECRET=your-secure-random-secret
```

### Social Platform Integration

```bash
# Discord Bot
DISCORD_API_TOKEN=your-bot-token
DISCORD_APPLICATION_ID=your-app-id

# Telegram Bot  
TELEGRAM_BOT_TOKEN=your-bot-token

# Twitter/X API
TWITTER_API_KEY=your-api-key
TWITTER_API_SECRET=your-api-secret
```

---

## Management Commands

### Container Management

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f eliza

# Stop services  
docker-compose down

# Rebuild and restart
docker-compose up -d --build
```

### elizaOS Process Management

**Inside Container:**
```bash
# Status check
./scripts/status-elizaos.sh

# Restart elizaOS
./scripts/start-elizaos.sh

# Stop gracefully
./scripts/stop-elizaos.sh
```

**From Host:**
```bash
# Status
docker exec <container> ./scripts/status-elizaos.sh

# Logs
docker exec <container> pm2 logs elizaos

# Restart
docker exec <container> pm2 restart elizaos

# Monitor resources
docker exec <container> pm2 monit
```

---

## Architecture

### Components

- **elizaOS CLI** - Latest published package (`@elizaos/cli@latest`)  
- **PM2 Process Manager** - Auto-restart, monitoring, resource limits
- **PostgreSQL Database** - Internal (default) or external connection
- **Health Monitoring** - API endpoints and process status
- **Security** - Non-root user, proper permissions, CORS configuration

### Features

- **Production-optimized** - Memory limits, process monitoring, graceful shutdowns
- **Scalable** - One agent per container, horizontal scaling support  
- **Secure** - Non-root execution, proper file permissions
- **Monitorable** - Health checks, logging, metrics via PM2

---

## Scaling & Multi-Agent Deployment

### Horizontal Scaling

Deploy multiple instances with different configurations:

```bash
# Agent 1 - Discord
CHARACTER_FILE=/app/config/characters/discord-agent.character.json
DISCORD_API_TOKEN=your-discord-token
docker-compose -p discord-agent up -d

# Agent 2 - Telegram
CHARACTER_FILE=/app/config/characters/telegram-agent.character.json  
TELEGRAM_BOT_TOKEN=your-telegram-token
docker-compose -p telegram-agent up -d
```

### Load Balancing

Use a reverse proxy (nginx, Traefik, Caddy) to distribute requests across multiple agent instances.

---

## Troubleshooting

### Common Issues

**Agent not responding:**
```bash
# Check elizaOS logs
docker-compose logs eliza
docker exec <container> pm2 logs elizaos

# Verify API key
docker exec <container> env | grep API_KEY

# Check character file
docker exec <container> cat /app/config/characters/your-character.character.json
```

**Database connection errors:**
```bash
# Check database status
docker-compose ps
docker exec <container> pg_isready -h db -p 5432

# View database logs
docker-compose logs db
```

**Memory/Performance issues:**
```bash
# Monitor resources
docker exec <container> pm2 monit
docker stats <container>

# Check disk space
docker exec <container> df -h
```

**Character loading errors:**
```bash
# Validate JSON syntax
docker exec <container> node -e "JSON.parse(require('fs').readFileSync('/app/config/characters/your-character.character.json'))"

# Check file permissions
docker exec <container> ls -la /app/config/characters/
```

### Health Checks

- **Web UI**: `http://localhost:3000`
- **API Health**: `http://localhost:3000/api/health`  
- **Agent Status**: `http://localhost:3000/api/agents`

### Log Locations

```bash
# PM2 logs
docker exec <container> pm2 logs

# Container logs  
docker-compose logs eliza

# System logs (inside container)
docker exec <container> tail -f /var/log/syslog
```

---

## Contributing

### Development Setup

```bash
# Fork and clone
git clone https://github.com/yourusername/elizaos-deployment
cd elizaos-deployment

# Local development with hot reload
docker-compose -f docker-compose.dev.yaml up
```

### Testing

```bash
# Run health checks
curl http://localhost:3000/api/health

# Test character loading
curl http://localhost:3000/api/agents
```

---

## References

- [elizaOS Documentation](https://eliza.how/docs/intro)
- [elizaOS GitHub](https://github.com/elizaOS/eliza)
- [Character File Schema](https://eliza.how/docs/core/characterfile)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Coolify Documentation](https://coolify.io/docs)


