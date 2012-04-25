CREATE TEMPORARY TABLE if not exists indicator_ids (
    id int null
) ENGINE=MEMORY;

# total turnout
insert into indicator_ids
select
i.id
from indicators as i inner join indicator_translations as it on i.id = it.indicator_id
where it.locale = 'en' and it.name = 'total turnout';

# vote share (%)...
insert into indicator_ids
select
i.id
from indicators as i inner join indicator_translations as it on i.id = it.indicator_id
where it.locale = 'en' and it.name like 'vote share (\%)%';

# old vpm at district and region level
insert into indicator_ids
select
i.id
from indicators as i inner join indicator_translations as it on i.id = it.indicator_id
where i.shape_type_id in (2,3) and
it.locale = 'en' and it.name like 'average votes per minute%';

delete from data where indicator_id in (select id from indicator_ids);
delete from indicator_scale_translations where indicator_scale_id in 
(select id from indicator_scales where indicator_id in (select id from indicator_ids));
delete from indicator_scales where indicator_id in (select id from indicator_ids);
delete from indicator_translations where indicator_id in (select id from indicator_ids);
delete from indicators where id in (select id from indicator_ids);




drop table indicator_ids;