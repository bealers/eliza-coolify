#!/bin/bash
set -e

# ElizaOS Production Status Script
# Shows comprehensive status of ElizaOS deployment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "📊 ElizaOS Production Status"
echo "📁 Project Directory: $PROJECT_DIR"
echo "⏰ Timestamp: $(date)"
echo ""

# Function to check if we're in a container
is_container() {
    [ -f /.dockerenv ] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null
}

# Container vs Host execution
if is_container; then
    echo "🐳 Environment: Container"
    ELIZAOS_MODE="container"
else
    echo "🖥️  Environment: Host System"
    ELIZAOS_MODE="host"
fi

echo ""

# Check if PM2 is available
if ! command -v pm2 &> /dev/null; then
    echo "❌ PM2 not found"
    exit 1
fi

# Check if ElizaOS CLI is available
if command -v elizaos &> /dev/null; then
    echo "✅ ElizaOS CLI: Available"
    ELIZAOS_VERSION=$(elizaos --version 2>/dev/null || echo "unknown")
    echo "   Version: $ELIZAOS_VERSION"
else
    echo "❌ ElizaOS CLI: Not found"
fi

echo ""

# PM2 Status
echo "📋 PM2 Process Status:"
if pm2 list | grep -q "elizaos"; then
    # ElizaOS process exists
    if pm2 list | grep -q "elizaos.*online"; then
        echo "✅ ElizaOS: Running"
        
        # Get process details
        PM2_INFO=$(pm2 show elizaos 2>/dev/null || echo "")
        if [ -n "$PM2_INFO" ]; then
            echo "$PM2_INFO" | grep -E "(status|pid|uptime|restarts|memory|cpu)" | sed 's/^/   /'
        fi
    elif pm2 list | grep -q "elizaos.*stopped"; then
        echo "🔴 ElizaOS: Stopped"
    else
        echo "❓ ElizaOS: Unknown state"
    fi
else
    echo "⚪ ElizaOS: Not managed by PM2"
fi

echo ""

# Show all PM2 processes
echo "📊 All PM2 Processes:"
pm2 list

echo ""

# API Health Check
API_PORT=${API_PORT:-3000}
echo "🔍 API Health Check (port $API_PORT):"

if command -v curl &> /dev/null; then
    HEALTH_URL="http://localhost:$API_PORT/api/health"
    
    if curl -s -f "$HEALTH_URL" -m 10 > /dev/null 2>&1; then
        echo "✅ API Health Check: PASSED"
        
        # Try to get health details
        HEALTH_RESPONSE=$(curl -s "$HEALTH_URL" -m 5 2>/dev/null || echo "")
        if [ -n "$HEALTH_RESPONSE" ]; then
            echo "   Response: $HEALTH_RESPONSE"
        fi
    else
        echo "❌ API Health Check: FAILED"
        echo "   URL: $HEALTH_URL"
        echo "   Check if ElizaOS is running and accessible"
    fi
else
    echo "⚠️  curl not available - skipping API health check"
fi

echo ""

# Environment Check
echo "🔧 Environment Configuration:"
ENV_VARS=("NODE_ENV" "API_PORT" "ENABLE_WEB_UI" "LOG_LEVEL" "DATABASE_URL")
AI_VARS=("OPENAI_API_KEY" "ANTHROPIC_API_KEY" "GEMINI_API_KEY")

for var in "${ENV_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        if [ "$var" = "DATABASE_URL" ]; then
            # Hide sensitive database URL details
            DB_TYPE=$(echo "${!var}" | cut -d: -f1)
            echo "   $var: $DB_TYPE://***"
        else
            echo "   $var: ${!var}"
        fi
    else
        echo "   $var: (not set)"
    fi
done

# Check AI providers
AI_PROVIDER_FOUND=false
echo "   AI Providers:"
for var in "${AI_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        echo "   ✅ $var: configured"
        AI_PROVIDER_FOUND=true
    else
        echo "   ⚪ $var: not set"
    fi
done

if [ "$AI_PROVIDER_FOUND" = false ]; then
    echo "   ⚠️  No AI provider configured!"
fi

echo ""

# Log Files Status
echo "📝 Log Files:"
LOG_DIRS=("$PROJECT_DIR/logs" "/app/logs")

for log_dir in "${LOG_DIRS[@]}"; do
    if [ -d "$log_dir" ]; then
        echo "   Directory: $log_dir"
        
        if [ "$(ls -A "$log_dir" 2>/dev/null)" ]; then
            echo "   Files:"
            ls -la "$log_dir" | tail -n +2 | while read -r line; do
                echo "     $line"
            done
        else
            echo "   (empty)"
        fi
        break
    fi
done

echo ""

# Character Files Status
echo "🎭 Character Configuration:"
if [ -d "$PROJECT_DIR/characters" ] && [ "$(ls -A "$PROJECT_DIR/characters")" ]; then
    echo "   Directory: $PROJECT_DIR/characters"
    echo "   Files:"
    ls -la "$PROJECT_DIR/characters"/*.json 2>/dev/null | while read -r line; do
        echo "     $line"
    done
else
    echo "   No custom character files found"
fi

echo ""

# System Resources (if available)
echo "💻 System Resources:"
if [ -f /proc/meminfo ]; then
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_AVAILABLE=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
    MEM_USAGE=$((MEM_USED * 100 / MEM_TOTAL))
    
    echo "   Memory: ${MEM_USAGE}% used ($(($MEM_USED / 1024))MB / $(($MEM_TOTAL / 1024))MB)"
fi

if [ -f /proc/loadavg ]; then
    LOAD_AVG=$(cat /proc/loadavg | cut -d' ' -f1-3)
    echo "   Load Average: $LOAD_AVG"
fi

echo ""

# Quick Actions
echo "🎯 Quick Actions:"
echo "   Start:   ./scripts/start-elizaos.sh"
echo "   Stop:    ./scripts/stop-elizaos.sh"
echo "   Logs:    pm2 logs elizaos"
echo "   Monitor: pm2 monit"
echo "   Restart: pm2 restart elizaos"

echo ""
echo "✅ Status check completed" 