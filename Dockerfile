# syntax=docker/dockerfile:1.4

# Eliza Coolify Wrapper 
# --------------------------------
# - Fetches and builds the latest tagged ElizaOS release (by default)
# - Optimized for ease of Coolify installation

FROM node:23.3.0-slim

# Install only what is needed for runtime
RUN apt-get update && \
    apt-get install -y curl ffmpeg python3 unzip ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@1.2.5

WORKDIR /app

# Download and extract the latest ElizaOS release
RUN curl -L https://github.com/elizaOS/eliza/archive/refs/tags/v1.0.9.tar.gz | tar xz --strip-components=1

# Remove dev/test scripts, submodules, and husky completely
RUN rm -rf ./scripts/init-submodules.sh && \
    sed -i -e '/postinstall/d' \
           -e '/"scripts": {/,/},/{ /"postinstall":.*,/d }' \
           -e '/"prepare": "husky install",/d' \
           -e '/"husky": ".*",/d' \
    package.json && \
    rm -rf .husky

# Set environment to ignore prepare scripts during install
ENV HUSKY=0
ENV NODE_ENV=production

# Install only production dependencies
RUN bun install --no-cache --production

# Expose default ElizaOS port
EXPOSE 3000
EXPOSE 50000-50100/udp

# Start the ElizaOS app
CMD ["bun", "run", "start"] 