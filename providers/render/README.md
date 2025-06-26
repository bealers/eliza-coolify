# ElizaOS on Render

Deploy ElizaOS on Render with managed services.

## Prerequisites

- Render account
- GitHub repository
- OpenAI API key

## Quick Deploy

1. **Web Service**: Connect this repository to Render
2. **Database**: Add PostgreSQL service
3. **Environment**: Configure variables
4. **Deploy**: Automatic builds on git push

## Configuration

### Web Service Settings
- **Build Command**: `bun install`
- **Start Command**: `bun run start`
- **Environment**: Node.js

### Environment Variables

See main `env.example`. Key variables:
- `OPENAI_API_KEY`: Your API key
- `DATABASE_URL`: Auto-provided by Render PostgreSQL
- `NODE_ENV=production`

## Features

- **Free tier available**: For testing
- **Auto-scaling**: Built into paid plans  
- **SSL**: Automatic
- **Logs**: Integrated logging
- **Database backups**: Automatic

## Cost

- **Free tier**: Limited hours/month
- **Starter**: $7/month per service
- **PostgreSQL**: $7/month (starter)

## Detailed Guide

*Coming soon - Step-by-step Render deployment with screenshots*

## Support

- Main project: `../../README.md`
- Render docs: [render.com/docs](https://render.com/docs) 