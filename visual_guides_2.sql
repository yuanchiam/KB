select
  avg(num_art) as avg_num_art
from
  (select
  --account_id,
  session_id,
  application_id,
  count(article_id) as num_art,
  --node_id,
  locale,
  sum(survey_response_cnt) as sur_res,
  sum(negative_survey_response_cnt) as sur_res_neg,
  fact_utc_date,
  sum(case when article_id in (
  4040,3664,32760,37102,3674,3641,5853,19095,36785,3711,35698,33922,6149,
  3631,30316,33302,3629,3630,30317,31933,4736,38706,38599,4697,38871,32925,
  3810,3604,3675,37496,37149,3972,3669,30328,11960,3691,3707,4021,3822,
  4941,3803,43611) then 1 else 0 end) as num_art_vg
  from dse.cs_kb_node_visit_f
  where fact_utc_date>=20170101
  and article_id>0
  group by session_id, application_id, locale, fact_utc_date) tmp


roup by
