-- Apply PR #5278 Fix: Change server_agents.server_id from uuid to text
-- This fixes the foreign key constraint type mismatch between:
-- - message_servers.id (text type)  
-- - server_agents.server_id (uuid type)

BEGIN;

-- Backup existing data
CREATE TEMP TABLE server_agents_backup AS
SELECT server_id, agent_id FROM server_agents;

-- Drop the problematic table with uuid foreign key constraint
DROP TABLE IF EXISTS server_agents CASCADE;

-- Recreate server_agents table with correct schema (server_id as text)
CREATE TABLE server_agents (
    server_id TEXT NOT NULL REFERENCES message_servers(id) ON DELETE CASCADE,
    agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    PRIMARY KEY (server_id, agent_id)
);

-- Restore the data (server_id will be implicitly cast from uuid to text)
INSERT INTO server_agents (server_id, agent_id)
SELECT server_id::text, agent_id FROM server_agents_backup;

-- Verify the fix
SELECT 
    'server_agents' as table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'server_agents' 
ORDER BY ordinal_position;

-- Verify foreign key constraints work
SELECT 
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name = 'server_agents';

COMMIT;

-- Show final record count
SELECT COUNT(*) as "Records restored" FROM server_agents; 