-- Проверка блокировок
SELECT 
    pid,
    usename,
    query,
    state,
    wait_event_type,
    wait_event,
    now() - query_start AS duration
FROM pg_stat_activity
WHERE state = 'active'
  AND query NOT LIKE '%pg_stat_activity%'
ORDER BY duration DESC;

-- Проверка активных сессий
SELECT 
    usename,
    state,
    COUNT(*) AS session_count
FROM pg_stat_activity
GROUP BY usename, state
ORDER BY session_count DESC;

-- Долгие запросы (более 5 секунд)
SELECT 
    pid,
    usename,
    now() - query_start AS duration,
    LEFT(query, 200) AS query_preview
FROM pg_stat_activity
WHERE state = 'active'
  AND now() - query_start > interval '5 seconds'
  AND query NOT LIKE '%pg_stat_activity%'
ORDER BY duration DESC;

-- Размер каждой таблицы в схеме 
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size('finance.' || tablename)) AS total_size,
    pg_size_pretty(pg_relation_size('finance.' || tablename)) AS table_size,
    pg_size_pretty(pg_total_relation_size('finance.' || tablename) - 
                   pg_relation_size('finance.' || tablename)) AS index_size
FROM pg_tables
WHERE schemaname = 'finance'
ORDER BY pg_total_relation_size('finance.' || tablename) DESC;
