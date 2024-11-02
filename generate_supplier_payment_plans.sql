-- Use the memory catalog and default schema
USE memory.default;

-- Ensure the SEXI schema exists
CREATE SCHEMA IF NOT EXISTS SEXI;


-- Define the payment start date (first day of next month)
WITH payment_start AS (
    SELECT date_trunc('month', current_date + interval '1' month) AS payment_start_date
),

-- Get the maximum due date from the invoices
max_due_date AS (
    SELECT MAX(due_date) AS max_due_date
    FROM SEXI.INVOICE
),

-- Generate a series of end-of-month dates from payment start date up to the maximum due date
end_of_months AS (
    SELECT date_trunc('month', date) + interval '1' month - interval '1' day AS end_of_month
    FROM (
        SELECT sequence(
            (SELECT payment_start_date FROM payment_start),
            (SELECT max_due_date FROM max_due_date),
            INTERVAL '1' MONTH
        ) AS payment_dates
    )
    CROSS JOIN UNNEST(payment_dates) AS t(date)
),

-- Calculate the number of payments and monthly payment amounts for each invoice
invoice_payments AS (
    SELECT
        inv.supplier_id,
        s.name AS supplier_name,
        inv.invoice_amount,
        inv.due_date,
        date_diff('month', (SELECT payment_start_date FROM payment_start) - INTERVAL '1' DAY, inv.due_date) AS months_till_payment,
        inv.invoice_amount / date_diff('month', (SELECT payment_start_date FROM payment_start) - INTERVAL '1' DAY, inv.due_date) AS monthly_payment_raw
    FROM SEXI.INVOICE inv
    JOIN SEXI.SUPPLIER s ON inv.supplier_id = s.supplier_id
),

-- Adjust monthly payments to handle rounding errors
adjusted_invoice_payments AS (
    SELECT
        supplier_id,
        supplier_name,
        invoice_amount,
        due_date,
        months_till_payment,
        ROUND(monthly_payment_raw, 2) AS monthly_payment,
        invoice_amount - (ROUND(monthly_payment_raw, 2) * (months_till_payment - 1)) AS last_payment_amount
    FROM invoice_payments
),

-- Generate payment schedule for each invoice
invoice_payment_schedule AS (
    SELECT
        aip.supplier_id,
        aip.supplier_name,
        aip.invoice_amount,
        aip.due_date,
        eom.end_of_month AS payment_date,
        CASE
            WHEN ROW_NUMBER() OVER (PARTITION BY aip.supplier_id, aip.invoice_amount ORDER BY eom.end_of_month) < aip.months_till_payment THEN aip.monthly_payment
            ELSE aip.last_payment_amount
        END AS payment_amount
    FROM adjusted_invoice_payments aip
    JOIN end_of_months eom ON eom.end_of_month <= aip.due_date
    WHERE eom.end_of_month >= (SELECT payment_start_date FROM payment_start)
),

-- Aggregate payments per supplier per payment date
supplier_payments AS (
    SELECT
        supplier_id,
        supplier_name,
        payment_date,
        SUM(payment_amount) AS payment_amount
    FROM invoice_payment_schedule
    GROUP BY supplier_id, supplier_name, payment_date
),

-- Calculate balance outstanding per supplier
balance_outstanding AS (
    SELECT
        supplier_id,
        supplier_name,
        SUM(invoice_amount) AS total_balance
    FROM adjusted_invoice_payments
    GROUP BY supplier_id, supplier_name
),

-- Calculate cumulative payments per supplier to determine balance outstanding after each payment
cumulative_payments AS (
    SELECT
        sp.supplier_id,
        sp.supplier_name,
        sp.payment_date,
        sp.payment_amount,
        bo.total_balance,
        SUM(sp.payment_amount) OVER (PARTITION BY sp.supplier_id ORDER BY sp.payment_date) AS cumulative_payment,
        bo.total_balance - SUM(sp.payment_amount) OVER (PARTITION BY sp.supplier_id ORDER BY sp.payment_date) AS balance_outstanding
    FROM supplier_payments sp
    JOIN balance_outstanding bo ON sp.supplier_id = bo.supplier_id
)

-- Final Output
SELECT
    supplier_id,
    supplier_name,
    ROUND(payment_amount, 2) AS payment_amount,
    ROUND(balance_outstanding, 2) AS balance_outstanding,
    payment_date
FROM cumulative_payments
ORDER BY supplier_id, payment_date;
