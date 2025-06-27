module.exports = {
  apps: [
    {
      name: 'elizaos-proxy',
      script: './src/proxy-server.js',
      cwd: '/app',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: process.env.NODE_ENV || 'development',
        API_PORT: process.env.API_PORT || 3000,
        ELIZAOS_INTERNAL_PORT: process.env.ELIZAOS_INTERNAL_PORT || 3001,
        WEB_UI_ENABLED: process.env.WEB_UI_ENABLED
      },
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      max_restarts: 10,
      min_uptime: '10s',
      kill_timeout: 3000,
      listen_timeout: 5000
    },
    {
      name: 'elizaos',
      script: './scripts/elizaos-wrapper.sh',
      cwd: '/app',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '2G',
      env: {
        NODE_ENV: process.env.NODE_ENV || 'development',
        API_PORT: process.env.ELIZAOS_INTERNAL_PORT || 3001,
        LOG_LEVEL: 'debug',
        HOST: '127.0.0.1',
        CHARACTER_FILE: process.env.CHARACTER_FILE || '/app/config/characters/server-bod.character.json'
      },
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      max_restarts: 10,
      min_uptime: '10s',
      kill_timeout: 5000,
      listen_timeout: 8000,
      reload_delay: 1000
    }
  ]
} 