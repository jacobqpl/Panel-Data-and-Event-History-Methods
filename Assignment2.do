*****Assignment2 Part 1****
use "D:\EDUC771\Assignment2\elem94_95.dta"
browse
des
sum
codebook bs

***Question 1
sum distid
sum schid // the total number of school is 1848.
egen Counter = count(schid), by (distid)
sum Counter // the Maximum value of Counter is 162
order Counter
sort Counter
sum Counter if Counter==1
sum distid if Counter==1

ssc inst unique
unique Counter // the number of unique values of Counter is 24.
unique distid // the number of unique values of distid is 537
dis 1848/537 // the result is 3.44

***Question 2 and Question 3
ssc inst outreg2
rvfplot 
reg lavgsal bs lenrol lstaff lunch
reg lavgsal bs lenrol lstaff lunch, r //It is ok to not add robust option.
outreg2 using "Table1.doc", replace ctitle("nocluster")

reg lavgsal bs lenrol lstaff lunch, vce(cluster distid)
outreg2 using Table1.doc, append ctitle(cluster)

***Question 4
drop if bs > 0.5 //(4 observations deleted)
reg lavgsal bs lenrol lstaff lunch, vce(cluster distid)
outreg2 using Table1.doc, append ctitle(cluster2)  //nothing changed


***Question 5 // xtreg //删掉下面两行
xtset distid
xtreg lavgsal bs lenrol lstaff lunch, fe
outreg2 using Table1.doc, append ctitle(xtreg)


*****Assignment2 Part 2****
use "D:\EDUC771\Assignment2\mathpnl.dta"
browse
des
sum
codebook bs

*Question 1
codebook rexpp
reg math4 lenrol lunch lexpp
outreg2 using "XTTable1.doc", replace ctitle("1")

*Question 2
reg math4 lenrol lunch lexpp i.year
outreg2 using XTTable1.doc, append ctitle(timeFE)

*Question 3
xtset distid
set matsize 3200 
xtreg math4 lenrol lunch lexpp i.year, re 
estimate store random
outreg2 using XTTable1.doc, append ctitle(time&distidRE)

*Question 4
xtreg math4 lenrol lunch lexpp i.year, fe
estimate store fixed
outreg2 using XTTable1.doc, append ctitle(time&distidFE)

*Question 5
help hausman
hausman fixed random
