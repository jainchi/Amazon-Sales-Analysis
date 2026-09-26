-- Amazon Analytics Project --




-- category table
create table category
(
category_id	INT PRIMARY KEY,
category_name VARCHAR(20)
);

-- customers TABLE

CREATE TABLE customers
(
customer_id INT PRIMARY KEY,	
first_name	VARCHAR(20),
last_name	VARCHAR(20),
state VARCHAR(20)
);

-- sellers TABLE
CREATE TABLE sellers
(
seller_id INT PRIMARY KEY,
seller_name	VARCHAR(25),
origin VARCHAR(15)
);

-- updating data types
ALTER TABLE sellers
ALTER COLUMN origin TYPE VARCHAR(10)
;

-- products table
CREATE TABLE products
(
product_id INT PRIMARY KEY,	
product_name VARCHAR(50),	
price	FLOAT,
cogs	FLOAT,
category_id INT  REFERENCES category(category_id)
);

-- orders
CREATE TABLE orders
(
order_id INT PRIMARY KEY, 	
order_date	DATE,
customer_id	INT  REFERENCES customers(customer_id),
seller_id INT REFERENCES sellers(seller_id),
order_status VARCHAR(15)
);


CREATE TABLE order_items
(
order_item_id INT PRIMARY KEY,
order_id INT,	-- FK 
product_id INT, -- FK
quantity INT,	
price_per_unit FLOAT,
CONSTRAINT order_items_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
CONSTRAINT order_items_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- payment TABLE
CREATE TABLE payments
(
payment_id	INT PRIMARY KEY,
order_id INT, -- FK 	
payment_date DATE,
payment_status VARCHAR(20),
CONSTRAINT payments_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);



CREATE TABLE shippings
(
shipping_id	INT PRIMARY KEY,
order_id	INT, -- FK
shipping_date DATE,	
return_date	 DATE,
shipping_providers	VARCHAR(15),
delivery_status VARCHAR(15),
CONSTRAINT shippings_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);



CREATE TABLE inventory
(
inventory_id INT PRIMARY KEY,
product_id INT, -- FK
stock INT,
warehouse_id INT,
last_stock_date DATE,
CONSTRAINT inventory_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);



-- End of schemas


/*
1. Basic Select: Retrieve the names of all products in the products table.

2. Simple Join: Write a query to find the full name of customers (first_name + last_name) and the
names of the products they ordered. Use a JOIN between customers, orders, and order_items.
3. Conditional Select: List all products with a price greater than 100. Display the product name and
price.
4. Inner Join: List all orders along with customer names and product names. Use INNER JOIN
between orders, customers, and order_items.
5. Left Join: Retrieve all customers and their corresponding orders. Include customers who haven't
placed any orders.


*/
-- Q.1
SELECT * FROM products


-- Q.2
SELECT first_name,last_name,concat("first_name",' ',"last_name") as full_name,product_name 
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN customers c
ON od.customer_id=c.customer_id
JOIN products p
ON oe.product_id=p.product_id

-- Q.3
SELECT product_name,price FROM products
WHERE price>100

-- Q.4

SELECT first_name,last_name,product_name
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN customers c
ON od.customer_id=c.customer_id
JOIN products p
ON oe.product_id=p.product_id

-- Q.5

SELECT *
FROM customers c
LEFT JOIN orders od
ON c.customer_id= od.customer_id
-- where order_id is null			



/*
6. Right Join: Retrieve all orders and their corresponding customers. Include orders without
customer information.

7. Join with Filtering: List all products sold by sellers originating from 'USA.' Include product names
and seller names.
8. Multi-table Join: Write a query to find the total amount paid for each order. Include the orders,
order_items, and payments tables.
9. Join with Subquery: List the customers who have ordered products in the 'electronics' category.
Use a subquery to find the category ID.
10. Cross Join: Write a query to list all combinations of category and sellers.
*/



-- Q.6

SELECT o.*, concat("first_name",' ',"last_name") as full_name , cu.* 
FROM customers cu 
RIGHT JOIN orders o
ON o.customer_id=cu.customer_id
-- WHERE o.customer_id is null





-- Q.7


SELECT product_name,seller_name,origin
FROM sellers s
JOIN orders oe
ON s.seller_id=oe.seller_id
JOIN order_items os
ON oe.order_id=os.order_id
JOIN products pu
ON os.product_id=pu.product_id
WHERE origin='USA'




-- Q.8

SELECT oe.order_id,sum(quantity*price_per_unit) as totalbill
FROM orders oe
JOIN order_items os
ON oe.order_id=os.order_id
group by 1



-- Q.9

SELECT distinct cr.customer_id
FROM customers cr
JOIN orders oe
ON cr.customer_id=oe.customer_id
JOIN order_items os
ON oe.order_id=os.order_id
JOIN products pu
ON os.product_id=pu.product_id
WHERE category_id in
(
SELECT category_id FROM category
WHERE category_name='electronics'
)






-- Q.10
SELECT 
    cat.category_name,
    sel.seller_name
FROM category cat
CROSS JOIN sellers sel



/*
11. Count Function: Count the total number of unique customers in the customers table.
12. Sum and Group By: Find the total revenue generated by each seller. Display the seller name
and total revenue.
13. Average Function: Calculate the average price of products in the products table.
*/


-- Q.11
SELECT COUNT(distinct customer_id) from customers





-- Q.12
SELECT sr.seller_id,seller_name,sum(quantity* price_per_unit) as total_revenue,sum(quantity* price_per_unit)-SUM(oe.quantity * p.cogs) as revenue_ex_cogs
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN sellers sr
ON od.seller_id=sr.seller_id
JOIN products p
ON oe.product_id=p.product_id
GROUP BY 1,2
ORDER BY 3 DESC


-- Q.13
SELECT AVG(price) FROM products




/*

14. Group By with Having: List all sellers who have sold more than 500 products quantity. Display seller
names and total products sold.


15. Group By Multiple Columns: Find the total revenue generated by each seller for each category.
Display seller names, category names, and total revenue.



16. Count and Distinct: Find the total number of distinct products sold in each category.
17. Join with Aggregation: Write a query to find the total number of orders and the total revenue
generated for each customer.
18. Aggregate Functions and CASE: Find the number of orders for each order status ('Inprogress,'
'Delivered,' etc.). Use CASE to categorize the statuses.
*/



-- Q.14


SELECT sellers.seller_id,seller_name,SUM(quantity)AS totalquantitysold
FROM sellers
JOIN orders
ON sellers.seller_id=orders.seller_id
JOIN order_items oms
ON orders.order_id=oms.order_id
GROUP BY 1,2
HAVING SUM(quantity)>500





-- Q.15
SELECT sellers.seller_id,seller_name,cy.category_id,category_name,SUM(price_per_unit*quantity) AS totalrevenue
FROM sellers
JOIN orders od
ON sellers.seller_id=od.seller_id
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN products pu
ON oe.product_id=pu.product_id
JOIN category cy
ON pu.category_id=cy.category_id
GROUP BY 1,2,3,4
order by 1





-- Q.16
SELECT category_name,COUNT(DISTINCT pu.product_id) as diffproduct
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN products pu
ON oe.product_id=pu.product_id
JOIN category cy
ON pu.category_id=cy.category_id
GROUP BY 1

-- Q.17 
SELECT customer_id, count(distinct od.order_id) as totalorders, SUM(quantity*price_per_unit) AS totalrevenue
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
GROUP BY 1

-- Q.18
SELECT 
	SUM(CASE WHEN order_status='Completed' THEN 1 ELSE 0 END) AS totalcompletedorders,
	SUM(CASE WHEN order_status='Returned' THEN 1 ELSE 0 END) AS totalreturnedorders,
	SUM(CASE WHEN order_status='Inprogress' THEN 1 ELSE 0 END) AS totalInprogressorders
FROM orders od


-- Q.19. Nested Aggregation: Find the category with the highest total revenue.
SELECT category_name from
(
SELECT category_name,cy.category_id, sum(quantity*price_per_unit) as totalrevenue
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN products p
ON oe.product_id=p.product_id
JOIN category cy 
ON p.category_id = cy.category_id
GROUP BY 1,2
ORDER BY 3 DESC
)
LIMIT 1



-- Q.20. Conditional Aggregation: Count the number of successful and failed payments for each customer

SELECT 
		cr.customer_id,
		CONCAT(cr.first_name, ' ', cr.last_name) AS customer_name,
 COUNT(*) FILTER(WHERE TRIM(payment_status)='Payment Failed') as totalfailedpayment,
 COUNT(*) FILTER(WHERE TRIM(payment_status)='Payment Successed') as totalsuccessedpayment,
 COUNT(*) FILTER(WHERE TRIM(payment_status)='Refunded') as totalrefundedpayment,
 COUNT(*) FILTER(WHERE payment_status IS null) as unrecorded
FROM customers cr
JOIN orders oe
ON cr.customer_id=oe.customer_id
LEFT JOIN payments pt
ON oe.order_id=pt.order_id
GROUP BY 1
SELECT * from payments



--21. Simple Subquery: Find the product with the highest price. Use a subquery to get the maximum price.
SELECT * FROM(
SELECT * FROM products
ORDER BY price DESC
)
limit 1

OR

SELECT * FROM products
WHERE price = (
    SELECT MAX(price) 
    FROM products
);



-- Q.22 Correlated Subquery: Find all products whose price is above the average price in their category.
SELECT p1.product_id, p1.product_name, p1.category_id, p1.price
FROM products p1
WHERE p1.price > (
    -- Inner query is 'correlated' because it references 'p1' from the outer query
    SELECT AVG(p2.price) 
    FROM products p2
    WHERE p2.category_id = p1.category_id
);



-- Q.23Subquery in WHERE Clause: Retrieve the names of customers who have ordered at least one
-- product in the 'Pet Supplies' category.
SELECT * FROM customers
WHERE customer_id IN(
SELECT DISTINCT customer_id
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN products p
ON oe.product_id=p.product_id
JOIN category cy 
ON p.category_id = cy.category_id
WHERE TRIM(category_name)='Pet Supplies'
)




-- Q.24 Subquery in SELECT Clause: For each product, display its name and the total number of times it has been ordered.


SELECT TRIM(product_name) AS prod_name,count(distinct order_id) AS totaltimeordered
FROM 
(SELECT od.*,oe.order_item_id,quantity,p.*,cy.*
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN products p
ON oe.product_id=p.product_id
JOIN category cy 
ON p.category_id = cy.category_id
)
GROUP BY 1




-- Q.25. List all customers who have made at least one order.
SELECT DISTINCT customers.customer_id 
FROM orders
JOIN customers
ON orders.customer_id=customers.customer_id






-- Q.26 IN Clause with Subquery: Find the names of sellers who have sold 'Apple' products.


SELECT *
from sellers 
WHERE seller_id IN(

SELECT  DISTINCT seller_id
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN products p
ON oe.product_id=p.product_id
where product_name ILIKE '%apple%'
)






-- 27. NOT IN Clause: List all customers who have not placed any orders.


select * from customers 
where customer_id not in(

SELECT DISTINCT c.customer_id FROM customers c
LEFT JOIN orders o
ON c.customer_id=o.customer_id
WHERE o.customer_id is not null

)






-- 28. Subquery with JOIN: Find the names of products that are out of stock. Use a subquery to get
-- product IDs with stock = 0 in the inventory table.


SELECT distinct product_name from
(
	SELECT * FROM products p 
	JOIN inventory i
	ON p.product_id=i.product_id
							--table with 0 stock
	WHERE stock=0
)


-- or-----


SELECT 
    product_name 
FROM 
    products
WHERE 
    product_id IN (
        -- Subquery handles the inventory data independently
        SELECT 
            product_id 
        FROM 
            inventory 
        WHERE 
            stock=0
    );






	
-- 29. Subquery with HAVING: Retrieve sellers who have an average selling price of their products  -- greater than 300.

SELECT
	s.seller_id,seller_name,
	AVG(price_per_unit) AS avgsellingprice
FROM orders od
JOIN order_items oe
ON od.order_id=oe.order_id
JOIN sellers s
ON od.seller_id=s.seller_id
GROUP BY 1,2
HAVING AVG(price_per_unit)>300









-- 30. Find the product that has generated the highest revenue. Use nested subqueries to calculate revenue.


SELECT * FROM
 (
		SELECT TRIM(product_name)AS product_name,SUM(price*quantity) as totalrev
		FROM orders od
		JOIN order_items oe
		ON od.order_id=oe.order_id
		JOIN products p
		ON oe.product_id=p.product_id
		GROUP BY 1
						)
ORDER BY totalrev DESC
LIMIT 1






-- 31. RANK() Function: For each category, rank the products based on their total sales amount.


SELECT
	category_name,product_name,
	SUM(quantity * price) as totalorder,
	RANK() OVER (PARTITION BY category_name ORDER BY SUM(quantity * price) desc) 
	FROM category c
	JOIN products p
	ON c.category_id=p.category_id
	join order_items oe
	ON p.product_id=oe.product_id
GROUP BY 1,2


--RANK()
--DENSE RANK()
--Row_Number



-- 32. DENSE_RANK() Function: List the top 5 customers based on the total amount spent. Use
-- DENSE_RANK().

select * from(

SELECT 
	c.customer_id,
	CONCAT(first_name,' ',last_name) AS fullname ,DENSE_RANK() OVER (Order by sum(price_per_unit*quantity) desc) as rnk,
	sum(price_per_unit*quantity) totalspent
	
	FROM customers c
	LEFT JOIN orders o
	ON c.customer_id=o.customer_id
	JOIN order_items oa
	ON o.order_id=oa.order_id
GROUP BY 1,2
)
where rnk<=5






-- 33. ROW_NUMBER() Function: Assign a row number to each product in the products table, ordered
-- by price descending.


SELECT product_name,	price,	ROW_NUMBER() OVER(order by price DESC) 	FROM products




-- 34. NTILE() Function: Divide all customers into 4 quartiles based on the total amount they have
-- spent.



with mycte as(
SELECT c.*,sum(quantity* price_per_unit) AS totalsold
FROM CUSTOMERS c
JOIN orders os on c.customer_id=os.customer_id
JOIN order_items oe on os.order_id=oe.order_id
GROUP BY c.customer_id
)
select customer_id ,totalsold , NTILE(4) over(ORDER BY totalsold DESC) from mycte







-- 35. OVER Clause: For each order, calculate the running total of sales for the corresponding
-- customer.

SELECT
 	customer_id,	os.order_id,
	price_per_unit * quantity as totalorder_value,
	SUM(price_per_unit*quantity) OVER(partition by customer_id order by os.order_id) as customers_runningtotal 
	FROM	orders os
	JOIN order_items oe	
	ON os.order_id=oe.order_id
	








-- 36. PARTITION BY Clause: Find the total revenue generated by each seller in each year.

WITH totalrevcte AS
(
SELECT s.seller_id,seller_name, EXTRACT(YEAR FROM order_date)as years ,sum(price_per_unit*quantity) as totalreven
FROM sellers s
LEFT JOIN orders os on s.seller_id=os.seller_id
LEFT JOIN order_items oe on os.order_id=oe.order_id
GROUP BY 1,2,3
)
SELECT *, DENSE_RANK() OVER(PARTITION BY seller_id ORDER BY totalreven DESC) from totalrevcte








-- 37. LEAD() Function: For each product, find the next higher-priced product in the same category.


SELECT *, 
	LEAD(product_id,1) OVER(PARTITION BY category_id ORDER BY price) as nextproductid, 
	LEAD(price) OVER(PARTITION BY category_id ORDER BY price) as nextproductprice
from products








-- 38. LAG() Function: For each product, find the previous lower-priced product in the same category.

SELECT *, 
	LAG(product_id,1) OVER(PARTITION BY category_id ORDER BY price asc) as previousproductid, 
	LAG(price,1) OVER(PARTITION BY category_id ORDER BY price asc) as lowerproductprice
from products








-- 39. Cumulative Sum: Calculate the cumulative sum of sales for each seller.

WITH ctee1 AS(
	SELECT s.seller_id,seller_name,order_date,	sum(price_per_unit* quantity) as saless
	FROM sellers s
	LEFT JOIN orders
	ON s.seller_id=orders.seller_id
	LEFT JOIN order_items oms
	ON orders.order_id=oms.order_id
	group by 1,2,3
	ORDER BY 1
	
)
SELECT *, SUM(saless) OVER(PARTITION BY seller_id ORDER BY order_date) as cumultive_sales from ctee1 








-- 40. Window Function with Aggregation: Find the average order amount for each customer and
-- compare it with their individual orders.




WITH MYCTE1 AS
(
	SELECT customer_id,o.order_id,SUM(quantity*price_per_unit) AS totalvalue
	from orders o
	JOIN order_items om
	ON o.order_id=om.order_id
	GROUP BY 1,2
),
CTE2 AS
(
	SELECT customer_id,AVG(totalvalue) as avgordervalue from MYCTE1
	GROUP BY 1
)
SELECT * FROM MYCTE1 
JOIN CTE2 
ON MYCTE1.customer_id=CTE2.customer_id
ORDER BY MYCTE1.customer_id




---- or-----




SELECT 
	customer_id,o.order_id, SUM(quantity* price_per_unit) as orderedamt , 
	AVG(sum(quantity* price_per_unit) ) OVER(PARTITION BY customer_id) avgordervalue
from orders o
JOIN order_items om
ON o.order_id=om.order_id
GROUP BY 1,2



----------------------------------------------------------------------------------------------------



-- Q.41. Date Filtering: List all orders placed in the current month for the year 2023. Include order ID, order date, and customer name.

SELECT *,CONCAT(first_name,' ',last_name) as fullname FROM orders o
JOIN customers cr
ON o.customer_id=cr.customer_id
where extract(month from order_date) = extract (month from current_date)
and extract(year from order_date)=2023






-- Q.42 . Extract and Group By: Find the number of orders placed in each year. Use the EXTRACT() function to group by year.

SELECT extract(year from order_date) AS yearr,count(*) as totalcont
from orders
GROUP BY 1








-- Q.43. DATEDIFF Function: Calculate the average delivery time for all delivered orders.

SELECT avg(shipping_date-order_date) as averagedelivertime FROM orders od
JOIN shippings s
ON od.order_id=s.order_id
where  delivery_status='Delivered'








-- Q.44. DATE_TRUNC Function: Find the total sales amount for each month in the  year 2022.

SELECT DATE_TRUNC('MONTH',order_date),SUM(price_per_unit*quantity) as totalrev from orders o
JOIN order_items om
ON o.order_id=om.order_id
WHERE extract(year from order_date)=2022
GROUP BY 1







-- Q.45 give me thise customers who used to buy regularly but went cold in last 26 months

SELECT * FROM customers 
where customer_id NOT IN
(
SELECT DISTINCT c.customer_id  from orders o
JOIN customers c
ON o.customer_id=c.customer_id
WHERE AGE(CURRENT_DATE,order_date)< INTERVAL'26 month'
)
and customer_id  IN(
SELECT DISTINCT c.customer_id  from orders o
JOIN customers c
ON o.customer_id=c.customer_id
WHERE AGE(CURRENT_DATE,order_date)>INTERVAL'26 month')







/*
46. Date Conversion: Convert the order_date to a different format (e.g., 'YYYY-MM-DD') and display
it with the order ID.
47. Date Arithmetic: Calculate the total number of days between the order date and shipping date
for each order.
48. Current Date Usage: Find all orders that are overdue for payment. Assume payment is due
within 30 days of the order date.
49. Weekend Orders: Retrieve all orders that were placed on weekends.
50. Next Day Delivery: List all orders that were delivered the next day after shipping.
*/



-- Q.46
SELECT order_id,TO_char(order_date,'YYYY-DD-MM')FROM orders
-- ppreviously it was 'YYYY-MM-DD'






--Q.47
SELECT od.order_id,shipping_date-order_date as daystooktodeliver  FROM orders od
JOIN shippings s
ON od.order_id=s.order_id





-- Q.48
select * from(
SELECT * FROM orders od
LEFT JOIN payments p 
ON od.order_id=p.order_id

)
where payment_date is null
and
CURRENT_DATE -order_date >30






-- Q.49
SELECT * from orders
WHERE EXTRACT(Dow FROM order_date) IN (0, 6)




--Q.50
SELECT * FROM orders oe
JOIN  shippings s
ON oe.order_id=s.order_id
WHERE shipping_date-order_date <=1



-- Q.51
-- Write a SQL query to calculate the Year-over-Year (YoY) revenue growth percentage for each product between the years 2022 and 2023.
-- Show BY Worst

SELECT * FROM
(
WITH cte1 AS(
SELECT p.product_id,product_name, EXTRACT(YEAR FROM order_date) as yeear ,SUM(price_per_unit*quantity ) as totalorderamount
FROM order_items oi
JOIN orders o
ON oi.order_id=o.order_id
JOIN products p
ON p.product_id=oi.product_id
WHERE  EXTRACT(YEAR FROM order_date) =2022
OR
EXTRACT(YEAR FROM order_date) =2023
GROUP BY 1 ,2,3
ORDER BY 1
)
SELECT product_id,product_name,
		SUM(case WHEN yeear=2022 THEN totalorderamount ELSE 0 END) AS sales2022,
		SUM(case WHEN yeear=2023 THEN totalorderamount ELSE 0 END) AS sales2023,
(		(SUM(case WHEN yeear=2023 THEN totalorderamount ELSE 0 END) - SUM(case WHEN yeear=2022 THEN totalorderamount ELSE 0 END) )
								/NULLIF(SUM(case WHEN yeear=2022 THEN totalorderamount ELSE 0 END),0)) *100 as revenueratioo
	FROM cte1
	GROUP BY 1,2
)
WHERE revenueratioo IS NOT NULL
ORDER BY 5 asc





-- ==========================================
-- Q52. Recency, Frequency, Monetary (RFM) Customer Segmentation Matrix
-- Business Goal: Classify users based on transactional frequency and macro spending power.
-- ==========================================
WITH customer_aggregates AS (
    SELECT 
        o.customer_id,
        MAX(o.order_date) AS last_purchase_date,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.price_per_unit) AS total_spend
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.customer_id
),
platform_metrics AS (
    SELECT AVG(total_spend) AS avg_platform_spend FROM customer_aggregates
)
SELECT 
    ca.customer_id,
    ca.total_orders,
    ca.total_spend,
    CASE 
        WHEN ca.last_purchase_date < CURRENT_DATE - INTERVAL '180 days' THEN 'Churn Risk Client'
        WHEN ca.total_orders > 5 AND ca.total_spend > pm.avg_platform_spend THEN 'High Value Gold'
        WHEN ca.total_orders BETWEEN 2 AND 5 THEN 'Active Silver Tier'
        ELSE 'Regular/New Customer'
    END AS customer_operational_segment
