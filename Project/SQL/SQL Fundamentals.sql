-- SELECT STATEMENT 

SELECT first_name,
last_name, 
birth_date
age,
age + 10 as 'Age +10'
FROM Parks_and_Recreation..EMPLOYEE_DEMOGRAPHICS

SELECT DISTINCT first_name,gender -- select uniques first_name.
FROM Parks_and_Recreation..EMPLOYEE_DEMOGRAPHICS

-- WHERE CLAUSE 

SELECT * 
FROM Parks_and_Recreation..EMPLOYEE_SALARY
WHERE salary >= 50000;

SELECT * 
FROM Parks_and_Recreation..employee_demographics
WHERE gender != 'female' ;

SELECT * 
FROM Parks_and_Recreation..employee_demographics
WHERE birth_date > '1985-01-01'
 AND gender = 'male'

SELECT * 
FROM Parks_and_Recreation..employee_demographics
WHERE birth_date > '1985-01-01'
 OR NOT gender = 'male' 

SELECT * 
FROM Parks_and_Recreation..employee_demographics
WHERE (first_name = 'Leslie' AND age = 44) OR age >= 55

SELECT * 
FROM Parks_and_Recreation..employee_demographics
WHERE First_name LIKE '%JER%'

SELECT * 
FROM Parks_and_Recreation..employee_demographics
WHERE birth_date LIKE '%1985%'

SELECT * 
FROM Parks_and_Recreation..employee_demographics
WHERE first_name LIKE 'A__';

/* % is anything "come before" or anything "come after" depends on the position */

-- GROUP BY (Group tgt row based on columns) / ORDER BY (columns) / HAVING / LIMIT

SELECT gender,AVG(age) as 'Average'
FROM Parks_and_Recreation..employee_demographics
GROUP BY gender

SELECT occupation,SUM(salary) AS 'Total Salary',COUNT(occupation) AS 'Total Occupation'
FROM Parks_and_Recreation..employee_salary
GROUP BY occupation
ORDER BY [Total Salary] DESC;

SELECT gender ,AVG(age) AS 'AVG',MAX(age) AS 'MAX', MIN(age) AS 'MIN',COUNT(age) AS 'COUNT'
FROM Parks_and_Recreation..employee_demographics
GROUP BY gender

SELECT occupation, AVG(salary)
FROM Parks_and_Recreation..employee_salary
WHERE occupation LIKE '%MANAGER%'
GROUP BY occupation
HAVING AVG(salary) > 75000

-- HAVING is for aggregate functions.

SELECT *
FROM Parks_and_Recreation..employee_demographics
ORDER BY age DESC
--LIMIT 3,2; -- take the second row from the TOP 3.

-- JOINS
-- INNER JOIN - return rows that have the same columns/rows in both tables.

SELECT a.employee_id, a.first_name, a.age, a.gender, a.birth_date, b.occupation, b.salary
FROM Parks_and_Recreation..employee_demographics a
INNER JOIN Parks_and_Recreation..employee_salary b
	ON a.employee_id = b.employee_id;

-- LEFT JOIN - take everything on the left and return matches on the right table.

SELECT * 
FROM Parks_and_Recreation..employee_demographics a
LEFT JOIN Parks_and_Recreation..employee_salary b
	ON a.employee_id = b.employee_id;

-- SELF JOIN - join with the same table.

SELECT a.employee_id AS emp_santa,
a.first_name AS first_name_santa,
a.last_name AS last_name_santa,
b.employee_id AS emp_name,
b.first_name AS first_name_emp,
b.last_name AS last_name_emp
FROM Parks_and_Recreation..employee_salary a
JOIN Parks_and_Recreation..employee_salary b
 ON a.employee_id + 1 = b.employee_id

-- Joining multiple tables 

SELECT *
FROM Parks_and_Recreation..employee_demographics a
INNER JOIN Parks_and_Recreation..employee_salary b
	ON a.employee_id = b.employee_id
INNER JOIN Parks_and_Recreation..parks_departments c
	ON b.dept_id = c.department_id;

-- UNIONS - COMBINE ROWS OF DATA FROM DIFFERENT TABLE (unique/distinct).

SELECT first_name,last_name
FROM Parks_and_Recreation..employee_demographics
UNION
SELECT first_name,last_name
FROM Parks_and_Recreation..employee_demographics

-- UNION ALL - Combine without distinct 

SELECT first_name,last_name
FROM Parks_and_Recreation..employee_demographics
UNION ALL
SELECT first_name,last_name
FROM Parks_and_Recreation..employee_demographics

-- USE CASE
SELECT first_name, last_name, 'Old Man' AS Label
FROM Parks_and_Recreation..employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Lady' AS Label
FROM Parks_and_Recreation..employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'Highly Paid Employee' AS Label
FROM Parks_and_Recreation..employee_salary
WHERE salary > 70000
ORDER BY first_name,last_name

-- STRING FUNCTIONS

