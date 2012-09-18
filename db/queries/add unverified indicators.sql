################################
# add 2012 voter list event
insert into events (event_type_id, event_date, created_at, updated_at)
values (2, '2012-08-01', now(), now());

set @event_id = LAST_INSERT_ID();

insert into event_translations(event_id, locale, name, name_abbrv, description, created_at, updated_at)
values (@event_id, 'en', '2012 August Voters List', '2012 August', 'The Central Election Commission of Georgia (CEC) regularly updates the voter\'s list. These versions change over time to reflect population shifts and precinct re-division. According to the Election Code of Georgia, precincts may not contain more than 1,500 voters. All of the data was obtained by public information requests to the CEC since 2008. The CEC can be found at <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.', now(), now());

insert into event_translations(event_id, locale, name, name_abbrv, description, created_at, updated_at)
values (@event_id, 'ka', '2012 წლის აგვისტო ამომრჩეველთა სია', '2012 აგვისტო', 'ცენტრალური საარჩევნო კომისია (ცესკო) რეგულარულად ახდენს ამომრჩეველთა სიის განახლებას. ამომრჩეველთა სია იცვლება მოსახლეობის გადანაწილებისა და საარჩევნო უბნების საზღვრების ცვლილებების გამო. საქართველოს საარჩევნო კოდექსის თანახმად, ამომრჩეველთა რაოდენობა თითოეულ უბანზე არ აღემატება 1500. მონაცემები მოპოვებულია 2008 წლიდან ცესკოსგან საჯარო ინფორმაციის გამოთხოვის მეთოდით. ცესკოს ვებ-გვერდის მისამართია: <a href="http://www.cec.gov.ge" target="_blank">http://www.cec.gov.ge</a>.', now(), now());

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

################################
# add custom view
insert into event_custom_views (event_id, shape_type_id, descendant_shape_type_id, is_default_view, created_at, updated_at)
values (@event_id, 1,3,1, now(), now());

set @id = LAST_INSERT_ID();

insert into event_custom_view_translations(event_custom_view_id, locale, note, created_at, updated_at)
values(@id, 'en', 'Tbilisi districts have been aggregated in this view. Click on Tbilisi to view it\'s districts.', now(), now());

insert into event_custom_view_translations(event_custom_view_id, locale, note, created_at, updated_at)
values(@id, 'ka', 'თბილისის ოლქების სანახავად დააჭირეთ თბილისს.', now(), now());


################################
# add indicator relationships

insert into event_indicator_relationships (event_id, core_indicator_id, related_core_indicator_id, sort_order, created_at, updated_at)
values
(@event_id, 1, 1, 1, now(), now()),
(@event_id, 1, 13, 2, now(), now()),
(@event_id, 1, 14, 3, now(), now()),
(@event_id, 1, 12, 4, now(), now()),
(@event_id, 1, 66, 5, now(), now()),
(@event_id, 1, 67, 6, now(), now()),
(@event_id, 1, 17, 7, now(), now()),

(@event_id, 13, 1, 1, now(), now()),
(@event_id, 13, 13, 2, now(), now()),
(@event_id, 13, 14, 3, now(), now()),
(@event_id, 13, 12, 4, now(), now()),
(@event_id, 13, 66, 5, now(), now()),
(@event_id, 13, 67, 6, now(), now()),
(@event_id, 13, 17, 7, now(), now()),

(@event_id, 14, 1, 1, now(), now()),
(@event_id, 14, 13, 2, now(), now()),
(@event_id, 14, 14, 3, now(), now()),
(@event_id, 14, 12, 4, now(), now()),
(@event_id, 14, 66, 5, now(), now()),
(@event_id, 14, 67, 6, now(), now()),
(@event_id, 14, 17, 7, now(), now()),

(@event_id, 12, 1, 1, now(), now()),
(@event_id, 12, 13, 2, now(), now()),
(@event_id, 12, 14, 3, now(), now()),
(@event_id, 12, 12, 4, now(), now()),
(@event_id, 12, 66, 5, now(), now()),
(@event_id, 12, 67, 6, now(), now()),
(@event_id, 12, 17, 7, now(), now()),

(@event_id, 17, 1, 1, now(), now()),
(@event_id, 17, 13, 2, now(), now()),
(@event_id, 17, 14, 3, now(), now()),
(@event_id, 17, 12, 4, now(), now()),
(@event_id, 17, 66, 5, now(), now()),
(@event_id, 17, 67, 6, now(), now()),
(@event_id, 17, 17, 7, now(), now()),

(@event_id, 66, 1, 1, now(), now()),
(@event_id, 66, 13, 2, now(), now()),
(@event_id, 66, 14, 3, now(), now()),
(@event_id, 66, 12, 4, now(), now()),
(@event_id, 66, 66, 5, now(), now()),
(@event_id, 66, 67, 6, now(), now()),
(@event_id, 66, 17, 7, now(), now()),

(@event_id, 67, 1, 1, now(), now()),
(@event_id, 67, 13, 2, now(), now()),
(@event_id, 67, 14, 3, now(), now()),
(@event_id, 67, 12, 4, now(), now()),
(@event_id, 67, 66, 5, now(), now()),
(@event_id, 67, 67, 6, now(), now()),
(@event_id, 67, 17, 7, now(), now());
