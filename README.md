# Zomato Data Analysis Project

This project involves analyzing data related to user signups, sales, and product purchases from Zomato, a food delivery platform. The SQL queries conducted on the provided database aim to derive insights into user behavior, purchase patterns, and loyalty programs.

## Data Overview

The dataset consists of tables:

- `goldusers_signup`: Records gold membership signups with user IDs and signup dates.
- `users`: User signup data with user IDs and signup dates.
- `sales`: Sales transactions with user IDs, transaction dates, and product IDs.
- `product`: Product information including IDs, names, and prices.

| Table Name        | Column Name      | Data Type  | Primary Key? | Foreign Key? |
|-------------------|------------------|------------|--------------|--------------|
| goldusers_signup  | userid           | integer    | Yes          | No           |
| goldusers_signup  | gold_signup_date | date       | No           | No           |
| users             | userid           | integer    | Yes          | No           |
| users             | signup_date      | date       | No           | No           |
| sales             | userid           | integer    | No           | Yes (users.userid) |
| sales             | created_date     | date       | No           | No           |
| sales             | product_id       | integer    | No           | Yes (product.product_id) |
| product           | product_id       | integer    | Yes          | No           |
| product           | product_name     | text       | No           | No           |
| product           | price            | integer    | No           | No           |


## Key SQL Queries and Findings

### 1. Customer Spending

- **Total Amount Spent:** Calculated the total amount each customer spent on Zomato.

### 2. Customer Visits

- **Number of Days Visited:** Determined the count of days each customer visited Zomato.

### 3. Initial Purchase

- **First Product Purchased:** Identified the first product purchased by each customer.

### 4. Popular Item

- **Most Purchased Item:** Discovered the most purchased item and its frequency among customers.

### 5. Customer Preferences

- **Most Popular Item per Customer:** Identified the most popular item for each customer.

### 6. Gold Membership Analysis

- **First Post-Gold Purchase:** Determined the first item purchased by customers after becoming gold members.
- **Last Pre-Gold Purchase:** Identified the last item purchased by customers before becoming gold members.

### 7. Pre-Gold Member Orders

- **Total Order and Amount Spent:** Calculated the total order count and amount spent by customers before joining the gold program.

### 8. Loyalty Points Calculation

- **Customer Points Accumulation:** Calculated points earned by customers based on purchases. Also, computed total cashback earned by customers.
- **Most Points Accumulated for a Product:** Identified the product for which the most points have been awarded.

### 9. First-Year Gold Program Points

- **Points Earned in First Year:** Calculated the points earned by customers in their first year of joining the gold program.

### 10. Customer Comparison

- **Point Earnings Comparison:** Compared the point earnings between customers 1 and 3 during their first year in the gold program.

### 11. Transaction Ranking

- **Transaction Ranking:** Ranked all transactions for each customer.

### 12. Gold Membership Transaction Ranking

- **Gold Member Transaction Ranking:** Ranked transactions for gold members, marking non-gold members' transactions as 'na'.

## Conclusion

This project delves into various aspects of user behavior and purchase patterns on Zomato, offering valuable insights for marketing strategies, loyalty programs, and understanding customer preferences.
