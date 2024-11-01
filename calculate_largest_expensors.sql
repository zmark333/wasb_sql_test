USE memory.default;

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.manager_id,
    CONCAT(COALESCE(m.first_name, ''), ' ', COALESCE(m.last_name, '')) AS manager_name,
    ROUND(SUM(exp.unit_price * exp.quantity), 2) AS total_expensed_amount
FROM
    SEXI.EMPLOYEE e
    LEFT JOIN SEXI.EMPLOYEE m ON e.manager_id = m.employee_id
    INNER JOIN SEXI.EXPENSE exp ON e.employee_id = exp.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    e.manager_id,
    m.first_name,
    m.last_name
HAVING
    SUM(exp.unit_price * exp.quantity) > 1000
ORDER BY
    total_expensed_amount DESC;
