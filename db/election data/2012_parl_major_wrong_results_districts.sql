drop table if exists district_results;
drop table if exists max_district_results;

create temporary table district_results (district_id int, result int);
create temporary table max_district_results (district_id int, result int);

insert into district_results (district_id, result)
select
 district_id, 
`Free Georgia count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`National Democratic Party of Georgia count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`United National Movement count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Movement for Fair Georgia count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Christian-Democratic Movement count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Public Movement count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Freedom Party count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Georgian Group count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`New Rights count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`People's Party count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Merab Kostava Society count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Future Georgia count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Labour Council of Georgia count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Labour count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Sportsman's Union count`
from `2012 election parl major - districts`
;

insert into district_results (district_id, result)
select
 district_id, 
`Georgian Dream count`
from `2012 election parl major - districts`
;

##############

insert into district_results (district_id, result)
select
 district_id, 
`Free Georgia count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`National Democratic Party of Georgia count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`United National Movement count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Movement for Fair Georgia count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Christian-Democratic Movement count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Public Movement count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Freedom Party count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Georgian Group count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`New Rights count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`People's Party count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Merab Kostava Society count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Future Georgia count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Labour Council of Georgia count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Labour count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Sportsman's Union count`
from `2012 election parl major - tbilisi district`
;

insert into district_results (district_id, result)
select
 district_id, 
`Georgian Dream count`
from `2012 election parl major - tbilisi district`
;



insert into max_district_results (district_id, result)
select
 district_id, max(result)
from district_results
group by district_id;



select
p.district_name, p.district_id, p.`total ballots cast`, (p.`total ballots cast` - p.`total valid ballots cast`) as `total invalid ballots cast`, p.`total valid ballots cast`, 
(`Free Georgia count` + `National Democratic Party of Georgia count` + `United National Movement count` + `Movement for Fair Georgia count` + `Christian-Democratic Movement count` + `Public Movement count` + `Freedom Party count` + `Georgian Group count` + `New Rights count` + `People's Party count` + `Merab Kostava Society count` + `Future Georgia count` + `Labour Council of Georgia count` + `Labour count` + `Sportsman's Union count` + `Georgian Dream count`) as sum_parties,
p.`sum logic fail difference`, t.first_result as first_place_result, t.second_result as second_place_result,
(t.first_result - t.second_result - p.`sum logic fail difference`) as difference_first_second_logic_check
from `2012 election parl major - districts` as p
inner join (
	select
	t1.district_id, tmax.result as first_result, max(t1.result) as second_result
	from district_results as t1
	inner join max_district_results as tmax on tmax.district_id = t1.district_id
	where t1.result < tmax.result
	group by t1.district_id
	order by t1.district_id asc
	) as t on t.district_id = p.district_id
where (t.first_result - t.second_result - p.`sum logic fail difference`) < 0
;

select
p.district_name, p.district_id, p.`total ballots cast`, (p.`total ballots cast` - p.`total valid ballots cast`) as `total invalid ballots cast`, p.`total valid ballots cast`, 
(`Free Georgia count` + `National Democratic Party of Georgia count` + `United National Movement count` + `Movement for Fair Georgia count` + `Christian-Democratic Movement count` + `Public Movement count` + `Freedom Party count` + `Georgian Group count` + `New Rights count` + `People's Party count` + `Merab Kostava Society count` + `Future Georgia count` + `Labour Council of Georgia count` + `Labour count` + `Sportsman's Union count` + `Georgian Dream count`) as sum_parties,
p.`sum logic fail difference`, t.first_result as first_place_result, t.second_result as second_place_result,
(t.first_result - t.second_result - p.`sum logic fail difference`) as difference_first_second_logic_check
from `2012 election parl major - tbilisi district` as p
inner join (
	select
	t1.district_id, tmax.result as first_result, max(t1.result) as second_result
	from district_results as t1
	inner join max_district_results as tmax on tmax.district_id = t1.district_id
	where t1.result < tmax.result
	group by t1.district_id
	order by t1.district_id asc
	) as t on t.district_id = p.district_id
where (t.first_result - t.second_result - p.`sum logic fail difference`) < 0

;


drop table district_results;
drop table max_district_results;

