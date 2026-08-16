-- Представление 1: Актуальный баланс по отделам (с использованием CTE)
CREATE OR REPLACE VIEW finance.v_department_balance AS
WITH dept_balances AS (
    SELECT 
        d.id AS department_id,
        d.name AS department_name,
        COALESCE(SUM(CASE WHEN tt.is_income THEN t.amount ELSE 0 END), 0) AS total_income,
        COALESCE(SUM(CASE WHEN NOT tt.is_income THEN t.amount ELSE 0 END), 0) AS total_expense
    FROM finance.departments d
    LEFT JOIN finance.transactions t ON d.id = t.department_id
    LEFT JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
    GROUP BY d.id, d.name
)
SELECT 
    department_id,
    department_name,
    total_income,
    total_expense,
    (total_income - total_expense) AS net_balance,
    CASE WHEN total_income = 0 THEN 0 ELSE ROUND(((total_income - total_expense) / total_income) * 100, 2) END AS margin
FROM dept_balances;

-- Представление 2: Сводка по контрагентам (Кто принес больше всего денег)
CREATE OR REPLACE VIEW finance.v_counterparty_summary AS
SELECT 
    c.id AS counterparty_id,
    c.name AS counterparty_name,
    c.type,
    COUNT(t.id) AS transaction_count,
    COALESCE(SUM(CASE WHEN tt.is_income THEN t.amount ELSE 0 END), 0) AS total_revenue, -- считаем суммарный доход
    COALESCE(SUM(CASE WHEN NOT tt.is_income THEN t.amount ELSE 0 END), 0) AS total_costs -- считаем суммарный расход
FROM finance.counterparties c
LEFT JOIN finance.transactions t ON c.id = t.counterparty_id
LEFT JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
GROUP BY c.id, c.name, c.type;

-- Представление 3: План-факт анализ (cравнение бюджета и факта с подзапросом)
CREATE OR REPLACE VIEW finance.v_budget_vs_actual AS
SELECT 
    bp.plan_year,
    bp.plan_month,
    d.name AS department_name,
    bp.planned_income_amount,
    (SELECT COALESCE(SUM(amount), 0) 
     FROM finance.transactions t 
     JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
     WHERE t.department_id = bp.department_id 
       AND EXTRACT(YEAR FROM t.transaction_date) = bp.plan_year 
       AND EXTRACT(MONTH FROM t.transaction_date) = bp.plan_month 
       AND tt.is_income = TRUE) AS actual_income,
    bp.planned_expense_amount,
    (SELECT COALESCE(SUM(amount), 0) 
     FROM finance.transactions t 
     JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id
     WHERE t.department_id = bp.department_id 
       AND EXTRACT(YEAR FROM t.transaction_date) = bp.plan_year 
       AND EXTRACT(MONTH FROM t.transaction_date) = bp.plan_month 
       AND tt.is_income = FALSE) AS actual_expense
FROM finance.budget_plans bp
JOIN finance.departments d ON bp.department_id = d.id;
