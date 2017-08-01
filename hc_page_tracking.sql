select count(*),
regexp_extract(request_url, '\d+') as node_id
from etl.cs_stg_padme_event_f
where action='kb-article-popular-categories'
and application_id='padme'
and country_iso_code='US'
and dateint>=20170701
group by regexp_extract(request_url, '\d+')
