USE flights;

-- Examine the data

SELECT *
FROM aircraft;
SELECT *
FROM certified
ORDER BY eid;
SELECT *
FROM employees;
SELECT *
FROM flight;

SELECT COUNT(*)
FROM aircraft;
-- aircraft 7 rows
SELECT COUNT(*)
FROM certified;
-- certified 14 rows
SELECT COUNT(*)
FROM employees;
-- 7 rows
SELECT COUNT(*)
FROM flight;
-- 7 rows

SELECT *
FROM aircraft
LEFT JOIN certified
	USING (aid)
LEFT JOIN employees
	USING (eid);

/*1.Find the names of aircraft such that all pilots certified to operate them have salaries more than $80,000. */
/*Per email question: For this question, the intention was asking for “the aircraft with pilots certified to operate them have salaries more than $80,000”
Just ignore “ALL” and try to solve this question again.*/
SELECT aname
FROM aircraft
JOIN certified
	USING (aid)
JOIN employees
	USING (eid)
WHERE salary > 80000
GROUP BY aname
ORDER BY aname;

-- Answer: Airbus, Airbus380, Aircraft02, Boeing, and Jet01 are the aircraft with pilots certified to operate them have salaries more than $80,000

/*2.Find the names of employees whose salary is less than the price of the cheapest route from Bangalore to Frankfurt. */
SELECT ename
	, salary
FROM employees
WHERE salary < (
	SELECT MIN(price)
    FROM flight
    WHERE origin = 'Bangalore'
		AND destination = 'Frankfurt'
);

-- Answer: Ajay, Ajith, Arnab, Harry, Ron

/*3.For all aircraft with cruising range over 1,000 miles,
find the name of the aircraft and the average salary of all pilots certified for this aircraft.*/

SELECT aid
	, aname
	, ROUND(AVG(salary), 2) as average_salary
FROM aircraft
	JOIN certified
		USING (aid)
	JOIN employees
		USING (eid)
WHERE aircraft.cruisingrange > 1000
	GROUP BY aid;
        
-- Answer: aid 302 Boeing, 306 Jet01, and 378 Airbus 380

/*4.Identify the routes that can be piloted by every pilot who makes more than $70,000.
(In other words, find the routes with distance less than the least cruising range of aircrafts driven by pilots who make more than $70,000) */

SELECT CONCAT(flno, ' ', origin, '-', destination) as route
	, origin
	, destination
    , distance
FROM flight
WHERE distance < (SELECT MIN(cruisingrange)
	FROM aircraft
    JOIN certified
		USING (aid)
	JOIN employees
		USING (eid)
	WHERE salary >70000);

-- Answer: Route 1 Bangalore-Mangalore

/*5. Print the names of pilots who can operate planes with cruising range greater than 3,000 miles but are not certified on any Boeing aircraft. */

SELECT ename, aname, cruisingrange 
FROM employees 
	JOIN certified
		ON employees.eid=certified.eid
    JOIN aircraft
		ON certified.aid=aircraft.aid
	WHERE cruisingrange>3000 
AND NOT EXISTS (SELECT *
	FROM certified 
		JOIN aircraft
			ON certified.aid=aircraft.aid 
	WHERE aname='Boeing' AND certified.eid=employees.eid);

-- Answer: Ajith

/*6. Compute the difference between the average salary of a pilot and the average salary of all employees (including pilots).*/
DROP TEMPORARY TABLE pilots;
CREATE TEMPORARY TABLE pilots
SELECT DISTINCT ename AS pilots
	, salary
FROM employees
LEFT JOIN certified
	USING (eid)
WHERE aid IS NOT NULL;

SELECT ROUND((AVG(pilots.salary) - AVG(employees.salary)),2) AS salary_diff
FROM employees
LEFT JOIN pilots
	ON employees.ename = pilots.pilots;
    
-- Answer: the salary difference is $285.71

/*7. Print the name and salary of every non-pilot whose salary is more than the average salary for pilots.*/
CREATE TEMPORARY TABLE nonpilots
SELECT DISTINCT ename
	, salary
FROM employees
LEFT JOIN certified
	USING (eid)
WHERE aid IS NULL;

SELECT *
FROM nonpilots;

SELECT ename
	, salary
FROM employees
WHERE (salary > (SELECT AVG(salary)
	FROM pilots))
		AND (ename IN (SELECT ename
			FROM nonpilots));
-- Answer: Josh is the nonpilot whose salary is ore than the average salary of pilots