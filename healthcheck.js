#!/usr/bin/env node

/**
 * ElizaOS Production Health Check Script
 * Comprehensive health monitoring for production deployments
 */

const http = require('http');
const { execSync } = require('child_process');

const HEALTH_CHECK_PORT = process.env.API_PORT || 3000;
const HEALTH_CHECK_TIMEOUT = 10000; // 10 seconds
const PM2_HEALTH_CHECK = process.env.PM2_HEALTH_CHECK !== 'false';

/**
 * Check if ElizaOS API is responding
 */
function checkAPI() {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: HEALTH_CHECK_PORT,
      path: '/api/health',
      method: 'GET',
      timeout: HEALTH_CHECK_TIMEOUT
    };

    const req = http.request(options, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        if (res.statusCode === 200) {
          try {
            const healthData = JSON.parse(data);
            resolve({
              status: 'healthy',
              api: true,
              statusCode: res.statusCode,
              response: healthData
            });
          } catch (e) {
            resolve({
              status: 'healthy',
              api: true,
              statusCode: res.statusCode,
              response: data
            });
          }
        } else {
          reject(new Error(`API returned status ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', (err) => {
      reject(new Error(`API connection failed: ${err.message}`));
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('API health check timeout'));
    });

    req.end();
  });
}

/**
 * Check PM2 process status
 */
function checkPM2() {
  if (!PM2_HEALTH_CHECK) {
    return Promise.resolve({ status: 'skipped', pm2: 'disabled' });
  }

  try {
    const pm2List = execSync('pm2 jlist', { encoding: 'utf8', timeout: 5000 });
    const processes = JSON.parse(pm2List);
    
    const elizaProcess = processes.find(p => p.name === 'elizaos');
    
    if (!elizaProcess) {
      throw new Error('ElizaOS process not found in PM2');
    }

    const isOnline = elizaProcess.pm2_env.status === 'online';
    const uptime = elizaProcess.pm2_env.pm_uptime;
    const restarts = elizaProcess.pm2_env.restart_time;
    const memory = elizaProcess.pm2_env.monit.memory;
    const cpu = elizaProcess.pm2_env.monit.cpu;

    if (!isOnline) {
      throw new Error(`ElizaOS process status: ${elizaProcess.pm2_env.status}`);
    }

    return Promise.resolve({
      status: 'healthy',
      pm2: true,
      process: {
        name: elizaProcess.name,
        status: elizaProcess.pm2_env.status,
        uptime: Date.now() - uptime,
        restarts: restarts,
        memory: Math.round(memory / 1024 / 1024), // MB
        cpu: cpu,
        pid: elizaProcess.pid
      }
    });
  } catch (error) {
    return Promise.reject(new Error(`PM2 health check failed: ${error.message}`));
  }
}

/**
 * Check system resources
 */
function checkSystem() {
  try {
    const memInfo = execSync('cat /proc/meminfo | head -3', { encoding: 'utf8' });
    const loadAvg = execSync('cat /proc/loadavg', { encoding: 'utf8' });
    const diskUsage = execSync('df -h /app', { encoding: 'utf8' });

    // Parse memory info
    const memLines = memInfo.split('\n');
    const memTotal = parseInt(memLines[0].match(/\d+/)[0]);
    const memFree = parseInt(memLines[1].match(/\d+/)[0]);
    const memAvailable = parseInt(memLines[2].match(/\d+/)[0]);
    const memUsed = memTotal - memFree;

    // Parse load average
    const load = loadAvg.split(' ');

    // Parse disk usage
    const diskLines = diskUsage.split('\n');
    const diskInfo = diskLines[1].split(/\s+/);

    return Promise.resolve({
      status: 'healthy',
      system: true,
      resources: {
        memory: {
          total: Math.round(memTotal / 1024), // MB
          used: Math.round(memUsed / 1024), // MB
          available: Math.round(memAvailable / 1024), // MB
          usage: Math.round((memUsed / memTotal) * 100) // %
        },
        load: {
          '1min': parseFloat(load[0]),
          '5min': parseFloat(load[1]),
          '15min': parseFloat(load[2])
        },
        disk: {
          filesystem: diskInfo[0],
          size: diskInfo[1],
          used: diskInfo[2],
          available: diskInfo[3],
          usage: diskInfo[4]
        }
      }
    });
  } catch (error) {
    return Promise.reject(new Error(`System health check failed: ${error.message}`));
  }
}

/**
 * Main health check function
 */
async function healthCheck() {
  const checks = {
    timestamp: new Date().toISOString(),
    service: 'elizaos',
    version: process.env.npm_package_version || 'unknown',
    environment: process.env.NODE_ENV || 'development',
    checks: {}
  };

  let overallHealth = true;
  const errors = [];

  // API Health Check
  try {
    const apiResult = await checkAPI();
    checks.checks.api = apiResult;
  } catch (error) {
    checks.checks.api = { status: 'unhealthy', error: error.message };
    overallHealth = false;
    errors.push(`API: ${error.message}`);
  }

  // PM2 Health Check
  try {
    const pm2Result = await checkPM2();
    checks.checks.pm2 = pm2Result;
  } catch (error) {
    checks.checks.pm2 = { status: 'unhealthy', error: error.message };
    overallHealth = false;
    errors.push(`PM2: ${error.message}`);
  }

  // System Health Check
  try {
    const systemResult = await checkSystem();
    checks.checks.system = systemResult;
  } catch (error) {
    checks.checks.system = { status: 'unhealthy', error: error.message };
    overallHealth = false;
    errors.push(`System: ${error.message}`);
  }

  // Summary
  checks.status = overallHealth ? 'healthy' : 'unhealthy';
  checks.healthy = overallHealth;
  
  if (!overallHealth) {
    checks.errors = errors;
  }

  return checks;
}

/**
 * Run health check and output results
 */
async function main() {
  try {
    const healthResult = await healthCheck();
    
    // Output JSON for structured logging
    console.log(JSON.stringify(healthResult, null, 2));
    
    // Exit with appropriate code
    process.exit(healthResult.healthy ? 0 : 1);
  } catch (error) {
    console.error(JSON.stringify({
      timestamp: new Date().toISOString(),
      service: 'elizaos',
      status: 'error',
      healthy: false,
      error: error.message,
      stack: error.stack
    }, null, 2));
    
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = { healthCheck, checkAPI, checkPM2, checkSystem }; 