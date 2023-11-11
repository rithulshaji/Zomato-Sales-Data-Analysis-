CREATE DATABASE zomato;
USE zomato;

CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date)
VALUES (1,STR_TO_DATE('09-22-2017','%m-%d-%Y')),
(3,STR_TO_DATE('04-21-2017','%m-%d-%Y'));

CREATE TABLE users(userid integer,signup_date date); 
INSERT INTO users(userid,signup_date) 
 VALUES (1,str_to_date('09-02-2014','%m-%d-%Y')),
(2,str_to_date('01-15-2015','%m-%d-%Y')),
(3,str_to_date('04-11-2014','%m-%d-%Y'));

CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,str_to_date('04-19-2017','%m-%d-%Y'),2),
(3,str_to_date('12-18-2019','%m-%d-%Y'),1),
(2,str_to_date('07-20-2020','%m-%d-%Y'),3),
(1,str_to_date('10-23-2019','%m-%d-%Y'),2),
(1,str_to_date('03-19-2018','%m-%d-%Y'),3),
(3,str_to_date('12-20-2016','%m-%d-%Y'),2),
(1,str_to_date('11-09-2016','%m-%d-%Y'),1),
(1,str_to_date('05-20-2016','%m-%d-%Y'),3),
(2,str_to_date('09-24-2017','%m-%d-%Y'),1),
(1,str_to_date('03-11-2017','%m-%d-%Y'),2),
(1,str_to_date('03-11-2016','%m-%d-%Y'),1),
(3,str_to_date('11-10-2016','%m-%d-%Y'),1),
(3,str_to_date('12-07-2017','%m-%d-%Y'),2),
(3,str_to_date('12-15-2016','%m-%d-%Y'),2),
(2,str_to_date('11-08-2017','%m-%d-%Y'),2),
(2,str_to_date('09-10-2018','%m-%d-%Y'),3);


CREATE TABLE product(product_id integer,product_name text,price integer); 
INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

-- 1) What is the total amount each customer spent on zomato?
SELECT sales.userid,
SUM(product.price) AS amount_spent 
FROM sales
INNER JOIN product ON sales.product_id = product.product_id
GROUP BY sales.userid;

-- 2) How many days has each customer visited zomato?
SELECT userid, COUNT(DISTINCT created_date) AS no_of_visits
FROM sales
GROUP BY userid
ORDER BY no_of_visits DESC;

-- 3) What was the first product purchased by each customert?
SELECT * FROM
(SELECT *, RANK() OVER(PARTITION BY userid ORDER BY created_date) AS rnk FROM sales) AS a WHERE rnk=1;

-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT * FROM sales WHERE product_id =
(SELECT product.product_name, COUNT(sales.product_id )
FROM product
INNER JOIN sales ON  product.product_id=sales.product_id 
GROUP BY product.product_name
ORDER BY COUNT(sales.product_id) DESC LIMIT 1);

SELECT userid, COUNT(product_id) FROM sales WHERE product_id =
(
SELECT product_id FROM sales
GROUP BY product_id
ORDER BY count(product_id) DESC
 LIMIT 1)
 GROUP BY userid;

-- 5) Which item was the most popular for each customer?
SELECT * FROM
(SELECT *, RANK() OVER (PARTITION BY userid ORDER BY cnt DESC) AS rnk FROM 
(SELECT userid,product_id,COUNT(userid) AS cnt
FROM sales
GROUP BY userid,product_id
) AS dt) AS dt2 WHERE rnk =1;


-- 6) Which item was purchased first by the customer after they becoming a gold member?
SELECT * FROM
(SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date) AS rnk FROM
(SELECT * FROM 
(SELECT sales.userid,sales.created_date, sales.product_id,goldusers_signup.gold_signup_date 
FROM sales
INNER JOIN goldusers_signup ON sales.userid=goldusers_signup.userid) AS dt1
WHERE created_date>=gold_signup_date) AS dt2) AS dt3 WHERE rnk=1;

-- 7) Which item was purchased just before the customer became a gold member?
SELECT * FROM
(SELECT *, RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) AS rnk FROM
(SELECT * FROM 
(SELECT sales.userid,sales.created_date, sales.product_id,goldusers_signup.gold_signup_date 
FROM sales
INNER JOIN goldusers_signup ON sales.userid=goldusers_signup.userid) AS dt1
WHERE created_date<=gold_signup_date) AS dt2) AS dt3 WHERE rnk=1;


-- 8) What is the total order and amount spent for each member before they became a gold member?
SELECT userid,SUM(price) AS amt_spent FROM
(SELECT dt1.userid,product_id,created_date,price,gold_signup_date FROM 
(SELECT sales.userid, sales.product_id, sales.created_date, product.price
 FROM sales
INNER JOIN product ON sales.product_id=product.product_id) AS dt1
LEFT JOIN goldusers_signup ON dt1.userid=goldusers_signup.userid) AS dt2
WHERE created_date<=gold_signup_date
GROUP BY userid
ORDER BY amt_spent DESC; -- RITHUL

-- INSTRUCTOR
SELECT userid,COUNT(created_date) AS no_of_orders,SUM(price) AS amt_spent FROM
(SELECT a.*,product.price FROM
(SELECT sales.userid,sales.created_date, sales.product_id,goldusers_signup.gold_signup_date 
FROM sales
INNER JOIN goldusers_signup ON sales.userid=goldusers_signup.userid AND created_date<=gold_signup_date) AS a
INNER JOIN product ON a.product_id=product.product_id) AS b
GROUP BY userid
ORDER BY amt_spent DESC;

