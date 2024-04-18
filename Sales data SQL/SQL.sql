use sales_new;

-- 1. How many customers do not have DOB information available?

select COUNT(cust_id) as Total_missing_DOB_Information  from customers$ where dob is null;

-- 2. How many customers are there in each pincode and gender combination?

select  primary_pincode, gender,COUNT(cust_id) as No_of_Customer from customers$ 
group by gender, primary_pincode 
order by primary_pincode;

--3. Print product name and mrp for products which have more than 50000 MRP?

select product_name, mrp from products$
where mrp>50000;

--4. How many delivery personal are there in each pincode?

select pincode,COUNT(delivery_person_id) as no_of_delivery_personal_available from delivery_person$ 
group by pincode
order by pincode;


--5. For each Pin code, print the count of orders, sum of total amount paid, average amount paid, maximum amount paid, minimum amount paid for the transactions which were paid by 'cash'. Take only 'buy' order types.


select delivery_pincode,COUNT(order_id) as Total_order,SUM(total_amount_paid) as Total_Amount, 
sum(total_amount_paid)/COUNT(order_id) as Avg_Amount, MAX(total_amount_paid) as maximum_amount_paid, min(total_amount_paid) as minimum_amount_paid from orders$
where order_type = 'buy' and payment_type = 'cash'
group by delivery_pincode


---6. For each delivery_person_id, print the count of orders and total amount paid for product_id = 12350 or 12348 and total units > 8. Sort the output by total amount paid in descending order. Take only 'buy' order types

select delivery_person_id ,COUNT(order_id) as Count_of_Orders, SUM(total_amount_paid) as Total_Amount_Paid  from orders$ 
where product_id = '12350' or product_id = '12348' and tot_units > 8 and order_type = 'buy' 
group by delivery_person_id 
order by Total_Amount_Paid desc;

---7. Print the Full names (first name plus last name) for customers that have email on "gmail.com"?

select (first_name +' '+ last_name) as Full_Name, email from customers$
where email like '%@gmail.com';

---8. Which pincode has average amount paid more than 150,000? Take only 'buy' order types

select delivery_pincode, sum(total_amount_paid)/COUNT(order_id) as Avg_Amount from orders$
where order_type = 'buy' 
group by delivery_pincode
having sum(total_amount_paid)/COUNT(order_id) > 150000

-- 11. How many units have been sold by each brand? Also get total returned units for each brand.
select p.brand, order_type , count(p.brand) as total_sold_and_return
from products$ P
inner join
orders$ O
on p.F1 = o.product_id
group by p.brand, o.order_type
order by p.brand

--12. How many distinct customers and delivery boys are there in each state?
 select   p.state, count( distinct d.delivery_person_id) as no_of_delivery_boy,count(distinct c.cust_id) as no_of_customer
 from customers$ c
 join pincode$ p on c.primary_pincode= p.pincode 
 join delivery_person$ d on p.pincode = d.pincode
 group by p.state



--14. For each product name, print the sum of number of units, total amount paid, total displayed selling price, total mrp of these units, and finally the net discount from selling price.
--(i.e. 100.0 - 100.0 * total amount paid / total displayed selling price) & the net discount from mrp (i.e. 100.0 - 100.0 * total amount paid / total mrp)

select p.product_name, sum(o.tot_units) as Total_Unit, sum(o.total_amount_paid) as Total_Amount_paid,sum(o.displayed_selling_price_per_unit * o.tot_units) as total_displayed_price,sum(p.mrp*o.tot_units) as total_mrp,round((((sum(o.displayed_selling_price_per_unit * o.tot_units) - sum(o.total_amount_paid))*100)/sum(o.displayed_selling_price_per_unit * o.tot_units)),1) as net_discount_from_selling_price,round((((sum(p.mrp*o.tot_units) - sum(o.total_amount_paid))*100)/sum(p.mrp*o.tot_units)),1) as net_discount_from_MRP
from products$ P
join 
orders$ O 
on p.F1 = o.product_id
where o.order_type = 'buy'
group by p.product_name
order by p.product_name


-- 15. For every order_id (exclude returns), get the product name and calculate the discount percentage from selling price. Sort by highest discount and print only those rows where discount percentage was above 10.10%.


select p.product_name, q.order_id,q.net_discount_percentage_from_selling_price
from products$ p
join 
(select O.order_id,o.product_id,round((((sum(o.displayed_selling_price_per_unit * o.tot_units) - sum(o.total_amount_paid))*100)/sum(o.displayed_selling_price_per_unit * o.tot_units)),2) as net_discount_percentage_from_selling_price
from products$ P
join 
orders$ O 
on p.F1 = o.product_id
where o.order_type = 'buy'
group by o.order_id,o.product_id) q
on p.F1 = q.product_id
where q.net_discount_percentage_from_selling_price >10.10
order by q.net_discount_percentage_from_selling_price desc;


-- 16. Using the per unit procurement cost in product_dim, find which product category has made the most profit in both absolute amount and percentage Absolute Profit = Total Amt Sold - Total Procurement Cost Percentage Profit = 100.0 * Total Amt Sold / Total Procurement Cost - 100.0

select p.product_name, q.product_id,q.total_profit,q.profit_percentage
from products$ p
join 
(select o.product_id,sum(p.procurement_cost_per_unit*o.tot_units) as total_procurement_cost,sum(o.total_amount_paid) as total_amount_sold,(sum(o.total_amount_paid) - sum(p.procurement_cost_per_unit*o.tot_units)) as total_profit, round (((sum(o.total_amount_paid) - sum(p.procurement_cost_per_unit*o.tot_units))*100) / sum(p.procurement_cost_per_unit*o.tot_units),2) as profit_percentage
from products$ p
join 
orders$ o on p.F1 = o.product_id
where o.order_type ='buy'
group by o.product_id) q
on p.F1 = q.product_id
order by q.total_profit desc



--- 18. For each gender - male and female - find the absolute and percentage profit (like in Q15) by product name


select c.gender, p.product_name,(sum(o.total_amount_paid) - sum(p.procurement_cost_per_unit*o.tot_units)) as total_profit, round (((sum(o.total_amount_paid) - sum(p.procurement_cost_per_unit*o.tot_units))*100) / sum(p.procurement_cost_per_unit*o.tot_units),2) as profit_percentage
from customers$ c
join 
orders$ o
on c.cust_id = o.cust_id
join products$ p
on p.F1 = o.product_id
group by c.gender, p.product_name



---19. Generally the more numbers of units you buy, the more discount seller will give you. For'Dell AX420' is there a relationship between number of units ordered and average discount from selling price? Take only 'buy' order types

select  o.tot_units,(sum(o.displayed_selling_price_per_unit * o.tot_units) - sum(o.total_amount_paid)) as net_discount,round((((sum(o.displayed_selling_price_per_unit * o.tot_units) - sum(o.total_amount_paid))*100)/sum(o.displayed_selling_price_per_unit * o.tot_units)),2) as net_discount_percentage_from_selling_price 
from orders$ o
join 
products$ p
on o.product_id = p.F1
where p.product_name = 'Dell AX420' and o.order_type = 'buy'
group by o.tot_units






