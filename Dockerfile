# syntax=docker/dockerfile:1.4

# Eliza Coolify Wrapper 
# --------------------------------
# - Fetches and builds the latest tagged ElizaOS release (by default)
# - Optimized for ease of Coolify installation

FROM node:23.3.0-slim

# Allow setting ElizaOS version at build time
ARG ELIZA_VERSION=v1.0.9

# Install only what is needed for runtime
RUN apt-get update && \
    apt-get install -y curl ffmpeg python3 unzip ca-certificates jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@1.2.5

WORKDIR /app

# Download and extract the specified ElizaOS release
RUN curl -L https://github.com/elizaOS/eliza/archive/refs/tags/${ELIZA_VERSION}.tar.gz | tar xz --strip-components=1

# Clean up package.json and remove all development artifacts
RUN rm -rf ./scripts/init-submodules.sh .husky bun.lockb && \
    jq 'del(.devDependencies) | del(.scripts.prepare) | del(.scripts.postinstall) | del(.husky)' package.json > package.json.tmp && \
    mv package.json.tmp package.json

# Set environment to ignore prepare scripts during install
ENV HUSKY=0
ENV NODE_ENV=production

# Install only production dependencies, allow lockfile update
RUN bun install --production --no-frozen-lockfile

# Expose default ElizaOS port
EXPOSE 3000
EXPOSE 50000-50100/udp

# Start the ElizaOS app
CMD ["bun", "run", "start"] 