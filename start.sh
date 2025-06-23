#!/bin/bash
set -e

# ElizaOS Production Startup Script
# Handles UI enable/disable and PM2 process management

echo "🚀 Starting ElizaOS Production Server..."

# Check required environment variables
if [ -z "$POSTGRES_URL" ]; then
    echo "⚠️  Warning: POSTGRES_URL not set, using default SQLite"
fi

# Set default values
export NODE_ENV=${NODE_ENV:-production}
export API_PORT=${API_PORT:-3000}
export ENABLE_WEB_UI=${ENABLE_WEB_UI:-false}
export LOG_LEVEL=${LOG_LEVEL:-info}

echo "📊 Environment Configuration:"
echo "  NODE_ENV: $NODE_ENV"
echo "  API_PORT: $API_PORT"
echo "  ENABLE_WEB_UI: $ENABLE_WEB_UI"
echo "  LOG_LEVEL: $LOG_LEVEL"

# Configure ElizaOS for API-only mode if UI is disabled
if [ "$ENABLE_WEB_UI" = "false" ]; then
    echo "🔒 API-only mode enabled (Web UI disabled)"
    export ELIZA_API_ONLY=true
    export ELIZA_DISABLE_WEB=true
else
    echo "🌐 Web UI enabled"
    export ELIZA_API_ONLY=false
    export ELIZA_DISABLE_WEB=false
fi

# Ensure log directory exists
mkdir -p /app/logs

# Validate character files if they exist
if [ -d "/app/characters" ] && [ "$(ls -A /app/characters)" ]; then
    echo "📝 Character files found:"
    ls -la /app/characters/
    
    # Validate JSON files
    for file in /app/characters/*.json; do
        if [ -f "$file" ]; then
            if ! node -p "JSON.parse(require('fs').readFileSync('$file', 'utf8'))" > /dev/null 2>&1; then
                echo "❌ Invalid JSON in $file"
                exit 1
            fi
        fi
    done
    echo "✅ All character files validated"
else
    echo "ℹ️  No character files found, using default configuration"
fi

# Use our structured PM2 management
echo "🔧 Using structured PM2 management..."

# Check if PM2 is already running
if pm2 list | grep -q "elizaos"; then
    echo "♻️  Restarting existing PM2 process..."
    pm2 restart elizaos
else
    echo "🆕 Starting new PM2 process..."
    pm2 start ecosystem.config.js
fi

# Show PM2 status
pm2 list
pm2 logs elizaos --lines 10

echo ""
echo "🎯 Management commands available:"
echo "   ./scripts/start-elizaos.sh    # Start/restart ElizaOS"
echo "   ./scripts/stop-elizaos.sh     # Stop ElizaOS gracefully"
echo "   ./scripts/status-elizaos.sh   # Show detailed status"
echo "   pm2 logs elizaos             # View logs"
echo "   pm2 monit                    # Monitor resources"
echo ""

# Keep the container running by following PM2 logs
echo "📋 Following PM2 logs (Ctrl+C to stop)..."
exec pm2 logs elizaos --raw 