CREATE TABLE `2013 may voter list - raw` LIKE `2013 feb voter list - raw`;

create view `2013 may voter list - country` as 
select avg(`raw`.`avg_age`) AS `avg_age`,
sum(`raw`.`greater_99`) AS `greater_99`,
sum(`raw`.`85_99`) AS `85_99`,
sum(`raw`.`less_than_85`) AS `less_than_85`,
sum(`raw`.`no_birthdate`) AS `no_birthdate`,
sum(`raw`.`total_voters`) AS `total_voters`,
sum(`raw`.`duplicates`) AS `duplicates`
from `2013 may voter list - raw` `raw`;


create view `2013 may voter list - district` as 
(select `raw`.`region` AS `region`,
`raw`.`district_id` AS `district_id`,
`raw`.`district_name` AS `district_name`,
avg(`raw`.`avg_age`) AS `avg_age`,
sum(`raw`.`greater_99`) AS `greater_99`,
sum(`raw`.`85_99`) AS `85_99`,
sum(`raw`.`less_than_85`) AS `less_than_85`,
sum(`raw`.`no_birthdate`) AS `no_birthdate`,
sum(`raw`.`total_voters`) AS `total_voters`,
sum(`raw`.`duplicates`) AS `duplicates`
from `2013 may voter list - raw` `raw` where (`raw`.`district_id` not between 1 and 10) group by `raw`.`region`,
`raw`.`district_id`,
`raw`.`district_name` order by `raw`.`district_id`) union (select `raw`.`region` AS `region`,
999 AS `district_id`,
`raw`.`region` AS `district_name`,
avg(`raw`.`avg_age`) AS `avg_age`,
sum(`raw`.`greater_99`) AS `greater_99`,
sum(`raw`.`85_99`) AS `85_99`,
sum(`raw`.`less_than_85`) AS `less_than_85`,
sum(`raw`.`no_birthdate`) AS `no_birthdate`,
sum(`raw`.`total_voters`) AS `total_voters`,
sum(`raw`.`duplicates`) AS `duplicates`
from `2013 may voter list - raw` `raw` where (`raw`.`district_id` between 1 and 10) group by `raw`.`region`);


create view `2013 may voter list - prec` as 
select `raw`.`region` AS `region`,
`raw`.`district_id` AS `district_id`,
`raw`.`district_name` AS `district_name`,
`raw`.`precinct_id` AS `precinct_id`,
concat(cast(`raw`.`district_id` as char charset utf8),
'-',
cast(`raw`.`precinct_id` as char charset utf8)) AS `precinct_name`,
`raw`.`prec_id_from_data` AS `prec_id_from_data`,
`raw`.`avg_age` AS `avg_age`,
`raw`.`greater_99` AS `greater_99`,
`raw`.`85_99` AS `85_99`,
`raw`.`less_than_85` AS `less_than_85`,
`raw`.`no_birthdate` AS `no_birthdate`,
`raw`.`total_voters` AS `total_voters`,
`raw`.`duplicates` AS `duplicates`
from `2013 may voter list - raw` `raw` where (`raw`.`district_id` not between 1 and 10) order by `raw`.`district_id`;


create view `2013 may voter list - region` as 
select `raw`.`region` AS `region`,
avg(`raw`.`avg_age`) AS `avg_age`,
sum(`raw`.`greater_99`) AS `greater_99`,
sum(`raw`.`85_99`) AS `85_99`,
sum(`raw`.`less_than_85`) AS `less_than_85`,
sum(`raw`.`no_birthdate`) AS `no_birthdate`,
sum(`raw`.`total_voters`) AS `total_voters`,
sum(`raw`.`duplicates`) AS `duplicates`
from `2013 may voter list - raw` `raw` group by `raw`.`region`;


create view `2013 may voter list - tbilisi district` as 
select `raw`.`region` AS `region`,
`raw`.`district_id` AS `district_id`,
`raw`.`district_name` AS `district_name`,
avg(`raw`.`avg_age`) AS `avg_age`,
sum(`raw`.`greater_99`) AS `greater_99`,
sum(`raw`.`85_99`) AS `85_99`,
sum(`raw`.`less_than_85`) AS `less_than_85`,
sum(`raw`.`no_birthdate`) AS `no_birthdate`,
sum(`raw`.`total_voters`) AS `total_voters`,
sum(`raw`.`duplicates`) AS `duplicates`
from `2013 may voter list - raw` `raw` where (`raw`.`district_id` between 1 and 10) group by `raw`.`region`,
`raw`.`district_id`,
`raw`.`district_name` order by `raw`.`district_id`;

