select  
fact_date,
api.article_id,
api.article_name, 
case when kb.language_id is null then api.language_id else kb.language_id end as language,
sum(coalesce(kb.visitors,0)) visitors

from

-- joining dse.cs_kb_article_d to find article names
(select node.article_id, art.article_name, node.node_id, node.application_id,
lower(node.language_id) as language_id
from dse.cs_kb_node_d node
left join dse.cs_kb_article_d art on node.article_id=art.article_id
where node.application_id='padme' and node.is_published=1) api

left join 

(select fact_date, node_id, 
case when node_id=article_id or article_id<0 then lower(language_id) else NULL end as language_id,
application_id, sum(coalesce(visitor_cnt,0)) as visitors 
from dse.cs_kb_node_visit_f 
where fact_date between cast(date_format(date_add('day',-95,current_date), '%Y%m%d') as bigint)
                  and cast(date_format(date_add('day',-1,current_date), '%Y%m%d') as bigint)
and application_id='padme' group by 1,2,3,4

) kb

on kb.node_id=api.node_id and kb.application_id=api.application_id
group by 1,2,3,4
