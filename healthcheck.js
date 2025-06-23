#!/usr/bin/env node

/**
 * ElizaOS Production Health Check
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const API_PORT = process.env.API_PORT || 3000;
const HOST = process.env.HOST || 'localhost';

// Health check configuration
const HEALTH_CONFIG = {
  timeout: 10000,
  endpoints: [
    '/health',
    '/api/health', 
    '/'
  ],
  checks: {
    api: true,
    pm2: true,
    logs: true,
    database: false // Optional, can be enabled if needed
  }
};

/**
 * Check if API endpoint is responding
 */
async function checkAPI() {
  return new Promise((resolve) => {
    let resolved = false;
    
    const checkEndpoint = (endpoint) => {
      return new Promise((endpointResolve) => {
        const options = {
          hostname: HOST,
          port: API_PORT,
          path: endpoint,
          method: 'GET',
          timeout: 5000,
          headers: {
            'User-Agent': 'ElizaOS-HealthCheck/1.0'
          }
        };

        const req = http.request(options, (res) => {
          console.log(`Health check ${endpoint}: ${res.statusCode}`);
          
          let data = '';
          res.on('data', chunk => data += chunk);
          res.on('end', () => {
            if (res.statusCode >= 200 && res.statusCode < 400) {
              endpointResolve({ success: true, endpoint, statusCode: res.statusCode, data });
            } else {
              endpointResolve({ success: false, endpoint, statusCode: res.statusCode, error: `HTTP ${res.statusCode}` });
            }
          });
        });

        req.on('error', (err) => {
          console.log(`Health check ${endpoint} failed: ${err.message}`);
          endpointResolve({ success: false, endpoint, error: err.message });
        });

        req.on('timeout', () => {
          console.log(`Health check ${endpoint} timed out`);
          req.destroy();
          endpointResolve({ success: false, endpoint, error: 'Timeout' });
        });

        req.end();
      });
    };

    // Try multiple endpoints
    Promise.all(HEALTH_CONFIG.endpoints.map(checkEndpoint))
      .then(results => {
        const successful = results.find(r => r.success);
        if (successful) {
          resolve({ success: true, result: successful });
        } else {
          resolve({ success: false, results });
        }
      });
  });
}

/**
 * Check PM2 process status
 */
function checkPM2() {
  return new Promise((resolve) => {
    const { exec } = require('child_process');
    
    exec('/app/node_modules/.bin/pm2 jlist', { timeout: 5000 }, (error, stdout, stderr) => {
      if (error) {
        resolve({ success: false, error: error.message });
        return;
      }

      try {
        const processes = JSON.parse(stdout);
        const elizaProcess = processes.find(p => p.name === 'elizaos');
        
        if (!elizaProcess) {
          resolve({ success: false, error: 'ElizaOS process not found' });
          return;
        }

        const isOnline = elizaProcess.pm2_env.status === 'online';
        const uptime = elizaProcess.pm2_env.pm_uptime;
        const restarts = elizaProcess.pm2_env.restart_time;

        resolve({
          success: isOnline,
          status: elizaProcess.pm2_env.status,
          uptime: Date.now() - uptime,
          restarts,
          memory: elizaProcess.monit ? elizaProcess.monit.memory : 0,
          cpu: elizaProcess.monit ? elizaProcess.monit.cpu : 0
        });
      } catch (parseError) {
        resolve({ success: false, error: `PM2 parse error: ${parseError.message}` });
      }
    });
  });
}

/**
 * Check log files
 */
function checkLogs() {
  const logFiles = [
    '/app/logs/elizaos-out.log',
    '/app/logs/elizaos-error.log',
    '/app/logs/elizaos-combined.log'
  ];

  const results = {};
  
  logFiles.forEach(logFile => {
    try {
      if (fs.existsSync(logFile)) {
        const stats = fs.statSync(logFile);
        const size = stats.size;
        const modified = stats.mtime;
        
        // Read last few lines if file has content
        let lastLines = '';
        if (size > 0) {
          try {
            const content = fs.readFileSync(logFile, 'utf8');
            const lines = content.split('\n').filter(line => line.trim());
            lastLines = lines.slice(-3).join('\n');
          } catch (readError) {
            lastLines = `Error reading: ${readError.message}`;
          }
        }
        
        results[path.basename(logFile)] = {
          exists: true,
          size,
          modified,
          lastModified: Date.now() - modified.getTime(),
          hasContent: size > 0,
          preview: lastLines
        };
      } else {
        results[path.basename(logFile)] = {
          exists: false
        };
      }
    } catch (error) {
      results[path.basename(logFile)] = {
        exists: false,
        error: error.message
      };
    }
  });

  return { success: true, files: results };
}

