CREATE TABLE customers (
  customer_id int,
  name text
);

INSERT INTO customers 
VALUES  (1, 'John'), 
        (2, 'Ann'), 
        (3, 'Marry'), 
        (4, 'Mark'), 
        (5, 'Tony');

.mode box
SELECT * FROM customers;
-------------------------------------------------------------------------------------------
CREATE TABLE menu (
  menu_id INT UNIQUE,
  menu_name text,
  price REAL
);

INSERT INTO menu
VALUES  ("P01", "Double Mozzarella Cheese", 399.0),
        ("P02", "Pepperoni Bacon", 499.0),
        ("P03", "Ham and Pineapple", 399.0),
        ("P04", "Sausage and Mushroom", 359.0),
        ("P05", "Margharita Cheese", 299.0),
        ("P06", "Truffle Carbonara", 519.0),
        ("P07", "Parma Ham Prociuotto", 519.0),
        ("P08", "Vegie", 399.0);

.mode box
SELECT * FROM menu;
-------------------------------------------------------------------------------------------
CREATE TABLE orders (
  order_id TEXT,
  menu_id TEXT,
  quantity INT,
  customer_id INT,
  order_date TEXT
);

INSERT INTO orders
VALUES  ("O01", "P01", 1, 1, "2023-08-01"),
        ("O02", "P02", 2, 1, "2023-08-05"),
        ("O03", "P03", 1, 2, "2023-08-08"),
        ("O04", "P04", 5, 1, "2023-08-09"),
        ("O05", "P05", 1, 3, "2023-08-10"),
        ("O06", "P06", 1, 1, "2023-08-15"),
        ("O07", "P07", 1, 4, "2023-08-17"),
        ("O08", "P08", 3, 1, "2023-08-20"),
        ("O09", "P01", 1, 2, "2023-08-23"),
        ("O10", "P02", 1, 5, "2023-08-25"),
        ("O11", "P03", 2, 2, "2023-08-28"),
        ("O12", "P04", 1, 1, "2023-08-30"),
        ("O13", "P05", 1, 2, "2023-09-02"),
        ("O14", "P06", 1, 5, "2023-09-08"),
        ("O15", "P07", 3, 3, "2023-09-11"),
        ("O16", "P08", 2, 2, "2023-09-14"),
        ("O17", "P01", 1, 4, "2023-09-15"),
        ("O18", "P02", 1, 3, "2023-09-18"),
        ("O19", "P03", 2, 5, "2023-09-20"),
        ("O20", "P04", 1, 3, "2023-09-23");

.mode box
SELECT * FROM orders;
-------------------------------------------------------------------------------------------

-- Join table
SELECT 
  odrs.order_id AS order_id,
  odrs.order_date AS order_date,
  cus.name AS name,
  piz.menu_name AS menu,
  piz.price AS price,
  odrs.quantity AS quantity
FROM orders AS odrs
LEFT JOIN customerS AS cus
  ON odrs.customer_id = cus.customer_id
LEFT JOIN menu AS piz
  ON odrs.menu_id = piz.menu_id
ORDER BY 1, 2, 5;

-------------------------------------------------------------------------------------------
  
-- Basic Query 1 :
SELECT
  piz.menu_name AS menu,
  SUM(odrs.quantity) AS total_quantity,
  SUM(piz.price * odrs.quantity) AS total_price
FROM orders AS odrs
LEFT JOIN menu AS piz
  ON piz.menu_id = odrs.menu_id
WHERE STRFTIME("%Y-%m" ,odrs.order_date) = "2023-09" AND piz.menu_name = "Parma Ham Prociuotto"
GROUP BY 1;
  
-------------------------------------------------------------------------------------------

-- With clauses Query 1 : UNCOMMENT TO RUN THIS CODE
WITH sep_order AS (
  SELECT 
    odrs.order_id AS order_id,
    odrs.order_date AS order_date,
    odrs.quantity AS quantity,
    menu_id
  FROM orders AS odrs
  WHERE STRFTIME("%Y-%m" ,order_date) = "2023-09"
), piz_menu AS (
  SELECT 
    menu_name AS menu,
    price,
    menu_id
  FROM menu
  WHERE menu_name = "Parma Ham Prociuotto"
) 

SELECT
  order_id,
  menu,
  SUM(t2.price * t1.quantity) AS total_price
FROM sep_order AS t1
JOIN piz_menu AS t2
  ON t1.menu_id = t2.menu_id
GROUP BY 2;

-------------------------------------------------------------------------------------------
-- Query 2 : The most popular menu
select 
  quantity,
  menu_name,
  sum(price)
from
  (
  select * from orders
  ) as t1
join (
  select * from menu
  ) as t2
  on t1.menu_id = t2.menu_id
group by 2
order by 1 desc;

-------------------------------------------------------------------------------------------
-- Query 3 : Who orders pizza the most frequently?
with cus_name as (
  select * from customers
), quan_order as (
  select * from orders
)

select 
  name,
  count(*) as frequency
from cus_name tb1
join quan_order tb2
  on tb1.customer_id = tb2.customer_id
group by 1
order by 2 desc
limit 1;

-- what menu did John order?
select 
    t1.quantity,
    t2.menu_name,
    t3.name,
    order_date
from 
    orders as t1
join menu  as t2
  on t1.menu_id = t2.menu_id
join customers as t3
  on t1.customer_id = t3.customer_id
where name = "John"