/* 9) If buying each product generates points for eg 5 rs=2 zomato points and each products has different purchase points 
for eg p1 5rs=1 zomato points, p2 10rs=5 zomato point, p3 5rs=1 zomato point
 calculate points collected by each customers and for which product most points have been given till now? */

SELECT userid, SUM(total_points) AS zomato_points FROM
(SELECT e.*,ROUND(amount/points,0) AS total_points FROM
(SELECT d.*, (CASE WHEN product_id=1 THEN 5 WHEN product_id=2 THEN 2 WHEN product_id=3 THEN 5 ELSE 0 END) AS points
FROM 
(SELECT c.userid, c.product_id, SUM(price) AS amount FROM 
(SELECT a.*,b.price FROM sales a 
INNER JOIN product b ON a.product_id=b.product_id) AS c
GROUP BY userid,product_id) AS d) AS e) AS f
GROUP BY userid;

SELECT userid, SUM(total_points) * 2.5 AS total_cashback FROM
(SELECT e.*,ROUND(amount/points,0) AS total_points FROM
(SELECT d.*, (CASE WHEN product_id=1 THEN 5 WHEN product_id=2 THEN 2 WHEN product_id=3 THEN 5 ELSE 0 END) AS points
FROM 
(SELECT c.userid, c.product_id, SUM(price) AS amount FROM 
(SELECT a.*,b.price FROM sales a 
INNER JOIN product b ON a.product_id=b.product_id) AS c
GROUP BY userid,product_id) AS d) AS e) AS f
GROUP BY userid;

-- for which product most points ahve been given till now? 
SELECT * FROM
(SELECT *, RANK() OVER (ORDER BY zomato_points DESC) AS rnk FROM
(SELECT product_id, SUM(total_points) AS zomato_points FROM
(SELECT e.*,ROUND(amount/points,0) AS total_points FROM
(SELECT d.*, (CASE WHEN product_id=1 THEN 5 WHEN product_id=2 THEN 2 WHEN product_id=3 THEN 5 ELSE 0 END) AS points
FROM 
(SELECT c.userid, c.product_id, SUM(price) AS amount FROM 
(SELECT a.*,b.price FROM sales a 
INNER JOIN product b ON a.product_id=b.product_id) AS c
GROUP BY userid,product_id) AS d) AS e) AS f
GROUP BY product_id) AS g) AS h
WHERE rnk=1;

/* 10) In the first one year after a customer joins the gold program 
(including joining date) irrespective of what the customer has purchased 
they earn 5 zomato points for every 10rs spent, who earned more 
customer 1 or 3? and what was their points earnings in their first year? */

SELECT userid,ROUND(amt_spent_on_1st_year/2,0) AS pointon1st_year FROM
(SELECT userid, SUM(price) AS amt_spent_on_1st_year FROM
(SELECT e.*, product.price FROM 
(SELECT * FROM
(SELECT * FROM
(SELECT a.*, b.gold_signup_date FROM sales AS a 
INNER JOIN goldusers_signup AS b ON a.userid=b.userid) AS c
WHERE created_date>=gold_signup_date) AS d
WHERE created_date<= DATE_ADD(gold_signup_date,INTERVAL 1 YEAR)) AS e
INNER JOIN product ON e.product_id=product.product_id) AS f
GROUP BY userid) AS g;

-- ------- Instructor
SELECT c.*,ROUND(product.price/2,0) AS points FROM
(SELECT a.*, b.gold_signup_date FROM sales AS a 
INNER JOIN goldusers_signup AS b ON a.userid=b.userid AND created_date>=gold_signup_date
AND created_date<= DATE_ADD(gold_signup_date,INTERVAL 1 YEAR)) AS c
INNER JOIN product ON c.product_id=product.product_id;

-- 11) Rank all the transaction of the customers
SELECT *, RANK() OVER(PARTITION BY userid ORDER BY created_date ) 
AS rnk FROM sales;

/* 12) Rank all the transactions for each member whenever they are a 
zomato gold member, for every non gold member mark transactions as na.*/

SELECT d.*, CASE WHEN rnk= '0' THEN 'na' ELSE rnk END AS rnkk FROM
(SELECT C.*, CASE WHEN gold_signup_date IS NULL THEN 0
 ELSE RANK() OVER(PARTITION BY userid ORDER BY created_date DESC) END AS rnk  FROM
(SELECT a.*,b.gold_signup_date FROM sales AS a LEFT JOIN 
goldusers_signup AS b ON a.userid=b.userid 
AND created_date>=gold_signup_date) AS c) AS d;


SELECT d.*, (CASE WHEN rnk= '0' THEN 'na' ELSE rnk END )AS rnkk FROM
(SELECT C.*,CAST(CASE WHEN gold_signup_date IS NULL THEN 0
 ELSE RANK() OVER(PARTITION BY userid ORDER BY created_date DESC) END) AS VARCHAR) AS rnk  FROM
(SELECT a.*,b.gold_signup_date FROM sales AS a LEFT JOIN 
goldusers_signup AS b ON a.userid=b.userid 
AND created_date>=gold_signup_date) AS c) AS d;






