-- 1. ВАЛЮТЫ
INSERT INTO finance.currencies (code, name, symbol) VALUES 
('RUB', 'Российский рубль', '₽'),
('USD', 'Доллар США', '$'),
('EUR', 'Евро', '€')
ON CONFLICT (code) DO NOTHING; 

-- 2. СТАТУСЫ СЧЕТОВ
INSERT INTO finance.invoice_statuses (id, name, is_closed) VALUES 
(1, 'Оплачен', TRUE),
(2, 'Не оплачен', FALSE),
(3, 'Просрочен', FALSE),
(4, 'Частично оплачен', FALSE)
ON CONFLICT (id) DO NOTHING;  

-- 3. ТИПЫ ОПЕРАЦИЙ
INSERT INTO finance.transaction_types (name, is_income, description) VALUES 
('Продажа товаров', TRUE, 'Реализация товаров клиентам'),
('Оказание услуг', TRUE, 'Продажа услуг'),
('Проценты по депозиту', TRUE, 'Банковские проценты'),
('Закупка сырья', FALSE, 'Приобретение материалов для производства'),
('Заработная плата', FALSE, 'Выплата зарплаты сотрудникам'),
('Аренда офиса', FALSE, 'Аренда помещений'),
('Коммунальные услуги', FALSE, 'Оплата ЖКХ'),
('Маркетинг и реклама', FALSE, 'Расходы на продвижение'),
('Налоги', FALSE, 'Налоговые платежи'),
('Транспортные расходы', FALSE, 'Логистика и перевозки')
ON CONFLICT (name) DO NOTHING;  

-- 4. КАТЕГОРИИ ДОХОДОВ
INSERT INTO finance.income_categories (name, description) VALUES 
('Продажа товаров', 'Доход от реализации товаров'),
('Консультационные услуги', 'Доход от консультаций'),
('Разработка ПО', 'Доход от IT-услуг'),
('Аутсорсинг', 'Доход от аутсорсинга'),
('Проценты по депозитам', 'Банковские проценты'),
('Субсидии', 'Государственные субсидии'),
('Курсовая разница', 'Доход от изменения курса валют')
ON CONFLICT (name) DO NOTHING; 

-- 5. КАТЕГОРИИ РАСХОДОВ
INSERT INTO finance.expense_categories (name, description) VALUES 
('Закупка сырья', 'Материалы для производства'),
('ФОТ', 'Фонд оплаты труда'),
('Аренда', 'Аренда помещений и оборудования'),
('Коммунальные услуги', 'Электричество, вода, отопление'),
('Маркетинг', 'Реклама и продвижение'),
('Транспорт', 'Логистика и перевозки'),
('Налоги и сборы', 'Налоговые платежи'),
('Обучение персонала', 'Курсы и тренинги'),
('Хостинг и IT-сервисы', 'Облачные сервисы, домены'),
('Командировки', 'Расходы на командировки')
ON CONFLICT (name) DO NOTHING;

-- 6. КОМПАНИЯ
INSERT INTO finance.companies (id, name, tax_id, registration_number, address, phone, email) VALUES 
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'ООО "Ромашка"', '7723456789', '1234567890', 
 'г. Москва, ул. Тверская, д. 15', '+7 (495) 123-45-67', 'info@romashka.ru')
ON CONFLICT (id) DO NOTHING; 

-- 7. ОТДЕЛЫ
INSERT INTO finance.departments (company_id, name, budget_holder) VALUES 
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'Отдел продаж', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'Маркетинговый отдел', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'IT-отдел', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'Отдел кадров', FALSE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'Финансовый отдел', TRUE)
ON CONFLICT DO NOTHING; 

