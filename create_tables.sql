-- 1. КОМПАНИИ (юрлица)
CREATE TABLE companies (
    id BIGSERIAL PRIMARY KEY,
    inn VARCHAR(12) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    legal_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE companies IS 'Юридические лица, по которым ведется учет';

-- 2. ДЕПАРТАМЕНТЫ (Центры финансовой ответственности)
CREATE TABLE departments (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    parent_id BIGINT REFERENCES departments(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    cost_center BOOLEAN DEFAULT TRUE,
    manager_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE departments IS 'Структурные подразделения для анализа по ЦФО';

-- 3. ПРОЕКТЫ
CREATE TABLE projects (
    id BIGSERIAL PRIMARY KEY,
    department_id BIGINT NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'cancelled')),
    budget NUMERIC(15,2) DEFAULT 0,
    start_date DATE,
    end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE projects IS 'Проекты для позатратной аналитики';

-- 4. КОНТРАГЕНТЫ (клиенты и поставщики)
CREATE TABLE counterparties (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    inn VARCHAR(12) UNIQUE,
    kpp VARCHAR(9),
    type VARCHAR(20) NOT NULL CHECK (type IN ('client', 'supplier', 'both')),
    rating SMALLINT DEFAULT 5 CHECK (rating BETWEEN 1 AND 10),
    email VARCHAR(255),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE counterparties IS 'Справочник контрагентов (клиенты/поставщики)';

-- 5. ДОГОВОРЫ
CREATE TABLE contracts (
    id BIGSERIAL PRIMARY KEY,
    counterparty_id BIGINT NOT NULL REFERENCES counterparties(id) ON DELETE CASCADE,
    project_id BIGINT REFERENCES projects(id) ON DELETE SET NULL,
    number VARCHAR(50) NOT NULL,
    type VARCHAR(30) NOT NULL CHECK (type IN ('sales', 'purchase', 'service', 'lease', 'other')),
    amount NUMERIC(15,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'RUB',
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE contracts IS 'Договоры с контрагентами (основание для операций)';

-- 6. ТИПЫ ОПЕРАЦИЙ
CREATE TABLE transaction_types (
    id BIGSERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    sign SMALLINT NOT NULL CHECK (sign IN (1, -1)),
    is_system BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE transaction_types IS 'Справочник типов финансовых операций';

-- 7. КАТЕГОРИИ ОПЕРАЦИЙ 
CREATE TABLE transaction_categories (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT REFERENCES transaction_categories(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE,
    is_tax_deductible BOOLEAN DEFAULT FALSE,
    level INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE transaction_categories IS 'Cправочник статей доходов/расходов';

-- 8. ТРАНЗАКЦИИ (ГЛАВНАЯ ФАКТОВАЯ ТАБЛИЦА)
CREATE TABLE transactions (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    department_id BIGINT NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    project_id BIGINT REFERENCES projects(id) ON DELETE SET NULL,
    contract_id BIGINT REFERENCES contracts(id) ON DELETE SET NULL,
    counterparty_id BIGINT NOT NULL REFERENCES counterparties(id) ON DELETE CASCADE,
    type_id BIGINT NOT NULL REFERENCES transaction_types(id),
    category_id BIGINT NOT NULL REFERENCES transaction_categories(id),
    amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) DEFAULT 'RUB',
    transaction_date DATE NOT NULL,
    description TEXT,
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('cash', 'bank', 'card', 'other')),
    document_number VARCHAR(50),
    created_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE transactions IS 'Все финансовые операции (доходы/расходы)';


-- 9. ПЛАНОВЫЕ ПОКАЗАТЕЛИ (БЮДЖЕТИРОВАНИЕ)
CREATE TABLE budget_plan (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    department_id BIGINT NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    category_id BIGINT NOT NULL REFERENCES transaction_categories(id) ON DELETE CASCADE,
    period DATE NOT NULL,
    planned_amount NUMERIC(15,2) NOT NULL DEFAULT 0,
    version INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(company_id, department_id, category_id, period, version)
);

COMMENT ON TABLE budget_plan IS 'Плановые показатели для анализа план-факт';

-- 10. НАЛОГОВЫЕ СОБЫТИЯ
CREATE TABLE tax_events (
    id BIGSERIAL PRIMARY KEY,
    transaction_id BIGINT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    tax_type VARCHAR(20) NOT NULL CHECK (tax_type IN ('vat', 'profit', 'property', 'other')),
    tax_rate NUMERIC(5,2) NOT NULL,
    tax_base NUMERIC(15,2) NOT NULL,
    tax_amount NUMERIC(15,2) NOT NULL,
    reporting_period DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(transaction_id, tax_type)
);

COMMENT ON TABLE tax_events IS 'Налоговые события для расчета налоговой базы';


-- ДОБАВЛЯЕМ НАЧАЛЬНЫЕ ДАННЫЕ (справочники)
INSERT INTO transaction_types (code, name, sign, is_system) VALUES
('REVENUE', 'Выручка от реализации', 1, TRUE),
('SERVICE_INCOME', 'Доход от услуг', 1, TRUE),
('OTHER_INCOME', 'Прочие доходы', 1, TRUE),
('SALARY', 'Заработная плата', -1, TRUE),
('RENT', 'Аренда', -1, TRUE),
('UTILITIES', 'Коммунальные платежи', -1, TRUE),
('OFFICE', 'Канцелярские расходы', -1, TRUE),
('TAXES', 'Налоги и сборы', -1, TRUE),
('MARKETING', 'Маркетинг и реклама', -1, TRUE),
('OTHER_EXPENSE', 'Прочие расходы', -1, TRUE);


INSERT INTO transaction_categories (name, code, level, is_tax_deductible) VALUES
('Доходы', 'INC', 1, FALSE),
('Расходы', 'EXP', 1, FALSE),
('Выручка', 'REV', 2, FALSE),
('Зарплата', 'SAL', 2, TRUE),
('Аренда', 'RENT', 2, TRUE),
('Коммунальные', 'UTIL', 2, TRUE),
('Налоги', 'TAX', 2, FALSE),
('Маркетинг', 'MKT', 2, TRUE),
('Канцелярия', 'OFF', 2, TRUE),
('Прочее', 'OTH', 2, TRUE);

