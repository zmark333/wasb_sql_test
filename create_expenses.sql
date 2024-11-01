USE memory.default;

-- Create the SEXI schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS SEXI;

-- Create the EXPENSE table if it doesn't exist
CREATE TABLE IF NOT EXISTS SEXI.EXPENSE (
    employee_id TINYINT,
    unit_price DECIMAL(8, 2),
    quantity TINYINT
);

-- Insert data into SEXI.EXPENSE using the VALUES clause and an INNER JOIN
INSERT INTO SEXI.EXPENSE (employee_id, unit_price, quantity)
SELECT
    emp.employee_id,
    rec.unit_price,
    rec.quantity
FROM
    (VALUES
        ('Alex', 'Jacobson', 6.50, 14),
        ('Alex', 'Jacobson', 11.00, 20),
        ('Alex', 'Jacobson', 22.00, 18),
        ('Alex', 'Jacobson', 13.00, 75),
        ('Andrea', 'Ghibaudi', 300.00, 1),
        ('Darren', 'Poynton', 40.00, 9),
        ('Umberto', 'Torrielli', 17.50, 4)
    ) AS rec (first_name, last_name, unit_price, quantity)
INNER JOIN SEXI.EMPLOYEE emp
    ON UPPER(emp.first_name) = UPPER(rec.first_name)
    AND UPPER(emp.last_name) = UPPER(rec.last_name);

-- Print SEXI.EXPENSE to check the solution
SELECT * FROM SEXI.EXPENSE;