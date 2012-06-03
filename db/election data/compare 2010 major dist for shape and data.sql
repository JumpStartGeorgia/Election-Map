select
a.district_id, a.count as `num maj dist in data`, b.count  as `num maj dist in shapes`,
a.count-b.count as `difference`
from
(
select district_id, count(*) as `count`
from data_dist_major_ids
group by district_id
) as a
left join (
select district_id, count(*) as `count`
from shape_dist_major_ids
group by district_id
) as b on a.district_id = b.district_id
order by a.district_id