create view `2013 may voter list - tbilisi prec` as 
select `raw`.`region` AS `region`,
`raw`.`district_id` AS `district_id`,
`raw`.`district_name` AS `district_name`,
`raw`.`precinct_id` AS `precinct_id`,
concat(cast(`raw`.`district_id` as char charset utf8),
'-',
cast(`raw`.`precinct_id` as char charset utf8)) AS `precinct_name`,
`raw`.`prec_id_from_data` AS `prec_id_from_data`,
`raw`.`avg_age` AS `avg_age`,
`raw`.`greater_99` AS `greater_99`,
`raw`.`85_99` AS `85_99`,
`raw`.`less_than_85` AS `less_than_85`,
`raw`.`no_birthdate` AS `no_birthdate`,
`raw`.`total_voters` AS `total_voters`,
`raw`.`duplicates` AS `duplicates`
from `2013 may voter list - raw` `raw` where (`raw`.`district_id` between 1 and 10) order by `raw`.`district_id`;


create view `2013 may voter list - csv` as 
(select 'Country' AS `shape`,
'Georgia' AS `common_id`,
'Georgia' AS `common_name`,
`raw`.`avg_age` as `Average age of voters`,
`raw`.`greater_99` as `Numbers of voters over 99 years old`,
`raw`.`85_99` as `Number of voters between 85 and 99 years old`,
`raw`.`total_voters` as `Total Voters`,
`raw`.`duplicates` as `Number of potential voter duplications`
from `2013 may voter list - country` `raw`) union (select 'Region' AS `shape`,
`raw`.`region` AS `common_id`,
`raw`.`region` AS `common_name`,
`raw`.`avg_age` as `Average age of voters`,
`raw`.`greater_99` as `Numbers of voters over 99 years old`,
`raw`.`85_99` as `Number of voters between 85 and 99 years old`,
`raw`.`total_voters` as `Total Voters`,
`raw`.`duplicates` as `Number of potential voter duplications`
from `2013 may voter list - region` `raw`) union (select 'District' AS `shape`,
`raw`.`district_id` AS `common_id`,
`raw`.`district_name` AS `common_name`,
`raw`.`avg_age` as `Average age of voters`,
`raw`.`greater_99` as `Numbers of voters over 99 years old`,
`raw`.`85_99` as `Number of voters between 85 and 99 years old`,
`raw`.`total_voters` as `Total Voters`,
`raw`.`duplicates` as `Number of potential voter duplications`
from `2013 may voter list - district` `raw`) union (select 'Precinct' AS `shape`,
`raw`.`precinct_id` AS `common_id`,
`raw`.`precinct_name` AS `common_name`,
`raw`.`avg_age` as `Average age of voters`,
`raw`.`greater_99` as `Numbers of voters over 99 years old`,
`raw`.`85_99` as `Number of voters between 85 and 99 years old`,
`raw`.`total_voters` as `Total Voters`,
`raw`.`duplicates` as `Number of potential voter duplications`
from `2013 may voter list - prec` `raw`) union (select 'Tbilisi District' AS `shape`,
`raw`.`district_id` AS `common_id`,
`raw`.`district_name` AS `common_name`,
`raw`.`avg_age` as `Average age of voters`,
`raw`.`greater_99` as `Numbers of voters over 99 years old`,
`raw`.`85_99` as `Number of voters between 85 and 99 years old`,
`raw`.`total_voters` as `Total Voters`,
`raw`.`duplicates` as `Number of potential voter duplications`
from `2013 may voter list - tbilisi district` `raw`) union (select 'Tbilisi Precinct' AS `shape`,
`raw`.`precinct_id` AS `common_id`,
`raw`.`precinct_name` AS `common_name`,
`raw`.`avg_age` as `Average age of voters`,
`raw`.`greater_99` as `Numbers of voters over 99 years old`,
`raw`.`85_99` as `Number of voters between 85 and 99 years old`,
`raw`.`total_voters` as `Total Voters`,
`raw`.`duplicates` as `Number of potential voter duplications`
from `2013 may voter list - tbilisi prec` `raw`);

