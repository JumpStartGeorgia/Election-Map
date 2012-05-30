# update the common id value
update shape_translations as st, shape_names as sn
	set st.common_id = sn.ka
where
 st.locale = 'ka'
and st.common_id = sn.en;

# update the common name value
update shape_translations as st, shape_names as sn
	set st.common_name = sn.ka
where
 st.locale = 'ka'
and st.common_name = sn.en;
