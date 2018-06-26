sqlplus/nolog
connect djohnson/Kirky2016!@ODSPEU1.ams
set echo off
set feedback off
set colsep ';'
set sqlprompt ''
set headsep off
set serveroutput on size unlimited
set linesize 30000
set trimspool on
set pagesize 0
set heading on
set trimout on
set wrap off
set termout off
spo U:\Desktop\aib_comp_pull_aib_data_sf.txt
SELECT 
ab.contract_id
,ab.issuer_country
,ab.clearing_country_name
,ab.interchange_region
,bn.clas_plat
,ab.card_brand
--,ab.issuer_bin
,ab.SF_RATE_DESCRIPTION
,CASE WHEN ab.security_level='Not relevant' THEN 'NON-SECURE' 
WHEN ab.security_level='Channel encrypted' THEN 'NON-SECURE'
WHEN ab.security_level='Not authenticated security transaction at a merchant who supports MasterCard SecureCode - UCAF' THEN 'NON-SECURE' 
WHEN ab.security_level='Not authenticated security transaction at a merchant who supports Verified-by-VISA - 3D-Secure' THEN 'NON-SECURE'
ELSE 'SECURE' END AS SECURITY_LEVEL
,AVG(SF_RATE_AMOUNT) AS SF_RATE_AMOUNT
,AVG(SF_RATE_PERC) AS SF_RATE_PERC
,ROUND(ab.transaction_flow_eur,0) AS FLOW
,CASE WHEN ROUND(ab.transaction_flow_eur)=0 THEN 0 WHEN ROUND(ab.transaction_flow_eur)>0 THEN AVG(ABS(ab.SCHEME_FEE_EUR))/ROUND(ab.transaction_flow_eur)END AS "SF_BPS"
,CASE WHEN ab.card_type_group LIKE '%Debit%' THEN 'Debit' WHEN ab.card_type_group LIKE '%Credit%' THEN 'Credit' WHEN ab.card_type_group LIKE '%Prepaid%' THEN 'Prepaid' END AS "CREDIT_DEBIT" 
,CASE WHEN ab.card_type_group LIKE '%Consumer%' THEN 'Consumer' WHEN ab.card_type_group LIKE '%Commercial%' THEN 'Commercial' END AS "CON_COM_BIN"
FROM fdwo.acquirer_aib_newgen_files ab
LEFT JOIN
    (select fdwo.mb_bin_table_full.bin,fdwo.mb_bin_table_full.clas_plat from fdwo.mb_bin_table_full 
    group by fdwo.mb_bin_table_full.bin,fdwo.mb_bin_table_full.clas_plat) bn
ON ab.issuer_bin=bn.bin
WHERE (ab.transaction_date) BETWEEN TO_DATE('02-01-2018','MM-DD-YYYY') AND TO_DATE('05-31-2018','MM-DD-YYYY')
AND ab.contract_id IN(5859,9391,4074,2201,2520,6891,9346,3195,2206,9411,8665,1946,9348,8966,9522,8970,1837
      ,9513,9415,7793,9226,8663,4878,3002,2160,9527,9524,2095,9416,4004,9511,5983,3063,9458
      ,9515,9528,4075,9510,9418,8953,2791,6886,3877,9514,9512,9455,2346,2165,2792,8968,9525
      ,9526,5405,9225)
AND PROCESSING_STATUS='Processed'
AND ab.scheme_fee_eur!=0
AND ab.transaction_type='Sale'
AND bn.clas_plat IS NOT NULL
--AND ab.interchange_region='Domestic'
GROUP BY 
ab.contract_id
,ab.issuer_country
,ab.card_brand
--,ab.issuer_bin
,ab.clearing_country_name
,ab.interchange_region
,ab.SF_RATE_DESCRIPTION
,ab.security_level
,ab.transaction_flow_eur
,ab.card_type_group
,bn.clas_plat;
spool off end