/**
 * Main health check function
 */
async function runHealthCheck() {
  console.log(`\nElizaOS Health Check Starting...`);
  console.log(`   Target: ${HOST}:${API_PORT}`);
  console.log(`   Time: ${new Date().toISOString()}`);
  
  const results = {
    timestamp: new Date().toISOString(),
    overall: false,
    checks: {}
  };

  // API Health Check
  if (HEALTH_CONFIG.checks.api) {
    console.log('\nChecking API...');
    try {
      const apiResult = await checkAPI();
      results.checks.api = apiResult;
      console.log(`   API Status: ${apiResult.success ? 'OK' : 'FAILED'}`);
      if (apiResult.success) {
        console.log(`   Endpoint: ${apiResult.result.endpoint} (${apiResult.result.statusCode})`);
      } else if (apiResult.results) {
        apiResult.results.forEach(r => {
          console.log(`   ${r.endpoint}: ${r.error || r.statusCode}`);
        });
      }
    } catch (error) {
      results.checks.api = { success: false, error: error.message };
      console.log(`   API Status: FAILED - ${error.message}`);
    }
  }

  // PM2 Health Check  
  if (HEALTH_CONFIG.checks.pm2) {
    console.log('\nChecking PM2...');
    try {
      const pm2Result = await checkPM2();
      results.checks.pm2 = pm2Result;
      console.log(`   PM2 Status: ${pm2Result.success ? 'OK' : 'FAILED'}`);
      if (pm2Result.success) {
        console.log(`   Process: ${pm2Result.status}, Uptime: ${Math.round(pm2Result.uptime/1000)}s, Restarts: ${pm2Result.restarts}`);
        console.log(`   Resources: ${Math.round(pm2Result.memory/1024/1024)}MB RAM, ${pm2Result.cpu}% CPU`);
      } else {
        console.log(`   Error: ${pm2Result.error}`);
      }
    } catch (error) {
      results.checks.pm2 = { success: false, error: error.message };
      console.log(`   PM2 Status: FAILED - ${error.message}`);
    }
  }

  // Logs Health Check
  if (HEALTH_CONFIG.checks.logs) {
    console.log('\nChecking Logs...');
    try {
      const logsResult = checkLogs();
      results.checks.logs = logsResult;
      
      Object.entries(logsResult.files).forEach(([filename, info]) => {
        if (info.exists) {
          const age = Math.round(info.lastModified / 1000);
          console.log(`   ${filename}: ${info.size} bytes, ${age}s ago ${info.hasContent ? '[HAS CONTENT]' : '[EMPTY]'}`);
          if (info.preview && info.hasContent) {
            console.log(`     Latest: ${info.preview.split('\n')[0].substring(0, 80)}`);
          }
        } else {
          console.log(`   ${filename}: Missing`);
        }
      });
    } catch (error) {
      results.checks.logs = { success: false, error: error.message };
      console.log(`   Logs Status: FAILED - ${error.message}`);
    }
  }

  // Overall health determination
  const criticalChecks = ['api'];
  results.overall = criticalChecks.every(check => 
    results.checks[check] && results.checks[check].success
  );

  console.log(`\nOverall Health: ${results.overall ? 'HEALTHY' : 'UNHEALTHY'}`);
  
  return results;
}

// Main execution
if (require.main === module) {
  runHealthCheck()
    .then(results => {
      if (results.overall) {
        console.log('\nHealth check passed');
        process.exit(0);
      } else {
        console.log('\nHealth check failed');
        console.log('\nDebug info:', JSON.stringify(results, null, 2));
        process.exit(1);
      }
    })
    .catch(error => {
      console.error('\nHealth check crashed:', error);
      process.exit(1);
    });
}

module.exports = { runHealthCheck }; 