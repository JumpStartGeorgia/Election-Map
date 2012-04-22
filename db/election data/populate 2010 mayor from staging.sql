update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`2 - Irakli Alasania` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 2;

update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`3 - Giorgi Topadze` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 3;

update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`5 - Gigi Ugulava` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 5;

update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`7 - Zviad Dzidziguri` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 7;

update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`10 - Giorgi Chanturia` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 10;

update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`14 - Giorgi Laghidze` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 14;

update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`18 - Tamaz Vashadze` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 18;

update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`21 - Davit Iakobidze` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 21;

update `2010 election tbilisi mayor - raw` as raw, `2010 election tbilisi mayor - staging` as stage
set raw.`25 - Nikoloz Ivanishvili` = stage.num_party_votes
where
raw.district_id = stage.district_id and raw.precinct_id = stage.precinct_id
and stage.party_num = 25;
