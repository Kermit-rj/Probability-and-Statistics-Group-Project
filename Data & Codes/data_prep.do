***************************************************************
*define work directory 
cd "D:\OD_20190729\Courses\概率论与数理统计\Individual Project\"
***************************************************************

***************************************************************
*import data file from the work directory
import excel using "FIN_Audit1.xlsx", firstrow clear

*clean the auditor name
gen auditor_name = subinstr(Dadtunit_en," Co., Ltd.","",.)
**Big8 in China include: PricewaterhouseCoopers, Deloitte,Ruihua, Ernst & Young, BDO China Shu Lun Pan,
**KPMG, WUYIGE, Pan-China  

*generate big8 dummy
gen big8 =  strpos(auditor_name, "PricewaterhouseCoopers") > 0
replace big8 =  strpos(auditor_name, "Deloitte") > 0 if big8 == 0
replace big8 =  strpos(auditor_name, "Ruihua") > 0 if big8 == 0
replace big8 =  strpos(auditor_name, "Ernst & Young") > 0 if big8 == 0
replace big8 =  strpos(auditor_name, "BDO China Shu Lun Pan") > 0 if big8 == 0
replace big8 =  strpos(auditor_name, "KPMG") > 0 if big8 == 0
replace big8 =  strpos(auditor_name, "WUYIGE") > 0 if big8 == 0
replace big8 =  strpos(auditor_name, "Pan-China") > 0 if big8 == 0
tab big8

*Add label to the variable big8
label var big8 "Audited by top 8 Accounting Firms in China"

gen Audit_Opinion = strpos(Audittyp_en, "Standard") > 0
label var Audit_Opinion "Standard vs. nonstandard opinions"

*Sort the sample by firm and year
sort Stkcd Accper

*Generate year and month
gen year = real(substr(Accper,1,4))
gen month = real(substr(Accper,6,2))

*keep only year end observations
drop if month == 6

*drop duplicated firm-year observations
bys Stkcd year: gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

*keep only needed variables
keep Stkcd Accper year big8 TotalAuditFees Audit_Opinion

*save data to a '.dta' file into the work directory 
save FIN_Audit, replace
***************************************************************

***************************************************************
*import balance sheet file from the work directory
import excel using "FS_Combas1.xlsx", firstrow clear

*Generate year and month
sort Stkcd Accper
tab StatementType 
gen year = real(substr(Accper,1,4))
gen month = real(substr(Accper,6,2))

*keep year-end consolidated observation only
keep if StatementType == "A" & month == 12

*drop duplicated firm-year observations
bys Stkcd year: gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

*calculate needed ratios
gen Debt_to_Equity = TotalLiabilities/TotalShareholdersEquity
gen Current_ratio = TotalCurrentAssets/TotalAssets

*keep necessary variables only
keep Stkcd Accper year TotalAssets Debt_to_Equity Current_ratio 

*save data to a '.dta' file into the work directory 
save Fin_Combas, replace
***************************************************************

***************************************************************
*merge two data file together based on common firm id and year
use Fin_Combas, clear
merge 1:1 Stkcd year using FIN_Audit

*keep matched sample only
keep if _merge == 3
drop _merge

*generate a numerical company id for regression purpose
gen Stkcd1 = real(Stkcd)

*save data to a '.dta' file into the work directory 
save Audit_Combas_data, replace
***************************************************************
