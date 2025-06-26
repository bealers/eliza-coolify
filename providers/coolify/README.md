# ElizaOS on Coolify

This guide covers deploying ElizaOS using Coolify, a self-hosted deployment platform.

## Prerequisites

- Coolify instance running
- Domain name configured (optional but recommended)
- OpenAI API key

## Quick Deploy

1. **Create New Project** in Coolify
2. **Add Git Repository**: Point to this repository
3. **Configure Environment Variables** (see env.example)
4. **Deploy**

## Environment Variables

Copy from the main `env.example` and set these Coolify-specific values:

```bash
# Core ElizaOS
OPENAI_API_KEY=your_openai_key_here

# Database (automatically provided by Coolify)
DATABASE_URL=postgresql://user:pass@host:5432/dbname

# Server Configuration
NODE_ENV=production
LOG_LEVEL=info
```

## Coolify Configuration

### Service Configuration
- **Port**: 3000 (automatically detected)
- **Build Command**: `bun install`
- **Start Command**: `bun run start`

### Database Setup
1. Add PostgreSQL database service in Coolify
2. Connect it to your ElizaOS application
3. Database URL will be automatically injected

### Domain & SSL
- Configure your domain in Coolify
- SSL is automatically handled via Let's Encrypt

## Deployment Steps

1. Fork/clone this repository
2. Create new project in Coolify
3. Connect your repository
4. Add environment variables
5. Add PostgreSQL database
6. Deploy!

## Troubleshooting

### Common Issues
- **Container won't start**: Check environment variables
- **Database connection failed**: Verify DATABASE_URL
- **Plugin loading errors**: Ensure all required env vars are set

### Logs
Access logs through Coolify's web interface:
- Application logs: Real-time in Coolify dashboard
- Database logs: Available in database service logs

## Support

- Main project docs: `../../README.md`
- General troubleshooting: `../../docs/troubleshooting.md`
- Architecture overview: `../../docs/architecture.md` 