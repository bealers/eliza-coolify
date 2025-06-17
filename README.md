# Eliza Coolify Wrapper

This repository makes it easy to deploy the latest [ElizaOS](https://github.com/elizaOS/eliza) on Coolify, with sensible defaults for most users.

## Default: Full Stack Deployment (Coolify Recommended)

By default, this setup runs both Eliza and a bundled Postgres database, mirroring the official ElizaOS configuration.

### Steps
1. Create a new app in Coolify and point it to this repo.
2. Set your environment variables in the Coolify UI (see below).
3. Deploy. Both Eliza and Postgres will be started automatically.

### Environment Variables
Set these in Coolify:
```
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=...
# if this is not 3000, you will need to change the Coolify proxy config
SERVER_PORT=3000 
# ...any other ElizaOS envs you need
```

The Eliza service will connect to the bundled Postgres by default.

## Advanced: Use an External Postgres (compose.slim.yaml)

If you want to use your own Postgres instance (e.g., managed database, shared DB, etc.), use the `docker-compose.slim.yaml` file:

1. In Coolify, set the compose file to `docker-compose.slim.yaml`.
2. Set the `POSTGRES_URL` environment variable to your external database connection string:
   ```
   POSTGRES_URL=postgresql://user:password@host:5432/db
   ```
3. Deploy. Only the Eliza service will be started.

## Reference
- [ElizaOS GitHub](https://github.com/elizaOS/eliza)



