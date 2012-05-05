update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`1 - Georgian Politics` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 1;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`2 - Republican party of Georgia` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 2;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`3 - Rightist alliance Topadze-Industrialists` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 3;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`4 - Labor party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 5;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`5 - United National Movement` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 5;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`6 - Union of sportsmen` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 6;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`7 - United Opposition` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 7;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`8 - Radical-democrats national party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 8;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`9 - Christian-democratic Alliance` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 9;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`10 - Christian-democratic movement` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 10;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`11 - Traditionallists-Our Georgia-Womens party` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 11;

update `2008 election parl major - raw` as raw, `2008 election parl major - staging` as stage
set raw.`12 - Our country` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 12;
