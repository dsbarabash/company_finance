-- Функция валидации доход/расход в таблице транзакций (для триггера trigger_validate_transaction_categories)
CREATE OR REPLACE FUNCTION finance.trg_validate_transaction_categories()
RETURNS TRIGGER AS $$
DECLARE
    v_is_income BOOLEAN;
BEGIN
    SELECT is_income INTO v_is_income 
    FROM finance.transaction_types 
    WHERE id = NEW.transaction_type_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Тип транзакции с ID % не существует', NEW.transaction_type_id;
    END IF;
    
    -- Валидация для доходов
    IF v_is_income THEN
        IF NEW.income_category_id IS NULL THEN
            RAISE EXCEPTION 'Для дохода необходимо указать income_category_id';
        END IF;
        IF NEW.expense_category_id IS NOT NULL THEN
            RAISE EXCEPTION 'Для дохода expense_category_id должен быть NULL';
        END IF;
    -- Валидация для расходов
    ELSE
        IF NEW.expense_category_id IS NULL THEN
            RAISE EXCEPTION 'Для расхода необходимо указать expense_category_id';
        END IF;
        IF NEW.income_category_id IS NOT NULL THEN
            RAISE EXCEPTION 'Для расхода income_category_id должен быть NULL';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер 1: Для таблицы transactions
CREATE TRIGGER trigger_validate_transaction_categories
BEFORE INSERT OR UPDATE OF transaction_type_id, income_category_id, expense_category_id 
ON finance.transactions
FOR EACH ROW
EXECUTE FUNCTION finance.trg_validate_transaction_categories();


-- Функция для автообновления updated_at (для триггера trigger_transactions_update)
CREATE OR REPLACE FUNCTION finance.trg_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер 2: Для таблицы transactions
CREATE TRIGGER trigger_transactions_update
BEFORE UPDATE ON finance.transactions
FOR EACH ROW
EXECUTE FUNCTION finance.trg_update_timestamp();