SELECT first_name, LENGTH(first_name)
FROM Parks_and_Recreation..employee_demographics
ORDER BY 2;

SELECT UPPER(first_name) AS 'first_name', LOWER(last_name) AS 'last_name'
FROM Parks_and_Recreation..employee_demographics

SELECT TRIM('              SKY         ') -- LTRIM/RTRIM

SELECT first_name, LEFT(first_name,4) AS 'LEFT', RIGHT(first_name,4) AS 'RIGHT',birth_date,
SUBSTRING(CONVERT(nvarchar, birth_date, 6), 3, 2) AS 'SUBSTRING'
FROM Parks_and_Recreation..employee_demographics

SELECT first_name, REPLACE (first_name,'a','z'), LOCATE('X',first_name)
FROM Parks_and_Recreation..employee_demographics

SELECT first_name, last_name, CONCAT(first_name,' ', last_name)
FROM Parks_and_Recreation..employee_demographics

-- CASE STATEMENT

SELECT first_name, last_name,age,
CASE
	WHEN age <= 30 THEN 'Young'
	WHEN age BETWEEN 31 and 40 THEN 'Middle Age'
	WHEN age >40 THEN 'Old'
END AS Age_Bracket
FROM Parks_and_Recreation..employee_demographics

SELECT a.first_name,a.last_name,a.salary,a.occupation,b.department_name,
CASE
	WHEN a.salary <= 50000 THEN a.salary *0.05
	WHEN a.salary > 50000 THEN a.salary *0.07
	WHEN a.occupation = 'Finance' THEN a.salary *0.1
END AS Increment,
CASE
	WHEN a.salary <= 50000 THEN a.salary + (a.salary *0.05)
	WHEN a.salary > 50000 THEN a.salary + (a.salary *0.07)
	WHEN a.occupation = 'Finance' THEN  a.salary + (a.salary *0.1)
END AS TOTAL_SALARY,
CASE
	WHEN b.department_name = 'Finance' THEN (a.salary *0.07)
	ELSE 0
END AS BONUS
FROM Parks_and_Recreation..employee_salary a
LEFT JOIN Parks_and_Recreation..parks_departments b
	ON a.dept_id =b.department_id

--SUBQUERIES
SELECT *
FROM Parks_and_Recreation..employee_demographics
WHERE employee_id IN (SELECT employee_id
						FROM Parks_and_Recreation..employee_salary 
						WHERE dept_id = 1)
-- Operant should only have one

SELECT first_name,salary,
(SELECT AVG(salary) AS AVG_SALARY FROM Parks_and_Recreation..employee_salary)
FROM Parks_and_Recreation..employee_salary

SELECT gender,avg_age
FROM
(SELECT gender, AVG(age) as avg_age, MAX(age) as Max_age, COUNT(age) as cnt_age
FROM Parks_and_Recreation..employee_demographics
GROUP BY gender ) AS Agg_table;

-- WINDOWS FUNCTION

SELECT b.first_name, b.last_name,b.gender, salary,SUM(a.salary) OVER (PARTITION BY gender ORDER BY b.employee_id) AS 'Rolling Total'
FROM Parks_and_Recreation..employee_salary a
JOIN Parks_and_Recreation..employee_demographics b
	ON a.employee_id = b.employee_id;

SELECT b.employee_id,b.first_name, b.last_name,b.gender, salary, 
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY a.salary DESC) AS 'Row_Num',
RANK() OVER(PARTITION BY gender ORDER BY a.salary DESC) AS 'Rank_Num', -- if there is duplicate it will show same number but the next number will show positionaly
DENSE_RANK() OVER(PARTITION BY gender ORDER BY a.salary DESC) AS 'DenseRank_Num'-- same as rank num but the next number will be accordingly.
FROM Parks_and_Recreation..employee_salary a
JOIN Parks_and_Recreation..employee_demographics b
	ON a.employee_id = b.employee_id;

-- COMMON TABLE EXPRESSION (CTE)

WITH CTE_Example AS (
SELECT gender, AVG(age) AS Avg_age, MAX(age) AS Max_age, COUNT(age) AS Cnt_age
FROM Parks_and_Recreation..employee_demographics
GROUP BY gender
)
SELECT avg(avg_age)
FROM CTE_Example

WITH CTE_Example2 AS (
SELECT employee_id,gender, birth_date
FROM Parks_and_Recreation..employee_demographics
WHERE birth_date > '1985-01-01'
),
CTE_Example3 AS
(
SELECT employee_id,salary
FROM Parks_and_Recreation..employee_salary
WHERE salary > 50000 
)
SELECT* 
FROM CTE_EXAMPLE2 a
JOIN CTE_EXAMPLE3 b
	ON a.employee_id = b.employee_id ;

-- CREATE PROCEDURE

CREATE PROCEDURE large_salaries()
SELECT *
FROM Parks_and_Recreation..employee_salary
WHERE salary >= 50000;




 


