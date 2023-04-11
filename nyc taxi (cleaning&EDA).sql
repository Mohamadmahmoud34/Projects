
--First step : Merged all dataset into 1 table

CREATE TABLE Dataset (
  vendorid int, 
  lpep_pickup_datetime datetime, 
  lpep_dropoff_datetime datetime, 
  Store_and_fwd_flag varchar(50), 
  RatecodeID int, 
  PULocationID int, 
  DOLocationID int, 
  passenger_count int, 
  trip_distance float, 
  fare_amount float, 
  extra float, 
  mta_tax float, 
  tip_amount float, 
  tolls_amount float, 
  improvement_surcharge float, 
  total_amount float, 
  payment_type float, 
  trip_type float
)

--------------------------------------------------------------------------------------------------------------------------------

--insert data from the first CSV file
INSERT INTO Dataset(
  vendorid, lpep_pickup_datetime, 
  lpep_dropoff_datetime, Store_and_fwd_flag, 
  RatecodeID, PULocationID, DOLocationID ,passenger_count, 
  trip_distance, fare_amount, extra, 
  mta_tax, tip_amount, tolls_amount, 
  improvement_surcharge, total_amount, 
  payment_type, trip_type
) 
SELECT 
  vendorid, 
  lpep_pickup_datetime, 
  lpep_dropoff_datetime, 
  Store_and_fwd_flag, 
  RatecodeID, 
  PULocationID, 
  DOLocationID, passenger_count, 
  trip_distance, 
  fare_amount, 
  extra, 
  mta_tax, 
  tip_amount, 
  tolls_amount, 
  improvement_surcharge, 
  total_amount, 
  payment_type, 
  trip_type 
FROM 
  [2017_taxi_trips]


-- insert data from the second CSV file
INSERT INTO Dataset(
  vendorid, lpep_pickup_datetime, 
  lpep_dropoff_datetime, Store_and_fwd_flag, 
  RatecodeID, PULocationID, DOLocationID ,passenger_count, 
  trip_distance, fare_amount, extra, 
  mta_tax, tip_amount, tolls_amount, 
  improvement_surcharge, total_amount, 
  payment_type, trip_type
) 
SELECT 
  vendorid, 
  lpep_pickup_datetime, 
  lpep_dropoff_datetime, 
  Store_and_fwd_flag, 
  RatecodeID, 
  PULocationID, 
  DOLocationID, passenger_count, 
  trip_distance, 
  fare_amount, 
  extra, 
  mta_tax, 
  tip_amount, 
  tolls_amount, 
  improvement_surcharge, 
  total_amount, 
  payment_type, 
  trip_type 
FROM 
  [2018_taxi_trips]


-- insert data from the third CSV file
INSERT INTO Dataset(
  vendorid, lpep_pickup_datetime, 
  lpep_dropoff_datetime, Store_and_fwd_flag, 
  RatecodeID, PULocationID, DOLocationID ,passenger_count, 
  trip_distance, fare_amount, extra, 
  mta_tax, tip_amount, tolls_amount, 
  improvement_surcharge, total_amount, 
  payment_type, trip_type
) 
SELECT 
  vendorid, 
  lpep_pickup_datetime, 
  lpep_dropoff_datetime, 
  Store_and_fwd_flag, 
  RatecodeID, 
  PULocationID, 
  DOLocationID, passenger_count, 
  trip_distance, 
  fare_amount, 
  extra, 
  mta_tax, 
  tip_amount, 
  tolls_amount, 
  improvement_surcharge, 
  total_amount, 
  payment_type, 
  trip_type 
FROM 
  [2019_taxi_trips]


-- insert data from the fourth CSV file
INSERT INTO Dataset (
  vendorid, lpep_pickup_datetime, 
  lpep_dropoff_datetime, Store_and_fwd_flag, 
  RatecodeID, PULocationID, DOLocationID ,passenger_count, 
  trip_distance, fare_amount, extra, 
  mta_tax, tip_amount, tolls_amount, 
  improvement_surcharge, total_amount, 
  payment_type, trip_type
) 
SELECT 
  vendorid, 
  lpep_pickup_datetime, 
  lpep_dropoff_datetime, 
  Store_and_fwd_flag, 
  RatecodeID, 
  PULocationID, 
  DOLocationID, passenger_count, 
  trip_distance, 
  fare_amount, 
  extra, 
  mta_tax, 
  tip_amount, 
  tolls_amount, 
  improvement_surcharge, 
  total_amount, 
  payment_type, 
  trip_type 
