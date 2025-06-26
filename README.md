# Elizify - Just Works Eliza Prod Deployments

Production-ready ElizaOS deployment that works across multiple cloud providers.

---

## Choose Your Platform

| Platform | Setup Time | Cost | Status |
|----------|------------|------|--------|
| **Custom** | 10 minutes | Just Docker | [Deploy Guide](providers/custom/README.md) |
| **Coolify** | 5 minutes | Self-hosted | [Deploy Guide](providers/coolify/README.md) |
| **Railway** | 2 minutes | $5+/month | Coming Soon |
| **Render** | 3 minutes | $7+/month | Coming Soon |
| **DigitalOcean** | 10 minutes | $12+/month | Coming Soon |

**First time?** Start with **Custom** for full control or **Coolify** for managed self-hosting.

---

## Quick Deploy Workflow

### 1. Fork & Customize
```bash
# 1. Fork and clone
git clone https://github.com/YOUR-USERNAME/elizify.git
cd elizify

# 3. Add your character files to config/characters/
cp your-character.json config/characters/
# Edit config/characters/your-character.json

# 4. Push your customizations
git add config/characters/
git commit -m "Add custom character"
git push
```

### 2. Deploy Your Fork

#### Custom (Docker Compose)
```bash
cp env.example .env
# Edit .env with your OPENAI_API_KEY and CHARACTER_FILE
docker-compose up -d
```

#### Coolify
1. Point Coolify at **your forked repository**
2. Add environment variables (see below)
3. Deploy

Your ElizaOS agent will be running with your custom character.

---

## Environment Configuration

### Required Variables
```bash
# AI Provider API Key (required)
OPENAI_API_KEY=sk-your-openai-key-here

# Character Configuration
CHARACTER_FILE=your-character.json
CHARACTER_NAME=Your Agent Name

# Database (auto-configured in most platforms)
DATABASE_URL=postgresql://user:pass@host:5432/dbname

# Server Configuration  
NODE_ENV=production
LOG_LEVEL=info
```

### Optional Variables
```bash
# Alternative AI Providers
ANTHROPIC_API_KEY=sk-ant-your-key
GEMINI_API_KEY=your-gemini-key

# Security & Performance
SECURITY_ENABLED=true
MAX_CONCURRENT_REQUESTS=10
RATE_LIMIT_ENABLED=true
```

---

## What You Get

### Core Features
- **Web Interface**: Direct chat with your AI agent
- **Socket.IO**: Real-time chat functionality  
- **REST API**: Integration endpoints for external systems
- **Multi-character**: Support for multiple agent personalities
- **Plugin System**: Full ElizaOS plugin ecosystem compatibility

### Production Features
- **Non-privileged execution**: Secure container without root access
- **Process supervision**: PM2 with proper restart policies
- **Health monitoring**: Built-in health checks and status endpoints
- **Dynamic plugin loading**: Automatic plugin installation and loading
- **Database management**: Automatic schema setup and migrations
- **Resource management**: Memory and CPU optimization

### Security & Reliability
- **Environment-based secrets**: No hardcoded API keys
- **Database isolation**: Secure PostgreSQL with proper user permissions
- **Container hardening**: Minimal attack surface
- **SSL termination**: HTTPS support via provider infrastructure
- **Graceful shutdown**: Proper cleanup on container stop

---

## Requirements

- **OpenAI API key** (or Anthropic/Gemini alternative)
- **2GB+ RAM** recommended for stable operation
- **PostgreSQL database** (auto-configured on most platforms)
- **Node.js 18+** runtime (handled by container)

---

## Project Structure

```
elizify/
├── scripts/           # Core deployment scripts
│   ├── start.sh       # Main container startup
│   ├── elizaos-wrapper.sh  # PM2 wrapper for direct execution
│   └── status-elizaos.sh   # Health and status monitoring
├── config/           # Agent configuration
│   └── characters/   # Character definition files (customize here)
├── providers/        # Platform-specific deployment guides  
│   ├── custom/       # Docker Compose setup
│   └── coolify/      # Coolify platform guide
├── database/         # Schema and migrations
│   ├── schema/       # Clean database initialization
│   ├── migrations/   # Database updates and fixes
│   └── scripts/      # Database maintenance utilities
├── testing/          # Test utilities
│   ├── chat/         # Socket.IO chat testing
│   └── health/       # Health check scripts
└── docs/            # Architecture and troubleshooting
```

---

## Character Customization

### Adding Your Character

1. **Create character file** in `config/characters/your-agent.json`
2. **Set environment variable** `CHARACTER_FILE=your-agent.json`  
3. **Deploy** - your agent personality will be loaded automatically

### Character File Structure
```json
{
  "name": "Your Agent Name",
  "bio": "Agent background and personality",
  "lore": ["Character backstory", "Key traits"],
  "knowledge": ["Domain expertise", "Special knowledge"],
  "messageExamples": [
    [{"user": "User1", "content": {"text": "Hello"}}],
    [{"user": "YourAgent", "content": {"text": "Hello! How can I help?"}}]
  ],
  "postExamples": ["Example posts your agent might make"],
  "topics": ["Topics your agent knows about"],
  "style": {
    "all": ["Tone", "Communication style"],
    "chat": ["Chat-specific behaviors"],
    "post": ["Social media style"]
  },
  "adjectives": ["Personality traits"]
}
```

---

## Management & Monitoring

### Health Checks
```bash
# HTTP health endpoint
curl http://your-domain/health

# Container status (for custom deployments)
docker exec elizify-elizaos-1 ./scripts/status-elizaos.sh

# Chat functionality test
bun testing/chat/test-chat-correct.js
```

### Process Management (Custom Deployments)
```bash
# View logs
docker-compose logs -f elizaos

# Restart service
docker-compose restart elizaos

# Update deployment
git pull
docker-compose pull
docker-compose up -d
```

---

## Need Help?

- **Custom Setup**: See [providers/custom/README.md](providers/custom/README.md)
- **Coolify Setup**: See [providers/coolify/README.md](providers/coolify/README.md)
- **Architecture Details**: See [docs/architecture.md](docs/architecture.md)
- **Character Creation**: Check ElizaOS character documentation

---

## Contributing

Production deployments only. All guides must be tested before merge.
