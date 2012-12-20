use election_data-elections;

# first truncate staging and raw tables
truncate table `2012 election parl major - staging`;
truncate table `2012 election parl major - raw`;

# load data from the csv file
LOAD DATA LOCAL INFILE '/var/www/data/major.csv'
INTO TABLE `2012 election parl major - staging`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

# load data into the raw table
insert into `2012 election parl major - raw`
select distinct
`rd`.`region` AS `region`,
`staging`.`district_id` AS `district_id`,
`rd`.`district_name` AS `district_name`,
`staging`.`precinct_id` AS `precinct_id`,
`staging`.`num_possible_voters` AS `num_possible_voters`,
`staging`.`num_special_voters` AS `num_special_voters`,
`staging`.`num_at_12` AS `num_at_12`,
`staging`.`num_at_17` AS `num_at_17`,
`staging`.`num_votes` AS `num_votes`,
`staging`.`num_ballots` AS `num_ballots`,
`staging`.`num_invalid_votes` AS `num_invalid_votes`,
(`staging`.`num_votes` - `staging`.`num_invalid_votes`) AS `num_valid_votes`,
`parties`.`Free Georgia` AS `Free Georgia`,
`parties`.`National Democratic Party of Georgia` AS `National Democratic Party of Georgia`,
`parties`.`United National Movement` AS `United National Movement`,
`parties`.`Movement for Fair Georgia` AS `Movement for Fair Georgia`,
`parties`.`Christian-Democratic Movement` AS `Christian-Democratic Movement`,
`parties`.`Public Movement` AS `Public Movement`,
`parties`.`Freedom Party` AS `Freedom Party`,
`parties`.`Georgian Group` AS `Georgian Group`,
`parties`.`New Rights` AS `New Rights`,
`parties`.`People's Party` AS `People's Party`,
`parties`.`Merab Kostava Society` AS `Merab Kostava Society`,
`parties`.`Future Georgia` AS `Future Georgia`,
`parties`.`Labour Council of Georgia` AS `Labour Council of Georgia`,
`parties`.`Labour` AS `Labour`,
`parties`.`Sportsman's Union` AS `Sportsman's Union`,
`parties`.`Georgian Dream` AS `Georgian Dream`
from ((`2012 election parl major - staging` `staging`
join `regions_districts` `rd` on((`staging`.`district_id` = `rd`.`district_id`)))
join `2012 election parl major - parties` `parties` on(((`staging`.`district_id` = `parties`.`district_id`) and (`staging`.`precinct_id` = `parties`.`precinct_id`))));


# now download the data to csv
SELECT 'shape', 'common_id', 'common_name', 'Total Turnout (#)', 'Total Turnout (%)', 'Number of Precincts with Invalid Ballots from 0-1%', 'Number of Precincts with Invalid Ballots from 1-3%', 'Number of Precincts with Invalid Ballots from 3-5%', 'Number of Precincts with Invalid Ballots > 5%', 'Invalid Ballots (%)', 'Average votes per minute (08:00-12:00)', 'Average votes per minute (12:00-17:00)', 'Average votes per minute (17:00-20:00)', 'Number of Precincts with votes per minute > 2 (08:00-12:00)', 'Number of Precincts with votes per minute > 2 (12:00-17:00)', 'Number of Precincts with votes per minute > 2 (17:00-20:00)', 'Number of Precincts with votes per minute > 2', 'Precincts Reported (#)', 'Precincts Reported (%)', 'Free Georgia', 'National Democratic Party of Georgia', 'United National Movement', 'Movement for Fair Georgia', 'Christian-Democratic Movement', 'Public Movement', 'Freedom Party', 'Georgian Group', 'New Rights', 'People\'s Party', 'Merab Kostava Society', 'Future Georgia', 'Labour Council of Georgia', 'Labour', 'Sportsman\'s Union', 'Georgian Dream'
union
select * from `2012 election parl major - csv` where common_id != '' && common_name != ''
INTO OUTFILE '/var/www/data/upload_major.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
