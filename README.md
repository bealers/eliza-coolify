# elizaOS Production Deployment

Production-ready Docker deployment for elizaOS agents. Deploy anywhere Docker Compose is supported.

## Quick Start (3 Steps)

1. **Fork this repository** or download the deployment files
2. **Set your API keys** in environment variables
3. **Deploy** - Run `docker-compose up -d`

Your elizaOS agent is running at `http://localhost:3000` with chat interface and ready for API connections.

## What's Included

- **Non-root execution** - Runs as dedicated user with proper file permissions
- **PostgreSQL database** - Internal database included, external database support
- **PM2 process management** - Auto-restart on failure, 2GB memory limit, graceful shutdowns
- **Health monitoring** - API health endpoints, PM2 status monitoring, structured logging
- **Docker deployment** - Standard Docker Compose, works on any Docker based platform

---

## Platform Deployment

### Coolify (Tested)

**Deployment with SSL and domain management**

1. **New Project** → **Git Repository**
2. **Repository URL**: `https://github.com/yourusername/your-fork`
3. **Build Pack**: Docker Compose
4. **Compose File**: `docker-compose.yaml`
5. **Environment Variables**: Set your AI API key (see [Environment Setup](#environment-configuration))
6. **Deploy**


### Cloud Platforms

- **Digital Ocean**: Use `docker-compose.slim.yaml` with managed PostgreSQL
- **Railway**: Deploy `docker-compose.yaml` with Railway PostgreSQL addon
- **AWS/GCP**: Use `docker-compose.slim.yaml` with managed database services

---

## Environment Configuration
### Database Options

**Internal PostgreSQL (Default)**
```bash
# Uses docker-compose.yaml - no configuration needed
```

**External PostgreSQL (Production)**
```bash
# Use docker-compose.slim.yaml
POSTGRES_URL=postgresql://user:password@host:5432/database
```

### Optional Platform Integration

```bash
# Discord Bot
DISCORD_APPLICATION_ID=your-app-id
DISCORD_API_TOKEN=your-bot-token

# Telegram Bot
TELEGRAM_BOT_TOKEN=your-bot-token
```

**Complete environment reference**: See `env.example` for all options.

---

## Character Configuration

### Default Character
Includes a production-ready character (`server-bod.character.json`) for immediate deployment testing.

### Custom Characters
1. **Create your character** following the [elizaOS character schema](https://eliza.how/docs/core/characterfile)
2. **Place in** `config/characters/your-character.character.json`
3. **Set environment**: `CHARACTER_FILE=/app/config/characters/your-character.character.json`
4. **Restart deployment**

**Character Development**: See [elizaOS Documentation](https://eliza.how/docs/core/characterfile) for detailed character creation guides.

---

## Management & Monitoring

### Container Management

```bash
# Start/restart services
docker-compose up -d

# View logs in real-time
docker-compose logs -f eliza

# Stop services
docker-compose down
```

### Agent Monitoring

```bash
# Comprehensive status
docker exec <container> ./scripts/status-elizaos.sh

# Process monitoring
docker exec <container> pm2 monit

# View agent logs
docker exec <container> pm2 logs elizaos
```

### Multi-Agent Scaling

```bash
# Deploy multiple agents with different configurations
CHARACTER_FILE=/app/config/characters/discord-agent.character.json
DISCORD_API_TOKEN=your-token
docker-compose -p discord-agent up -d

CHARACTER_FILE=/app/config/characters/telegram-agent.character.json
TELEGRAM_BOT_TOKEN=your-token
docker-compose -p telegram-agent up -d
```

---

## Troubleshooting

### Quick Diagnostics

```bash
# Check all services
docker-compose ps

# View agent logs
docker-compose logs eliza

# Check agent process
docker exec <container> pm2 list

# Validate configuration
docker exec <container> ./scripts/status-elizaos.sh
```

### Common Issues

**Agent not responding**: Check API key configuration and elizaOS logs
**Database errors**: Verify PostgreSQL connection and credentials  
**Memory issues**: Monitor with `pm2 monit` and adjust container resources
**Character loading**: Validate JSON syntax and file permissions

### Performance Monitoring

```bash
# Resource usage
docker stats <container>

# Process monitoring
docker exec <container> pm2 monit

# Database status
docker exec <container> pg_isready -h db -p 5432
```

---

## Contributing

Open to PRs and collaboration.

