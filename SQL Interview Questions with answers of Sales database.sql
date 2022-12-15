/*
This file contains the solutions of all the tasks. After completing the assigned tasks or Questions refer this file for correction

Thank You
*/
select * from customers;
# Sample:- How many customers are male and female?

select gender , count(*) from customers
group by gender;

/* BASIC SQL QUESTIONS */

# Q1. How many customers do not have DOB information available?

select count(*) from customers where dob is null;


# Q2-- How many customers are there in each pincode and gender combination?
select pincode, gender, count(cust_id) from customers
group by pincode, gender
order by pincode desc;


# Q3--  Print product name and mrp for products which have more than 50000 MRP? 

select product_name, mrp 
from products 
where mrp>50000;

# Q4. How many delivery personal are there in each pincode?

select pincode, count(person_id) from delivery_person
group by pincode;

/* Q5. For each Pin code, print the count of orders, sum of total amount paid, average amount paid, maximum amount paid,
 minimum amount paid for the transactions which were paid by 'cash'. 
Take only 'buy' order types
*/

select delivery_pincode as pd , count(order_id), sum(total_amount_paid), avg(total_amount_paid), max(total_amount_paid)
,min(total_amount_paid)
from orders
where payment_type="cash" and order_type="buy"
group by pd;

/*
Q6. For each delivery_person_id, print the count of orders and 
total amount paid for product_id = 12350 or 12348 and total units > 8. 
Sort the output by total amount paid in descending order. Take only 'buy' order types
*/

select delivery_person_id as pd, count(order_id), sum(total_amount_paid) as tap from orders
where product_id IN (12348,12350)
and tot_units>8 and order_type="buy"
group by pd
order by tap desc;

# Q7. Print the Full names (first name plus last name) for customers that have email on "gmail.com"?
select concat(first_name," ",last_name) as Name from customers
where email like "%gmail%";

# Q8. How many orders had #units between 1-3, 4-6 and 7+? Take only 'buy' order types
select 
case 
when tot_units<3 then "1-3"
when tot_units>=4 and tot_units<=6 then "4-6"
else "7+"
end as cat,
count(order_id) from orders
where order_type="buy"
group by cat
order by cat;

# Q9. Which pincode has average amount paid more than 150,000? Take only 'buy' order types

select delivery_pincode as pd, avg(total_amount_paid) as avge
from orders
where order_type="buy"
 group by pd
 having avge>150000;

/* Q10. Create following columns from order_dim data -

order_date
Order day
Order month
Order year */
 
 select order_date, 
 substr(order_date,1,2) as order_day,
 substr(order_date,4,2) as order_month,
 substr(order_date,7) as order_year
 from orders
 where order_type="buy";

/* Q11. How many total orders were there in each month and how many of them were returned? Add a column for return rate too.
return rate = (100.0 * total return orders) / total buy orders
Hint: You will need to combine SUM() with CASE WHEN
*/
 with cte as
 (
 select substr(order_date, 4,2) as mon,
 sum(case when order_type="return" then 1 else 0 end) as Total_Returns,
 sum(case when order_type="buy" then 1 else 0 end) as Total_buys
 from orders
 group by mon)
 select *, round((total_returns/total_buys)*100,1) as Return_Rate from cte
 order by return_rate desc;
 
 
 # QUESTION ON SQL JOINS
 
 # Q12. How many units have been sold by each brand? Also get total returned units for each brand.
 
 select p.brand, sum(case when order_type="buy" then o.tot_units end)  from products p inner join orders o ON
 p.product_id=o.product_id
 group by p.brand;
 

 # Q13. How many distinct customers and delivery boys are there in each state?

 select p.state, count(distinct c.cust_id) as Customers, count(distinct dp.person_id) as Delivery_Man 
 from pincode p inner join customers c
 ON p.pin_id=c.pincode
 inner join delivery_person dp 
 ON p.pin_id=dp.pincode
 group by p.state;


