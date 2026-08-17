-- Создаем роли
CREATE ROLE finance_admin WITH LOGIN PASSWORD 'StrongP@ssw0rd!';
CREATE ROLE finance_accountant WITH LOGIN PASSWORD 'SecureP@ss123';
CREATE ROLE finance_viewer WITH LOGIN PASSWORD 'ReadOnlyP@ssw0r@';

-- Назначаем владельцем схемы админа
ALTER SCHEMA finance OWNER TO finance_admin;

-- Бухгалтер: может читать, вставлять и обновлять, но не удалять и не менять структуру
GRANT USAGE ON SCHEMA finance TO finance_accountant;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA finance TO finance_accountant;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA finance TO finance_accountant;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA finance TO finance_accountant;

-- Наблюдатель: только чтение
GRANT USAGE ON SCHEMA finance TO finance_viewer;
GRANT SELECT ON ALL TABLES IN SCHEMA finance TO finance_viewer;

-- Настройка прав для будущих таблиц
ALTER DEFAULT PRIVILEGES IN SCHEMA finance 
GRANT SELECT, INSERT, UPDATE ON TABLES TO finance_accountant;

ALTER DEFAULT PRIVILEGES IN SCHEMA finance 
GRANT SELECT ON TABLES TO finance_viewer;

ALTER DEFAULT PRIVILEGES IN SCHEMA finance 
GRANT USAGE ON SEQUENCES TO finance_accountant;
