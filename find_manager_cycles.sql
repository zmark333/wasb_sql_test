USE memory.default;

WITH RECURSIVE manager_cycles (employee_id, manager_id, path, visited) AS (
    -- Anchor member
    SELECT
        employee_id,
        manager_id,
        CAST(employee_id AS VARCHAR) AS path,
        CAST(employee_id AS VARCHAR) AS visited
    FROM
        sexi.EMPLOYEE

    UNION ALL

    -- Recursive member
    SELECT
        mc.employee_id,
        e.manager_id,
        CONCAT(mc.path, '->', CAST(e.manager_id AS VARCHAR)) AS path,
        CONCAT(mc.visited, ',', CAST(e.manager_id AS VARCHAR)) AS visited
    FROM
        manager_cycles mc
        JOIN sexi.EMPLOYEE e ON mc.manager_id = e.employee_id
    WHERE
        POSITION(',' || CAST(e.manager_id AS VARCHAR) || ',' IN ',' || mc.visited || ',') = 0
        AND e.manager_id IS NOT NULL
)

SELECT
    employee_id AS cyclic_employee_id,
    path AS cycle_path
FROM
    manager_cycles
WHERE
    POSITION(',' || CAST(manager_id AS VARCHAR) || ',' IN ',' || visited || ',') > 0;
