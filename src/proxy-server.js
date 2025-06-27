const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const PORT = process.env.API_PORT || 3000;
const ELIZAOS_PORT = process.env.ELIZAOS_INTERNAL_PORT || 3001;
const WEB_UI_ENABLED = process.env.WEB_UI_ENABLED === 'true';

// API routes - always allowed
const apiPaths = ['/api'];

// Create proxy middleware for ElizaOS
const elizaProxy = createProxyMiddleware({
  target: `http://localhost:${ELIZAOS_PORT}`,
  changeOrigin: true,
  ws: true, // Support WebSocket proxying if needed later
  logLevel: 'warn'
});

// Apply proxy to API paths
apiPaths.forEach(path => {
  app.use(path, elizaProxy);
});

// Web UI handling
app.use('*', (req, res, next) => {
  const path = req.originalUrl;
  
  // Check if this is an API path (should not reach here, but safety check)
  if (apiPaths.some(apiPath => path.startsWith(apiPath))) {
    return elizaProxy(req, res, next);
  }
  
  // Web UI request
  if (WEB_UI_ENABLED) {
    // Forward to ElizaOS if Web UI is enabled
    return elizaProxy(req, res, next);
  } else {
    // Block Web UI by default
    res.status(403).json({
      error: 'Web UI is disabled',
      message: 'This ElizaOS deployment only allows API access. Use the /api, /agents, or /messaging endpoints.',
      api_documentation: '/api/docs',
      status: 'api_only_mode'
    });
  }
});

// Start the proxy server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`ElizaOS Proxy Server running on port ${PORT}`);
  console.log(`Forwarding API requests to ElizaOS on port ${ELIZAOS_PORT}`);
  console.log(`Web UI enabled: ${WEB_UI_ENABLED}`);
  console.log(`API endpoints available: ${apiPaths.join(', ')}`);
});

module.exports = app; 