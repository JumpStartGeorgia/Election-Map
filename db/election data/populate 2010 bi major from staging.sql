update `2010 election bi maj - raw` as raw, `2010 election bi maj - staging` as stage
set raw.`5- United National Movement` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 5;

update `2010 election bi maj - raw` as raw, `2010 election bi maj - staging` as stage
set raw.`10 - Christian-democratic movement` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 10;

update `2010 election bi maj - raw` as raw, `2010 election bi maj - staging` as stage
set raw.`16 - Future Party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 16;

update `2010 election bi maj - raw` as raw, `2010 election bi maj - staging` as stage
set raw.`21 - Tortladze- democratic party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 21;

update `2010 election bi maj - raw` as raw, `2010 election bi maj - staging` as stage
set raw.`24 - Movement for fair Georgia` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 24;

update `2010 election bi maj - raw` as raw, `2010 election bi maj - staging` as stage
set raw.`25 - Ivanishvili-Public democrats` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 25;
