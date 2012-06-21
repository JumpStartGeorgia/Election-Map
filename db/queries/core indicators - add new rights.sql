# create core indicator for New Rights
insert into core_indicators (indicator_type_id, number_format, created_at, updated_at, ancestry, color)
values (2, '%', now(), now(), null, '#4a7a8b');

insert into core_indicator_translations (core_indicator_id, locale, name, name_abbrv, description, created_at, updated_at)
select
ci.id,
'en',
'New Rights',
'New Rights',
'Vote share New Rights (%)',
now(),
now()
from 
core_indicators as ci
order by id desc
limit 1;
insert into core_indicator_translations (core_indicator_id, locale, name, name_abbrv, description, created_at, updated_at)
select
ci.id,
'ka',
'ახალი მემარჯვენეები',
'ახალი მემარჯვენეები',
'ახალი მემარჯვენეები (%)',
now(),
now()
from 
core_indicators as ci
order by id desc
limit 1;

# now assign Davit Gamkrelidze to new rights
update core_indicators as child, core_indicator_translations as child_trans, core_indicators as parent, core_indicator_translations as parent_trans
set child.ancestry = parent.id, child.color = null
where
child.id = child_trans.core_indicator_id
and parent.id = parent_trans.core_indicator_id
and child_trans.name = 'Davit Gamkrelidze'
and parent_trans.name = 'New Rights';

