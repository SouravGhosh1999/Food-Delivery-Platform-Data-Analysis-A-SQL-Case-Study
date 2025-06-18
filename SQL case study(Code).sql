-- Swiggy Case Study-

-- 1. Find customers who have never ordered

SELECT name FROM users 
WHERE user_id NOT IN 
(SELECT user_id FROM orders)

-- 2. Average Price/dish

SELECT f.f_name, ROUND(AVG(m.price),2) AS "Avg Price"
FROM menu m 
JOIN food f
ON m.f_id = f.f_id 
GROUP BY f.f_name 
ORDER BY ROUND(AVG(m.price),2) ASC;

-- 3. Find top restaurant in terms of number of orders for a given month

SELECT TO_CHAR(date,'Month') AS full_month_name
FROM orders 
GROUP BY full_month_name;

SELECT r.r_name,COUNT(*)
FROM orders o
JOIN restaurants r
ON o.r_id = r.r_id
WHERE (EXTRACT(MONTH from date) FROM orders)
GROUP BY o.r_id
ORDER BY COUNT(*) DESC LIMIT 1


-- 4. Restaurants with monthly sales > x for

SELECT * , TO_CHAR(date,'Month') AS month_name  FROM orders
WHERE  TO_CHAR(date,'Month') LIKE 'June'

SELECT r.r_name, SUM(o.amount) AS revenue 
FROM orders o
JOIN restaurants r
ON o.r_id =r.r_id
WHERE TO_CHAR(date,'Month') LIKE 'June'
GROUP BY o.r_id
HAVING SUM(o.amount)>500;

SELECT r.r_id,r.r_name,SUM(o.amount) AS total_sales
FROM restaurants AS r
JOIN orders AS o
ON o.r_id = r.r_id
WHERE DATE_TRUNC('month', o.date) = DATE '2025-06-01'
GROUP BY r.r_id, r.r_name
HAVING SUM(o.amount) > 500
ORDER BY total_sales DESC;


-- 5. Show all orders with order details for a particular customer in a particular customer in a particular date range

SELECT o.order_id,r.r_name,f.f_name FROM orders o 
JOIN restaurants r 
ON r.r_id = o.r_id
JOIN order_details od
ON o.order_id = od.order_id
JOIN food f
ON f.f_id = od.f_id
WHERE user_id = (SELECT user_id FROM users WHERE name LIKE 'Nitish') AND
(date >'2022-05-10' AND date < '2022-06-10');

-- 6. Find restaurants with max repeated customers

SELECT r_id,COUNT(*) AS loyal_customers
FROM(
SELECT r_id,user_id,COUNT(*) AS visits
FROM orders GROUP BY r_id,user_id
HAVING COUNT(*) >1
) t
GROUP BY r_id
ORDER BY  loyal_customers DESC LIMIT 1;
SELECT r_name FROM restaurants 
WHERE r_id = 2

-- 7. Month over month revenue growth of swiggy

SELECT months,((revenue-prev)/prev)*100 FROM (
	WITH sales AS
	(
		SELECT  SUM(amount) AS revenue,TO_CHAR(date,'Month')
		AS months FROM orders
		GROUP BY months
		ORDER BY revenue DESC
	)
SELECT months, revenue,LAG(revenue,1) OVER(ORDER BY revenue) AS prev FROM sales

-- 8. Customer -> favorite food

WITH temp AS (
SELECT o.user_id,od.f_id,COUNT(*) AS frequency FROM orders o
JOIN order_details od 
ON o.order_id = od.order_id
GROUP BY o.user_id,od.f_id
)
SELECT u.name,f.f_name,frequency FROM temp t1 
JOIN users u
ON u.user_id = t1.user_id
JOIN food f
ON f.f_id = t1.f_id
WHERE t1.frequency = (SELECT MAX(frequency) FROM temp t2 WHERE t2.user_id = t1.user_id);
