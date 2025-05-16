SELECT *
FROM parks_and_recreation.employee_salary
WHERE salary >+ 50000;


SELECT *
FROM employee_demographics
WHERE (first_name= 'Leslie' AND age = 44) OR gender = 'male';

-- LIKE Statement
-- % and _
SELECT *
FROM employee_demographics
WHERE first_name LIKE 'a___%';


-- Group By
SELECT *
FROM employee_demographics;

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(first_name)
FROM employee_demographics
GROUP BY gender;

-- ORDER BY
SELECT *
FROM employee_demographics
ORDER BY gender ASC, age DESC;

-- Having vs Where
SELECT gender, AVG(age)
FROM employee_demographics
GROUP BY gender
HAVING AVG(age) > 40;

SELECT occupation, AVG(salary)
FROM employee_salary
WHERE occupation LIKE '%manager'
GROUP BY occupation
HAVING AVG(salary) > 75000;

-- Limit % Aliasing
SELECT *
FROM employee_demographics
ORDER BY age DESC
LIMIT 2, 1;

-- Aliasing
select gender, avg(age) as avg_age
from employee_demographics
group by gender 
having avg_age < 40;

-- Joins
select * from employee_demographics;
select * from employee_salary;

select dem.employee_id, age, occupation, salary
from employee_demographics as dem
inner join employee_salary as sal
	on dem.employee_id = sal.employee_id
having salary > 40000;

-- Outer Join
select * 
from employee_demographics as dem
right join employee_salary as sal
	on dem.employee_id = sal.employee_id;
    
-- Self Join
select * 
from employee_salary emp1
join employee_salary emp2
	on emp1.employee_id + 1 = emp2.employee_id;

-- Joining multiple tables together
select * from parks_departments;

select *
from employee_demographics as dem
inner join employee_salary as sal
	on dem.employee_id = sal.employee_id
inner join parks_departments prk
	on sal.dept_id = prk.department_id;
    
-- Unions
select first_name, last_name, 'old_man' as Label
from employee_demographics
where age > 40 and gender = 'Male'
union
select first_name, last_name, 'old_lady' as Label
from employee_demographics
where age > 40 and gender = 'Female'
union
select first_name, last_name, 'high_paid_employee' as Label
from employee_salary
where salary > 70000
order by first_name, last_name;

-- String Functions
select first_name, length(first_name) as lenght
from employee_demographics
order by 1;

select first_name, upper(first_name) as upper, lower(first_name) as lower
from employee_demographics
order by first_name;

select trim('    sky    ') as trim;
select rtrim('            sky    ') as trim;
select ltrim('    sky    ') as trim;


select first_name, 
left(first_name, 4) as left_, 
right(first_name, 4) as right_,
birth_date,
substring(birth_date, 9, 2) as bday
from employee_demographics;


select first_name, replace(first_name, 'A', 'f')
from employee_demographics;

select first_name, locate('ri', first_name)
from employee_demographics;

select first_name, last_name,
concat(first_name, ' ', last_name) as full_name
from employee_demographics;

-- Case Statement

select first_name, last_name, age,
case
	when age < 34 then 'young'
    when age between 34 and 45 then 'middle age'
    when age >= 46 then 'old'
end as age_situation
from employee_demographics
order by age;

select * 
from employee_salary;
select * 
from parks_departments;

select first_name, last_name, salary,
case
	when salary < 50000 then salary + (salary * 0.05)
	when salary >= 50000 then salary + (salary * 0.07)
end as new_salary,
case
	when dept_id = 6 then salary * .1
end as bonus
from employee_salary;

-- Subqueries

SELECT *
FROM employee_demographics
WHERE employee_id IN (
				SELECT employee_id
                FROM employee_salary
                WHERE dept_id = 1);
                
SELECT AVG(max_age)
FROM
(SELECT gender,
AVG(age) as avg_age,
max(age) as max_age,
min(age) as min_age,
count(age)
FROM employee_demographics
GROUP BY gender) as Agg_table;

-- Window Functions

select gender, avg(salary) as avg_salary
from employee_demographics dem
		join employee_salary sal
		on dem.employee_id = sal.employee_id
group by gender;


select dem.first_name, gender, salary,
sum(salary) over(partition by gender order by dem.employee_id) as rolling_total
from employee_demographics dem
		join employee_salary sal
		on dem.employee_id = sal.employee_id;


select dem.first_name, gender, salary,
row_number() over(partition by gender order by salary desc) as row_num,
rank() over(partition by gender order by salary desc) as rank_num,
dense_rank() over(partition by gender order by salary desc) as dense_rank_num
from employee_demographics dem
		join employee_salary sal
		on dem.employee_id = sal.employee_id;


-- CTEs common table expression

WITH CTE_Example AS
(
SELECT employee_id, gender, birth_date
from employee_demographics
where birth_date > '1985-01-01'
),
CTE_Example2 AS
(
select employee_id, salary
from employee_salary
where salary > 50000
)
select *
from CTE_Example
	join CTE_Example2
    on CTE_Example.employee_id = CTE_Example2.employee_id;
    

-- Temporary Tables

CREATE TEMPORARY TABLE temp_table
(
first_name varchar(50),
last_name varchar(50),
fav_movie varchar(150)
);

select * 
from temp_table;

INSERT INTO temp_table
VALUES('Fatih','Ayar','LOTR');

select * 
from temp_table;

select * 
from employee_salary;

CREATE TEMPORARY TABLE salary_over_50k
select *
from employee_salary
where salary >= 50000;

select * 
from salary_over_50k;























































































































































