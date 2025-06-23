module.exports = {
  apps: [{
    name: 'elizaos',
    script: 'npx',
    args: '@elizaos/cli@latest start --host 0.0.0.0 --port ' + (process.env.API_PORT || 3000),
    cwd: '/app',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '2G',
    env: {
      NODE_ENV: 'production',
      API_PORT: process.env.API_PORT || 3000,
      ENABLE_WEB_UI: process.env.ENABLE_WEB_UI || 'false',
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
    restart_delay: 4000,
    exp_backoff_restart_delay: 100,
    kill_timeout: 5000,
    listen_timeout: 8000,
    // Health monitoring
    health_check_grace_period: 3000,
    health_check_fatal_exceptions: true,
    // Performance monitoring
    pmx: true,
    // Auto-restart on specific exit codes
    stop_exit_codes: [0]
  }]
} 