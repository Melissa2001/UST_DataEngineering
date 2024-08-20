-- Create a database with condition to test if it exist --
-- Declare a variable with name Databasename --
DECLARE @Databasename VARCHAR(128) = 'taxidb';
-- Test condition to check if database exists --
IF NOT EXISTS(select 1 from sys.databases where name = @Databasename)
BEGIN
DECLARE @SQL NVARCHAR(MAX) = 'CREATE DATABASE ' + QUOTENAME(@Databasename)
EXEC sp_executesql @SQL;
END

USE taxidb

CREATE TABLE [dbo].taxi (
    VendorID INT,
    lpep_pickup_datetime VARCHAR(50),
    lpep_dropoff_datetime VARCHAR(50),
    store_and_fwd_flag VARCHAR(10),
    RatecodeID INT,
    PULocationID INT,
    DOLocationID INT,
    passenger_count INT,
    trip_distance float,
    fare_amount DECIMAL(6, 2),
    extra DECIMAL(3, 2),
    mta_tax DECIMAL(3, 2),
    tip_amount DECIMAL(5, 2),
    tolls_amount DECIMAL(5, 2),
    ehail_fee DECIMAL(5, 2),
    improvement_surcharge DECIMAL(3, 2),
    total_amount DECIMAL(7, 2),
    payment_type INT,
    trip_type INT,
    congestion_surcharge DECIMAL(3, 2)
);



BULK INSERT taxi FROM 'D:\2021_Green_Taxi_Trip_Data.csv'
WITH
(
FIELDTERMINATOR = ',', -- | ; \t ' '
ROWTERMINATOR = '0x0a', -- Carriage & New Line character \r\n,\n,\r,\0x0a (linefeed)
FIRSTROW = 2 --Skip the header from records
);

select * from taxi

-- 1) Shape of the Table (Number of Rows and Columns)
select count(*) as num_rows from taxi
select count(*) as num_columns from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='taxi'

-- 2) Show Summary of Green Taxi Rides – Total Rides, Total Customers, Total Sales
select VendorID,count(*) as totalrides,sum(passenger_count) as totalcustomers , sum(total_amount) as totalsales 
from taxi group by VendorID HAVING VendorID>=0

-- 3) Total Rides with Surcharge and its percentage.
select count(*) as total_rides, sum(improvement_surcharge)+ sum(congestion_surcharge) as total_surcharge,
(sum(improvement_surcharge)+ sum(congestion_surcharge))/sum(total_amount) as percentage
from taxi

-- 4) Cumulative Sum of Total Fare Amount for Each Pickup Location
select PULocationID,total_amount,SUM(total_amount) OVER(partition by PULocationID
ORDER BY VendorID
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW)
AS cumulative_fare
from taxi order by PULocationID

-- 5) Which Payment Type is Most Common in Each Drop-off Location
WITH PaymentTypeCounts AS (
    SELECT 
        DOLocationID,
        payment_type,
        COUNT(*) AS payment_count
    FROM [dbo].taxi
    GROUP BY DOLocationID, payment_type
),
RankedPaymentTypes AS (
    SELECT 
        DOLocationID,
        payment_type,
        payment_count,
        RANK() OVER (PARTITION BY DOLocationID ORDER BY payment_count DESC) AS rank
    FROM PaymentTypeCounts
)
SELECT 
    DOLocationID,
    payment_type AS most_common_payment_type
FROM RankedPaymentTypes
WHERE rank = 1 and payment_type is not null;


-- 6) Create a New Column for Trip Distance Band and Show Distribution
ALTER TABLE [dbo].taxi
ADD TripDistanceBand VARCHAR(20);
UPDATE [dbo].taxi
SET TripDistanceBand = CASE
    WHEN trip_distance <= 1 THEN '0-1 miles'
    WHEN trip_distance <= 3 THEN '1-3 miles'
    WHEN trip_distance <= 5 THEN '3-5 miles'
    WHEN trip_distance <= 10 THEN '5-10 miles'
    ELSE '10+ miles'
END;
SELECT 
    TripDistanceBand,
    COUNT(*) AS count
FROM [dbo].taxi
GROUP BY TripDistanceBand
ORDER BY count DESC;


-- 7) Find the Most Frequent Pickup Location (Mode) with rides fare greater than average of ride fare.
WITH AvgFare AS (
    SELECT AVG(fare_amount) AS avg_fare
    FROM taxi
),
FilteredRides AS (
    SELECT 
        PULocationID
    FROM taxi
    WHERE fare_amount > (SELECT avg_fare FROM AvgFare)
),
PickupCounts AS (
    SELECT 
        PULocationID,
        COUNT(*) AS ride_count
    FROM FilteredRides
    GROUP BY PULocationID
),
RankedPickups AS (
    SELECT 
        PULocationID,
        ride_count,
        RANK() OVER (ORDER BY ride_count DESC) AS rank
    FROM PickupCounts
)
SELECT 
    PULocationID AS most_frequent_pickup_location
FROM RankedPickups
WHERE rank = 1;


-- 8) Show the Rate Code with the Highest Percentage of Usage
WITH TotalTrips AS (
    SELECT COUNT(*) AS total_count
    FROM [dbo].taxi
),
RateCodeCounts AS (
    SELECT 
        RatecodeID,
        COUNT(*) AS rate_code_count
    FROM [dbo].taxi
    GROUP BY RatecodeID
),
RateCodePercentages AS (
    SELECT 
        r.RatecodeID,
        (r.rate_code_count * 100.0 / t.total_count) AS percentage
    FROM RateCodeCounts r
    CROSS JOIN TotalTrips t
)
SELECT TOP(1)
    RatecodeID,
    percentage
FROM RateCodePercentages
ORDER BY percentage DESC



-- 9) Show Distribution of Tips, Find the Maximum Chances of Getting a Tip
SELECT
    COUNT(CASE WHEN tip_amount > 0 THEN 1 END) AS trips_with_tips,
    COUNT(*) AS total_trips,
    (COUNT(CASE WHEN tip_amount > 0 THEN 1 END) * 100.0 / COUNT(*)) AS percentage_with_tips
FROM [dbo].taxi;


-- 10) Calculate the Rank of Trips Based on Fare Amount within Each Pickup Location
select VendorID, PULocationID,
RANK() over(partition by PULocationID order by fare_amount)
AS RANK FROM taxi where VendorID is not null

-- 11) Find Top 20 Most Frequent Rides Routes. 
SELECT TOP(20) PULocationID,DOLocationID,count 
from (select PULocationID,DOLocationID,count(*) as count 
from taxi group by PULocationID,DOLocationID ) 
as _ order by count desc

-- 12) Calculate the Average Fare of Completed Trips vs. Cancelled Trips 

select avg(fare_amount) as completedfare from taxi where VendorID is not null
select avg(fare_amount) as cancelledfare from taxi where VendorID is null