FROM customer_aggregates ca
CROSS JOIN platform_metrics pm
ORDER BY ca.total_spend DESC;





-- ==========================================
-- Q53. Churn Prediction Indicators (Sudden Drop in Active Purchase Cycles)
-- Business Goal: Identify customers who used to buy regularly but went cold in the last 60 days.
-- ==========================================
WITH customer_monthly_activity AS (
    SELECT 
        customer_id,
        EXTRACT(YEAR FROM order_date) AS order_year,
        EXTRACT(MONTH FROM order_date) AS order_month,
        COUNT(order_id) AS monthly_order_count
    FROM orders
	WHERE order_status = 'Completed'
    GROUP BY customer_id, EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
	order by 1,4
),
historical_consistency AS (
    SELECT 
        customer_id,
        COUNT(*) AS active_months_count
    FROM customer_monthly_activity
    WHERE monthly_order_count >= 1
    GROUP BY customer_id
),
recent_buy AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_purchase_date
    FROM orders
	WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT 
    hc.customer_id,
    hc.active_months_count AS total_historic_active_months,
    rb.last_purchase_date
FROM historical_consistency hc
JOIN recent_buy rb
ON hc.customer_id = rb.customer_id
WHERE hc.active_months_count >= 3 -- Context: old loyal customers
  AND rb.last_purchase_date < '2024-05-01'::DATE - INTERVAL '60 days' -- Context: Adjusted based on dataset timestamps
