CREATE DATABASE coffee_shop_sales_db;
USE coffee_shop_sales_db;

SELECT * FROM coffee_shop_sales;

# 1.Total sales analysis:
#Calculate total sales for each respective months
SELECT CONCAT((ROUND(SUM(unit_price * transaction_qty)))/1000, "K") AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 3 -- March Month

#Calculate the difference in sales between selected month and previous month
SELECT 
    MONTH(transaction_date) AS month, -- number of month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales, -- total sales column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- month sales difference
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- dividon by PM sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- percentage 
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
  
# 2.Total Orders Analysis:
# calculate total number of orders for each respective month.alter
SELECT COUNT(transaction_id) AS total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- may month

# calculate the difference in the number of orders between selected month and previous month
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(COUNT(transaction_id)) AS total_orders,
    (COUNT(transaction_id) - LAG(COUNT(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(COUNT(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
# 3.Total Quantity SOld:
# calculate the total quantity sold for each respective month
SELECT SUM(transaction_qty) AS Total_Quantity_Sold
FROM coffee_shop_sales  
WHERE MONTH(transaction_date) = 6 -- jun month

#calculate the difference in the number of quantity between selected month and previous month
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
# 1.Calander Heat Map
# Impliment tooltips to display detailed matrics (sales, order, quantity) when hovering over a specific day
SELECT
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS Total_Sales,
     CONCAT(ROUND(SUM(transaction_qty)/1000,1), 'K') AS Total_Qty_Sold,
     CONCAT(ROUND(COUNT(transaction_id)/1000,1), 'K') AS Total_Orders
FROM coffee_shop_sales 
WHERE transaction_date = '2023-05-18' -- May Month    
     
# 2. Sales Analysis by weekdays and Weekends
# Sagment sales data into weekdays and weekends to anayze performance variation
SELECT
     CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'weekends'
     ELSE 'weekdays'
     END day_type,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,1), 'K') AS total_sales
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 2 -- feb month
GROUP BY
     CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'weekends'
     ELSE 'weekdays'
     END; 

# 3.Sales Analysis by Store Location
SELECT
     store_location,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS Total_Sales
     
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 6 -- jun month
GROUP BY store_location
ORDER BY SUM(unit_price * transaction_qty) DESC;

# 4. Daily Sales Analysis With Average Line
SELECT
    CONCAT(ROUND(AVG(total_sales)/1000,1), 'K') AS avg_sales
FROM(
    SELECT SUM(transaction_qty * unit_price) AS total_sales
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 4 -- april month
    GROUP BY transaction_date
    ) AS Inner_query

SELECT
	 DAY(transaction_date) AS day_of_month,
	 SUM(transaction_qty * unit_price) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY DAY(transaction_date)
ORDER BY DAY(transaction_date)        

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    
# 5.Sales Analysis by Product Category
SELECT
     product_category,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- may month
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;       
    
# 6.Top 10 Product By Sales
SELECT
     product_type,
     CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000,2), 'K') AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 AND product_category = 'Coffee'
GROUP BY product_type
ORDER BY SUM(unit_price * transaction_qty) DESC
LIMIT 10;

# 7.Sales Analysis by Days and Hours
SELECT
     SUM(unit_price * transaction_qty) AS total_sales,
     SUM(transaction_qty) AS total_qty_sold,
     COUNT(*) AS total_orders
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- may month
AND dayofweek(transaction_date) = 1 -- sunday
AND hour(transaction_time) = 14 -- hour no 14     

SELECT
     HOUR(transaction_time),
     SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)    
ORDER BY  HOUR(transaction_time);

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

