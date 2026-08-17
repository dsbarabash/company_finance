-- Расширение для UUID 
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Схема
CREATE SCHEMA IF NOT EXISTS finance;

-- Создаем таблицы:
-- 1. Валюты
CREATE TABLE finance.currencies (
    id SERIAL PRIMARY KEY,
    code VARCHAR(3) NOT NULL UNIQUE, -- 'RUB', 'USD', 'EUR'
    name VARCHAR(100) NOT NULL,
    symbol VARCHAR(5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Компании
CREATE TABLE finance.companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    tax_id VARCHAR(20) UNIQUE, -- ИНН
    registration_number VARCHAR(50),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Отделы
CREATE TABLE finance.departments (
    id SERIAL PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES finance.companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    budget_holder BOOLEAN DEFAULT FALSE, -- является ли руководителем бюджета
    parent_department_id INT REFERENCES finance.departments(id), -- иерархия
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Сотрудники
CREATE TABLE finance.employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES finance.companies(id) ON DELETE CASCADE,
    department_id INT REFERENCES finance.departments(id),
    full_name VARCHAR(255) NOT NULL,
    position VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Контрагенты
CREATE TABLE finance.counterparties (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES finance.companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    tax_id VARCHAR(20), -- ИНН контрагента
    type VARCHAR(50) CHECK (type IN ('Client', 'Supplier', 'Partner', 'Other')),
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Типы операций (Transaction Types)
CREATE TABLE finance.transaction_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE, -- 'Sale', 'Purchase', 'Salary', 'Rent'
    is_income BOOLEAN NOT NULL, -- TRUE = доход, FALSE = расход
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Категории доходов
CREATE TABLE finance.income_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Категории расходов
CREATE TABLE finance.expense_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Статусы счетов
CREATE TABLE finance.invoice_statuses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE, -- 'Paid', 'Unpaid', 'Overdue', 'Partially Paid'
    is_closed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Транзакции (доходы и расходы)
CREATE TABLE finance.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES finance.companies(id) ON DELETE CASCADE,
    department_id INT REFERENCES finance.departments(id),
    employee_id UUID REFERENCES finance.employees(id),
    counterparty_id UUID REFERENCES finance.counterparties(id),
    transaction_type_id INT NOT NULL REFERENCES finance.transaction_types(id),
    income_category_id INT REFERENCES finance.income_categories(id),
    expense_category_id INT REFERENCES finance.expense_categories(id),
    invoice_status_id INT NOT NULL REFERENCES finance.invoice_statuses(id) DEFAULT 2, -- По умолчанию "Не оплачен"
    
    transaction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    currency_id INT NOT NULL REFERENCES finance.currencies(id),
    vat_rate DECIMAL(5, 2) DEFAULT 20.00, -- ставка НДС
    description TEXT,
    reference_number VARCHAR(100), -- номер счета/договора
    due_date DATE, -- срок оплаты
    
    is_reconciled BOOLEAN DEFAULT FALSE, -- подтверждено/сверено
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 11. Бюджетные планы (План-факт)
CREATE TABLE finance.budget_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES finance.companies(id) ON DELETE CASCADE,
    department_id INT REFERENCES finance.departments(id),
    plan_year INT NOT NULL,
    plan_month INT NOT NULL CHECK (plan_month BETWEEN 1 AND 12),
    planned_income_amount DECIMAL(15, 2) DEFAULT 0,
    planned_expense_amount DECIMAL(15, 2) DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_id, department_id, plan_year, plan_month)
);



-- Индексы
CREATE INDEX idx_transactions_date ON finance.transactions(transaction_date);
CREATE INDEX idx_transactions_company_date ON finance.transactions(company_id, transaction_date DESC);
CREATE INDEX idx_transactions_department ON finance.transactions(department_id);
CREATE INDEX idx_transactions_type ON finance.transactions(transaction_type_id);
CREATE INDEX idx_transactions_counterparty ON finance.transactions(counterparty_id);
CREATE INDEX idx_budget_plans_company_year ON finance.budget_plans(company_id, plan_year, plan_month);
