SELECT d.id, d.value, ci.number_format, 
if (ci.ancestry is null, cit.name, concat(cit.name, " (", cit_parent.name_abbrv, ")")) as 'indicator_name',
if(ci.ancestry is null OR (ci.ancestry is not null AND (ci.color is not null AND length(ci.color)>0)),ci.color,ci_parent.color) as 'color'
FROM data as d
inner join datum_translations as dt on d.id = dt.datum_id
inner join indicators as i on d.indicator_id = i.id
inner join core_indicators as ci on i.core_indicator_id = ci.id
inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id
left join core_indicators as ci_parent on ci.ancestry = ci_parent.id
left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id and cit.locale = cit_parent.locale
inner join shapes as s on i.shape_type_id = s.shape_type_id
inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name
WHERE 
i.event_id = 2
and ci.indicator_type_id = 2 # political parties
AND s.id =  1
AND dt.locale = 'en' 
AND st.locale = 'en'
AND cit.locale = 'en'
order by cast(d.value as decimal(12,6)) desc
limit 5

/* original way using max - very long

SELECT d.id, d.value, ci.number_format, 
if (ci.ancestry is null, cit.name, concat(cit.name, " (", cit_parent.name_abbrv, ")")) as 'indicator_name',
if(ci.ancestry is null OR (ci.ancestry is not null AND (ci.color is not null AND length(ci.color)>0)),ci.color,ci_parent.color) as 'color'
FROM data as d
inner join datum_translations as dt on d.id = dt.datum_id
inner join indicators as i on d.indicator_id = i.id
inner join core_indicators as ci on i.core_indicator_id = ci.id
inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id
left join core_indicators as ci_parent on ci.ancestry = ci_parent.id
left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id and cit.locale = cit_parent.locale
inner join shapes as s on i.shape_type_id = s.shape_type_id
inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name
inner join (
	SELECT max(cast(d.value as decimal(12,6))) as max_value
	FROM data as d
	inner join datum_translations as dt on d.id = dt.datum_id
	inner join indicators as i on d.indicator_id = i.id
	inner join core_indicators as ci on i.core_indicator_id = ci.id
	inner join shapes as s on i.shape_type_id = s.shape_type_id
	inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name
	WHERE 
	i.event_id = 3
	and ci.indicator_type_id = 2 # political parties
	AND s.id =  3525
	AND dt.locale = 'en' 
	AND st.locale = 'en'
) as max_val on cast(d.value as decimal(12,6)) = max_val.max_value
WHERE 
i.event_id = 3
and ci.indicator_type_id = 2 # political parties
and s.id =  3525
AND dt.locale = 'en' 
AND st.locale = 'en'
AND cit.locale = 'en'
*/