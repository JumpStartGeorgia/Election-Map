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
order by e.event_date asc;


##############################
CREATE TEMPORARY TABLE if not exists records (
    party varchar(255) not null,
    vote_share decimal(8,3) not null
) ENGINE=MEMORY;

# get party data
insert into records
select
cit.name,
avg(cast(d.value as decimal)) as vote_share
from
events as e
inner join event_translations as et on e.id = et.event_id
inner join indicators as i on e.id = i.event_id
inner join core_indicators as ci on i.core_indicator_id = ci.id
inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id
inner join data as d on i.id = d.indicator_id
where
ci.indicator_type_id = 2
and ci.ancestry is null
and i.shape_type_id = 1
and et.locale = 'en'
and cit.locale = 'en'
group by cit.name
order by vote_share desc;

# add people data
insert into records
select
cit.name,
avg(cast(d.value as decimal)) as vote_share
from
events as e
inner join event_translations as et on e.id = et.event_id
inner join indicators as i on e.id = i.event_id
inner join core_indicators as ci2 on i.core_indicator_id = ci2.id
inner join core_indicators as ci on ci2.ancestry = ci.id
inner join core_indicator_translations as cit on ci.id = cit.core_indicator_id
inner join data as d on i.id = d.indicator_id
where
ci.indicator_type_id = 2
and ci.ancestry is null
and ci2.indicator_type_id = 2
and ci2.ancestry is not null
and i.shape_type_id = 1
and et.locale = 'en'
and cit.locale = 'en'
group by cit.name
order by vote_share desc;


select party, avg(vote_share) from records group by party order by vote_share desc;

drop table records;
