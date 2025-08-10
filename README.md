
# Task 4: Aggregate Functions and Grouping

## Objective
Use aggregate functions and grouping to summarize data using SQL.

## Tools Used
- DB Browser for SQLite
- SQLite Database

## Dataset
The dataset is stored in `task4_sample.db` and contains an `employees` table with the following columns:
- `employee_id` (INTEGER)
- `name` (TEXT)
- `department` (TEXT)
- `job_title` (TEXT)
- `salary` (INTEGER)

## SQL Queries
All SQL queries are stored in `task4_queries.sql` and cover:
1. **SUM** - Total salary by department  
2. **AVG + HAVING** - Average salary by department where average > 55000  
3. **COUNT** - Number of employees in each department  
4. **MAX** - Highest salary in each department  
5. **COUNT(DISTINCT)** - Number of unique job titles  
6. **ROUND + AVG** - Average salary rounded to 2 decimal places

## How to Run
1. Open `task4_sample.db` in DB Browser for SQLite.
2. Load and execute queries from `task4_queries.sql`.
3. View and screenshot the results.
4. Upload the database file, queries file, and screenshots to a GitHub repository.

## Author
Rohit Gupta
