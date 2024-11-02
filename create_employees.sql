-- Use the memory catalog and default schema
USE memory.default;

-- Create the SEXI schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS SEXI;

-- Drop the EMPLOYEE table if it exists
DROP TABLE IF EXISTS SEXI.EMPLOYEE;

-- Create the EMPLOYEE table with data, casting employee_id and manager_id to TINYINT
CREATE TABLE SEXI.EMPLOYEE AS
SELECT
    CAST(employee_id AS TINYINT) AS employee_id,
    first_name,
    last_name,
    job_title,
    CAST(manager_id AS TINYINT) AS manager_id
FROM
(
    VALUES
        (1, 'Ian', 'James', 'CEO', 4),
        (2, 'Umberto', 'Torrielli', 'CSO', 1),
        (3, 'Alex', 'Jacobson', 'MD EMEA', 2),
        (4, 'Darren', 'Poynton', 'CFO', 2),
        (5, 'Tim', 'Beard', 'MD APAC', 2),
        (6, 'Gemma', 'Dodd', 'COS', 1),
        (7, 'Lisa', 'Platten', 'CHR', 6),
        (8, 'Stefano', 'Camisaca', 'GM Activation', 2),
        (9, 'Andrea', 'Ghibaudi', 'MD NAM', 2)
) AS t (employee_id, first_name, last_name, job_title, manager_id);

-- Print out the result
SELECT * FROM SEXI.EMPLOYEE;
