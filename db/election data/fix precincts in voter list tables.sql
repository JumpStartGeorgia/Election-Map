start transaction;

# reset 'x_' hack to null
update `2006 voter list - prec`
set prec_id = null
where prec_id like 'x_%';

# update the column names
alter table `2006 voter list - prec` change column precinct precinct_id int null;
alter table `2006 voter list - prec` change column prec_id prec_id_from_data int null;
alter table `2006 voter list - prec` add column precinct_name varchar(255) null after precinct_id;

# add the new precinct_name value
update `2006 voter list - prec`
set precinct_name = case length(precinct_id)
	when 1 then concat(district_id, "00", precinct_id)
	else concat(district_id, "0", precinct_id)
end;

# reset 'x_' hack to null
update `2007 voter list - prec`
set prec_id = null
where prec_id like 'x_%';

# update the column names
alter table `2007 voter list - prec` change column precinct precinct_id int null;
alter table `2007 voter list - prec` change column prec_id prec_id_from_data int null;
alter table `2007 voter list - prec` add column precinct_name varchar(255) null after precinct_id;

# add the new precinct_name value
update `2007 voter list - prec`
set precinct_name = case length(precinct_id)
	when 1 then concat(district_id, "00", precinct_id)
	else concat(district_id, "0", precinct_id)
end;

# reset 'x_' hack to null
update `2008 apr voter list - prec`
set prec_id = null
where prec_id like 'x_%';

# update the column names
alter table `2008 apr voter list - prec` change column precinct precinct_id int null;
alter table `2008 apr voter list - prec` change column prec_id prec_id_from_data int null;
alter table `2008 apr voter list - prec` add column precinct_name varchar(255) null after precinct_id;

# add the new precinct_name value
update `2008 apr voter list - prec`
set precinct_name = case length(precinct_id)
	when 1 then concat(district_id, "00", precinct_id)
	else concat(district_id, "0", precinct_id)
end;

# reset 'x_' hack to null
update `2008 jan voter list - prec`
set prec_id = null
where prec_id like 'x_%';

# update the column names
alter table `2008 jan voter list - prec` change column precinct precinct_id int null;
alter table `2008 jan voter list - prec` change column prec_id prec_id_from_data int null;
alter table `2008 jan voter list - prec` add column precinct_name varchar(255) null after precinct_id;

# add the new precinct_name value
update `2008 jan voter list - prec`
set precinct_name = case length(precinct_id)
	when 1 then concat(district_id, "00", precinct_id)
	else concat(district_id, "0", precinct_id)
end;

# reset 'x_' hack to null
update `2008 may voter list - prec`
set prec_id = null
where prec_id like 'x_%';

# update the column names
alter table `2008 may voter list - prec` change column precinct precinct_id int null;
alter table `2008 may voter list - prec` change column prec_id prec_id_from_data int null;
alter table `2008 may voter list - prec` add column precinct_name varchar(255) null after precinct_id;

# add the new precinct_name value
update `2008 may voter list - prec`
set precinct_name = case length(precinct_id)
	when 1 then concat(district_id, "00", precinct_id)
	else concat(district_id, "0", precinct_id)
end;

# reset 'x_' hack to null
update `2009 voter list - prec`
set prec_id = null
where prec_id like 'x_%';

# update the column names
alter table `2009 voter list - prec` change column precinct precinct_id int null;
alter table `2009 voter list - prec` change column prec_id prec_id_from_data int null;
alter table `2009 voter list - prec` add column precinct_name varchar(255) null after precinct_id;

# add the new precinct_name value
update `2009 voter list - prec`
set precinct_name = case length(precinct_id)
	when 1 then concat(district_id, "00", precinct_id)
	else concat(district_id, "0", precinct_id)
end;

# reset 'x_' hack to null
update `2010 feb voter list - prec`
set prec_id = null
where prec_id like 'x_%';

# update the column names
alter table `2010 feb voter list - prec` change column precinct precinct_id int null;
alter table `2010 feb voter list - prec` change column prec_id prec_id_from_data int null;
alter table `2010 feb voter list - prec` add column precinct_name varchar(255) null after precinct_id;

# add the new precinct_name value
update `2010 feb voter list - prec`
set precinct_name = case length(precinct_id)
	when 1 then concat(district_id, "00", precinct_id)
	else concat(district_id, "0", precinct_id)
end;

# reset 'x_' hack to null
update `2010 may voter list - prec`
set prec_id = null
where prec_id like 'x_%';

# update the column names
alter table `2010 may voter list - prec` change column precinct precinct_id int null;
alter table `2010 may voter list - prec` change column prec_id prec_id_from_data int null;
alter table `2010 may voter list - prec` add column precinct_name varchar(255) null after precinct_id;

# add the new precinct_name value
update `2010 may voter list - prec`
set precinct_name = case length(precinct_id)
	when 1 then concat(district_id, "00", precinct_id)
	else concat(district_id, "0", precinct_id)
end;


commit;