FROM 
  [2020_taxi_trips]

----------------------------------------------------------------------------------------------------------------------

 -- Checking for data quality :

--first we insterest on store_and_fwd_flag='N' and trips in street-hailed and trips payed by cash or card with a standard rate(Trip_type=1,Payment_type=1 or 2 ,RatecodeID=1)
Delete from Dataset 
where Store_and_fwd_flag='Y'

Select distinct(trip_type)
from Dataset

Delete from Dataset 
where payment_type not in(1,2)

Delete from Dataset 
where RatecodeID !=1

 --we found some outliers date (2008,2009,2021,2030,2040,etc..)

 DELETE FROM 
  Dataset 
WHERE 
  lpep_pickup_datetime < '2017-01-01 00:00:00' 
  OR lpep_pickup_datetime > '2020-12-31 23:59:59';
DELETE FROM 
  Dataset 
WHERE 
  lpep_dropoff_datetime < '2017-01-01 00:00:00' 
  OR lpep_dropoff_datetime > '2020-12-31 23:59:59';


--there are records passanger had 1 passenger and recordes with 0 passanger so we assume that we can replace 0 per 1 

update 
  Dataset 
set 
  passenger_count = Case when passenger_count = 0 then 1 else passenger_count end 
from 
  Dataset


----check pickup datetime and dropoff_datetime  we found some data where pickup_datetime>dropoff_datetime so we switch them 

UPDATE 
  Dataset 
SET 
  lpep_pickup_datetime = CASE WHEN lpep_pickup_datetime > lpep_dropoff_datetime THEN lpep_dropoff_datetime ELSE lpep_pickup_datetime END, 
  lpep_dropoff_datetime = CASE WHEN lpep_pickup_datetime < lpep_dropoff_datetime THEN lpep_pickup_datetime ELSE lpep_pickup_datetime END 
WHERE 
  lpep_pickup_datetime > lpep_dropoff_datetime;

--if any recors shows negative we switch it positive 

select 
  * 
from 
  Dataset 
where 
  trip_distance < 0 
  or fare_amount < 0 
  or mta_tax < 0 
  or extra < 0 
  or tip_amount < 0 
  or tolls_amount < 0 
  or total_amount < 0 
  or improvement_surcharge < 0


UPDATE 
  Dataset 
SET 
  fare_amount = CASE WHEN fare_amount < 0 THEN REPLACE(fare_amount, '-', '') ELSE fare_amount END, 
  mta_tax = CASE WHEN mta_tax < 0 THEN REPLACE(mta_tax, '-', '') ELSE mta_tax END, 
  trip_distance = CASE WHEN trip_distance < 0 THEN REPLACE(trip_distance, '-', '') ELSE trip_distance END, 
  extra = CASE WHEN extra < 0 THEN REPLACE(extra, '-', '') ELSE extra END, 
  tip_amount = CASE WHEN tip_amount < 0 THEN REPLACE(tip_amount, '-', '') ELSE tip_amount END, 
  tolls_amount = CASE WHEN tolls_amount < 0 THEN REPLACE(tolls_amount, '-', '') ELSE tolls_amount END, 
  total_amount = CASE WHEN total_amount < 0 THEN REPLACE(total_amount, '-', '') ELSE total_amount END, 
  improvement_surcharge = CASE WHEN improvement_surcharge < 0 THEN REPLACE(improvement_surcharge, '-', '') ELSE improvement_surcharge END 
WHERE 
  fare_amount < 0 
  OR mta_tax < 0 
  OR trip_distance < 0 
  OR extra < 0 
  OR tip_amount < 0 
  OR tolls_amount < 0 
  OR total_amount < 0 
  OR improvement_surcharge < 0;



--remove trips lasting than a 24 hours,and any trips which show both a distance and fae amount=0 

delete from Dataset
where datediff(HOUR,lpep_pickup_datetime,lpep_dropoff_datetime)>24 or trip_distance=0 or fare_amount=0


/* Check for total_amount(count,mean,Stddev,min,max) */


SELECT 
  AVG(total_amount) AS mean, 
  COUNT(total_amount) AS count, 
  STDEV(total_amount) AS stdev, 
  MIN(total_amount) AS min, 
  MAX(total_amount) AS max 
