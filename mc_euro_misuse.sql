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
spo \\amscifs01\homefolders$\djohnson\Desktop\mc_euro_misuse.csv
SELECT 
extract(month from CAST(pa.statusdate AS DATE))
,extract(year from CAST(pa.statusdate AS DATE))
,pa.orderid,pa.merchantid,m.merchantname,pa.amount,pa.currencycode,pa.statusid
,pa.paymentproductid,pa.paymentmethodid,co.paymentprocessor
,co.creditcardcompany,co.countrycode,co.IIN,invoice_currency
,serviceaccountname
,cc.icplus_type,interchange_region
FROM eps.opr_paymentattempt pa
LEFT JOIN eps.pco_creditcardonline co
ON pa.MERCHANTID=co.MERCHANTID
AND pa.ORDERID=co.ORDERID
AND PA.ATTEMPTID=CO.ATTEMPTID
AND pa.statusdate=co.authorisationdatetime
AND pa.amount=co.amount
LEFT JOIN eps.mrm_merchant m
ON pa.MERCHANTID=m.MERCHANTID
LEFT JOIN FDWO.MB_PAYMENTPROCESSOR pp
ON co.PAYMENTPROCESSOR=pp.paymentprocessor_id
LEFT JOIN 
(SELECT paymentprocessornumber,
        CASE WHEN SERVICEACCOUNTNAME LIKE '%AIB%' then 'AIB'
        WHEN SERVICEACCOUNTNAME LIKE '%Barclays%' then 'Barclays'
        WHEN SERVICEACCOUNTNAME LIKE '%Euroline%' then 'Bambora'
        WHEN SERVICEACCOUNTNAME LIKE '%EuroConex%' then 'Elavon'
        ELSE SERVICEACCOUNTNAME
        END AS "SERVICEACCOUNTNAME" 
FROM EPS.GPM_SERVICEACCOUNT
group by paymentprocessornumber,SERVICEACCOUNTNAME)sa
ON CO.PAYMENTPROCESSOR=SA.PAYMENTPROCESSORNUMBER
LEFT JOIN 
(SELECT 
    contract_id,payment_processor_nr,transaction_currency,bin,icplus_type,invoice_currency
    FROM fdwo.cc_processing_data_pt
    WHERE MATCH_DATE BETWEEN TO_DATE('4/1/2018','MM/DD/YYYY') AND TO_DATE('4/30/2018','MM/DD/YYYY')
    AND TRANSACTION_TYPE='TRANSACTION'
    AND INVOICE_CURRENCY IS NOT NULL
    AND TRADING_REVENUE IS NOT NULL
    group by contract_id,payment_processor_nr,transaction_currency,icplus_type,bin,invoice_currency) cc
ON CO.PAYMENTPROCESSOR=cc.payment_processor_nr
AND PA.CONTRACTID=cc.contract_id
AND pa.currencycode=cc.transaction_currency
AND co.IIN=cc.BIN
WHERE pa.statusdate BETWEEN TO_DATE('4/1/2018','MM/DD/YYYY') AND TO_DATE('4/30/2018','MM/DD/YYYY')
AND pa.statusid in (525,600)
and paymentproductid=3
and pp.interchange_region IN('Europe','EMEA')
and icplus_type IS NOT NULL -- DO NOT INCLUDE ANY INFORMATION WHERE AN IC PLUS TYPE COULD NOT BE LOCATED
group by
statusdate ,pa.orderid,pa.merchantid,m.merchantname,pa.amount,pa.currencycode
,pa.statusid,pa.paymentproductid,pa.paymentmethodid,co.paymentprocessor,co.IIN,invoice_currency
,serviceaccountname,co.creditcardcompany,co.countrycode,serviceaccountname,cc.icplus_type,interchange_region;
spo end