update `2012 election parl major - raw`
set logic_check_fail = 
if(num_valid_votes = (`Free Georgia` + `National Democratic Party of Georgia` + `United National Movement` + `Movement for Fair Georgia` + `Christian-Democratic Movement` + `Public Movement` + `Freedom Party` + `Georgian Group` + `New Rights` + `People's Party` + `Merab Kostava Society` + `Future Georgia` + `Labour Council of Georgia` + `Labour` + `Sportsman's Union` + `Georgian Dream`), 0, 1)
;


update `2012 election parl major - raw`
set logic_check_difference = 
num_valid_votes - (`Free Georgia` + `National Democratic Party of Georgia` + `United National Movement` + `Movement for Fair Georgia` + `Christian-Democratic Movement` + `Public Movement` + `Freedom Party` + `Georgian Group` + `New Rights` + `People's Party` + `Merab Kostava Society` + `Future Georgia` + `Labour Council of Georgia` + `Labour` + `Sportsman's Union` + `Georgian Dream`);


select logic_check_fail, count(*) from `2012 election parl major - raw` group by logic_check_fail;

select min(abs(logic_check_difference)), max(abs(logic_check_difference)), avg(logic_check_difference) 
from `2012 election parl major - raw` 
where logic_check_difference != 0;


