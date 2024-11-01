-- Use the memory catalog and default schema
USE memory.default;

-- Create the SEXI schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS SEXI;

-- Drop tables if they already exist
DROP TABLE IF EXISTS SEXI.SUPPLIER;
DROP TABLE IF EXISTS SEXI.INVOICE;

-- Create the SUPPLIER table
CREATE TABLE SEXI.SUPPLIER (
    supplier_id TINYINT,
    name VARCHAR
);

-- Insert suppliers into the SUPPLIER table
INSERT INTO SEXI.SUPPLIER (supplier_id, name)
VALUES
    (1, 'Catering Plus'),
    (2, 'Dave''s Discos'),
    (3, 'Entertainment tonight'),
    (4, 'Ice Ice Baby'),
    (5, 'Party Animals');

-- Create the INVOICE table
CREATE TABLE SEXI.INVOICE (
    supplier_id TINYINT,
    invoice_amount DECIMAL(8, 2),
    due_date DATE
);

-- Base date for calculations (assuming current date is '2024-11-01')
-- We'll hardcode this date in each calculation

-- Insert invoices into the INVOICE table
INSERT INTO SEXI.INVOICE (supplier_id, invoice_amount, due_date)
SELECT
    (SELECT supplier_id FROM SEXI.SUPPLIER WHERE name = 'Party Animals') AS supplier_id,
    6000.00 AS invoice_amount,
    date_trunc('month', DATE '2024-11-01' + INTERVAL '4' MONTH) - INTERVAL '1' DAY AS due_date
UNION ALL
SELECT
    (SELECT supplier_id FROM SEXI.SUPPLIER WHERE name = 'Catering Plus') AS supplier_id,
    2000.00 AS invoice_amount,
    date_trunc('month', DATE '2024-11-01' + INTERVAL '3' MONTH) - INTERVAL '1' DAY AS due_date
UNION ALL
SELECT
    (SELECT supplier_id FROM SEXI.SUPPLIER WHERE name = 'Catering Plus') AS supplier_id,
    1500.00 AS invoice_amount,
    date_trunc('month', DATE '2024-11-01' + INTERVAL '4' MONTH) - INTERVAL '1' DAY AS due_date
UNION ALL
SELECT
    (SELECT supplier_id FROM SEXI.SUPPLIER WHERE name = 'Dave''s Discos') AS supplier_id,
    500.00 AS invoice_amount,
    date_trunc('month', DATE '2024-11-01' + INTERVAL '2' MONTH) - INTERVAL '1' DAY AS due_date
UNION ALL
SELECT
    (SELECT supplier_id FROM SEXI.SUPPLIER WHERE name = 'Entertainment tonight') AS supplier_id,
    6000.00 AS invoice_amount,
    date_trunc('month', DATE '2024-11-01' + INTERVAL '4' MONTH) - INTERVAL '1' DAY AS due_date
UNION ALL
SELECT
    (SELECT supplier_id FROM SEXI.SUPPLIER WHERE name = 'Ice Ice Baby') AS supplier_id,
    4000.00 AS invoice_amount,
    date_trunc('month', DATE '2024-11-01' + INTERVAL '7' MONTH) - INTERVAL '1' DAY AS due_date;
