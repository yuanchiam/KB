-- Intent to Contact

select cast(sum(contact_intent_cnt) as float)/cast(sum(visitor_cnt) as float) itc
from dse.cs_kb_node_visit_f
where fact_date between 20170401 and 20170630
and page_load_cnt>0
and application_id='padme'
and node_id not in (-12345)


-- Article RCR

select 
cast(sum(coalesce(rcr.has_recontact_cnt,0)) as float)/
cast(sum(coalesce(c.member_ticket_cnt,0)) as float) rcr
from   dse.cs_contact_f c 
join dse.geo_country_d geo on c.contact_origin_country_code = geo.country_iso_code 
join dse.cs_transfer_type_d trt on c.transfer_type_id = trt.transfer_type_id 
join dse.cs_contact_subchannel_d sub on c.contact_subchannel_id=sub.contact_subchannel_id 
join dse.cs_contact_skill_d sk on c.contact_skill_id=sk.contact_skill_id 
join dse.cs_kb_node_visit_f kb on c.first_ticket_id=kb.ticket_code
left join (select * from dse.cs_recontact_f 
     where days_to_recontact_cnt<=7 
     and fact_utc_date >= 20170401 ) rcr on c.contact_code = rcr.contact_code
where c.fact_utc_date between 20170401 and 20170630
and sk.escalation_code = 'No-Escalation' 
and trt.major_transfer_type_desc!='TRANSFER_OUT' 
and sub.contact_channel_id in ('Phone','Chat') 
and c.call_center_id in ('TPPL','ARMX','NCSL','24FR','24TB','24DV','24ML','TTBR','TLLV','SMBN','SMNL','TCLV','NCJP','TDSG')
and c.answered_cnt>0 
and c.cust_msg_cnt>=2 
and kb.page_load_cnt>0
and kb.application_id='padme'
and kb.article_id>0
and kb.fact_date between 20170401 and 20170630


-- Articles per Ticket
-- cust_msg_cnt>=2 t0 remove prank chats, voice assigned to 999
-- application_id in ('padme','csinternalkb'): padme = customer+agent, csinternalkb=agent

select avg(art.num_articles)
from
(select 
kb.ticket_code,
count(distinct article_id) num_articles
from   dse.cs_contact_f c 
join dse.geo_country_d geo on c.contact_origin_country_code = geo.country_iso_code 
join dse.cs_transfer_type_d trt on c.transfer_type_id = trt.transfer_type_id 
join dse.cs_contact_subchannel_d sub on c.contact_subchannel_id=sub.contact_subchannel_id 
join dse.cs_contact_skill_d sk on c.contact_skill_id=sk.contact_skill_id 
join dse.cs_kb_node_visit_f kb on c.first_ticket_id=kb.ticket_code
left join (select * from dse.cs_recontact_f 
     where days_to_recontact_cnt<=7 
     and fact_utc_date >= 20170401 ) rcr on c.contact_code = rcr.contact_code
where c.fact_utc_date between 20170401 and 20170630
and sk.escalation_code = 'No-Escalation' 
and trt.major_transfer_type_desc!='TRANSFER_OUT' 
and sub.contact_channel_id in ('Phone','Chat') 
and c.call_center_id in ('TPPL','ARMX','NCSL','24FR','24TB','24DV','24ML','TTBR','TLLV','SMBN','SMNL','TCLV','NCJP','TDSG')
and c.answered_cnt>0 
and c.cust_msg_cnt>=2 
and kb.page_load_cnt>0
and kb.application_id in ('padme','csinternalkb')
and kb.article_id>0
and kb.fact_date between 20170401 and 20170630
group by kb.ticket_code) art


-- Articles per Session

select avg(sess.articles_viewed)
from
(select session_id,
count(distinct article_id) articles_viewed
from dse.cs_kb_node_visit_f
where fact_date between 20170401 and 20170630
and page_load_cnt>0
and application_id='padme'
and node_id not in (-12345)
group by 1) sess


-- Searches per Ticket
-- those who perform at least one search per ticket 

select avg(search.num_searches)
from
(select 
kb.ticket_code,
sum(c.kb_search_cnt) num_searches
from dse.cs_contact_f c 
join dse.geo_country_d geo on c.contact_origin_country_code = geo.country_iso_code 
join dse.cs_transfer_type_d trt on c.transfer_type_id = trt.transfer_type_id 
join dse.cs_contact_subchannel_d sub on c.contact_subchannel_id=sub.contact_subchannel_id 
join dse.cs_contact_skill_d sk on c.contact_skill_id=sk.contact_skill_id 
join dse.cs_kb_node_visit_f kb on c.first_ticket_id=kb.ticket_code
left join (select * from dse.cs_recontact_f 
     where days_to_recontact_cnt<=7 
     and fact_utc_date >= 20170401 ) rcr on c.contact_code = rcr.contact_code
where c.fact_utc_date between 20170401 and 20170630
and sk.escalation_code = 'No-Escalation' 
and trt.major_transfer_type_desc!='TRANSFER_OUT' 
and sub.contact_channel_id in ('Phone','Chat') 
and c.call_center_id in ('TPPL','ARMX','NCSL','24FR','24TB','24DV','24ML','TTBR','TLLV','SMBN','SMNL','TCLV','NCJP','TDSG')
and c.answered_cnt>0 
and c.cust_msg_cnt>=2 
and kb.page_load_cnt>0
and kb.application_id in ('padme','csinternalkb')
and kb.article_id>0
and kb.fact_date between 20170401 and 20170630
and c.kb_search_cnt>0
group by kb.ticket_code) search
