
update `2006 voter list - district` as t, regions_districts as rd
set t.region = rd.region, t.district_name = rd.district_name
where t.district_id = rd.district_id;