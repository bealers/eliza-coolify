-- ElizaOS PostgreSQL Database Initialization
-- This script runs when the PostgreSQL container starts for the first time

-- Create database if it doesn't exist (handled by POSTGRES_DB env var)
-- But we can create additional schemas and tables here

-- Set default encoding and locale
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

-- Create extensions that ElizaOS might need
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create schemas for organization
CREATE SCHEMA IF NOT EXISTS eliza_core;
CREATE SCHEMA IF NOT EXISTS eliza_conversations;
CREATE SCHEMA IF NOT EXISTS eliza_memory;
CREATE SCHEMA IF NOT EXISTS eliza_analytics;

-- Grant permissions to the eliza user
GRANT ALL PRIVILEGES ON SCHEMA eliza_core TO eliza;
GRANT ALL PRIVILEGES ON SCHEMA eliza_conversations TO eliza;
GRANT ALL PRIVILEGES ON SCHEMA eliza_memory TO eliza;
GRANT ALL PRIVILEGES ON SCHEMA eliza_analytics TO eliza;

-- Create indexes for common queries (ElizaOS will create tables automatically)
-- These are just optimizations for expected usage patterns

-- ElizaOS will handle table creation automatically via its ORM/migrations
-- This script just ensures the database is optimally configured

-- Set up connection limits and performance settings
ALTER DATABASE eliza SET max_connections = 100;
ALTER DATABASE eliza SET shared_preload_libraries = 'pg_stat_statements';

-- Log successful initialization
DO $$
BEGIN
    RAISE NOTICE 'ElizaOS database initialized successfully';
    RAISE NOTICE 'Schemas created: eliza_core, eliza_conversations, eliza_memory, eliza_analytics';
    RAISE NOTICE 'Extensions enabled: uuid-ossp, pgcrypto';
END $$; 