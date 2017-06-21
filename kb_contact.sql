select

  count(contact.account_id) as cnt,
  contact.article_name,
  contact.HC_KB_flag,
  contact.vg_flag,
  sum(contact.rcr7)*1.0/sum(contact.volume) as rcr,
  contact.member_status,
  contact.ticket_gate_level0_desc,
  contact.ticket_gate_level1_desc,
  contact.ticket_gate_level2_desc,
  contact.ticket_gate_level3_desc,
  contact.contact_subchannel_id,
  sum(contact.negative_survey_responses)*1.0/sum(contact.survey_responses) as dsat,
  contact.is_referred_externally,
  sum(contact.handle_time)*1.0/sum(contact.volume) as aht,
  contact.fact_utc_date

from

(

select 
  b.*,
  c.article_name,
  case when b.application_id='padme' then 'HC' else 'KB' end as HC_KB_flag,
  case when b.article_id in (
  4040,3664,32760,37102,3674,3641,5853,19095,36785,3711,35698,33922,6149,
  3631,30316,33302,3629,3630,30317,31933,4736,38706,38599,4697,38871,32925,
  3810,3604,3675,37496,37149,3972,3669,30328,11960,3691,3707,4021,3822,
  4941,3803,43611) then 1 else 0 end as vg_flag,
  cc.call_center_desc,
  cf.account_id,
  cf.contact_origin_country_code,
  case when rcr.contact_code is null then 0 else 1 end as rcr7,
  case when cf.account_id<0 then 'Non-Member' else 'Member' end as member_status,
  cf.ticket_gate_level0_desc,
  cf.ticket_gate_level1_desc,
  cf.ticket_gate_level2_desc,
  cf.ticket_gate_level3_desc,
  cf.contact_subchannel_id,
  cf.makegood_amt,
  cf.makegood_cnt,
  (coalesce(cf.answered_cnt,0)) volume,
  (coalesce(cf.member_ticket_cnt,0)) member_tickets,
  (coalesce(cf.dsat_survey_response_cnt,0)) survey_responses,
  (coalesce(cf.dsat_negative_survey_response_cnt,0)) negative_survey_responses,
  (coalesce(cf.has_referral_gate,0)) has_referral_gate,
  (coalesce(cf.is_referred_externally,0)) is_referred_externally,
  (((coalesce(cf.talk_duration_secs,0)+coalesce(cf.acw_duration_secs,0)+coalesce(cf.answer_hold_duration_secs,0))/60.0)) handle_time,
  cf.contact_start_epoch_utc_ts,
  cf.fact_utc_date

from

(select 
ticket_code,
session_id
from dse.cs_kb_node_visit_f
where ticket_code is not null
and fact_date>=20170101) a

join

(select 
ticket_code,
session_id,
article_id,
node_id,
application_id
from dse.cs_kb_node_visit_f
where fact_date>=20170101
and application_id in ('padme','csinternalkb')) b

on a.session_id=b.session_id

 join dse.cs_kb_article_d c on b.article_id=c.article_id
 join dse.cs_contact_f cf on a.ticket_code=cf.first_ticket_id
 join dse.cs_transfer_type_d trt on cf.transfer_type_id = trt.transfer_type_id
 join dse.cs_contact_skill_d r on r.contact_skill_id = cf.contact_skill_id
 join dse.cs_call_center_d cc on cc.call_center_id = cf.call_center_id 
 join dse.account_d acc on acc.account_id = cf.account_id
 left join (select contact_code from dse.cs_recontact_f
            where days_to_recontact_cnt<=7
            and has_recontact_cnt =1
            and fact_utc_date >= cast(date_format((current_date - interval '7' month ), '%Y%m%d') as bigint)
            group by contact_code) rcr on cf.contact_code = rcr.contact_code
 -- 6 months prior            
 where cf.fact_utc_date >= cast(date_format((current_date - interval '6' month ), '%Y%m%d') as bigint)
 and r.escalation_code not in ('G-Escalation', 'SC-Consult','SC-Escalation','Corp-Escalation')
 and trt.major_transfer_type_desc not in ('TRANSFER_OUT')
 and cf.answered_cnt>0
 and cf.contact_subchannel_id in ('Phone', 'Chat', 'voip','InApp', 'MBChat')
  
) contact

group by
  contact.article_name,
  contact.HC_KB_flag,
  contact.vg_flag,
  contact.member_status,
  contact.ticket_gate_level0_desc,
  contact.ticket_gate_level1_desc,
  contact.ticket_gate_level2_desc,
  contact.ticket_gate_level3_desc,
  contact.contact_subchannel_id,
  contact.is_referred_externally,
  contact.fact_utc_date
 
