select
cit.name,
et.name,
d.value
from
events as e
inner join event_translations as et on e.id = et.event_id
inner join indicators as i on e.id = i.event_id
inner join core_indicators as ci on i.core_indicator_id = ci.id
inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id
inner join data as d on i.id = d.indicator_id
where
ci.id = 59
and i.shape_type_id = 1
and et.locale = 'en'
and cit.locale = 'en'
order by e.event_date asc
