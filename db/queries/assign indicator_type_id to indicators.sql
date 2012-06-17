# sql to update default indicator_type_id of 2 (political results) to 1 (indicators)

# all voter list indicators are of type indicators
update indicators
set indicator_type_id = 1
where event_id in (select id from events where event_type_id = 2);

# under elections event type, all of the following indicators are of type indicator:
# - vpm 08-12, vpm12-17, vpm 17-12, vpm 12-15, vpm 15-20, tt %, tt #
update indicators as i, indicator_translations as it
set i.indicator_type_id = 1
where i.id = it.indicator_id
and it.locale = 'en'
and it.name_abbrv in ('TT#', 'TT%', 'VPM 08:00-12:00', 'VPM 12:00-15:00', 'VPM 12:00-17:00', 'VPM 15:00-20:00', 'VPM 17:00-20:00');


# view the breakdown of indicators by type
select
i.indicator_type_id, it.name_abbrv, count(*)
from
indicators as i
inner join indicator_translations as it on i.id = it.indicator_id
where it.locale = 'en'
group by 
i.indicator_type_id, it.name_abbrv
order by i.indicator_type_id, it.name_abbrv;