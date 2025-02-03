load spatial;

attach '${DATABASE_PATH}' as db;

select id, var_pop(m) from (select id, unnest(m_dimension) as m from db.main.track where id = 2496) group by id;