ORDER BY hc.active_months_count DESC;





-- ==========================================
-- Q54. Cumulative Running Revenue  per Seller with Milestone Tracking
-- Business Goal: Break down progressive timeline growth and identify when target has hit.
-- ==========================================
WITH seller_daily_revenue AS (
    SELECT 
        o.seller_id,
        o.order_date,
        SUM(oi.quantity * oi.price_per_unit) AS daily_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY o.seller_id, o.order_date
),
cumulative_calculation AS (
    SELECT 
        seller_id,
        order_date,
        daily_sales,
        SUM(daily_sales) OVER(PARTITION BY seller_id ORDER BY order_date ROWS UNBOUNDED PRECEDING) AS cumulative_revenue
    FROM seller_daily_revenue
)
SELECT 
    seller_id,
    order_date,
    daily_sales,
    cumulative_revenue AS cumulative_revenue,
    CASE 
        WHEN cumulative_revenue >= 100000 THEN 'TARGET MILESTONE CRACKED (100k+)'
        ELSE 'Progressive Scaling'
    END AS performance_milestone_status
FROM cumulative_calculation
ORDER BY seller_id, order_date;



-- ==========================================
-- Q55. Top-3 Dominant Product Categories Per State (Geographic Consumption Density)
-- Business Goal: Identify localized user preferences for targeted marketplace distribution.
-- ==========================================

