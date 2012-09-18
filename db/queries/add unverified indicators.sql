################################
# add 2012 voter list event
insert into events (event_type_id, event_date, created_at, updated_at)
values (2, '2012-08-01', now(), now());

set @id = LAST_INSERT_ID();

insert into event_translations(event_id, locale, name, name_abbrv, description, created_at, updated_at)
values (@id, 'en', '2012 August Voters List', '2012 August', 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.', now(), now());

insert into event_translations(event_id, locale, name, name_abbrv, description, created_at, updated_at)
values (@id, 'ka', '2012 წლის აგვისტო ამომრჩეველთა სია', '2012 აგვისტო', 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.', now(), now());

################################
# add new core indicators

# unverified #
insert into core_indicators (indicator_type_id, number_format, created_at, updated_at)
values (1, null, now(), now());

set @id = LAST_INSERT_ID();

insert into core_indicator_translations(core_indicator_id, locale, name, name_abbrv, description, created_at, updated_at)
values(@id, 'en', 'Unverified by Voter List Commission (#)', 'Unverified (#)', 'Unverified by Voter List Commission (#)', now(), now());

insert into core_indicator_translations(core_indicator_id, locale, name, name_abbrv, description, created_at, updated_at)
values(@id, 'ka', 'ამომრჩევეთა სიების დაზუსტების უზრუნველყოფის კომისიის მიერ დაუზუსტებელი ამომრჩევლები (#)', 'დაუზუსტებელი (#)', 'ამომრჩევეთა სიების დაზუსტების უზრუნველყოფის კომისიის მიერ დაუზუსტებელი ამომრჩევლები (#)', now(), now());


# unverified %
insert into core_indicators (indicator_type_id, number_format, created_at, updated_at)
values (1, '%', now(), now());

set @id = LAST_INSERT_ID();

insert into core_indicator_translations(core_indicator_id, locale, name, name_abbrv, description, created_at, updated_at)
values(@id, 'en', 'Unverified by Voter List Commission (%)', 'Unverified (%)', 'Unverified by Voter List Commission (%)', now(), now());

insert into core_indicator_translations(core_indicator_id, locale, name, name_abbrv, description, created_at, updated_at)
values(@id, 'ka', 'ამომრჩევეთა სიების დაზუსტების უზრუნველყოფის კომისიის მიერ დაუზუსტებელი ამომრჩევლები (%)', 'დაუზუსტებელი (%)', 'ამომრჩევეთა სიების დაზუსტების უზრუნველყოფის კომისიის მიერ დაუზუსტებელი ამომრჩევლები (%)', now(), now());