-- 8. СОТРУДНИКИ
INSERT INTO finance.employees (company_id, department_id, full_name, position, email, phone, hire_date, is_active) VALUES 
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, (SELECT id FROM finance.departments WHERE name = 'Отдел продаж' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid), 'Иванов Иван Иванович', 'Директор по продажам', 'ivanov@romashka.ru', '+7 (495) 111-11-11', '2020-01-15', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, (SELECT id FROM finance.departments WHERE name = 'Отдел продаж' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid), 'Петров Петр Петрович', 'Менеджер по продажам', 'petrov@romashka.ru', '+7 (495) 222-22-22', '2021-03-20', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, (SELECT id FROM finance.departments WHERE name = 'Маркетинговый отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid), 'Сидоров Сидор Сидорович', 'Руководитель маркетинга', 'sidorov@romashka.ru', '+7 (495) 333-33-33', '2020-06-10', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, (SELECT id FROM finance.departments WHERE name = 'IT-отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid), 'Козлов Александр Николаевич', 'Team Lead разработки', 'kozlov@romashka.ru', '+7 (495) 444-44-44', '2019-09-01', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, (SELECT id FROM finance.departments WHERE name = 'Отдел кадров' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid), 'Смирнова Елена Владимировна', 'HR-менеджер', 'smirnova@romashka.ru', '+7 (495) 555-55-55', '2022-02-14', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, (SELECT id FROM finance.departments WHERE name = 'Финансовый отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid), 'Михайлова Ольга Сергеевна', 'Финансовый аналитик', 'mikhaylova@romashka.ru', '+7 (495) 666-66-66', '2021-08-01', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, (SELECT id FROM finance.departments WHERE name = 'Отдел продаж' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid), 'Николаев Дмитрий Андреевич', 'Менеджер по работе с клиентами', 'nikolaev@romashka.ru', '+7 (495) 777-77-77', '2023-01-10', TRUE),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, (SELECT id FROM finance.departments WHERE name = 'IT-отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid), 'Алексеев Максим Владимирович', 'Разработчик', 'alekseev@romashka.ru', '+7 (495) 888-88-88', '2022-06-15', TRUE)
ON CONFLICT (email) DO NOTHING;

