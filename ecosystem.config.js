module.exports = {
  apps: [{
    name: 'elizaos',
    script: './node_modules/.bin/elizaos',
    args: 'start --port ' + (process.env.API_PORT || 3000) + ' --character /app/characters/server-bod.character.json',
    cwd: '/app',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '2G',
    env: {
      NODE_ENV: 'production',
      API_PORT: process.env.API_PORT || 3000,
      LOG_LEVEL: process.env.LOG_LEVEL || 'info',
      HOST: '0.0.0.0'
    },
    error_file: '/app/logs/elizaos-error.log',
    out_file: '/app/logs/elizaos-out.log',
    log_file: '/app/logs/elizaos-combined.log',
    time: true,
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_restarts: 10,
    min_uptime: '10s',
    kill_timeout: 5000,
    listen_timeout: 8000,
    shutdown_with_message: true
  }]
} 