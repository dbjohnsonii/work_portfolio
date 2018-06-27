sqlplus/nolog
connect djohnson/RhiBoo02!@ODSPEU1.ams
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
spo \\amscifs01\homefolders$\djohnson\Desktop\aib_comp_pull_bb_data.csv
select 
t1.transaction_ref
,t1.additional_ref_2
,t2.paymentreference
,t1.bambora_transaction_type
,t1.merchant_mcc
,t1.contract_id
,t2.iin
,t3.clas_plat
,t2.orderid
,t2.paymentprocessor
,t1.MONTH
,t1.DAY
,t1.YEAR
,t1.PERIOD
,t1.issuer_country_name
,t1.MERCHANT_COUNTRY_NAME
,t1.TRANSACTION_TYPE
,t1.CARD_SCHEME
,t1.CREDIT_DEBIT
,t1.CONSUMER_CORPORATE
,t1.ECOM_SECURITY_LEVEL
,t1.REGIONALITY
,t1.PRODUCT_CODE
,t1.SF_FIXED_FEE
,t1.SF_PERC_FEE
,t1.CON_COM_BIN
,t1.VOLUME
,t1.ROUNDED_TRXN_AMOUNT
,t1.SCHEME_TOTAL_FEE_EUR
,t1.TRANSACTION_AMOUNT_EUR
,t1.INTERCHANGE_TOTAL_FEE_EUR
,t1.IC_BPS
,t1.SF_BPS
from
  (select 
   bb.transaction_ref
  ,bb.additional_ref_2
  ,bb.bambora_transaction_type
  ,bb.merchant_mcc
  ,bb.contract_id
  ,to_char(bb.SETTLEMENT_DATE,'MM') AS MONTH
  ,to_char(bb.SETTLEMENT_DATE,'DD') AS DAY
  ,to_char(bb.SETTLEMENT_DATE,'YYYY') AS YEAR
  ,to_char(bb.SETTLEMENT_DATE,'YYYY-MM') AS PERIOD
  ,bb.issuer_country_name
  ,bb.MERCHANT_COUNTRY_NAME
  ,bb.TRANSACTION_TYPE
  ,bb.CARD_SCHEME
  ,bb.CREDIT_DEBIT
  ,bb.CONSUMER_CORPORATE
  ,bb.ECOM_SECURITY_LEVEL
  ,bb.REGIONALITY
  ,bb.PRODUCT_CODE
  ,bb.SF_FIXED_FEE
  ,bb.SF_PERC_FEE
  ,bb.CONSUMER_CORPORATE AS CON_COM_BIN
  ,bb.VOLUME
  ,ROUND(bb.TRANSACTION_AMOUNT_EUR) AS ROUNDED_TRXN_AMOUNT
  ,bb.SCHEME_TOTAL_FEE_EUR
  ,bb.TRANSACTION_AMOUNT_EUR
  ,bb.INTERCHANGE_TOTAL_FEE_EUR
  ,bb.INTERCHANGE_TOTAL_FEE_EUR/bb.TRANSACTION_AMOUNT_EUR AS IC_BPS
  ,bb.SCHEME_TOTAL_FEE_EUR/bb.TRANSACTION_AMOUNT_EUR AS SF_BPS
  from fdwo.acquirer_bambora_cost bb
  where bb.settlement_date between to_date('01-01-2018','MM-DD-YYYY') and to_date('04-30-2018','MM-DD-YYYY')
  and bb.additional_ref_2 not in('0')
  and bb.bambora_transaction_type='Sale') t1
left join 
   (select eps.opr_paymentattempt.orderid,
       eps.opr_paymentattempt.effortid,
       eps.opr_paymentattempt.attemptid,
       eps.opr_paymentattempt.statusid,
       eps.opr_paymentattempt.statusdate,
       eps.pco_creditcardonline.paymentprocessor,
       eps.opr_paymentattempt.paymentreference,
       eps.opr_paymentattempt.merchantid,
       eps.opr_paymentattempt.amount,
       eps.pco_creditcardonline.iin,
       eps.pco_creditcardonline.authorisationcode,
       eps.pco_creditcardonline.terminalid	
  from eps.opr_paymentattempt
  left join eps.pco_creditcardonline
  on eps.opr_paymentattempt.orderid=eps.pco_creditcardonline.orderid
  and eps.opr_paymentattempt.merchantid=eps.pco_creditcardonline.merchantid
  and eps.opr_paymentattempt.attemptid=eps.pco_creditcardonline.attemptid
  and eps.opr_paymentattempt.requestamount=eps.pco_creditcardonline.amount
  and eps.opr_paymentattempt.creditdebitindicator=eps.pco_creditcardonline.creditdebitindicator
  where eps.opr_paymentattempt.statusid=1050) t2
  on t1.contract_id=t2.merchantid
  and t1.additional_ref_2=t2.paymentreference
left join
	(select fdwo.mb_bin_table_full.bin,fdwo.mb_bin_table_full.clas_plat from fdwo.mb_bin_table_full 
	group by fdwo.mb_bin_table_full.bin,fdwo.mb_bin_table_full.clas_plat) t3
	on t2.iin=t3.bin
where t3.clas_plat IS NOT NULL;
spo end