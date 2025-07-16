import excel using "D:\WORK SPACE\Siyu Lin\Raw Data\FIN_Audit1.xlsx", firstrow clear

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