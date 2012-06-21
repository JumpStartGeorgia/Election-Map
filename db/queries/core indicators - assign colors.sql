# assign colors to core_indicator parties
CREATE TEMPORARY TABLE if not exists records (
    color varchar(255) not null,
    party varchar(255) not null
) ENGINE=MEMORY;

insert into records values ('#E99334', 'United National Movement');
insert into records values ('#7FAB78', 'United Opposition');
insert into records values ('#A29B88', 'CDM');
insert into records values ('#7F7182', 'Movement for Fair Georgia');
insert into records values ('#C26254', 'Alliance for Georgia');
insert into records values ('#8AB2C1', 'National Democratic Party of Georgia');
insert into records values ('#D9C4A5', 'Freedom Party');
insert into records values ('#8e9b8b', 'Georgian Group');
insert into records values ('#9b8b8e', 'National Council');
insert into records values ('#975710', 'We Ourselves');
insert into records values ('#486b42', 'Arkadi (Badri) Patarkatsishvili');
insert into records values ('#985271', 'Labour');
insert into records values ('#b8afba', 'United Communist Party');
insert into records values ('#76342a', 'Republican party');
insert into records values ('#4a7a8b', 'Davit Gamkrelidze');
insert into records values ('#545f52', 'Right Wing Alliance Topadze Industrialists');
insert into records values ('#c6cc88', 'Industry Will Save Georgia');
insert into records values ('#6e658f', 'Christian Democratic Alliance');
insert into records values ('#53351a', 'Tortladze Democratic Party');
insert into records values ('#155a8f', 'Nikoloz Ivanishvili Public Democrats');
insert into records values ('#b95836', 'Giorgi (Gia) Maisashvili');
insert into records values ('#3a0c17', 'National Party of Radical Democrats of Georgia');
insert into records values ('#408a85', 'Georgian Politics');
insert into records values ('#53501a', 'Traditionalists - Our Georgia and Women\'s Party');
insert into records values ('#8d9b48', 'Solidarity');
insert into records values ('#a51d3d', 'Party of Future');
insert into records values ('#554d45', 'Sportsman\'s Union');
insert into records values ('#231331', 'Public Alliance of Whole Georgia');
insert into records values ('#ae8d9f', 'Our Country');
insert into records values ('#372a24', 'Mamulishvili');
insert into records values ('#280b00', 'Irina Sarishvili-Chanturia');
insert into records values ('#d38b40', 'Future Georgia');

update core_indicators as ci, core_indicator_translations as cit, records
set ci.color = records.color
where
ci.id = cit.core_indicator_id
and cit.name = records.party
and length(records.color) > 0;


drop table records;


