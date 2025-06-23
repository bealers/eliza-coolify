# syntax=docker/dockerfile:1.4

# ElizaOS Production Deployment

FROM node:23.3.0-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        ffmpeg \
        python3 \
        ca-certificates \
        dumb-init \
        procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install PM2 globally for process management
RUN npm install -g pm2@5.3.0

# Install ElizaOS CLI (not globally)
RUN npm install -g @elizaos/cli@1.0.9

# Create app user
RUN groupadd -r eliza && useradd -r -g eliza -s /bin/bash eliza

WORKDIR /app

# Create necessary directories with proper permissions
RUN mkdir -p /app/characters /app/data /app/logs && \
    chown -R eliza:eliza /app

# Copy application files
COPY --chown=eliza:eliza ecosystem.config.js ./
COPY --chown=eliza:eliza start.sh ./
COPY --chown=eliza:eliza healthcheck.js ./
COPY --chown=eliza:eliza .env* ./

# Copy management scripts
COPY --chown=eliza:eliza scripts/ ./scripts/

# Copy character files if they exist
COPY --chown=eliza:eliza characters/ ./characters/

# Make scripts executable
RUN chmod +x start.sh healthcheck.js scripts/*.sh

# Switch to app user
USER eliza

# Expose ElizaOS ports
EXPOSE 3000
EXPOSE 50000-50100/udp

# Health check with comprehensive monitoring
HEALTHCHECK --interval=30s --timeout=15s --start-period=90s --retries=3 \
    CMD node /app/healthcheck.js || exit 1

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start ElizaOS using PM2 through our startup script
CMD ["./start.sh"] 