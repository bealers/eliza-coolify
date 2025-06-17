# syntax=docker/dockerfile:1.4

# Eliza Coolify Wrapper 
# --------------------------------
# - Fetches and builds the latest tagged ElizaOS release (by default)
# - Optimized for ease of Coolify installation

FROM node:23.3.0-slim as builder

# Allow override of ElizaOS version/tag at build time
ARG ELIZA_TAG=latest
ENV ELIZA_TAG=${ELIZA_TAG}

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    curl \
    ffmpeg \
    g++ \
    git \
    make \
    python3 \
    unzip \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@1.2.5 turbo@2.3.3

RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app

# Download ElizaOS
RUN if [ "$ELIZA_TAG" = "latest" ]; then \
      export ELIZA_TAG=$(curl -s https://api.github.com/repos/elizaOS/eliza/releases/latest | grep tag_name | cut -d '"' -f4); \
    fi && \
    echo "Using ElizaOS tag: $ELIZA_TAG" && \
    curl -L https://github.com/elizaos/eliza/archive/refs/tags/$ELIZA_TAG.tar.gz | tar xz --strip-components=1

# Remove git submodules script and modify package.json
RUN rm -f ./scripts/init-submodules.sh && \
    sed -i -e '/postinstall/d' \
           -e '/"scripts": {/,/},/{ /"postinstall":.*,/d }' \
           -e 's/"prepare": "husky install"/"prepare": "echo Skipping husky install"/g' \
    package.json

# Install dependencies and build
RUN bun install --no-cache && \
    turbo run build || true

# Create production image
FROM node:23.3.0-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ffmpeg \
    python3 \
    unzip \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@1.2.5 turbo@2.3.3

# Copy built files from builder
COPY --from=builder /app/package.json ./
COPY --from=builder /app/bun.lockb ./
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