SELECT d.id, d.value, ci.number_format, itt.name as 'indicator_type_name',
stt.name_singular as 'shape_type_name', st.common_id, st.common_name,
if (ci.ancestry is null, cit.name, concat(cit.name, " (", cit_parent.name_abbrv, ")")) as 'indicator_name',
if(ci.ancestry is null OR (ci.ancestry is not null AND (ci.color is not null AND length(ci.color)>0)),ci.color,ci_parent.color) as 'color'
FROM data as d
inner join datum_translations as dt on d.id = dt.datum_id
inner join indicators as i on d.indicator_id = i.id
inner join core_indicators as ci on i.core_indicator_id = ci.id
inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id and dt.locale = cit.locale
left join core_indicators as ci_parent on ci.ancestry = ci_parent.id
left join core_indicator_translations as cit_parent on ci_parent.id = cit_parent.core_indicator_id and dt.locale = cit_parent.locale
inner join shapes as s on i.shape_type_id = s.shape_type_id
inner join shape_translations as st on s.id = st.shape_id and dt.common_id = st.common_id and dt.common_name = st.common_name and dt.locale = st.locale
inner join shape_types as sts on i.shape_type_id = sts.id
inner join shape_type_translations as stt on sts.id = stt.shape_type_id and dt.locale = stt.locale
inner join indicator_types as it on ci.indicator_type_id = it.id
inner join indicator_type_translations as itt on it.id = itt.indicator_type_id and dt.locale = itt.locale
WHERE 
i.event_id = 2
and ci.indicator_type_id = 2 # political parties
AND s.id =  46303
AND dt.locale = 'en' 
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
