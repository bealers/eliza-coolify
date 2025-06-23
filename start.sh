#!/bin/bash
set -e

# ElizaOS Production Startup Script
# Handles UI enable/disable and PM2 process management

echo "Starting ElizaOS Production Server..."

# Check required environment variables
if [ -z "$POSTGRES_URL" ]; then
    echo "Warning: POSTGRES_URL not set, using default SQLite"
fi

# Set default values
export NODE_ENV=${NODE_ENV:-production}
export API_PORT=${API_PORT:-3000}
export ENABLE_WEB_UI=${ENABLE_WEB_UI:-false}
export LOG_LEVEL=${LOG_LEVEL:-info}
export HOST=${HOST:-0.0.0.0}

echo "Environment Configuration:"
echo "  NODE_ENV: $NODE_ENV"
echo "  API_PORT: $API_PORT"
echo "  HOST: $HOST"
echo "  ENABLE_WEB_UI: $ENABLE_WEB_UI"
echo "  LOG_LEVEL: $LOG_LEVEL"

# Check if ElizaOS CLI is available locally
echo "Checking ElizaOS CLI availability..."
if [ -f "./node_modules/.bin/elizaos" ]; then
    echo "ElizaOS CLI found locally"
    ./node_modules/.bin/elizaos --version || echo "Could not get version"
elif command -v elizaos >/dev/null 2>&1; then
    echo "ElizaOS CLI found in PATH"
    elizaos --version || echo "Could not get version"
elif npx @elizaos/cli@latest --version >/dev/null 2>&1; then
    echo "ElizaOS CLI available via npx"
    npx @elizaos/cli@latest --version
else
    echo "ElizaOS CLI not found - checking if npm install was run..."
    if [ ! -d "node_modules" ]; then
        echo "Installing dependencies..."
        npm install
    else
        echo "Dependencies installed but ElizaOS CLI not found"
        exit 1
    fi
fi

# Configure ElizaOS for API-only mode if UI is disabled
if [ "$ENABLE_WEB_UI" = "false" ]; then
    echo "API-only mode enabled (Web UI disabled)"
    export ELIZA_API_ONLY=true
    export ELIZA_DISABLE_WEB=true
else
    echo "Web UI enabled"
    export ELIZA_API_ONLY=false
    export ELIZA_DISABLE_WEB=false
fi

# Ensure log directory exists
mkdir -p /app/logs

# Validate character files if they exist
if [ -d "/app/characters" ] && [ "$(ls -A /app/characters)" ]; then
    echo "Character files found:"
    ls -la /app/characters/
    
    # Validate JSON files
    for file in /app/characters/*.json; do
        if [ -f "$file" ]; then
            if ! node -p "JSON.parse(require('fs').readFileSync('$file', 'utf8'))" > /dev/null 2>&1; then
                echo "Invalid JSON in $file"
                exit 1
            fi
        fi
    done
    echo "All character files validated"
else
    echo "No character files found, using default configuration"
fi

# Test database connection if available
if [ -n "$POSTGRES_URL" ]; then
    echo "Testing database connection..."
    # Simple connection test - this will be handled by ElizaOS itself
    echo "Database URL configured: ${POSTGRES_URL%%@*}@[REDACTED]"
fi

# Use our structured PM2 management
echo "Using structured PM2 management..."

# Stop any existing PM2 processes first
if pm2 list | grep -q "elizaos"; then
    echo "Stopping existing PM2 process..."
    pm2 stop elizaos || echo "Could not stop existing process"
    pm2 delete elizaos || echo "Could not delete existing process"
fi

# Clear old logs
echo "Clearing old logs..."
truncate -s 0 /app/logs/elizaos-*.log 2>/dev/null || echo "Could not clear logs"

echo "Starting new PM2 process..."
pm2 start ecosystem.config.js

# Wait a moment for the process to initialize
sleep 5

# Show PM2 status
echo "PM2 Status:"
pm2 list

# Show initial logs
echo "Initial Logs:"
pm2 logs elizaos --lines 20 --nostream || echo "Could not display logs"

echo ""
echo "Management commands available:"
echo "   ./scripts/start-elizaos.sh    # Start/restart ElizaOS"
echo "   ./scripts/stop-elizaos.sh     # Stop ElizaOS gracefully"
echo "   ./scripts/status-elizaos.sh   # Show detailed status"
echo "   pm2 logs elizaos             # View logs"
echo "   pm2 monit                    # Monitor resources"
echo ""

# Test if the service is responding
echo "Running initial health check in 10 seconds..."
sleep 10

if node /app/healthcheck.js; then
    echo "Health check passed - service is responding"
else
    echo "Health check failed - investigating..."
    echo "Recent logs:"
    pm2 logs elizaos --lines 50 --nostream || echo "Could not get logs"
    echo ""
    echo "PM2 Status:"
    pm2 list
    echo ""
    echo "Process details:"
    pm2 describe elizaos || echo "Could not get process details"
fi

# Keep the container running by following PM2 logs
echo "Following PM2 logs (Ctrl+C to stop)..."
exec pm2 logs elizaos --raw 