/* Q14. For every customer, print how many total units were ordered, how many units were 
ordered from their primary_pincode and how many were ordered not from the primary_pincode. 
Also calulate the percentage of total units which were ordered from 
primary_pincode(remember to multiply the numerator by 100.0). Sort by the percentage column in descending order.
*/ 

 select c.cust_id, sum(o.tot_units)as Total_orders,
 sum(case when c.pincode=o.delivery_pincode then o.tot_units else 0 end) as Same_city,
 sum(case when c.pincode!=o.delivery_pincode then o.tot_units else 0 end) as Diff_city
 from customers c 
 inner join orders o 
 ON c.cust_id=o.cust_id
 where o.order_type="buy"
 group by c.cust_id;
 
 
 /* Task 15 
 For each product name, print the sum of number of units, total amount paid, 
 total displayed selling price, total mrp of these units, and finally the net discount from selling price 
 (i.e. 100.0 - 100.0 * total amount paid / total displayed selling price) 
 AND the net discount from mrp (i.e. 100.0 - 100.0 * total amount paid / total mrp)
*/
 
 with cte as
 (
 select p.product_name, sum(o.tot_units) as units, sum(o.total_amount_paid) as Total_Amount_Paid,
 sum(o.tot_units*o.displayed_selling_price_per_unit) as Total_Display_Price, sum(o.tot_units*p.mrp) as Total_MRP 
 from products p left join orders o
 ON p.product_id = o.product_id
 group by p.product_name
 )
 select *, 100-((total_amount_paid/total_display_price)*100) as Net_SP_discount,
 100-((total_amount_paid/total_mrp)*100) as Net_MRP_discount from cte;

 /* Task 16
 For every order_id (exclude returns), get the product name and calculate the discount 
 percentage from selling price. Sort by highest discount and print only
 those rows where discount percentage was above 10.10%.
 */

 select o.order_id,p.product_name,
 round((((o.tot_units*o.displayed_selling_price_per_unit)-o.total_amount_paid)/(o.tot_units*o.displayed_selling_price_per_unit))*100,2) as discount
 from orders o left join products p ON o.product_id=p.product_id
 where order_type="buy"
 group by o.order_id, p.product_name
 having discount>=10.10;

/* Task 17
Using the per unit procurement cost in product_dim, find which product category has made the most profit in both absolute amount and percentage
Absolute Profit = Total Amt Sold - Total Procurement Cost
Percentage Profit = 100.0 * Total Amt Sold / Total Procurement Cost - 100.0 
*/

with cte as
(
select p.category as cat, sum(o.tot_units) as Units_Sold, sum(o.tot_units*procurement_cost_per_unit) as Total_Cost, sum(total_amount_paid) as Revenue
 from products p left join orders o 
ON p.product_id=o.product_id
group by p.category
) 
select cat, Revenue-total_cost as Absolute_Profit, 100-((total_cost/revenue)*100) as Percentage_Profit from cte;

/* Task 18
For every delivery person(use their name), print the total number of order ids (exclude returns) 
by month in seperate columns i.e. there should be one row for each delivery_person_id and 12 columns for every month in the year
*/

select dp.name as Delivery_Man, 
sum(case when substr(o.delivery_date,4,2)=01 then 1 else 0 end) as Jan,
sum(case when substr(o.delivery_date,4,2)=02 then 1 else 0 end) as Feb,
sum(case when substr(o.delivery_date,4,2)=03 then 1 else 0 end) as Mar,
sum(case when substr(o.delivery_date,4,2)=04 then 1 else 0 end) as Apr,
sum(case when substr(o.delivery_date,4,2)=05 then 1 else 0 end) as May,
sum(case when substr(o.delivery_date,4,2)=06 then 1 else 0 end) as Jun,
sum(case when substr(o.delivery_date,4,2)=07 then 1 else 0 end) as Jul,
sum(case when substr(o.delivery_date,4,2)=08 then 1 else 0 end) as Aug,
sum(case when substr(o.delivery_date,4,2)=09 then 1 else 0 end) as Sept,
sum(case when substr(o.delivery_date,4,2)=10 then 1 else 0 end) as Oct,
sum(case when substr(o.delivery_date,4,2)=11 then 1 else 0 end) as Nov,
sum(case when substr(o.delivery_date,4,2)=12 then 1 else 0 end) as Decem
from delivery_person dp inner join orders o
ON dp.person_id=o.delivery_person_id
where o.order_type="buy"
group by dp.name
order by dp.name;

/* Task 19
For each gender - male and female - find the absolute and percentage profit (like in Q16) by product name
*/


with cte as
(
select c.gender,p.category as cat, sum(tot_units) as Total_units, sum(total_amount_paid) as Amount_Paid,
sum(p.procurement_cost_per_unit*o.tot_units) as Total_Cost
from customers c left join orders o
ON c.cust_id = o.cust_id
inner join products p
ON o.product_id=p.product_id
where o.order_type="buy"
group by c.gender,p.category
order by c.gender
)
select gender,cat, Amount_paid-total_cost as Abs_Profit,
100-((total_cost/amount_paid)*100) as Profit from cte;
 
 
 /* Task 20 
 Generally the more numbers of units you buy, the more discount seller will give you.
 For 'Dell AX420' is there a relationship between number of units ordered and average discount 
 from selling price? Take only 'buy' order types
 */
 
select o.tot_units, (avg(o.displayed_selling_price_per_unit*o.tot_units)-avg(o.total_amount_paid)) as Average_discount 
from orders o inner join products p
ON o.product_id=p.product_id
where p.product_name="Dell AX420" and o.order_type="buy"
group by o.tot_units
order by o.tot_units;
 