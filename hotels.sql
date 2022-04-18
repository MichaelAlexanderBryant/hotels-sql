-- Question 1: Is the revenue for each hotel growing each year?
-- Question 2: Should the parking lot size be increased?

-- Combine all yearly tables and view all columns
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'];

-- year_tables CTE
WITH year_tables AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$']
)
-- Yearly revenue per year for each hotel (number of nights stayed * average daily rate * (1 - discount))
SELECT hotel, arrival_date_year, ROUND(SUM((stays_in_weekend_nights+stays_in_week_nights)*adr*(1-discount)),2) AS revenue
FROM year_tables
LEFT JOIN market_segment$ ms
	ON ms.market_segment = year_tables.market_segment
GROUP BY arrival_date_year, hotel
ORDER BY hotel, arrival_date_year;


-- year_tables CTE
WITH year_tables AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$']
)
-- Total revenue by hotel
SELECT hotel, ROUND(SUM((stays_in_weekend_nights+stays_in_week_nights)*adr*(1-discount)),2) AS revenue
FROM year_tables
LEFT JOIN market_segment$ ms
	ON ms.market_segment = year_tables.market_segment
GROUP BY hotel;


-- year_tables CTE
WITH year_tables AS (
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$']
)
-- Returning customers per year for each hotel
SELECT hotel, arrival_date_year, COUNT(is_repeated_guest) AS return_guests
FROM year_tables
GROUP BY arrival_date_year, hotel;

-- Create a view from CTE
CREATE VIEW year_tables AS
SELECT * FROM dbo.['2018$']
UNION
SELECT * FROM dbo.['2019$']
UNION
SELECT * FROM dbo.['2020$'];

-- Create a view using previous view where month strings are converted into integers
CREATE VIEW month_converted AS
SELECT *,
CASE
	WHEN arrival_date_month = 'January' THEN 1
	WHEN arrival_date_month = 'February' THEN 2
	WHEN arrival_date_month = 'March' THEN 3
	WHEN arrival_date_month = 'April' THEN 4
	WHEN arrival_date_month = 'May' THEN 5
	WHEN arrival_date_month = 'June' THEN 6
	WHEN arrival_date_month = 'July' THEN 7
	WHEN arrival_date_month = 'August' THEN 8
	WHEN arrival_date_month = 'September' THEN 9
	WHEN arrival_date_month = 'October' THEN 10
	WHEN arrival_date_month = 'November' THEN 11
	ELSE 12
END AS [month]
FROM year_tables;


-- returning customers running total for each hotel ordered by month, year
-- City Hotel
SELECT [month],arrival_date_year AS [year], 
		SUM(SUM(is_repeated_guest)) OVER (PARTITION BY hotel ORDER BY arrival_date_year, [month]) AS running_total_return_guests
FROM month_converted
WHERE hotel = 'City Hotel'
GROUP BY [month], arrival_date_year, hotel
ORDER BY [year],[month];
--Resort Hotel
SELECT [month],arrival_date_year AS [year], 
		SUM(SUM(is_repeated_guest)) OVER (PARTITION BY hotel ORDER BY arrival_date_year, [month]) AS running_total_return_guests
FROM month_converted
WHERE hotel = 'Resort Hotel'
GROUP BY [month], arrival_date_year, hotel
ORDER BY [year],[month];

-- total amount of parking required per month
-- City Hotel
SELECT [month],arrival_date_year AS [year], SUM(required_car_parking_spaces) AS total_parking
FROM month_converted
WHERE hotel = 'City Hotel'
GROUP BY [month], arrival_date_year, hotel
ORDER BY [year],[month];
-- Resort Hotel
SELECT [month],arrival_date_year AS [year], SUM(required_car_parking_spaces) AS total_parking
FROM month_converted
WHERE hotel = 'Resort Hotel'
GROUP BY [month], arrival_date_year, hotel
ORDER BY [year],[month];


-- required_car_parking_spaces running total for each hotel ordered by month, year
-- City Hotel
SELECT [month],arrival_date_year AS [year], 
		SUM(SUM(required_car_parking_spaces)) OVER (PARTITION BY hotel ORDER BY arrival_date_year, [month]) AS running_total_car_parking
