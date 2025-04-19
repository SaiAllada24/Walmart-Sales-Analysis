select * from walmart;
select count(*) from walmart;


select payment_method, count(*) from walmart group by payment_method;
select count(distinct Branch) as no_of_stores from walmart;

select min(quantity) from walmart;

/*Business Problems*/
-- q1)Find diff payment methods and number of transactions, no of quantity sold  --
 select payment_method, count(*) as no_of_payments, sum(quantity) as no_qty_sld from walmart group by payment_method;

-- q2) Identify the highest rated category in each branch, displaying branch, categoty and averge ratuing-- 
select * from (
select branch, category, avg(rating) as avg_rating,
rank() over(partition by branch order by avg(rating) desc) as rnk
from walmart
group by 1,2
) as sub
where rnk=1;

select date from walmart;
-- q3) Identify the busiest day of each branch based on no of transactions -- 
SELECT 
  branch,
  DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
  COUNT(*) AS no_transactions
FROM walmart
GROUP BY branch, day_name
ORDER BY branch, no_transactions DESC;




-- Q3) Identify the busiest day of each branch based on no of transactions
SELECT * FROM (
  SELECT 
    branch, 
    DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
    COUNT(*) AS no_transactions,
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
  FROM walmart
  GROUP BY branch, day_name
) AS days_ranked
WHERE rnk = 1;

-- q5) calculate total quantity of items sold per payment method, list payment method and total quantity  --
select payment_method, count(payment_method) as no_of_transactions ,sum(quantity) as total_quantity from walmart
group by payment_method;

-- q5) determine avg,min,max rating of category for each city, list city adn these --
select city, category, max(rating), avg(rating), min(rating) from walmart group by city, category;

-- q6) Calculate total profit for each category by considering total profit as unit price*quantity*margin. List category and total profit ordered from highest to lowest profit--
select category, sum(total*profit_margin) as total_profit from walmart group by category order by total_profit desc;

-- q7) MOst preferred method for each branch -- 
with cte as (
 select branch, payment_method, count(payment_method) as most_preferred_payment_method, 
 rank() over(partition by branch  order by count(*) desc) as rnk
 from walmart
 group by 1,2 
 )
 select * from cte where rnk=1;
 
 
 -- q8) categorize sales into 3 group morning, afternoon,evening
 -- find out each of the shift and no of invoices 
 
 SELECT branch, 
       CASE 
           WHEN EXTRACT(HOUR FROM time) < 12 THEN 'morning'
           WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'afternoon'
           ELSE 'evening'
       END AS day_time,
       count(*)
FROM walmart
group by 1,2
order by 1,3 desc;


-- q10) identift 5 branch with highest decrese ratio in evevenue compare to last year * (current year 2023 and last year 2022)

-- rdr==last_rev-cr_rev/ls_rev * 100
WITH revenue_2022 AS (
    SELECT branch, SUM(total) AS revenue 
    FROM walmart 
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT branch, SUM(total) AS revenue 
    FROM walmart 
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)
SELECT ls.branch, ls.revenue AS revenue_2022, cs.revenue AS revenue_2023, round((ls.revenue-cs.revenue)/(ls.revenue)*100,2) as ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
ON ls.branch = cs.branch
where ls.revenue>cs.revenue
order by 4 desc
limit 5;



