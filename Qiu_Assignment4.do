****EDUC 771 Assignment 4*****
capture clear all
use "D:\EDUC771\Assignment4\nlsy79_college_data_2.dta"
set matsize 3200

stset coll_4yr_spell_1, failure(censor_ba_1) id(pubid)
stdescribe
sts list

**************Question 1*****************
*a
sts graph

*b
stcox i.race mom_educ_97_miss mom_educ_97_hs mom_educ_97_sc mom_educ_97_ba hs_gpa key_sex physics calculus

testparm mom_educ_97_miss mom_educ_97_hs mom_educ_97_sc mom_educ_97_ba

*c
estat phtest
estat phtest, detail


*d
linktest

*e
predict cs, csnell
stset cs, failure(censor_ba_1) 
sts gen H=na
line H cs cs, sort xlab(0 1 to 4) ylab(0 1 to 4)

*f
stcox i.race mom_educ_97_miss mom_educ_97_hs mom_educ_97_sc mom_educ_97_ba hs_gpa key_sex physics calculus, nohr nolog noshow tvc(i.race mom_educ_97_miss mom_educ_97_hs mom_educ_97_sc mom_educ_97_ba hs_gpa key_sex physics calculus) texp(ln(_t))
test [tvc]


**************Question 2*****************

*a, b, and c
streg i.race mom_educ_97_miss mom_educ_97_hs mom_educ_97_sc mom_educ_97_ba hs_gpa key_sex physics calculus, distribution(weibull) frailty(gamma)
stcurve, hazard unconditional
stcurve, hazard alpha1
stcurve, hazard 


*d
margins race,contrast
margins race
margins race,pwcompare

**************Question 3*****************

*a, b, and c
streg i.race mom_educ_97_miss mom_educ_97_hs mom_educ_97_sc mom_educ_97_ba hs_gpa key_sex physics calculus, distribution(lognormal) frailty(gamma)
stcurve, hazard unconditional
stcurve, hazard alpha1
stcurve, hazard 

*d
margins race,contrast
margins race
margins race,pwcompare