FROM month_converted
WHERE hotel = 'City Hotel'
GROUP BY [month], arrival_date_year, hotel
ORDER BY [year],[month];
--Resort Hotel
SELECT [month],arrival_date_year AS [year], 
		SUM(SUM(required_car_parking_spaces)) OVER (PARTITION BY hotel ORDER BY arrival_date_year, [month]) AS running_total_car_parking
FROM month_converted
WHERE hotel = 'Resort Hotel'
GROUP BY [month], arrival_date_year, hotel
ORDER BY [year],[month];

-- Revenue from meal sales per month from 'City Hotel'
SELECT [month], arrival_date_year AS [year], ROUND(SUM(Cost*(stays_in_week_nights+stays_in_weekend_nights)*adults),2) AS total_meal_revenue
FROM month_converted
LEFT JOIN meal_cost$ mc
	ON mc.meal = month_converted.meal
WHERE hotel = 'City Hotel'
GROUP BY [month], arrival_date_year, hotel
ORDER BY [year], [month];

-- Revenue from meal sales per month from 'Resort Hotel'
SELECT [month], arrival_date_year AS [year], ROUND(SUM(Cost*(stays_in_week_nights+stays_in_weekend_nights)*adults),2) AS total_meal_revenue
FROM month_converted
LEFT JOIN meal_cost$ mc
	ON mc.meal = month_converted.meal
WHERE hotel = 'Resort Hotel'
GROUP BY [month], arrival_date_year, hotel
ORDER BY [year], [month];

-- Running total revenue from meal sales per month from 'City Hotel'
WITH total_meal_rev_ch AS (
SELECT hotel, [month], arrival_date_year AS [year], ROUND(SUM(Cost*(stays_in_week_nights+stays_in_weekend_nights)*adults),2) AS total_meal_revenue
FROM month_converted
LEFT JOIN meal_cost$ mc
	ON mc.meal = month_converted.meal
GROUP BY [month], arrival_date_year, hotel)
SELECT [month],[year], 
		SUM(total_meal_revenue) OVER (PARTITION BY hotel ORDER BY [month], [year]) AS running_total_car_parking
FROM total_meal_rev_ch
WHERE hotel = 'City Hotel'
GROUP BY [month], [year], total_meal_revenue, hotel
ORDER BY [year], [month]


-- Running total revenue from meal sales per month from 'Resort Hotel'
WITH total_meal_rev_ch AS (
SELECT hotel, [month], arrival_date_year AS [year], ROUND(SUM(Cost*(stays_in_week_nights+stays_in_weekend_nights)*adults),2) AS total_meal_revenue
FROM month_converted
LEFT JOIN meal_cost$ mc
	ON mc.meal = month_converted.meal
GROUP BY [month], arrival_date_year, hotel)
SELECT [month],[year], 
		SUM(total_meal_revenue) OVER (PARTITION BY hotel ORDER BY [month], [year]) AS running_total_car_parking
FROM total_meal_rev_ch
WHERE hotel = 'Resort Hotel'
GROUP BY [month], [year], total_meal_revenue, hotel
ORDER BY [year], [month]

-- Cost per meal
SELECT * FROM [meal_cost$];

-- Discount per market segment
SELECT * FROM [market_segment$];

-- Meal type total each month
SELECT [month], arrival_date_year AS [year], meal, COUNT(meal) AS total_meal
FROM month_converted
GROUP BY [month], arrival_date_year, meal
ORDER BY meal, [year], [month];

-- Total meals per year per type of meal
SELECT arrival_date_year AS [year], meal, COUNT(meal) AS total_meal
FROM month_converted
GROUP BY arrival_date_year, meal
ORDER BY [year], meal;

-- Market segment total each month
SELECT [month], arrival_date_year AS [year], market_segment, COUNT(market_segment) AS total_market_segment
FROM month_converted
GROUP BY [month], arrival_date_year, market_segment
ORDER BY market_segment, [year], [month];

-- Total market segment per year per type of market segment
SELECT arrival_date_year AS [year], market_segment, COUNT(market_segment) AS total_market_segment
FROM month_converted
GROUP BY arrival_date_year, market_segment
ORDER BY [year], market_segment;
