/*
Presidential:
final_1 - Levan Gachechiladze - Freedom party
final_2 - Arkadi (Badri) Patarkatsishvili - initiative group
final_3 - Davit Gamkrelidze - political union of citizens new rights
final_4 - Shalva Natelashvili - ??? (initiative)
final_5 - Mikheil Saakashvili - unm
final_6 - Giorgi (Gia) Maisashvili - initiative
final_7 - Irina Sarishvili-Chanturia - initiative

Tbilisi:
2 - Irakli Alasania - Alliance for Georgia
3 - Giorgi Topadze - Topadze-industrialists
5 - Gigi Ugulava - unm
7 - Zviad Dzidziguri - National council
10 - Giorgi Chanturia - Christian-democratic movement
14 - Giorgi Laghidze - Future Georgia
18 - Tamaz Vashadze - Solidarity
21 - Davit Iakobidze - Tortladze- democratic party
25 - Nikoloz Ivanishvili - Ivanishvili-Public democrats

*/
CREATE TEMPORARY TABLE if not exists records (
    person varchar(255) not null,
    party varchar(255) not null
) ENGINE=MEMORY;

# 2008 pres
insert into records values ('Levan Gachechiladze', 'Freedom Party');
#insert into records values ('Arkadi (Badri) Patarkatsishvili', '');
#insert into records values ('Davit Gamkrelidze', '');
insert into records values ('Shalva Natelashvili', 'Labour');
insert into records values ('Mikheil Saakashvili', 'United National Movement');
#insert into records values ('Giorgi (Gia) Maisashvili', '');
#insert into records values ('Irina Sarishvili-Chanturia', '');

# 2010 tbilisi mayor
insert into records values ('Irakli Alasania', 'Alliance for Georgia');
insert into records values ('Giorgi Topadze', 'Right Wing Alliance Topadze Industrialists');
insert into records values ('Gigi Ugulava', 'United National Movement');
insert into records values ('Zviad Dzidziguri', 'National Council');
insert into records values ('Giorgi Chanturia', 'CDM');
insert into records values ('Giorgi Laghidze', 'Future Georgia');
insert into records values ('Tamaz Vashadze', 'Solidarity');
insert into records values ('Davit Iakobidze', 'Tortladze Democratic Party');
insert into records values ('Nikoloz Ivanishvili', 'Nikoloz Ivanishvili Public Democrats');

update core_indicators as child, core_indicator_translations as child_trans, core_indicators as parent, core_indicator_translations as parent_trans, records
set child.ancestry = parent.id
where
child.id = child_trans.core_indicator_id
and parent.id = parent_trans.core_indicator_id
and child_trans.name = records.person
and parent_trans.name = records.party;


drop table records;


