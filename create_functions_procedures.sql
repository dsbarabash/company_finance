-- Функции и процедуры

-- Функция 1: Получение баланса компании (Доходы - Расходы)
CREATE OR REPLACE FUNCTION finance.fn_get_company_balance(
    p_company_id UUID,
    p_as_of_date DATE DEFAULT CURRENT_DATE
)
RETURNS DECIMAL(15, 2) AS $$
DECLARE
    v_total_income DECIMAL(15, 2);
    v_total_expense DECIMAL(15, 2);
BEGIN
    SELECT COALESCE(SUM(amount), 0) INTO v_total_income
    FROM finance.transactions t
    JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
    WHERE t.company_id = p_company_id
      AND t.transaction_date <= p_as_of_date
      AND tt.is_income = TRUE;

    SELECT COALESCE(SUM(amount), 0) INTO v_total_expense
    FROM finance.transactions t
    JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
    WHERE t.company_id = p_company_id
      AND t.transaction_date <= p_as_of_date
      AND tt.is_income = FALSE;

    RETURN v_total_income - v_total_expense;
END;
$$ LANGUAGE plpgsql;

-- Функция 2: Рентабельность (Маржинальность)
CREATE OR REPLACE FUNCTION finance.fn_calculate_profit_margin(
    p_company_id UUID,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS DECIMAL(5, 2) AS $$
DECLARE
    v_income DECIMAL(15, 2);
    v_expense DECIMAL(15, 2);
    v_margin DECIMAL(5, 2);
BEGIN
    SELECT COALESCE(SUM(amount), 0) INTO v_income
    FROM finance.transactions t
    JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
    WHERE t.company_id = p_company_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date
      AND tt.is_income = TRUE;

    SELECT COALESCE(SUM(amount), 0) INTO v_expense
    FROM finance.transactions t
    JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
    WHERE t.company_id = p_company_id
      AND t.transaction_date BETWEEN p_start_date AND p_end_date
      AND tt.is_income = FALSE;

    IF v_income = 0 THEN
        RETURN 0;
    ELSE
        v_margin := ((v_income - v_expense) / v_income) * 100;
        RETURN ROUND(v_margin, 2);
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Функция 3: Форматирование валюты (для отчетов)
CREATE OR REPLACE FUNCTION finance.fn_format_currency(
    p_amount DECIMAL(15, 2),
    p_currency_code VARCHAR(3)
)
RETURNS VARCHAR(50) AS $$
DECLARE
    v_symbol VARCHAR(5);
BEGIN
    SELECT symbol INTO v_symbol FROM finance.currencies WHERE code = p_currency_code;
    IF v_symbol IS NULL THEN
        v_symbol := p_currency_code;
    END IF;
    RETURN CONCAT(v_symbol, ' ', TO_CHAR(p_amount, 'FM999G999G999G999G999D00'));
END;
$$ LANGUAGE plpgsql;


-- Процедура 1: Создание дохода
CREATE OR REPLACE PROCEDURE finance.sp_create_income_transaction(
    p_company_id UUID,
    p_department_id INT,
    p_employee_id UUID,
    p_counterparty_id UUID,
    p_transaction_type_id INT,
    p_income_category_id INT,
    p_transaction_date DATE,
    p_amount DECIMAL(15, 2),
    p_currency_id INT,
    p_vat_rate DECIMAL(5, 2),
    p_description TEXT,
    p_reference_number VARCHAR(100),
    p_due_date DATE,
	p_invoice_status_id INT DEFAULT 2
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO finance.transactions (
        company_id, department_id, employee_id, counterparty_id,
        transaction_type_id, income_category_id, expense_category_id,
        invoice_status_id, transaction_date, amount, currency_id,
        vat_rate, description, reference_number, due_date
    ) VALUES (
        p_company_id, p_department_id, p_employee_id, p_counterparty_id,
        p_transaction_type_id, p_income_category_id, NULL,
        p_invoice_status_id, p_transaction_date, p_amount, p_currency_id,
        p_vat_rate, p_description, p_reference_number, p_due_date
    );
    RAISE NOTICE 'Доход успешно создан для компании %', p_company_id;
END;
$$;

-- Процедура 2: Создание расхода
CREATE OR REPLACE PROCEDURE finance.sp_create_expense_transaction(
    p_company_id UUID,
    p_department_id INT,
    p_employee_id UUID,
    p_counterparty_id UUID,
    p_transaction_type_id INT,
    p_expense_category_id INT,
    p_transaction_date DATE,
    p_amount DECIMAL(15, 2),
    p_currency_id INT,
    p_vat_rate DECIMAL(5, 2),
    p_description TEXT,
    p_reference_number VARCHAR(100),
    p_due_date DATE,
	p_invoice_status_id INT DEFAULT 2
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO finance.transactions (
        company_id, department_id, employee_id, counterparty_id,
        transaction_type_id, income_category_id, expense_category_id,
        invoice_status_id, transaction_date, amount, currency_id,
        vat_rate, description, reference_number, due_date
    ) VALUES (
        p_company_id, p_department_id, p_employee_id, p_counterparty_id,
        p_transaction_type_id, NULL, p_expense_category_id,
        p_invoice_status_id, p_transaction_date, p_amount, p_currency_id,
        p_vat_rate, p_description, p_reference_number, p_due_date
    );
    RAISE NOTICE 'Расход успешно создан для компании %', p_company_id;
END;
$$;

-- Процедура 3: Подтверждение транзакций
CREATE OR REPLACE PROCEDURE finance.sp_reconcile_transactions(
    p_company_id UUID,
    p_start_date DATE,
    p_end_date DATE
)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE finance.transactions
    SET is_reconciled = TRUE,
        updated_at = NOW()
    WHERE company_id = p_company_id
      AND transaction_date BETWEEN p_start_date AND p_end_date
      AND is_reconciled = FALSE;
    
    RAISE NOTICE 'Транзакции за период с % по % подтверждены.', p_start_date, p_end_date;
END;
$$;

-- Процедура 4: Обновление бюджетного плана (или создание, если его нет)
CREATE OR REPLACE PROCEDURE finance.sp_update_budget_plan(
    p_company_id UUID,
    p_department_id INT,
    p_year INT,
    p_month INT,
    p_planned_income DECIMAL(15, 2),
    p_planned_expense DECIMAL(15, 2)
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO finance.budget_plans (
        company_id, department_id, plan_year, plan_month,
        planned_income_amount, planned_expense_amount, updated_at
    ) VALUES (
        p_company_id, p_department_id, p_year, p_month,
        p_planned_income, p_planned_expense, NOW()
    )
    ON CONFLICT (company_id, department_id, plan_year, plan_month)
    DO UPDATE SET
        planned_income_amount = EXCLUDED.planned_income_amount,
        planned_expense_amount = EXCLUDED.planned_expense_amount,
        updated_at = NOW();
    
    RAISE NOTICE 'Бюджет для отдела % на %-% обновлен.', p_department_id, p_year, p_month;
END;
$$;


-- Процедура 5: Генерация ежемесячного отчета (вставляет данные в таблицу monthly_reports)

CREATE TABLE IF NOT EXISTS finance.monthly_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES finance.companies(id),
    report_year INT NOT NULL,
    report_month INT NOT NULL,
    total_income DECIMAL(15, 2),
    total_expense DECIMAL(15, 2),
    net_profit DECIMAL(15, 2),
    margin_percent DECIMAL(5, 2),
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE OR REPLACE PROCEDURE finance.sp_generate_monthly_financial_report(
    p_company_id UUID,
    p_year INT,
    p_month INT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_start_date DATE := TO_DATE(CONCAT(p_year, '-', p_month, '-01'), 'YYYY-MM-DD');
    v_end_date DATE := (v_start_date + INTERVAL '1 month - 1 day')::DATE;
    v_income DECIMAL(15, 2);
    v_expense DECIMAL(15, 2);
    v_profit DECIMAL(15, 2);
    v_margin DECIMAL(5, 2);
BEGIN
    -- Агрегация данных
    SELECT COALESCE(SUM(CASE WHEN tt.is_income THEN t.amount ELSE 0 END), 0),
           COALESCE(SUM(CASE WHEN NOT tt.is_income THEN t.amount ELSE 0 END), 0)
    INTO v_income, v_expense
    FROM finance.transactions t
    JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
    WHERE t.company_id = p_company_id
      AND t.transaction_date BETWEEN v_start_date AND v_end_date;

    v_profit := v_income - v_expense;
    IF v_income = 0 THEN v_margin := 0; ELSE v_margin := ROUND((v_profit / v_income) * 100, 2); END IF;

    INSERT INTO finance.monthly_reports (
        company_id, report_year, report_month,
        total_income, total_expense, net_profit, margin_percent
    ) VALUES (
        p_company_id, p_year, p_month,
        v_income, v_expense, v_profit, v_margin
    )
    ON CONFLICT (id) DO UPDATE SET
        total_income = EXCLUDED.total_income,
        total_expense = EXCLUDED.total_expense,
        net_profit = EXCLUDED.net_profit,
        margin_percent = EXCLUDED.margin_percent,
        generated_at = NOW();

    RAISE NOTICE 'Отчет за %-% сгенерирован.', p_year, p_month;
END;
$$;
