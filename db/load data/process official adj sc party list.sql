use election_data-elections;

# first truncate staging and raw tables
truncate table `2012 election adjara suprm counc party list - raw`;

# load data from the csv file
LOAD DATA LOCAL INFILE '/var/www/data/official_adj_sc_party_list.csv'
INTO TABLE `2012 election adjara suprm counc party list - raw`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# add the region/district names
update `2012 election adjara suprm counc party list - raw` as t, regions_districts as rd
set t.region = rd.region,t.district_name = rd.district_name
where t.district_id = rd.district_id;

# add valid votes
update `2012 election adjara suprm counc party list - raw`
set num_valid_votes = (num_votes-num_invalid_votes);

# now download the data to csv
SELECT 'shape', 'common_id', 'common_name', 'Total Turnout (#)', 'Total Turnout (%)', 'Number of Precincts with Invalid Ballots from 0-1%', 'Number of Precincts with Invalid Ballots from 1-3%', 'Number of Precincts with Invalid Ballots from 3-5%', 'Number of Precincts with Invalid Ballots > 5%', 'Invalid Ballots (%)', 'Precincts Reported (#)', 'Precincts Reported (%)', 'Free Georgia', 'United National Movement', 'Movement for Fair Georgia', 'Christian-Democratic Movement', 'New Rights', 'Labour', 'Georgian Dream'
union
select * from `2012 election adjara suprm counc party list - csv` where common_id != '' && common_name != ''
INTO OUTFILE '/var/www/data/upload_official_adj_sc_party_list.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
