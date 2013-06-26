use election_data-voter_lists;

# first truncate staging and raw tables
truncate table `2013 feb voter list - raw`;

# load data from the csv file
LOAD DATA LOCAL INFILE '/var/www/data/voters_list.csv'
INTO TABLE `2013 feb voter list - raw`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# add the region/district names
update `2013 feb voter list - raw` as t, regions_districts as rd
set t.region = rd.region,t.district_name = rd.district_name
where t.district_id = rd.district_id;


# now download the data to csv
SELECT 'shape', 'common_id', 'common_name', 'Average age of voters', 'Numbers of voters over 99 years old', 'Number of voters between 85 and 99 years old', 'Total Voters', 'Number of potential voter duplications'
union
select * from `2013 feb voter list - csv` where common_id != '' && common_name != ''
INTO OUTFILE '/var/www/data/upload_voters_list.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';



