load spatial;

attach '${DATABASE_PATH}' as db (READ_ONLY);

select 
    id, 
    var_pop(m) 
from (
    select
        id,
        location,
        radar_name,
        month,
        year,
        unnest(m_dimension) as m 
    from (
        from db.main.track limit 10
    )
) group by id, location, radar_name, month, year;
