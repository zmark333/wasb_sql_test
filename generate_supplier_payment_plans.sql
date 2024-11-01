USE memory.default;

WITH SupplierBalances AS (
    SELECT
        sup.supplier_id,
        sup.name AS supplier_name,
        inv.invoice_amount,
        date_trunc('month', inv.due_date + interval '1' month) - interval '1' day AS due_date
    FROM
        SEXI.SUPPLIER AS sup
        INNER JOIN SEXI.INVOICE AS inv ON sup.supplier_id = inv.supplier_id
)
SELECT
    supplier_id,
    supplier_name,
    due_date,
    SUM(invoice_amount) AS total_invoice_amount
FROM
    SupplierBalances
GROUP BY
    supplier_id,
    supplier_name,
    due_date
ORDER BY
    due_date,
    supplier_name;
