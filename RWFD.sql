CREATE DATABASE rwfd;

-- Create the table based on RWFD.csv file
CREATE TABLE public.rwfd (
    date TIMESTAMP,
    patient_id VARCHAR(255),
    patient_gender VARCHAR(255),
    patient_age NUMERIC,
    patient_sat_score NUMERIC,
    patient_race VARCHAR(255),
    patient_waittime NUMERIC,
    department_referral VARCHAR(255)
);

-- Load csv into this new table
COPY rwfd
FROM 'D:\SQL Projects\RWFD\RWFD csv.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Inspect data to ensure general quality
SELECT *
FROM rwfd;

/*
Question: What patient demographic is most commonly seen in this ED? 
*/

-- Find the most prevalent or average of each: race, gender, age
SELECT 
    patient_gender,
    COUNT(patient_gender) AS gender_count,
    ROUND(AVG(patient_age), 0) AS age_avg,
    patient_race,
    COUNT(patient_race) AS race_count
FROM rwfd
GROUP BY patient_gender, patient_race 
ORDER BY 
    gender_count DESC,
    age_avg DESC,
    race_count DESC
;

/*
Answer: the data shows that the most commonly seen demographic is a White, 40-year-old male.
*/

