-- Retail Sales & KPI Performance Query
-- Key Concepts Covered: Multi-Table JOINs, Revenue & Profit Calculations, Inventory Stock Management CTEs

WITH ProductPerformance AS (
    SELECT 
        s.Sale_ID,
        s.Date,
        st.Store_Name,
        st.Store_City,
        p.Product_Name,
        p.Product_Category,
        s.Units,
        p.Product_Cost,
        p.Product_Price,
        CAST(REPLACE(REPLACE(p.Product_Cost, '$', ''), ',', '') AS DECIMAL(10,2)) * s.Units AS Total_Cost,
        CAST(REPLACE(REPLACE(p.Product_Price, '$', ''), ',', '') AS DECIMAL(10,2)) * s.Units AS Total_Revenue
    FROM sales s
    JOIN products p ON s.Product_ID = p.Product_ID
    JOIN stores st ON s.Store_ID = st.Store_ID
),
CategoryKPIs AS (
    SELECT 
        Product_Category,
        Store_City,
        SUM(Units) AS Total_Units_Sold,
        SUM(Total_Revenue) AS Total_Revenue,
        SUM(Total_Revenue - Total_Cost) AS Gross_Profit,
        ROUND((SUM(Total_Revenue - Total_Cost) / SUM(Total_Revenue)) * 100, 2) AS Gross_Margin_Pct
    FROM ProductPerformance
    GROUP BY Product_Category, Store_City
)
SELECT 
    c.Product_Category,
    c.Store_City,
    c.Total_Units_Sold,
    ROUND(c.Total_Revenue, 2) AS Total_Revenue,
    ROUND(c.Gross_Profit, 2) AS Gross_Profit,
    c.Gross_Margin_Pct,
    -- Window Function: Rank top performing product categories by total profit per city
    RANK() OVER (
        PARTITION BY c.Store_City 
        ORDER BY c.Gross_Profit DESC
    ) AS Category_Profit_Rank
FROM CategoryKPIs c
ORDER BY c.Store_City, Category_Profit_Rank;
