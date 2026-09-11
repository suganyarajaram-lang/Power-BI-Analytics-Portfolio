-- Healthcare & Insurance Claims Analytics
-- Key Concepts Covered: Multi-Table Aggregation, Window Functions (AVG OVER), Correlated Subquery Risk Scoring

WITH PatientRiskProfiles AS (
    SELECT 
        age,
        sex,
        bmi,
        smoker,
        region,
        charges,
        -- Categorize BMI Risk Levels
        CASE 
            WHEN bmi < 18.5 THEN 'Underweight'
            WHEN bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
            WHEN bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
            ELSE 'Obese'
        END AS bmi_category
    FROM insurance
)
SELECT 
    p.region,
    p.smoker,
    p.bmi_category,
    COUNT(*) AS patient_count,
    ROUND(AVG(p.charges), 2) AS avg_charges,
    ROUND(MIN(p.charges), 2) AS min_charges,
    ROUND(MAX(p.charges), 2) AS max_charges,
    -- Window Function: Calculate overall regional average charge to benchmark patients against regional norms
    ROUND(AVG(AVG(p.charges)) OVER (PARTITION BY p.region), 2) AS regional_avg_benchmark,
    -- Correlated Subquery / Conditional Flag for high-cost patient variance
    ROUND(
        AVG(p.charges) - (
            SELECT AVG(i2.charges) 
            FROM insurance i2 
            WHERE i2.region = p.region
        ), 2
    ) AS cost_variance_from_regional_avg
FROM PatientRiskProfiles p
GROUP BY p.region, p.smoker, p.bmi_category
ORDER BY p.region, avg_charges DESC;
