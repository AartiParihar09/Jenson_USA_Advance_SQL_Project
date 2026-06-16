                        --Jenson USA Project
 
 
 -- 1  the total number of product sold by each store along with store name
 
SELECT 
    store_name, SUM(quantity) 'total quantity'
FROM
    orders
        JOIN
    order_items USING (order_id)
        JOIN
    stores USING (store_id)
GROUP BY store_name;
    
     -- 2  cumulative sum of quantities sold for each product over time
     
     select 
     product_name, order_date, quantity,
     sum(quantity) 
     over(partition by product_name order by order_date) 'cumulative quantity sold'
     from 	
     orders
     join 
     order_items using (order_id) 
     join 
     products using (product_id);
     
     -- 3  the product with the highest product sales (quantity * price) for each category
     
     select* from(
     SELECT 
    category_name,
    product_name,
    FLOOR((quantity * oi.list_price) - (quantity * oi.list_price * discount / 100)) AS 'Total_Sales' ,
    ROW_NUMBER() OVER (
            PARTITION BY c.category_name
            ORDER BY (oi.quantity * oi.list_price)
                     - (oi.quantity * oi.list_price * oi.discount/100) DESC ) as rn
FROM
    order_items oi
        JOIN
    products p USING (product_id)
        JOIN
    categories c USING (category_id)
    order by Total_Sales desc 
    ) as t where rn = 1;
    
    
    -- 4  the customer who spent the most money on orders 
    
    SELECT 
    customer_id,
    concat( first_name, " " , last_name ) as Full_name,

    ROUND(SUM((quantity * list_price) - (quantity * list_price * discount / 100))) AS total_spent
FROM
    customers
        JOIN
    orders o USING (customer_id)
        JOIN
    order_items oi USING (order_id)
GROUP BY customer_id , first_name , last_name
ORDER BY total_spent DESC
LIMIT 1;
    
    
    -- 5  the highest-priced product for each category name

select* from (
select
category_id, category_name,
product_id,
product_name,
list_price as Highest_price, 
row_number()
over (partition by category_name order by list_price desc)  as rn
from products
 join categories
 using (category_id) 
 order by list_price desc
 )as t 
 where rn = 1;
 
 
 -- 6  the total number of orders placed by each customer per store

     
  SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    store_name,
    COUNT(order_id) AS total_orders
FROM
    customers
        JOIN
    orders USING (customer_id)
        JOIN
    stores USING (store_id)
GROUP BY customer_id , full_name , store_name
ORDER BY customer_id;
    
    
    -- 7  the names of staff members who have not made any sales
    
    
   SELECT 
    staff_id, CONCAT(first_name, ' ', last_name) AS Staff_name
FROM
    staffs
        LEFT JOIN
    orders USING (staff_id)
WHERE
    order_id IS NULL;
    
    
    -- 8  the top 3 most sold products in terms of quantity
    
    
    select 
    
    product_name,
    sum(quantity) as total_quantity_sold
    from products
    join order_items using(product_id )
    group by product_name
    order by total_quantity_sold desc
    limit 3;
    
    
    -- 9 The median value of the price list
    
    select 
    avg (list_price) as median_value
    from ( select list_price,
    Row_number() over (order by list_price) as rn,
     count(*) over () as cnt
    from order_items 
    ) t
    where rn in (
    floor((cnt + 1 )/2),
    floor((cnt + 2 )/2)
    );
    
   
    
-- 10 list all products that have never been ordered(use exists)
    
   SELECT 
    product_id, product_name
FROM
    products
WHERE
    NOT EXISTS( SELECT 
            product_id
        FROM
            order_items
        WHERE
            products.product_id = order_items.product_id);
            
            
-- 11 list the names of staff members who have made more sales than the average number of sales by all staff members
            
            SELECT 
    staff_id,
    CONCAT(first_name, " ", last_name) AS staff_name,
    COUNT(order_id) AS total_sales
FROM staffs
JOIN orders USING (staff_id)
GROUP BY staff_id, staff_name
HAVING COUNT(order_id) > (
    SELECT AVG(sales_count) 
    FROM (
        SELECT COUNT(order_id) AS sales_count
        FROM orders
        GROUP BY staff_id
    ) AS staff_sales
);
     
     
     
     
     -- 12 identify the customers who have ordered all the types of products (i.e.,from every category)
     
     select 
     customer_id,
     concat(c.first_name, " ", c.last_name ) as customer_name, 
     count(product_id) as total_product
     from customers c
     join orders using (customer_id)
     join order_items using (order_id)
     join products using (product_id)
     group by customer_id, customer_name
     having count(distinct category_id) = (
     select count(*) from categories
     );
     
     
     
    
