
-- 1. Total salary by department
SELECT department, SUM(salary) AS total_salary
FROM employees
GROUP BY department;

-- 2. Average salary by department (only if average > 55000)
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 55000;

-- 3. Count of employees in each department
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department;

-- 4. Highest salary in each department
SELECT department, MAX(salary) AS highest_salary
FROM employees
GROUP BY department;

-- 5. Count of distinct job titles
SELECT COUNT(DISTINCT job_title) AS unique_job_titles
FROM employees;

-- 6. Round average salary to 2 decimal places
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department;
