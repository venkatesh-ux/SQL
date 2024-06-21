select *
from customer_purchases;

select *,customer_last_name
from customer;

# Looking for the total cost to the customer and quantity as total
select  concat(c.customer_first_name," ",c.customer_last_name) as cust_name,cp.product_id,cp.vendor_id,cp.customer_id,cp.quantity,cp.cost_to_customer_per_qty, (cp.customer_id*cp.quantity) total 
from customer_purchases cp 
left join customer c
on cp.customer_id=c.customer_id;

# checking for the top 3 customers
select cust_name,customer_id,round(sum(total),0) as amnt_spent_by_cust
from (select  concat(c.customer_first_name," ",c.customer_last_name) as cust_name,cp.product_id,cp.vendor_id,cp.customer_id,cp.quantity,cp.cost_to_customer_per_qty, (cp.customer_id*cp.quantity) total 
		from customer_purchases cp 
		left join customer c
		on cp.customer_id=c.customer_id) x
group by customer_id
order by amnt_spent_by_cust desc
limit 3;

# Looking at the total customer purchsed products
select count(*)
from
(select b.product_name,b.product_size,b.product_category_id,a.market_date,a.quantity,a.cost_to_customer_per_qty
from customer_purchases a
left join product b
on a.product_id=b.product_id) x;

#sales of each product based on their category
with cte1 as
(
select b.product_name,b.product_size,b.product_category_id,a.market_date,a.quantity,a.cost_to_customer_per_qty,
(a.quantity*a.cost_to_customer_per_qty) total_Cast
from customer_purchases a
left join product b
on a.product_id=b.product_id
)

select product_name,product_category_id,round(sum(total_Cast),0) by_product_total                     #product_name,product_size,product_category_id,market_date
from cte1
group by product_name,product_category_id
order by by_product_total desc;

select *
from vendor;

# vendors by category
select vendor_id,vendor_name,count(*) as vendor_count
from(
	select b.booth_number,v.vendor_id,b.booth_price_level,b.booth_type,vba.market_date,v.vendor_name,v.vendor_type
	from booth b 
	left join vendor_booth_assignments vba
	on vba.booth_number=b.booth_number
	left join vendor v
	on v.vendor_id=vba.vendor_id
) x
group by vendor_id,vendor_name
order by vendor_count desc;


# Total count of each vendor type
select vendor_type,count(*) as no_vendor_type
from(
		select b.booth_number,v.vendor_id,b.booth_price_level,b.booth_type,vba.market_date,v.vendor_name,v.vendor_type
		from booth b 
		left join vendor_booth_assignments vba
		on vba.booth_number=b.booth_number
		left join vendor v
		on v.vendor_id=vba.vendor_id
) x
group by vendor_type
order by no_vendor_type desc;


select vendor_id,vendor_name,booth_price_level,market_date,
lag(market_date) over(order by market_date) prev_date,
datediff(market_date,lag(market_date) over(order by market_date)) total_days
from 
(
	select b.booth_number,v.vendor_id,b.booth_price_level,b.booth_type,vba.market_date,v.vendor_name,v.vendor_type
	from booth b 
	left join vendor_booth_assignments vba
	on vba.booth_number=b.booth_number
	left join vendor v
	on v.vendor_id=vba.vendor_id
) x
order by total_days desc;

# the amount of amount spent by customes on each product
with cte2 as
(select p.product_name,
p.product_size,
cp.market_date,
cp.quantity,
cp.cost_to_customer_per_qty,
(cp.quantity*cp.cost_to_customer_per_qty) total_amount
from customer_purchases cp
join product p
on cp.product_id=p.product_id)

select product_name,round(sum(total_amount),0) as by_tota_prod
from cte2
group by product_name
order by by_tota_prod desc