FROM node:23.3.0-slim AS builder

WORKDIR /app

RUN apt-get update && \n    apt-get install -y --no-install-recommends \n    build-essential \n    curl \n    ffmpeg \n    g++ \n    make \n    python3 \n    unzip && \n    apt-get clean && \n    rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@1.2.5 turbo@2.3.3

RUN ln -s /usr/bin/python3 /usr/bin/python

# Clone the main repository without git history
RUN curl -L https://github.com/elizaos/eliza/archive/refs/tags/v1.0.0-beta.76.tar.gz | tar xz --strip-components=1

# Clone the plugin specification without git
RUN mkdir -p plugin-specification && \n    curl -L https://github.com/elizaos/plugin-specification/archive/refs/heads/main.tar.gz | tar xz --strip-components=1 -C plugin-specification

# Remove the postinstall script that tries to initialize git submodules
RUN sed -i '/postinstall:/d' package.json

RUN bun install --no-cache

RUN bun run build

FROM node:23.3.0-slim

WORKDIR /app

RUN apt-get update && \n    apt-get install -y --no-install-recommends \n    curl \n    ffmpeg \n    python3 \n    unzip && \n    apt-get clean && \n    rm -rf /var/lib/apt/lists/*

RUN npm install -g bun@1.2.5 turbo@2.3.3

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

EXPOSE 3000
EXPOSE 50000-50100/udp

CMD ["bun", "run", "start"]