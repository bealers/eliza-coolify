# syntax=docker/dockerfile:1.4

# ElizaOS Production Deployment

FROM oven/bun:1.2.17-slim

# Install Node.js 23.x and system dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        ffmpeg \
        python3 \
        ca-certificates \
        dumb-init \
        procps \
        unzip \
        gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_23.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create app user
RUN groupadd -r eliza && useradd -r -g eliza -s /bin/bash eliza

WORKDIR /app

# Create necessary directories with proper permissions
RUN mkdir -p /app/config /app/data /app/logs && \
    chown -R eliza:eliza /app && \
    mkdir -p /home/eliza/.pm2 && \
    chown -R eliza:eliza /home/eliza/.pm2 && \
    mkdir -p /home/eliza/.npm && \
    chown -R eliza:eliza /home/eliza/.npm

# Copy package.json first for better Docker layer caching
COPY --chown=eliza:eliza package.json ./

# Install dependencies as root (before switching to eliza user)
RUN bun install

# Copy application files
COPY --chown=eliza:eliza config/ecosystem.config.js ./config/
COPY --chown=eliza:eliza scripts/start.sh ./scripts/
COPY --chown=eliza:eliza scripts/healthcheck.js ./scripts/

# Copy management scripts
COPY --chown=eliza:eliza scripts/ ./scripts/

# Copy character files if they exist
COPY --chown=eliza:eliza config/ ./config/

# Make scripts executable
RUN chmod +x scripts/*.sh scripts/*.js

# Switch to app user for security
USER eliza

# Expose ElizaOS ports
EXPOSE 3000
EXPOSE 50000-50100/udp

# Health check with comprehensive monitoring
HEALTHCHECK --interval=30s --timeout=15s --start-period=90s --retries=3 \
    CMD bun /app/scripts/healthcheck.js || exit 1

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start ElizaOS using PM2 through our startup script
CMD ["./start.sh"] 