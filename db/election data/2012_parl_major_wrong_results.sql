drop table if exists precinct_results;
drop table if exists max_precinct_results;

create temporary table precinct_results (district_id int, precinct_id int, result int);
create temporary table max_precinct_results (district_id int, precinct_id int, result int);

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Free Georgia`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`National Democratic Party of Georgia`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`United National Movement`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Movement for Fair Georgia`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Christian-Democratic Movement`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Public Movement`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Freedom Party`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Georgian Group`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`New Rights`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`People's Party`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Merab Kostava Society`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Future Georgia`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Labour Council of Georgia`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Labour`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Sportsman's Union`
from `2012 election parl major - raw`
;

insert into precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id,
`Georgian Dream`
from `2012 election parl major - raw`
;



insert into max_precinct_results (district_id, precinct_id, result)
select
 district_id, precinct_id, max(result)
from precinct_results
group by district_id, precinct_id;



select
p.district_name, p.district_id, p.precinct_id, p.num_votes, p.num_invalid_votes, p.num_valid_votes, 
(`Free Georgia` + `National Democratic Party of Georgia` + `United National Movement` + `Movement for Fair Georgia` + `Christian-Democratic Movement` + `Public Movement` + `Freedom Party` + `Georgian Group` + `New Rights` + `People's Party` + `Merab Kostava Society` + `Future Georgia` + `Labour Council of Georgia` + `Labour` + `Sportsman's Union` + `Georgian Dream`) as sum_parties,
p.logic_check_difference, t.first_result as first_place_result, t.second_result as second_place_result,
(t.first_result - t.second_result - p.logic_check_difference) as difference_first_second_logic_check
from `2012 election parl major - raw` as p
inner join (
	select
	t1.district_id, t1.precinct_id, tmax.result as first_result, max(t1.result) as second_result
	from precinct_results as t1
	inner join max_precinct_results as tmax on tmax.district_id = t1.district_id and tmax.precinct_id = t1.precinct_id
	where t1.result < tmax.result
	group by t1.district_id, t1.precinct_id 	
	order by t1.district_id asc, t1.precinct_id asc
	) as t on t.district_id = p.district_id and t.precinct_id = p.precinct_id
where (t.first_result - t.second_result - p.logic_check_difference) < 0
;


drop table precinct_results;
drop table max_precinct_results;

