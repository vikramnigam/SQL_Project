--Create a Database name 'insurance'
CREATE DATABASE insurance;
USE insurance;
GO;

--Import Data from Excel file to SQL Server through Import and Export Wizard

-- Check the Table

SELECT * FROM insurance_dataset$;

-- How many rows are in dataset?

SELECT
	COUNT(*)
FROM insurance_dataset$;


--What is the average age of Smoker in the dataset?

SELECT
	ROUND(AVG(age), 2) AS Average_age
FROM insurance_dataset$
WHERE smoker ='yes';


--Organize Occupation by Most number of Workers

SELECT 
	occupation,
	COUNT(*) as No_of_Employees
FROM insurance_dataset$
GROUP BY occupation
ORDER BY No_of_Employees DESC;

--Which occupation has most number of Smokers?

SELECT
	occupation,
	COUNT(*) as No_of_Smokers
FROM insurance_dataset$
WHERE smoker= 'yes'
GROUP BY occupation
ORDER BY No_of_Smokers DESC;


--Since we know that above 25 BMI is considered Overweight, Let's find out what percentage of people in each
--region that can be considred as Overweight or Obese


WITH region_bmi AS (
	SELECT 
		region,
		COUNT(*) as total_counts,
		SUM(CASE WHEN bmi > 25.0 THEN 1 ELSE 0 END) AS bmi_25
	FROM insurance_dataset$
	GROUP BY region
)
SELECT
	region,
	total_counts,
	CONCAT((bmi_25*100/ total_counts),'%') AS Per_of_bmi_25
FROM region_bmi;

--Seems like Every Region has 78% percentage of people above 25.0 BMI



--What % of people who exercise 'Frequently' has 'High Blood Pressure' and they are smoker?



SELECT
	exercise_frequency,
	COUNT(*) AS total_people,
	CONCAT(ROUND((COUNT(*) * 100/ SUM(COUNT(*)) OVER()),2), '%') AS Percen
FROM insurance_dataset$
WHERE 
	medical_history = 'High blood pressure'
	AND smoker= 'yes'
GROUP BY exercise_frequency;



--What is the coverage level with the highest average charges for people with high blood pressure?


WITH high_bp AS(
	SELECT
		coverage_level,
		ROUND(AVG(charges),2) AS avg_charges
	FROM insurance_dataset$
	WHERE medical_history= 'High blood pressure'
	GROUP BY coverage_level
)
SELECT
	coverage_level,
	avg_charges
FROM high_bp
WHERE avg_charges = (SELECT MAX(avg_charges) FROM high_bp);


-- How many percentage of all occupations where people doesn't have any family medical history 
--but he has high blood pressre now


WITH family_history AS (
	SELECT 
		*
	FROM insurance_dataset$
	WHERE medical_history= 'High blood pressure'
		AND family_medical_history ='None'
)
SELECT 
	occupation,
	COUNT(*) AS total_counts,
	CONCAT(ROUND((COUNT(*) * 100/ SUM(COUNT(*)) OVER()),2), '%') AS Percen
FROM family_history
GROUP BY occupation
ORDER BY Percen DESC;


-- Which region has the highest number of Heart Disease


SELECT
	region,
	SUM(CASE WHEN medical_history= 'Heart disease' THEN 1 ELSE 0 END) AS no_of_heart_patient
FROM insurance_dataset$
GROUP BY region
ORDER BY no_of_heart_patient DESC;



-- How many percentage of each gender has High blood pressure and are smoker but no diabetes in their medical histroy


WITH gender_count AS(
	SELECT 
		gender,
		COUNT(*) AS total_counts,
		SUM(CASE WHEN medical_history= 'High blood pressure' AND 
			smoker= 'yes' AND 
			medical_history NOT LIKE '%diabetes%' THEN 1 ELSE 0 END) as details
	FROM insurance_dataset$
	GROUP BY gender
)
SELECT 
	gender,
	total_counts,
	(details*100/ total_counts) as total_percentage
FROM gender_count;


-- What are the average charges for all exercise group if you are smoker?


SELECT
	exercise_frequency,
	ROUND(AVG(charges),2) AS avg_charges
FROM insurance_dataset$
WHERE smoker= 'Yes'
GROUP BY exercise_frequency
ORDER BY avg_charges DESC;


-- What are the average charges of people who have twice number of chidren as average number of children
-- and when people are smokers vs when people are not?


WITH avg_smoker_children AS(
	SELECT 
		FLOOR(AVG(CASE WHEN smoker= 'Yes' THEN children END)) AS avg_smoke
	FROM insurance_dataset$
)
SELECT
	ROUND(AVG(charges),2) as avg_charges
FROM insurance_dataset$
WHERE children >= 2*(SELECT avg_smoke FROM avg_smoker_children);