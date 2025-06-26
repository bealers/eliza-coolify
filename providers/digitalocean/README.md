# ElizaOS on DigitalOcean

Deploy ElizaOS on DigitalOcean Droplets using Docker.

## Prerequisites

- DigitalOcean account
- Domain name (optional)
- OpenAI API key

###  DigitalOcean Apps Platform
1. Create new app in Apps Platform
2. Connect this repository
3. Configure environment variables
4. Add managed PostgreSQL database
5. Deploy

## Environment Variables

See main `env.example` for required variables.

## Database Options

- **Managed PostgreSQL**: Recommended for production
- **Docker PostgreSQL**: Included in docker-compose.yaml

## Cost Estimation

- **Basic droplet**: $12-24/month (2-4GB RAM)
- **Managed database**: $15+/month
- **Total**: ~$27-40/month

## Detailed Setup Guide

*Coming soon - This will include step-by-step droplet setup, security configuration, and domain setup.*

## Support

- Main project: `../../README.md`
- DigitalOcean docs: [official documentation](https://docs.digitalocean.com/) 