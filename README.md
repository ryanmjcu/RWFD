# RWFD Exploratory Data Analysis
# Introduction
In this self-guided project, I set my sights on this emergency department (ED) dataset, looking to identify trends and gain insights into the patient population which this ED serves.
# Background
This dataset is part of a project called "Real World Fake Data" or RWFD, [a project by Mark Bradbourne](https://sonsofhierarchies.com/real-world-fake-data/) created to allow users to analyze and create working visualizations from computer-generated datasets. As that implies, all of this ED data is fake, and as such is NOT PHI!

As someone with a healthcare-focused background and education, and a recently-gained interest in analytics, I found this to be the perfect crossover for me to explore. 

I wanted to keep this concise and just identify a few, varied questions to answer and analyze: 
1. What patient demographic is most commonly seen in this ED?
2. What do satisfaction scores look like based on patient age?
3. How does patient satisfaction change by their wait time?
4. Do different department referrals result in changes to satisfaction scores?
5. What time of day sees the shortest wait time?
6. How many patients visited this ED per month, and how does that look compared to the rolling/running total?

To see my full, annotated code, [click here!](RWFD.sql)

Additionally, I realized that this dataset would make for a great dashboard on Tableau, [click here to visit my Tableau Public page and see my viz!](https://public.tableau.com/app/profile/ryan.johnson8348/viz/RWFDEDDashboard/Dashboard1)
# Tools Used
As with my other projects, I utilized only a few tools to complete this analysis:
- SQL
- PostgreSQL
- Tableau
- Visual Studio Code (VSCode)
- Git + GitHub

# Analysis

### Pre-Analysis Data Inspection:
Before diving into my questions, I was curious about general characteristics of this dataset, so I looked into more broad questions like "How many patients visited this ED across the whole available timeframe?" or "How many patients of each reported race visited this ED?" etc. So here's a few result sets that I find give us a baseline understanding of the population we see at this ED: 

- How many total patients were seen?

    |patient_count|
    |--------------|
    |9216         |

- How many patients identified with each race category?

    | Patient Race                        | Count |
    |------------------------------------|-------|
    | White                              | 2571  |
    | African American                   | 1951  |
    | Two or More Races                  | 1557  |
    | Asian                              | 1060  |
    | Declined to Identify               | 1030  |
    | Pacific Islander                   | 549   |
    | Native American/Alaska Native      | 498   |

- What was the average satisfaction score among those who responded?

    |avg_sat_score|
    |--------------|
    |4.99         |

- How many patients received referrals to each department?

    | Department Referral     | Count |
    |-------------------------|-------|
    | None                    | 5400  |
    | General Practice        | 1840  |
    | Orthopedics             | 995   |
    | Physiotherapy           | 276   |
    | Cardiology              | 248   |
    | Neurology               | 193   |
    | Gastroenterology        | 178   |
    | Renal                   | 86    |

Now that I have a general understanding of some of the data, I dove into answering my questions. 

### Question 1:  What patient demographic is most commonly seen in this ED?
To answer this question I needed to find the most prevalent of each qualitative demographic, and the average of each quantitative one. So I found the COUNT of the the gender identities and races, and the average of the age.
```sql
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
    race_count DESC;
```

| patient_gender | Gender_Count | Avg_Age | Patient_Race         | Race_Count |
|--------|--------------|---------|----------------------|------------|
| M      | 1296         | 40      | White                | 1296       |
| F      | 1270         | 40      | White                | 1270       |
| M      | 1028         | 40      | African American     | 1028       |
| F      | 917          | 39      | African American     | 917        |
| M      | 788          | 39      | Two or More Races    | 788        |

From the first 5 rows I'm showing above, we can see that the "average" or most commonly served demographic of patient seen at this ED is a White, ~40 year-old male.

### 2. What do satisfaction scores look like based on patient age?
Instead of showing the average satisfaction score for each individual patient age, I decided to bucket the ages into five groupings using CASE WHEN. This allowed for a more usable results set for the human eye.

```sql
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
```
The results show a largely similar satisfaction score across all age bins, all with their average hovering around 5.00. However there is an appreciable drop in satisfaction for the oldest patient group, those aged 61 or older.

### 3. How does patient satisfaction change by their wait time?
Again, I saw it most fit to apply a bucketing system to the data to answer this question for user-friendlienss. I bucketed the wait times into short, medium, and long wait time bins. Then all I had to do was average the satisfaction scores and group by the bin.

```sql
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
```

| wait_bin     | avg_sat_score |
|-------------------|-------------------------|
| 0-20 minutes      | 5.26                    |
| 21-40 minutes     | 4.83                    |
| 41+ minutes       | 5.01                    |

The results set shows us that the patients with the shortest wait times had the highest satisfaction scores. Interestingly, those who waited the longest didn't have the lowest satisfaction scores, indicating that other factors such as the quality of the care recieved made a positive impact on the patient experience.
### 4. Do different department referrals result in changes to satisfaction scores?
I wanted to take one more look at satisfaction scores, this time just grouping by the departments to see if there were any appreciable differences.
```sql
SELECT 
    department_referral,
    ROUND(AVG(patient_sat_score),2) AS avg_sat_score
FROM rwfd
WHERE patient_sat_score IS NOT NULL
GROUP BY department_referral
ORDER BY avg_sat_score ASC;
```

| Department_Referral     | Avg_sat_score |
|-------------------------|-------------------------|
| Renal                   | 4.57                    |
| Orthopedics             | 4.86                    |
| None                    | 4.95                    |
| Physiotherapy           | 4.99                    |
| General Practice        | 5.06                    |
| Cardiology              | 5.14                    |
| Neurology               | 5.28                    |
| Gastroenterology        | 5.80                    |

While I didn't suspect any specific department to have the highest satisfaction scores when referred to, I was surprised to see the disparity between the lowest and highest was over one whole point!

### 5. What time of day sees the shortest wait time?
Here, I really wanted to answer the question "What is the best time to have to go to the ED"... but the answer, of course, is "Never." So I instead examined when patients were more likely to be seen quickly. I achieved this by extracting the hour of the day from the visit timestamp, and again using CASE WHEN to bucket these into different intervals, then grouping by those buckets.
```sql
SELECT CASE
            WHEN EXTRACT(HOUR FROM date) BETWEEN 0 AND 5 THEN '0-5am'
            WHEN EXTRACT(HOUR FROM date) BETWEEN 6 AND 11 THEN '6-11am'
            WHEN EXTRACT(HOUR FROM date) BETWEEN 12 AND 17 THEN '12-5pm'
            ELSE '6-midnight'
        END AS time_of_day,
        ROUND(AVG(patient_waittime),2) AS avg_wait_mins
FROM rwfd
GROUP BY time_of_day;
```

| time_of_day  | avg_wait_mins |
|--------------|------------------|
| 0-5am        | 35.37            |
| 6-11am       | 35.70            |
| 12-5pm       | 34.66            |
| 6pm-midnight | 35.31            |

Much to my surprise, at least based on these time buckets, this ED consistently gets to the patients in around 35 minutes on average. This may point to a hospital which serves a large population, and as such sees patients quite regularly throughout the day, not in bursts around any one time.
### 6. How many patients visited this ED per month, and how does that look compared to the rolling/running total?
I was curious not just how many patients visited this ED per month, but also how that adds up over time. As such, I utilized a window function to help me find the answer to this question. 
```sql
SELECT 
    to_char(date::DATE, 'YYYY-MM') AS year_month,
    COUNT(*) AS monthly_visits,
    SUM(COUNT(*)) OVER (ORDER BY TO_CHAR(date::DATE,'YYYY-MM')) AS rolling_total
FROM rwfd
GROUP BY year_month
ORDER BY year_month;
```

| year_month | monthly_vists | rolling_total |
|------------|----------------|----------------|
| 2019-04    | 479            | 479            |
| 2019-05    | 480            | 959            |
| 2019-06    | 506            | 1465           |
| ...        | ...            | ...            |
| 2020-08    | 530            | 8279           |
| 2020-09    | 466            | 8745           |
| 2020-10    | 471            | 9216           |

The only real insight here is again the consistency with which this ED sees patients, there were no large spikes in ED visits in any particular month. Or vice versa, there wasn't any one month that saw significantly less patients.

# What I learned
I had a few key learning points from this mini-project:
- **Advanced Functions:** I learned how to apply CASE WHEN and window functions in real-life scenarios!
- **Limiting My Exploration:** There are countless other questions that could be answered here, but I found myself identifying just six questions that I felt were important either from an analytic standpoint, or a learning standpoint for me.
- **Problem-Solving:** As with every coding project, errors were encountered and I had to find the correct resources needed to answer my questions.. about my quesitions!
- **Dashboard Creation:** I created a full dashboard based on this data to give a holisitc representation of the data, I learned how to create different graphs, filter data, and more through the creation of this dashboard.

# Concluding Insight
I had a single primary insight regarding this EDA:
- This ED, perhaps as a result of being computer-generated, is consistent. With similar wait times throughout the day, and a satisfaction score averaging right at 4.99 (among many other datapoints), this ED doesn't see much variance in many anything that we can examine through the given data.
