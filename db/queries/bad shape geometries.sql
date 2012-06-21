SELECT * 
FROM shapes as s
inner join shape_translations as st on s.id = st.shape_id
WHERE RIGHT( s.GEOMETRY, 4 ) <>  ']]]}' and st.locale = 'en'
