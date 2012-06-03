update `2010 election bi maj - raw`
set `num_valid_votes` = 
(ifnull(`5- United National Movement`,0) +
ifnull(`10 - Christian-democratic movement`,0) +
ifnull(`16 - Future Party`,0) +
ifnull(`21 - Tortladze- democratic party`,0) +
ifnull(`24 - Movement for fair Georgia`,0) +
ifnull(`25 - Ivanishvili-Public democrats`,0) )
