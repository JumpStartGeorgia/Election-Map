use election_data-elections;

# first truncate staging and raw tables
truncate table `2013 election bi maj - raw`;

# load data from the csv file
LOAD DATA LOCAL INFILE '/var/www/data/official_bi_major.csv'
INTO TABLE `2013 election bi maj - raw`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# add the region/district names
update `2013 election bi maj - raw` as t, regions_districts as rd
set t.region = rd.region,t.district_name = rd.district_name
where t.district_id = rd.district_id;

# add valid votes
update `2013 election bi maj - raw`
set num_valid_votes = (num_votes-num_invalid_votes);


# now download the data to csv
SELECT 'shape', 'common_id', 'common_name', 'Total Turnout (#)', 'Total Turnout (%)', 'Free Georgia', 'National Democratic Party of Georgia', 'United National Movement', 'Movement for Fair Georgia', 'Freedom Party', 'Merab Kostava Society', 'Labour Council of Georgia', 'Labour', 'Georgian Dream', 'Ioseb Manjavidze', 'Zviad Chitishvili', 'Roman Robakidze', 'Zurab Mskhvilidze'
union
select * from `2013 election bi maj - csv` where common_id != '' && common_name != ''
INTO OUTFILE '/var/www/data/upload_official_bi_major.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
