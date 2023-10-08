/*
-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
-- [Q1] What is the distribution of customers across states?
SELECT state, COUNT(DISTINCT customer_id) AS number_of_customers
FROM customer_t
GROUP BY state
ORDER BY number_of_customers DESC;


-- ---------------------------------------------------------------------------------------------------------------------------------

-- [Q2] What is the average rating in each quarter?
WITH RatingCTE AS (
    SELECT 
        quarter_number,
        CASE 
            WHEN customer_feedback = 'Very Bad' THEN 1
            WHEN customer_feedback = 'Bad' THEN 2
            WHEN customer_feedback = 'Okay' THEN 3
            WHEN customer_feedback = 'Good' THEN 4
            WHEN customer_feedback = 'Very Good' THEN 5
            ELSE 0
        END AS rating_value
    FROM order_t
)

SELECT 
    quarter_number,
    AVG(rating_value) AS average_rating
FROM RatingCTE
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

-- [Q3] Are customers getting more dissatisfied over time?
WITH FeedbackCTE AS (
    SELECT 
        quarter_number,
        customer_feedback,
        COUNT(customer_feedback) AS feedback_count
    FROM order_t
    GROUP BY quarter_number, customer_feedback
),

TotalFeedbackCTE AS (
    SELECT 
        quarter_number,
        COUNT(*) AS total_feedback
    FROM order_t
    GROUP BY quarter_number
)

SELECT 
    f.quarter_number,
    f.customer_feedback,
    f.feedback_count,
    t.total_feedback,
    (f.feedback_count * 100.0 / t.total_feedback) AS feedback_percentage
FROM FeedbackCTE f
JOIN TotalFeedbackCTE t ON f.quarter_number = t.quarter_number
ORDER BY f.quarter_number, feedback_percentage DESC;
      


-- ---------------------------------------------------------------------------------------------------------------------------------

-- [Q4] Which are the top 5 vehicle makers preferred by the customer.
SELECT 
    p.vehicle_maker,
    COUNT(DISTINCT o.customer_id) AS number_of_customers
FROM product_t p
JOIN order_t o ON p.product_id = o.product_id
GROUP BY p.vehicle_maker
ORDER BY number_of_customers DESC
LIMIT 5;



-- ---------------------------------------------------------------------------------------------------------------------------------

-- [Q5] What is the most preferred vehicle make in each state?

WITH RankedVehicleMakers AS (
    SELECT 
        c.state,
        p.vehicle_maker,
        COUNT(DISTINCT o.customer_id) AS number_of_customers,
        RANK() OVER(PARTITION BY c.state ORDER BY COUNT(DISTINCT o.customer_id) DESC) AS rank
    FROM customer_t c
    JOIN order_t o ON c.customer_id = o.customer_id
    JOIN product_t p ON o.product_id = p.product_id
    GROUP BY c.state, p.vehicle_maker
)

SELECT 
    state,
    vehicle_maker,
    number_of_customers
FROM RankedVehicleMakers
WHERE rank = 1;




-- ---------------------------------------------------------------------------------------------------------------------------------


-- [Q6] What is the trend of number of orders by quarters?

SELECT 
    quarter_number,
    COUNT(order_id) AS number_of_orders
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;




-- ---------------------------------------------------------------------------------------------------------------------------------

-- [Q7] What is the quarter over quarter % change in revenue? 

WITH QuarterlyRevenue AS (
    SELECT 
        quarter_number,
        SUM(vehicle_price * quantity - vehicle_price * quantity * discount / 100) AS total_revenue
    FROM order_t
    JOIN product_t ON order_t.product_id = product_t.product_id
    GROUP BY quarter_number
)

SELECT 
    quarter_number,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY quarter_number) AS previous_quarter_revenue,
    (total_revenue - LAG(total_revenue) OVER (ORDER BY quarter_number)) / LAG(total_revenue) OVER (ORDER BY quarter_number) * 100 AS qoq_percentage_change
FROM QuarterlyRevenue
ORDER BY quarter_number;
            

-- ---------------------------------------------------------------------------------------------------------------------------------

-- [Q8] What is the trend of revenue and orders by quarters?

SELECT 
    quarter_number,
    COUNT(order_id) AS number_of_orders,
    SUM(vehicle_price * quantity - vehicle_price * quantity * discount / 100) AS total_revenue
FROM order_t
JOIN product_t ON order_t.product_id = product_t.product_id
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

--   [Q9] What is the average discount offered for different types of credit cards?
SELECT 
    credit_card_type,
    AVG(discount) AS average_discount
FROM order_t
JOIN customer_t ON order_t.customer_id = customer_t.customer_id
GROUP BY credit_card_type;

-- ---------------------------------------------------------------------------------------------------------------------------------

-- [Q10] What is the average time taken to ship the placed orders for each quarters?
SELECT 
    quarter_number,
    AVG(DATEDIFF(ship_date, order_date)) AS average_shipping_days
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;



-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



