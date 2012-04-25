update indicators as i, data as d
set d.common_name = 
if(
substr(common_name, length(common_name)-1, 1)="0",
if(substr(common_name, length(common_name)-2, 1)="0",
concat(substr(common_name, 1, length(common_name)-3), "-", substr(common_name, length(common_name))),
concat(substr(common_name, 1, length(common_name)-4), "-", substr(common_name, length(common_name)-2))),
if(substr(common_name, length(common_name)-2, 1)="0",
concat(substr(common_name, 1, length(common_name)-3), "-", substr(common_name, length(common_name)-1)),
concat(substr(common_name, 1, length(common_name)-4), "-", substr(common_name, length(common_name)-2)))
)
where
i.id = d.indicator_id
and i.shape_type_id = 4
and common_name not like '%-%'
and common_name != 'null';


select 
common_name,
if(
substr(common_name, length(common_name)-1, 1)="0",
if(substr(common_name, length(common_name)-2, 1)="0",
concat(substr(common_name, 1, length(common_name)-3), "-", substr(common_name, length(common_name))),
concat(substr(common_name, 1, length(common_name)-4), "-", substr(common_name, length(common_name)-2))),
if(substr(common_name, length(common_name)-2, 1)="0",
concat(substr(common_name, 1, length(common_name)-3), "-", substr(common_name, length(common_name)-1)),
concat(substr(common_name, 1, length(common_name)-4), "-", substr(common_name, length(common_name)-2)))
)
from indicators as i
inner join data as d on i.id = d.indicator_id
where 
i.shape_type_id = 4
and common_name not like '%-%'
and common_name != 'null';
