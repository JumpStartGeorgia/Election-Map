# add the en records
insert into datum_translations (datum_id, locale, common_id, common_name)
select
	id,
	'en',
	common_id_old,
	common_name_old
from data;

# add the ka records
insert into datum_translations (datum_id, locale, common_id, common_name)
select
	d.id,
	'ka',
	ifnull(sn_id.ka,d.common_id_old),	
	ifnull(sn_name.ka,d.common_name_old)
from data as d
left join shape_names as sn_id on d.common_id_old = sn_id.en
left join shape_names as sn_name on d.common_name_old = sn_name.en;