WITH state_category_financials AS (
    SELECT 
        c.state,
        p.category_id,
        SUM(oi.quantity * oi.price_per_unit) AS total_category_revenue
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY c.state, p.category_id
),
ranked_state_demographics AS (
    SELECT 
        state,
        category_id,
        total_category_revenue,
        DENSE_RANK() OVER(PARTITION BY state ORDER BY total_category_revenue DESC) AS category_position_rank
    FROM state_category_financials
)
SELECT 
    rs.state,
    cat.category_name,
    rs.total_category_revenue AS total_revenue_generated,
    rs.category_position_rank
FROM ranked_state_demographics rs
JOIN category cat ON rs.category_id = cat.category_id
WHERE rs.category_position_rank <= 3
ORDER BY rs.state, rs.category_position_rank;





-- ==========================================
-- Q56. Matrix Crosstab Ledger Report (Manual Pivot Structure)(find seller's sales with in each category)
-- Business Goal: Build standard multi-dimensional aggregation grids manually.
-- ==========================================

SELECT 
    s.seller_name,
    SUM(CASE WHEN LOWER(cat.category_name) = 'electronics' THEN (oi.quantity * oi.price_per_unit) ELSE 0 END) AS revenue_electronics,
    SUM(CASE WHEN LOWER(cat.category_name) = 'clothing' THEN (oi.quantity * oi.price_per_unit) ELSE 0 END) AS revenue_clothing,
    SUM(CASE WHEN LOWER(cat.category_name) = 'home & kitchen' THEN (oi.quantity * oi.price_per_unit) ELSE 0 END) AS revenue_home_kitchen,
    SUM(CASE WHEN LOWER(cat.category_name) = 'pet supplies' THEN (oi.quantity * oi.price_per_unit) ELSE 0 END) AS revenue_pet_supplies,
    SUM(CASE WHEN LOWER(cat.category_name) = 'toys & games' THEN (oi.quantity * oi.price_per_unit) ELSE 0 END) AS revenue_toys_games,
    SUM(CASE WHEN LOWER(cat.category_name) = 'sports & outdoors' THEN (oi.quantity * oi.price_per_unit) ELSE 0 END) AS revenue_sports_outdoors,
    SUM(oi.quantity * oi.price_per_unit) AS consolidated_grand_total
	
FROM sellers s
JOIN orders o ON s.seller_id = o.seller_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category cat ON p.category_id = cat.category_id
WHERE o.order_status = 'Completed'
GROUP BY s.seller_name
ORDER BY consolidated_grand_total DESC;






-- ==========================================
-- Q57. Payment Breakdown Audit Matrix (Success vs Financial Exposure)
-- Business Goal: Isolate pipeline leakage where orders went through but liquidity failed.
-- ==========================================
WITH order_gross_values AS (
SELECT 
    o.order_id,
    o.order_date,
    SUM(oi.quantity * oi.price_per_unit) AS gross_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date
)
SELECT 
    gv.order_id,
    gv.order_date,
    gv.gross_order_value,
    COALESCE(p.payment_status, 'No Payment Attempt Record') AS payment_status,
    COALESCE(p.payment_date, gv.order_date + INTERVAL '1 day') AS audit_payment_timeline,
    CASE 
        WHEN LOWER(p.payment_status) LIKE '%success%' THEN gv.gross_order_value ELSE 0 
    END AS successfully_realized_cashflow,

    CASE 
        WHEN LOWER(p.payment_status) NOT LIKE '%success%' OR p.payment_status IS NULL THEN gv.gross_order_value ELSE 0 
    END AS locked_risk_exposure
FROM order_gross_values gv
LEFT JOIN payments p ON gv.order_id = p.order_id
ORDER BY gv.gross_order_value DESC;



-- ==========================================
-- Q58. Predictive Out-Of-Stock Inventory Burn Alert Engine
-- Business Goal: Forecast item depletion rates to prevent retail supply chain blackout lines.
-- ==========================================
WITH product_sales_velocity AS (
    SELECT 
        product_id,
        SUM(quantity) AS absolute_units_sold,
        COUNT(DISTINCT o.order_id) AS unique_orders_count,
        (MAX(order_date) - MIN(order_date)) + 1 AS active_trading_days
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY product_id
),
velocity_index AS (
    SELECT 
        product_id,
        absolute_units_sold,
        -- Anti division-by-zero validation handler
        (absolute_units_sold::NUMERIC / active_trading_days) AS average_units_demanded_daily
    FROM product_sales_velocity
)
SELECT 
    i.product_id,
    p.product_name,
    i.stock AS current_warehouse_stock,
    ROUND(vi.average_units_demanded_daily, 2) AS daily_velocity_speed,
    CASE 
        WHEN vi.average_units_demanded_daily = 0 THEN 999
        ELSE ROUND((i.stock / vi.average_units_demanded_daily), 0)
    END AS estimated_days_until_blackout
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN velocity_index vi ON i.product_id = vi.product_id
WHERE (CASE WHEN vi.average_units_demanded_daily = 0 THEN 999 ELSE (i.stock / vi.average_units_demanded_daily) END) <= 15
ORDER BY estimated_days_until_blackout ASC;






-- ==========================================
-- Q59. Month-Over-Month (MoM) Category Revenue Growth Metrics
-- Business Goal: Track momentum trajectory shifting across distinct product lines.
-- ==========================================
WITH monthly_category_financials AS (
    SELECT 
        p.category_id,
        EXTRACT(YEAR FROM o.order_date) AS sales_year,
        EXTRACT(MONTH FROM o.order_date) AS sales_month,
        SUM(oi.quantity * oi.price_per_unit) AS current_month_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category_id, EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date)
	order by 2,3
),
chronological_shift AS (
    SELECT 
        category_id,
        sales_year,
        sales_month,
        current_month_revenue,
        LAG(current_month_revenue, 1) OVER(PARTITION BY category_id ORDER BY sales_year, sales_month) AS previous_month_revenue
    FROM monthly_category_financials
)
SELECT 
    cs.sales_year,
    cs.sales_month,
    cat.category_name,
    cs.current_month_revenue AS net_revenue, cs.previous_month_revenue AS base_prior_revenue,
        ((cs.current_month_revenue - cs.previous_month_revenue) / NULLIF(cs.previous_month_revenue, 0)) * 100
     AS mom_growth_percentage
