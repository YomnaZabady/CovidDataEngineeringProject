CREATE database covid_db;

use covid_db;

CREATE TABLE IF NOT EXISTS covid_db.covid_staging 
(
 Country 			                STRING,
 Total_Cases   		                DOUBLE,
 New_Cases    		                DOUBLE,
 Total_Deaths                       DOUBLE,
 New_Deaths                         DOUBLE,
 Total_Recovered                    DOUBLE,
 Active_Cases                       DOUBLE,
 Serious		                  	DOUBLE,
 Tot_Cases                   		DOUBLE,
 Deaths                      		DOUBLE,
 Total_Tests                   		DOUBLE,
 Tests			                 	DOUBLE,
 CASES_per_Test                     DOUBLE,
 Death_in_Closed_Cases     	        STRING,
 Rank_by_Testing rate 		        DOUBLE,
 Rank_by_Death_rate    		        DOUBLE,
 Rank_by_Cases_rate    		        DOUBLE,
 Rank_by_Death_of_Closed_Cases   	DOUBLE
)
ROW FORMAT DELIMITED FIELDS TERMINATED by ','
STORED as TEXTFILE
LOCATION '/user/cloudera/ds/COVID_HDFS_LZ'
tblproperties ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE IF NOT EXISTS covid_db.covid_ds_partitioned 
(
 Country 			                STRING,
 Total_Cases   		                DOUBLE,
 New_Cases    		                DOUBLE,
 Total_Deaths                       DOUBLE,
 New_Deaths                         DOUBLE,
 Total_Recovered                    DOUBLE,
 Active_Cases                       DOUBLE,
 Serious		                  	DOUBLE,
 Tot_Cases                   		DOUBLE,
 Deaths                      		DOUBLE,
 Total_Tests                   		DOUBLE,
 Tests			                 	DOUBLE,
 CASES_per_Test                     DOUBLE,
 Death_in_Closed_Cases     	        STRING,
 Rank_by_Testing rate 		        DOUBLE,
 Rank_by_Death_rate    		        DOUBLE,
 Rank_by_Cases_rate    		        DOUBLE,
 Rank_by_Death_of_Closed_Cases   	DOUBLE
)
PARTITIONED BY (COUNTRY_NAME STRING)
LOCATION '/user/cloudera/ds/COVID_HDFS_PARTITIONED';

FROM
covid_db.covid_staging
INSERT INTO TABLE covid_db.covid_ds_partitioned PARTITION(COUNTRY_NAME)
SELECT *,Country WHERE Country is not null;


CREATE EXTERNAL TABLE covid_db.covid_final_output 
(
 TOP_DEATH 			                DOUBLE,
death_rank                                      DOUBLE,
 TOP_TEST 			                DOUBLE,
test_rank                                       DOUBLE
)
PARTITIONED BY (COUNTRY_NAME STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED by ','
STORED as TEXTFILE
LOCATION '/user/cloudera/ds/COVID_FINAL_OUTPUT';

set hive.exec.dynamic.partition.mode=nonstrict;
set hive.exec.dynamic.partition=true;
set hive.exec.boolean.evaluation=nonstrict;
set hive.exec.max.dynamic.partitions=100000;
set hive.exec.max.dynamic.partitions.pernode=100000;


FROM
covid_db.covid_ds_partitioned
INSERT INTO TABLE covid_db.covid_final_output PARTITION(COUNTRY_NAME)
SELECT deaths,rank_by_death_rate, tests, rank_by_testing_rate, Country WHERE Country is not null and (rank_by_death_rate < 11 or rank_by_testing_rate < 11);
