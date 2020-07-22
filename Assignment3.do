****Assignment 3****
***Created by Peilin Qiu***
capture clear all
use "D:\EDUC771\Assignment3\nlsy79_college_data_2.dta"
set matsize 3200

********Dataset Statement******
stset coll_4yr_spell_1, failure(censor_ba_1)
stdescribe
sts list

********Data Cleaning********

*Time Variable
codebook coll_4yr_spell_1 // Four-year College Spell 1
sum coll_4yr_spell_1 

*Censor Variable
codebook censor_ba_1 
sum censor_ba_1  //the student completed the BA (censor_ba_1=1)
                 // was right-censored (censor_ba_1=0) 
	//In this case, the independent variable contains only two values, the 
	  //first value is 1 (completed the BA), another value is 0 (right-censored)

*Control Variable				 
codebook race
sum race

codebook dad_educ_97_miss 

codebook dad_educ_97_hs 

codebook dad_educ_97_sc 

codebook dad_educ_97_ba

codebook hs_gpa
sum hs_gpa

codebook key_sex //1: male,  2: female

***Basic Knowledge for Event History Analysis****

//1. The dependent variable measures the duration of time that units
    //spend in a state before experiencing some event.

//2. Right-censored:Units not experiencing an event by the time of the last observation
	//are known as “right censored” observations because the history
	//subsequent to the last time it was observed is unknown.
	//右删失(Right Censoring)：只知道实际寿命大于某数.

//3. Hazard Function: 风险函数 h(t)=f(t)/S(t)
    //其中，f(t)是指 CDF, 概率密度函数; F（t）是分布函数； f(t)=△F（t）/△t
	//S(t)是指survival function， 生存函数 
	//S(t)=1-F(t)
	
//4. Spell: （持续的）一段时间。 i=1,2,...,N

//5. The expected duration, E（T）

//6. The length of time from either the date of diagnosis or the start of treatment
	//for a disease, such as cancer, that half of the patients in a group of patients 
	//diagnosed with the disease are still alive. In a clinical trial, measuring the median
	//survival is one way to see how well a new treatment works. Also called median overall survival.

***Question Set 1***
*(a)
global cvar "i.race dad_educ_97_miss dad_educ_97_hs dad_educ_97_sc dad_educ_97_ba hs_gpa i.key_sex"
streg $cvar, distribution(weibull) 
streg $cvar, distribution(weibull) nohr

testparm  dad_educ_97_miss dad_educ_97_hs dad_educ_97_sc dad_educ_97_ba

*(b)
stcurve, hazard
sts graph

**calculate the z value
display (4.6195-1)/0.1257 //the result is 28.79
//the z value is 28.79 and greater than 2.33

*(c)


***Question Set 2***
*(a)
streg $cvar, distribution(ggamma)

test [kappa]=1

*(b)
testparm dad_educ_97_miss dad_educ_97_hs dad_educ_97_sc dad_educ_97_ba
  
*(c)
testparm i.race

/* 
    testparm provides a useful alternative to test that permits varlist rather than a list of coefficients (which is
    often nothing more than a list of variables), allowing the use of standard Stata notation, including '-' and
    '*', which are given the expression interpretation by test.
*/


*(d)

***Question Set 3***
streg $cvar i.race#c.hs_gpa, distribution(ggamma)

testparm i.race#c.hs_gpa


问题如下：
1. 要不要加Missing的father education
2. 什么是baseline hazard， 如何对其test?
3. 如何解释average median duration between male and female
4. generalized gamma distribution 比 Weibull distrubution好在哪？ 