FROM chronological_shift cs
JOIN category cat ON cs.category_id = cat.category_id
ORDER BY cat.category_name, cs.sales_year, cs.sales_month;





-- Q.60 Create a stored procedure named productquantity in PL/pgSQL that automates inventory stock updates when an order is processed.
-- p_order_id INT
-- p_order_item_id INT
CREATE OR REPLACE PROCEDURE productquantity(p_seller_id INT,p_product_id INT,p_customer_id INT ,p_quantity INT)
LANGUAGE plpgsql
AS $$

DECLARE
v_current_stock INT;
v_price FLOAT;
v_order_id INT;
v_order_item_id INT;
BEGIN
	SELECT stock INTO v_current_stock
    FROM inventory
    WHERE product_id = p_product_id;

	SELECT price
	INTO v_price
	from products
	WHERE product_id=p_product_id;


	IF p_quantity>v_current_stock THEN
	RAISE EXCEPTION 'Insufficient stock!';
	END IF;

	SELECT COALESCE(MAX(order_id),0) +1
	INTO v_order_id
	FROM orders;

	SELECT COALESCE(MAX(order_item_id),0) +1
	INTO v_order_item_id
	FROM order_items;
	
	UPDATE inventory
	SET stock= stock -p_quantity
	WHERE product_id=p_product_id;

	INSERT INTO orders(order_id,order_date,customer_id,seller_id,order_status)
	VALUES
	(v_order_id,CURRENT_DATE,p_customer_id,p_seller_id,'Inprogress');
	
	INSERT INTO order_items(order_item_id,order_id,product_id,quantity,price_per_unit)
	VALUES
	(v_order_item_id,v_order_id,p_product_id,p_quantity,v_price);



	RAISE NOTICE 'Order processed successfully for Customer %', p_customer_id;

END;
$$

CALL productquantity(1,2,894,4)
SELECT * FROM inventory
WHERE product_id=2

SELECT * FROM order_items
SELECT max(order_id) FROM orders

select * from sellers





