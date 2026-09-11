-- HR Attrition & Operations Analysis
-- Key Concepts Covered: CTEs, Conditional Aggregation (CASE WHEN), Window Functions, Departmental Groupings

WITH EmployeeStats AS (
    SELECT 
        Department,
        JobRole,
        OverTime,
        COUNT(EmployeeNumber) AS Total_Employees,
        SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS Total_Attrition,
        AVG(MonthlyIncome) AS Avg_Monthly_Income,
        AVG(YearsAtCompany) AS Avg_Tenure_Years,
        AVG(JobSatisfaction) AS Avg_Job_Satisfaction
    FROM hr_employee_attrition
    GROUP BY Department, JobRole, OverTime
),
DepartmentSummary AS (
    SELECT 
        Department,
        SUM(Total_Employees) AS Dept_Total_Employees,
        SUM(Total_Attrition) AS Dept_Total_Attrition,
        ROUND((SUM(Total_Attrition) * 100.0 / SUM(Total_Employees)), 2) AS Dept_Attrition_Rate_Pct
    FROM EmployeeStats
    GROUP BY Department
)
SELECT 
    e.Department,
    e.JobRole,
    e.OverTime,
    e.Total_Employees,
    e.Total_Attrition,
    ROUND((e.Total_Attrition * 100.0 / e.Total_Employees), 2) AS Role_Attrition_Rate_Pct,
    ROUND(e.Avg_Monthly_Income, 2) AS Avg_Monthly_Income,
    ROUND(e.Avg_Tenure_Years, 1) AS Avg_Tenure_Years,
    ROUND(e.Avg_Job_Satisfaction, 2) AS Avg_Job_Satisfaction,
    d.Dept_Attrition_Rate_Pct,
    -- Window Function to Rank High Attrition Roles within each Department
    DENSE_RANK() OVER (
        PARTITION BY e.Department 
        ORDER BY (e.Total_Attrition * 100.0 / e.Total_Employees) DESC
    ) AS Attrition_Risk_Rank
FROM EmployeeStats e
JOIN DepartmentSummary d ON e.Department = d.Department
ORDER BY e.Department, Attrition_Risk_Rank;
