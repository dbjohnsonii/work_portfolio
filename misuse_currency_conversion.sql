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
spo \\amscifs01\homefolders$\djohnson\Desktop\monthly_currency_average.txt
SELECT
ROUND(AVG(AVERAGE_RATE_USD),3)
,ROUND(AVG(AVERAGE_RATE_EUR),3)
,CURRENCY
,extract(year from CAST(DAY AS DATE)) 
,extract(month from CAST(DAY AS DATE)) 
FROM fdwo.mb_exchange_rates
WHERE DAY BETWEEN TO_DATE('1-5-2018','DD-MM-YYYY') AND TO_DATE('31-5-2018','DD-MM-YYYY')
GROUP BY CURRENCY,extract(year from CAST(DAY AS DATE)),extract(month from CAST(DAY AS DATE));
spo end
