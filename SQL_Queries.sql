
-- Find all male customers (Gender = 'M') who are not homeowners (HomeOwner = 'N') and have at least 3 children
SELECT *
FROM Customers
WHERE Gender = 'M' AND HomeOwner = 'N' AND  TotalChildren = 3;
-- Get the top 5 highest-income customers, showing their EmailAddress, AnnualIncome, and Occupation, sorted by AnnualIncome descending
SELECT TOP 5 EmailAddress, AnnualIncome, Occupation
FROM Customers
ORDER BY CAST(REPLACE(REPLACE(AnnualIncome, '$', ''), ',', '') AS INT) DESC;
-- Show the average income per occupation (i.e., group by Occupation) for customers with at least 1 child.
SELECT Occupation, AVG(CAST(REPLACE(REPLACE(AnnualIncome, '$', ''), ',', '') AS INT)) AS AvgIncome
FROM Customers
WHERE TotalChildren = 1
GROUP BY Occupation;
-- List all customers who have either a 'Partial College' or 'High School' education level and earn more than $30,000 annually.
SELECT FirstName, LastName, EmailAddress, AnnualIncome 
FROM Customers
WHERE EducationLevel IN ('Partial College' , 'High School')  
AND (CAST(REPLACE(REPLACE(AnnualIncome, '$', ''), ',', '') AS INT)) > 30000
ORDER BY CAST(REPLACE(REPLACE(AnnualIncome, '$', ''), ',', '') AS INT) DESC;
-- Count the number of customers who are homeowners (HomeOwner = 'Y') for each marital status (MaritalStatus).
SELECT MaritalStatus, COUNT(*) AS Homeownercount
FROM Customers
WHERE HomeOwner = 'Y'
GROUP BY MaritalStatus ;


SELECT * FROM Sales_2015;
SELECT * FROM Sales_2016;
SELECT * FROM Sales_2017;

--count total OrderQuantity per year and compare it across 2015, 2016, and 2017

WITH CombinedSales AS(
    SELECT 2015 AS Salesyear, ProductKey, OrderQuantity
    FROM Sales_2015
    UNION ALL
    SELECT 2016, ProductKey, OrderQuantity
    FROM Sales_2016
    UNION ALL
    SELECT 2017, ProductKey, OrderQuantity
    FROM Sales_2017
), 
YearlySales AS(
    SELECT Salesyear, ProductKey, SUM(OrderQuantity) AS TotalQuantity
    FROM CombinedSales
    GROUP BY Salesyear, ProductKey
),
Saleswithgrowth AS(
    SELECT Salesyear, ProductKey,TotalQuantity,
    LAG(TotalQuantity) OVER (PARTITION BY (ProductKey) ORDER BY Salesyear) AS PrevTotalQuantity
    FROM YearlySales
),
Growthrate AS(
    SELECT Salesyear, ProductKey,TotalQuantity, PrevTotalQuantity,
    CASE
        WHEN PrevTotalQuantity IS NULL or PrevTotalQuantity = 0 THEN NULL
        ELSE ROUND((100.0*(TotalQuantity - PrevTotalQuantity)/PrevTotalQuantity),2) 
    END AS YearoveryearGrowthrate
FROM Saleswithgrowth
)
SELECT *
FROM Growthrate
ORDER BY Salesyear, ProductKey;


-- Show productkey that new and product key that were erase over year from 15-17
🔍 1. New ProductKeys → that were not present in the previous year
🔍 2. Discontinued ProductKeys → that were present before but gone in later year
WITH AllProduct AS(
SELECT 2015 AS Salesyear, ProductKey
    FROM Sales_2015
    UNION 
    SELECT 2016, ProductKey
    FROM Sales_2016
    UNION 
    SELECT 2017, ProductKey
    FROM Sales_2017
), 
YearlyPresence AS(
    SELECT ProductKey,
    MAX (CASE WHEN Salesyear = 2015 THEN 1 ELSE 0 END) AS In2015,
    MAX (CASE WHEN Salesyear = 2016 THEN 1 ELSE 0 END) AS In2016,
    MAX (CASE WHEN Salesyear = 2017 THEN 1 ELSE 0 END) AS In2017
    FROM AllProduct
    GROUP BY ProductKey
),
ProductChanges AS(
    SELECT ProductKey,
    CASE WHEN In2015 = 1 AND In2016 = 0 THEN 'Discontinued in 2016'
         WHEN In2016 = 1 AND In2017 = 0 THEN 'Discontinued in 2017'
    END AS 'Discontinued',
    CASE WHEN In2015 = 0 AND In2016 = 1 THEN 'New in 2016'
         WHEN In2016 = 0 AND In2017 = 1 THEN 'New in 2017' 
    END AS 'New Product'
FROM YearlyPresence
)
SELECT *
FROM ProductChanges
WHERE 'New Product' IS NOT NULL OR 'Discontinued' IS NOT NULL
ORDER BY ProductKey;
    

SELECT * FROM Territories;
--Which continents have more than 2 countries in them?
SELECT Continent, COUNT(DISTINCT Country) AS CountryCount
FROM SalesTerritory
GROUP BY Continent
HAVING COUNT(DISTINCT Country) > 2;

SELECT * FROM Products;
-- Get the product name and its subcategory name.
SELECT p.ProductName, s.SubcategoryName
FROM Products p
JOIN Product_Subcategories s
  ON p.ProductSubcategoryKey = s.ProductSubcategoryKey;

-- Find all products in the subcategory "Mountain Bikes". Show product name, subcategory name, and model name.
SELECT 
    p.ProductName, 
    ps.SubcategoryName, 
    p.ModelName
FROM Products AS p
JOIN Product_Subcategories AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
WHERE ps.SubcategoryName = 'Mountain Bikes';

--For each subcategory, count how many products belong to it. Show subcategory name and product count.
SELECT 
    ps.SubcategoryName,
    COUNT(p.ProductKey) AS ProductCount
FROM dbo.Product_Subcategories AS ps
LEFT JOIN dbo.Products AS p
    ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
GROUP BY ps.SubcategoryName;

--Find all products that cost more than $500 and display their name, price, and subcategorySELECT 
SELECT
    p.ProductName,
    p.ProductPrice,
    ps.SubcategoryName
FROM dbo.Products AS p
JOIN dbo.Product_Subcategories AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
WHERE p.ProductPrice > 500;