FROM 
  Dataset;

--  there are only 7 rows we can delete them 
 delete from Dataset
  where total_amount>1000


  --Check for trip_distance

  
SELECT 
  AVG(trip_distance) AS mean, 
  COUNT(trip_distance) AS count, 
  STDEV(trip_distance) AS stdev, 
  MIN(trip_distance) AS min, 
  MAX(trip_distance) AS max 
FROM 
  Dataset;

  delete from Dataset
  where trip_distance>1000

---Check passenger_count
select 
  min(passenger_count) as min, 
  max(passenger_count) as max, 
  stdev(passenger_count) as stdev 
from 
  Dataset
 
delete from 
  Dataset 
where 
  passenger_count > 6

---------------------------------------------------------------------------------------------------------------------------

/*Exploring  NYC Taxi Trips */

--1_What payment methods are popular?
SELECT 
  payment_type, 
  COUNT(*) AS trips_count, 
  SUM(
    CASE WHEN payment_type = 1 THEN 1 ELSE 0 END
  ) AS pt1, 
  SUM(
    CASE WHEN payment_type = 2 THEN 1 ELSE 0 END
  ) AS pt2 
FROM 
  Dataset 
GROUP BY 
  payment_type


-- 2_top destinations and where the trips coming from ?

SELECT 
  TOP 3 tz_dest.Borough, 
  tz_dest.Zone AS destination, 
  COUNT(*) AS num_trips, 
  tz_pickup.Zone AS pickup_location 
FROM 
  Dataset d 
  JOIN taxi_zones tz_dest ON d.DOLocationID = tz_dest.LocationID 
  JOIN taxi_zones tz_pickup ON d.PULocationID = tz_pickup.LocationID 
GROUP BY 
  tz_dest.Borough, 
  tz_dest.Zone, 
  tz_pickup.Zone 
ORDER BY 
  num_trips DESC;


-- 3_Do people Travel solo or groups?

select 
  sum(
    case when passenger_count = 1 then 1 else 0 end
  ) as solo, 
  sum(
    case when passenger_count > 1 then 1 else 0 end
  ) as Groups 
from 
  dataset

-- 4_which days of weeks do we see more rush?

SELECT 
  DATENAME(WEEKDAY, d.lpep_pickup_datetime) AS day_name, 
  COUNT(*) AS num_trips 
FROM 
  Dataset d 
  LEFT JOIN [454_calendar] c ON c.date = CAST(d.lpep_pickup_datetime AS DATE) 
GROUP BY 
  DATENAME(WEEKDAY, d.lpep_pickup_datetime) 
order by 
  num_trips desc


-- 5_which time of the day high rider trips? 

SELECT  top 3 DATEPART(hour, lpep_pickup_datetime) AS ride_hour, COUNT(*) AS num_rides
FROM Dataset
GROUP BY DATEPART(hour, lpep_pickup_datetime)
ORDER BY num_rides DESC

--6_which heavy demanding seasons of the year 

SELECT 
  YEAR(d.lpep_pickup_datetime) AS year, 
  CASE WHEN MONTH(d.lpep_pickup_datetime) BETWEEN 3 
  AND 5 THEN 'Spring' 
  WHEN MONTH(d.lpep_pickup_datetime) BETWEEN 6 
  AND 8 THEN 'Summer' 
  WHEN MONTH(d.lpep_pickup_datetime) BETWEEN 9 
  AND 11 THEN 'Fall' 
  ELSE 'Winter' 
  END AS season, 
  COUNT(*) AS num_trips 
FROM 
  Dataset d 
GROUP BY 
  YEAR(d.lpep_pickup_datetime), 
  CASE WHEN MONTH(d.lpep_pickup_datetime) BETWEEN 3 
  AND 5 THEN 'Spring' 
  WHEN MONTH(d.lpep_pickup_datetime) BETWEEN 6 
  AND 8 THEN 'Summer' 
  WHEN MONTH(d.lpep_pickup_datetime) BETWEEN 9 
  AND 11 THEN 'Fall' 
  ELSE 'Winter' 
  END 
ORDER BY 
  year, 
  season;

--which vendor get max number of rider?

select 
  vendorid, 
  count(*) as nb_of_rd 
from 
  Dataset 
group by 
  vendorid 
order by 
  nb_of_rd desc
