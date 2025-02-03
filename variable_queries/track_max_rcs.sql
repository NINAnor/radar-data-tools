load spatial;

attach '${DATABASE_PATH}' as db;

select max(m_dimension) from db.main.track limit 10;