-- 9. КОНТРАГЕНТЫ
INSERT INTO finance.counterparties (company_id, name, tax_id, type, address, phone, email) VALUES 
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'ООО "Клиент Альфа"', '7701234567', 'Client', 'г. Москва, ул. Ленина, д. 10', '+7 (495) 999-11-11', 'info@alpha.ru'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'ООО "Поставщик Бета"', '7702345678', 'Supplier', 'г. Санкт-Петербург, ул. Невская, д. 5', '+7 (812) 999-22-22', 'info@beta.ru'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'ООО "Партнер Гамма"', '7703456789', 'Partner', 'г. Новосибирск, ул. Советская, д. 3', '+7 (383) 999-33-33', 'info@gamma.ru'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'ООО "Клиент Дельта"', '7704567890', 'Client', 'г. Екатеринбург, ул. Малышева, д. 7', '+7 (343) 999-44-44', 'info@delta.ru'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'ООО "Поставщик Омега"', '7705678901', 'Supplier', 'г. Казань, ул. Кремлевская, д. 2', '+7 (843) 999-55-55', 'info@omega.ru'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'ООО "Клиент Сигма"', '7706789012', 'Client', 'г. Красноярск, ул. Мира, д. 12', '+7 (391) 999-66-66', 'info@sigma.ru'),
('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 'ООО "Поставщик Тау"', '7707890123', 'Supplier', 'г. Владивосток, ул. Океанская, д. 8', '+7 (423) 999-77-77', 'info@tau.ru')
ON CONFLICT DO NOTHING; 

-- 10. БЮДЖЕТНЫЕ ПЛАНЫ (Январь - Июнь 2026)
INSERT INTO finance.budget_plans (company_id, department_id, plan_year, plan_month, planned_income_amount, planned_expense_amount)
SELECT 
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    d.id,
    2026,
    m.month,
    CASE 
        WHEN d.name = 'Отдел продаж' THEN 250000 + (m.month * 5000)
        WHEN d.name = 'Маркетинговый отдел' THEN 50000 + (m.month * 1000)
        WHEN d.name = 'IT-отдел' THEN 100000 + (m.month * 2000)
        ELSE 0
    END,
    CASE 
        WHEN d.name = 'Отдел продаж' THEN 150000 + (m.month * 2000)
        WHEN d.name = 'Маркетинговый отдел' THEN 80000 + (m.month * 3000)
        WHEN d.name = 'IT-отдел' THEN 120000 + (m.month * 2500)
        ELSE 0
    END
FROM finance.departments d
CROSS JOIN (SELECT generate_series(1, 6) AS month) m
WHERE d.company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid
  AND d.name IN ('Отдел продаж', 'Маркетинговый отдел', 'IT-отдел')
ON CONFLICT (company_id, department_id, plan_year, plan_month)
DO UPDATE SET
    planned_income_amount = EXCLUDED.planned_income_amount,
    planned_expense_amount = EXCLUDED.planned_expense_amount,
    updated_at = NOW();

-- 11. ДОХОДЫ ОТ ПРОДАЖ (Январь - Июнь 2026)
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, income_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'Отдел продаж' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    CASE (RANDOM() * 1)::INT
        WHEN 0 THEN (SELECT id FROM finance.employees WHERE email = 'ivanov@romashka.ru')
        ELSE (SELECT id FROM finance.employees WHERE email = 'petrov@romashka.ru')
    END,
    CASE (RANDOM() * 3)::INT
        WHEN 0 THEN (SELECT id FROM finance.counterparties WHERE name = 'ООО "Клиент Альфа"')
        WHEN 1 THEN (SELECT id FROM finance.counterparties WHERE name = 'ООО "Клиент Дельта"')
        WHEN 2 THEN (SELECT id FROM finance.counterparties WHERE name = 'ООО "Партнер Гамма"')
        ELSE (SELECT id FROM finance.counterparties WHERE name = 'ООО "Клиент Альфа"')
    END,
    (SELECT id FROM finance.transaction_types WHERE name = 'Продажа товаров'),
    (SELECT id FROM finance.income_categories WHERE name = 'Продажа товаров'),
    CASE (RANDOM() * 3)::INT
        WHEN 0 THEN 1
        WHEN 1 THEN 2
        ELSE 4
    END,
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + ((RANDOM() * 27)::INT) * INTERVAL '1 day',
    10000 + (RANDOM() * 490000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    20.0,
    'Продажа товаров клиенту',
    'INV-' || TO_CHAR(DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month', 'YYYYMM') || '-' || LPAD((SELECT COUNT(*) FROM generate_series(1, months.month * 2 + 5) AS cnt)::TEXT, 4, '0'),
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '30 days'
FROM generate_series(1, 6) AS months(month)
CROSS JOIN generate_series(1, months.month * 2 + 5) AS cnt
WHERE RANDOM() > 0.3;


-- 12. РАСХОДЫ НА ЗАКУПКИ (Январь - Июнь 2026)
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, expense_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    CASE (RANDOM() * 2)::INT
        WHEN 0 THEN (SELECT id FROM finance.departments WHERE name = 'Отдел продаж' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid)
        ELSE (SELECT id FROM finance.departments WHERE name = 'IT-отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid)
    END,
    CASE (RANDOM() * 2)::INT
        WHEN 0 THEN (SELECT id FROM finance.employees WHERE email = 'ivanov@romashka.ru')
        ELSE (SELECT id FROM finance.employees WHERE email = 'petrov@romashka.ru')
    END,
    CASE (RANDOM() * 2)::INT
        WHEN 0 THEN (SELECT id FROM finance.counterparties WHERE name = 'ООО "Поставщик Бета"')
        ELSE (SELECT id FROM finance.counterparties WHERE name = 'ООО "Поставщик Омега"')
    END,
    (SELECT id FROM finance.transaction_types WHERE name = 'Закупка сырья'),
    (SELECT id FROM finance.expense_categories WHERE name = 'Закупка сырья'),
    CASE (RANDOM() * 2)::INT
        WHEN 0 THEN 1
        ELSE 2
    END,
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + ((RANDOM() * 27)::INT) * INTERVAL '1 day',
    20000 + (RANDOM() * 180000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    20.0,
    'Закупка сырья для производства',
    'PO-' || TO_CHAR(DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month', 'YYYYMM') || '-' || LPAD((SELECT COUNT(*) FROM generate_series(1, months.month + 3) AS cnt)::TEXT, 4, '0'),
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '45 days'
FROM generate_series(1, 6) AS months(month)
CROSS JOIN generate_series(1, months.month + 3) AS cnt
WHERE RANDOM() > 0.3;

-- 13. ЗАРПЛАТА (каждый месяц)
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, expense_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'Отдел кадров' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    (SELECT id FROM finance.employees WHERE email = 'smirnova@romashka.ru'),
    NULL,
    (SELECT id FROM finance.transaction_types WHERE name = 'Заработная плата'),
    (SELECT id FROM finance.expense_categories WHERE name = 'ФОТ'),
    1,
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '24 days',
    350000 + (RANDOM() * 50000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    13.0,
    'Начисление заработной платы',
    'PAYROLL-2026' || LPAD(months.month::TEXT, 2, '0'),
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '29 days'
FROM generate_series(1, 6) AS months(month);

-- 14. АРЕНДА (каждый месяц)
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, expense_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'Финансовый отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    (SELECT id FROM finance.employees WHERE email = 'mikhaylova@romashka.ru'),
    NULL,
    (SELECT id FROM finance.transaction_types WHERE name = 'Аренда офиса'),
    (SELECT id FROM finance.expense_categories WHERE name = 'Аренда'),
    1,
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month',
    150000 + (RANDOM() * 30000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    20.0,
    'Аренда офисного помещения',
    'RENT-2026' || LPAD(months.month::TEXT, 2, '0'),
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '9 days'
FROM generate_series(1, 6) AS months(month);

-- 15. КОММУНАЛЬНЫЕ УСЛУГИ (каждый месяц)
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, expense_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'Финансовый отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    (SELECT id FROM finance.employees WHERE email = 'mikhaylova@romashka.ru'),
    NULL,
    (SELECT id FROM finance.transaction_types WHERE name = 'Коммунальные услуги'),
    (SELECT id FROM finance.expense_categories WHERE name = 'Коммунальные услуги'),
    1,
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '14 days',
    30000 + (RANDOM() * 20000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    20.0,
    'Оплата коммунальных услуг',
    'UTIL-2026' || LPAD(months.month::TEXT, 2, '0'),
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '29 days'
FROM generate_series(1, 6) AS months(month);

-- 16. МАРКЕТИНГОВЫЕ РАСХОДЫ (Январь - Июнь 2026)
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, expense_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'Маркетинговый отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    (SELECT id FROM finance.employees WHERE email = 'sidorov@romashka.ru'),
    NULL,
    (SELECT id FROM finance.transaction_types WHERE name = 'Маркетинг и реклама'),
    (SELECT id FROM finance.expense_categories WHERE name = 'Маркетинг'),
    CASE (RANDOM() * 2)::INT
        WHEN 0 THEN 1
        ELSE 2
    END,
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + (4 + (RANDOM() * 20)::INT) * INTERVAL '1 day',
    10000 + (RANDOM() * 90000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    20.0,
    'Рекламная кампания',
    'MARKET-2026' || LPAD(months.month::TEXT, 2, '0') || '-' || LPAD((SELECT COUNT(*) FROM generate_series(1, months.month / 2 + 1) AS cnt)::TEXT, 2, '0'),
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '29 days'
FROM generate_series(1, 6) AS months(month)
CROSS JOIN generate_series(1, months.month / 2 + 1) AS cnt
WHERE RANDOM() > 0.3;

-- 17. IT-УСЛУГИ (каждый второй месяц)
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, expense_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'IT-отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    (SELECT id FROM finance.employees WHERE email = 'kozlov@romashka.ru'),
    NULL,
    (SELECT id FROM finance.transaction_types WHERE name = 'Транспортные расходы'),
    (SELECT id FROM finance.expense_categories WHERE name = 'Хостинг и IT-сервисы'),
    1,
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '19 days',
    50000 + (RANDOM() * 50000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    20.0,
    'Оплата облачных сервисов и хостинга',
    'HOST-2026' || LPAD(months.month::TEXT, 2, '0'),
    DATE '2026-01-01' + (months.month - 1) * INTERVAL '1 month' + INTERVAL '29 days'
FROM generate_series(1, 6) AS months(month)
WHERE months.month % 2 = 0;

-- 18. НАЛОГИ (квартальные платежи)
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, expense_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'Финансовый отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    (SELECT id FROM finance.employees WHERE email = 'mikhaylova@romashka.ru'),
    NULL::uuid,
    (SELECT id FROM finance.transaction_types WHERE name = 'Налоги'),
    (SELECT id FROM finance.expense_categories WHERE name = 'Налоги и сборы'),
    1,
    DATE '2026-03-28',
    80000 + (RANDOM() * 40000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    0.0,
    'Авансовый платеж по налогу на прибыль за Q1 2026',
    'TAX-2026Q1',
    DATE '2026-04-05'
UNION ALL
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'Финансовый отдел' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    (SELECT id FROM finance.employees WHERE email = 'mikhaylova@romashka.ru'),
    NULL,
    (SELECT id FROM finance.transaction_types WHERE name = 'Налоги'),
    (SELECT id FROM finance.expense_categories WHERE name = 'Налоги и сборы'),
    1,
    DATE '2026-06-28',
    90000 + (RANDOM() * 50000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    0.0,
    'Авансовый платеж по налогу на прибыль за Q2 2026',
    'TAX-2026Q2',
    '2026-07-05';

-- 19. ОБУЧЕНИЕ ПЕРСОНАЛА
INSERT INTO finance.transactions (
    company_id, department_id, employee_id, counterparty_id,
    transaction_type_id, expense_category_id, invoice_status_id,
    transaction_date, amount, currency_id, vat_rate,
    description, reference_number, due_date
)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    (SELECT id FROM finance.departments WHERE name = 'Отдел кадров' AND company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid),
    (SELECT id FROM finance.employees WHERE email = 'smirnova@romashka.ru'),
    NULL,
    (SELECT id FROM finance.transaction_types WHERE name = 'Транспортные расходы'),
    (SELECT id FROM finance.expense_categories WHERE name = 'Обучение персонала'),
    1,
    DATE '2026-02-15' + (i * 30) * INTERVAL '1 day',
    15000 + (RANDOM() * 35000),
    (SELECT id FROM finance.currencies WHERE code = 'RUB'),
    20.0,
    'Обучение сотрудников: курс #' || i,
    'EDU-2026-' || LPAD(i::TEXT, 2, '0'),
    DATE '2026-02-15' + (i * 30) * INTERVAL '1 day' + INTERVAL '14 days'
FROM generate_series(1, 3) AS i;

-- 20. ГЕНЕРАЦИЯ ОТЧЕТОВ (Январь - Июнь 2026)
INSERT INTO finance.monthly_reports (company_id, report_year, report_month, total_income, total_expense, net_profit, margin_percent)
SELECT
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid,
    2026,
    months.month,
    COALESCE((
        SELECT SUM(amount) 
        FROM finance.transactions t 
        JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id 
        WHERE t.company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid
          AND EXTRACT(YEAR FROM t.transaction_date) = 2026
          AND EXTRACT(MONTH FROM t.transaction_date) = months.month
          AND tt.is_income = TRUE
    ), 0),
    COALESCE((
        SELECT SUM(amount) 
        FROM finance.transactions t 
        JOIN finance.transaction_types tt ON t.transaction_type_id = tt.id 
        WHERE t.company_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid
          AND EXTRACT(YEAR FROM t.transaction_date) = 2026
          AND EXTRACT(MONTH FROM t.transaction_date) = months.month
          AND tt.is_income = FALSE
    ), 0),
    0,
    0
FROM generate_series(1, 6) AS months(month);

-- 21. ПРОВЕРКА РЕЗУЛЬТАТОВ
SELECT COUNT(*) AS total_transactions FROM finance.transactions;
SELECT COUNT(*) AS total_reports FROM finance.monthly_reports;
