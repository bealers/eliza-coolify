# syntax=docker/dockerfile:1.4

#
# Eliza Coolify Wrapper Dockerfile
# --------------------------------
# - Fetches and builds the latest ElizaOS release by default.
# - Optimized for Coolify

FROM node:23.3.0-slim AS builder

# Allow override of ElizaOS version/tag at build time
ARG ELIZA_TAG=latest
ENV ELIZA_TAG=${ELIZA_TAG}

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    ffmpeg \
    g++ \
    make \
    python3 \
    unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@1.2.5 turbo@2.3.3

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN if [ "$ELIZA_TAG" = "latest" ]; then \
      export ELIZA_TAG=$(curl -s https://api.github.com/repos/elizaOS/eliza/releases/latest | grep tag_name | cut -d '"' -f4); \
    fi && \
    echo "Using ElizaOS tag: $ELIZA_TAG" && \
    curl -L https://github.com/elizaos/eliza/archive/refs/tags/$ELIZA_TAG.tar.gz | tar xz --strip-components=1

# Download plugin-specification (required for ElizaOS plugins)
RUN mkdir -p plugin-specification && \
    curl -L https://github.com/elizaos/plugin-specification/archive/refs/heads/main.tar.gz | tar xz --strip-components=1 -C plugin-specification

# Remove postinstall script that tries to initialize git submodules (not needed in this wrapper)
RUN sed -i '/postinstall:/d' package.json

RUN bun install --no-cache

# Build the ElizaOS app
RUN bun run build

# --- Runtime Stage ---
FROM node:23.3.0-slim

WORKDIR /app

# Install runtime dependencies only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ffmpeg \
    python3 \
    unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@1.2.5 turbo@2.3.3

# Copy built app and dependencies from builder stage
COPY --from=builder /app/package.json ./
COPY --from=builder /app/turbo.json ./
COPY --from=builder /app/tsconfig.json ./
COPY --from=builder /app/lerna.json ./
COPY --from=builder /app/renovate.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/plugin-specification ./plugin-specification
COPY --from=builder /app/scripts ./scripts

ENV NODE_ENV=production

# Expose default ElizaOS ports
EXPOSE 3000
EXPOSE 50000-50100/udp

# Start the ElizaOS app
CMD ["bun", "run", "start"] 