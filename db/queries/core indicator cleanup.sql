# update core indicator name to not include 'vote share' and '(%)' at end
update core_indicators as ci, core_indicator_translations as cit
set cit.name = substring(cit.name, 12, length(cit.name)-4-11)
where 
ci.id = cit.core_indicator_id
and ci.indicator_type_id = 2 
and cit.locale = 'en'
and cit.name like 'vote share%';

update core_indicators as ci, core_indicator_translations as cit
set cit.name = replace(cit.name, ' (%)', '')
where 
ci.id = cit.core_indicator_id
and ci.indicator_type_id = 2 
and cit.locale = 'ka'
and cit.name like '% (\%)'
and cit.name != 'ქდმ (%)';


######################################
# fix duplicates in core indicators with slightly different names
######################################
select * from
core_indicator_translations as cit
inner join (
select locale, name_abbrv
from 
core_indicator_translations 
group by locale, name_abbrv
having count(*) > 1
) as cit2 on cit.locale = cit2.locale and cit.name_abbrv = cit2.name_abbrv
order by cit.name_abbrv, cit.id;

select 
i.core_indicator_id,
core_old.core_indicator_id,
core_new.core_indicator_id
 from
indicators as i
inner join (select core_indicator_id, name_abbrv from core_indicator_translations where locale = 'en' and name = 'National Democratic Party') as core_old on i.`core_indicator_id` = core_old.`core_indicator_id`
inner join (select core_indicator_id, name_abbrv from core_indicator_translations where locale = 'en' and name = 'National Democratic Party of Georgia') as core_new on core_old.name_abbrv = core_new.name_abbrv;


######################################
#National Democratic Party
#National Democratic Party of Georgia
update indicators as i, 
  (select core_indicator_id, name_abbrv from core_indicator_translations where locale = 'en' and name = 'National Democratic Party') as core_old, 
  (select core_indicator_id, name_abbrv from core_indicator_translations where locale = 'en' and name = 'National Democratic Party of Georgia') as core_new
set i.core_indicator_id = core_new.core_indicator_id
where
i.`core_indicator_id` = core_old.`core_indicator_id`
and core_old.name_abbrv = core_new.name_abbrv;
# delete the unused record
CREATE TEMPORARY TABLE if not exists ids (
    id int null
) ENGINE=MEMORY;
insert into ids
select core_indicator_id from core_indicator_translations where locale = 'en' and name = 'National Democratic Party';
delete from core_indicator_translations where core_indicator_id in (select id from ids);
delete from core_indicators where id in (select id from ids);
drop table ids;


######################################
# unm
#United National Movement
update indicators as i, 
  (select core_indicator_id, name_abbrv from core_indicator_translations where locale = 'en' and name = 'UNM') as core_old, 
  (select core_indicator_id, name_abbrv from core_indicator_translations where locale = 'en' and name = 'United National Movement') as core_new
set i.core_indicator_id = core_new.core_indicator_id
where
i.`core_indicator_id` = core_old.`core_indicator_id`
and core_old.name_abbrv = core_new.name_abbrv;
# delete the unused record
CREATE TEMPORARY TABLE if not exists ids (
    id int null
) ENGINE=MEMORY;
insert into ids
select core_indicator_id from core_indicator_translations where locale = 'en' and name = 'UNM';
delete from core_indicator_translations where core_indicator_id in (select id from ids);
delete from core_indicators where id in (select id from ids);
drop table ids;

