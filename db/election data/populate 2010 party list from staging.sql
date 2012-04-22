update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`2 - Alliance for Georgia` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 2;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`3 - Topadze-industrialists` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 3;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`5- United National Movement` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 5;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`6 - Union of sportsmen` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 6;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`7 - National council` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 7;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`8 - Radical-democrats national party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 8;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`10 - Christian-democratic movement` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 10;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`12 - Our country` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 12;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`14 - Future Georgia` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 14;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`15 - Freedom party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 15;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`16 - Future Party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 16;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`17 - National Democratic Party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 17;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`18 - Solidarity` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 18;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`19 - Mamulishvili` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 19;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`21 - Tortladze- democratic party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 21;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`23 - National alliance of all Georgia` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 23;

update `2010 election party list - raw` as raw, `2010 election party list - staging` as stage
set raw.`25 - Ivanishvili-Public democrats` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 25;
