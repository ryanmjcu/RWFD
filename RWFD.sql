-- REMINDER: This is all fake data. i.e., this isn't PHI, as it was all machine-generated. 

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
General descriptors of columns:
*/

-- Total patient count
SELECT COUNT(*) as patient_count
FROM rwfd;

-- Gender count
SELECT patient_gender, COUNT(*) AS count
FROM rwfd
GROUP BY patient_gender
ORDER BY count DESC;

-- Race count
SELECT patient_race, COUNT(*) AS count
FROM rwfd
GROUP BY patient_race
ORDER BY count DESC;

-- Department referral count
SELECT department_referral, COUNT(*) AS count
FROM rwfd
GROUP BY department_referral
ORDER BY count DESC;

-- Average age
SELECT ROUND(AVG(patient_age),2) AS avg_age
FROM rwfd;

-- Average satisfaction score
SELECT ROUND(AVG(patient_sat_score),2)
FROM rwfd
WHERE patient_sat_score IS NOT NULL;

-- Average wait time
SELECT ROUND(AVG(patient_waittime),2) AS avg_wait_mins
FROM rwfd;

/*
Question 1: What patient demographic is most commonly seen in this ED? 
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

/*
Question 2: What do satisfaction scores look like based on patient age?
*/

SELECT CASE
            WHEN patient_age < 18 THEN '0-18'
            WHEN patient_age BETWEEN 18 AND 30 THEN '18-30'
            WHEN patient_age BETWEEN 31 AND 45 THEN '31-45'
            WHEN patient_age BETWEEN 46 AND 60 THEN '46-60'
            ELSE '61+'
        END AS age_bin,
        ROUND(AVG(patient_sat_score), 2) AS avg_sat_score
FROM rwfd
GROUP BY age_bin
ORDER BY age_bin;

/*
Answer: Generally similar across age bins, but notably the oldest patients seem to have the lowest satisfaction scores.
*/

/*
Question 3: How does patient satisfaction change by their wait time?
*/

SELECT CASE
            WHEN patient_waittime < 20 THEN '0-20 minutes'
            WHEN patient_waittime BETWEEN 21 AND 40 THEN '21-40 minutes'
            ELSE '41+ minutes'
        END AS wait_bin,
        ROUND(AVG(patient_sat_score),2) AS avg_sat_score
FROM rwfd
WHERE patient_sat_score IS NOT NULL
GROUP BY wait_bin
ORDER BY wait_bin ASC;

/*
Answer: Satisfaction is hightest for patients with shorter (<20 minute) wait times, but doesn't follow a linear progression with longer wait bins.
*/

/*
Question 4: Do different department referrals result in changes to satisfaction scores?
*/

SELECT 
    department_referral,
    ROUND(AVG(patient_sat_score),2) AS avg_sat_score
FROM rwfd
WHERE patient_sat_score IS NOT NULL
GROUP BY department_referral
ORDER BY avg_sat_score ASC;

/*
Answer: Yes! Average satisfaction varies by over a whole point from the lowest to highest scores. Of note, even the highest and lowest are still within a point of 5.00, meaning the average patient overall doesn't have a particularly high satisfaction with their experience.
*/

/*
Question 5: what time of day sees the shortest wait time?
*/
SELECT CASE
            WHEN EXTRACT(HOUR FROM date) BETWEEN 0 AND 5 THEN '0-5am'
            WHEN EXTRACT(HOUR FROM date) BETWEEN 6 AND 11 THEN '6-11am'
            WHEN EXTRACT(HOUR FROM date) BETWEEN 12 AND 17 THEN '12-5pm'
            ELSE '6-midnight'
        END AS time_of_day,
        ROUND(AVG(patient_waittime),2) AS avg_wait_mins
FROM rwfd
GROUP BY time_of_day;

/*
Answer: It seems that this ED consistently sees a roughly 35 minute wait time for patients despite the time of day
*/

/*
Question 6: How many patients visited this ED per month, and how does that look compared to the rolling/running total?
*/

SELECT 
    to_char(date::DATE, 'YYYY-MM') AS year_month,
    COUNT(*) AS monthly_visits,
    SUM(COUNT(*)) OVER (ORDER BY TO_CHAR(date::DATE,'YYYY-MM')) AS rolling_total
FROM rwfd
GROUP BY year_month
ORDER BY year_month;

/*
Insight: Very consistent month-to-month volume, no one month seemed to have extraordinarily high vists
*/