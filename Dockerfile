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
RUN mkdir -p /app/characters /app/data /app/logs && \
    chown -R eliza:eliza /app && \
    mkdir -p /home/eliza/.pm2 && \
    chown -R eliza:eliza /home/eliza/.pm2 && \
    mkdir -p /home/eliza/.npm && \
    chown -R eliza:eliza /home/eliza/.npm

# Add both Bun and Node.js to PATH for eliza user
RUN echo 'export PATH="/root/.bun/bin:$PATH"' >> /home/eliza/.bashrc && \
    chown eliza:eliza /home/eliza/.bashrc

# Copy package.json first for better Docker layer caching
COPY --chown=eliza:eliza package.json ./

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

# Install ElizaOS CLI locally using Bun
RUN bun install

# Expose ElizaOS ports
EXPOSE 3000
EXPOSE 50000-50100/udp

# Health check with comprehensive monitoring
HEALTHCHECK --interval=30s --timeout=15s --start-period=90s --retries=3 \
    CMD bun /app/healthcheck.js || exit 1

# Use dumb-init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start ElizaOS using PM2 through our startup script
CMD ["./start.sh"] 