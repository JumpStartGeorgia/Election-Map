select
et.name, count(*)
from
indicators as i
inner join event_translations as et on i.event_id = et.event_id
where et.locale = 'en' and i.shape_type_id = 1
group by et.name;



select
et.name, count(*)
from
indicators as i
inner join data as d on i.id = d.indicator_id
inner join event_translations as et on i.event_id = et.event_id
where et.locale = 'en'
group by et.name;

