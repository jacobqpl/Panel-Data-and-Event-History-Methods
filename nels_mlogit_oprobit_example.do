
/*******************************************************************************************/
/*** Program: nels_mlogit_oprobit_example.do                                             ***/
/*** Purpose: This program estimates a multinomial logit model of education attainment   ***/
/***          and an oredered probit model of job autonomy                               ***/
/*** Data used: NELS_88_00_BYF4STU_V1_0.dta                                              ***/
/*** Written by: Brian McCall                                                            ***/
/*** Last revised: 09-09-19                                                              ***/
/*******************************************************************************************/
capture clear
capture log close
set more off
local log_out  "/D:/EDUC771/Assignment1/Logs/"
local graphout  "/D:/EDUC771/Assignment1/Graphs/"
local data_in_out  "/D:/EDUC771/Assignment1\Data/"
#delimit ;
log using "`log_out'nels_mlogit_oprobit_example.log",replace;
use "`data_in_out'NELS_88_00_BYF4STU_V1_0.dta";
rename *,lower;
/*

/* Male */
gen byte male=f3sex==1;
label var male "1 if male";
label def  male_lb
0 "Female"  1 "Male";
label val male male_lb;
/* Race */
drop if f3race<0 | f3race==6;
label def f3race_lb
1 "API"
2 "Hispanic"
3 "Black, not Hispanic"
4 "White, not Hispanic"
5 "Native American";
label val f3race f3race_lb;
/* Mother's education */
drop if bys34b>=97;
label def bys34b_lb
1 "H.S. Dropout"
2 "H.S. Grad./GED"
3 "Junior College"
4 "College l.t. 4 years"
5 "BA/BS"
6 "MA/MS"
7 "Ph.D., M.D., etc."
8 "Don't know" ;
label val bys34b bys34b_lb;

drop if f4hstype<0 | f4hstype==.;
label def f4hstype_lb
1 "High school diploma"
2 "GED"
3 "Certificate of attendance"
4 "No diploma or equivalent";
label val f4hstype f4hstype_lb;

label def f4hhdg_lb
1 "Some PSE, no degree attained"
2 "Certificate/license"
3 "Associate's degree"
4 "Bachelor's degree"
5 "Master's degree/equivalent"
6 "Ph.D or a professional degree"
-3 "{Legitimate skip}"
-9 "{Missing}";
label val f4hhdg f4hhdg_lb;
/* Educational Attainment by 2000 */
gen educ_attain_2000=.;
replace educ_attain_2000=1 if f4hstype==3 | f4hstype ==4;
replace educ_attain_2000=2 if (f4hstype==1 | f4hstype==2) & f4hhdg<0;
replace educ_attain_2000=3 if (f4hstype==1 | f4hstype==2) & f4hhdg==1;
replace educ_attain_2000=4 if (f4hstype==1 | f4hstype==2) & (f4hhdg==2 | f4hhdg==3);
replace educ_attain_2000=5 if (f4hstype==1 | f4hstype==2) & f4hhdg==4 ;
replace educ_attain_2000=6 if (f4hstype==1 | f4hstype==2) & (f4hhdg==5 | f4hhdg==6);
label var educ_attain_2000 "Educational attainment by 2000";
label def educ_attain_2000_lb
1 "H.S. Dropout"
2 "H.S. Grad./GED"
3 "Some college/No degree"
4 "AA deg./Cert."
5 "BA deg."
6 "MA degree or higher";
label val educ_attain_2000 educ_attain_2000_lb;
/* Job autonomy */
drop if f4bjaut<0;
label def f4bjaut_lb
1  "Someone else decides what & how"
2  "Someone else decides what you decide how"
3  "You have some freedom in deciding"
4  "You are basically your own boss";
label val f4bjaut f4bjaut_lb;
/****************************************************************************************/
/*** Use c. & i. so Stata can keep track of continuous and categorical variables      ***/
/****************************************************************************************/

global x_var_1 "c.by2xmstd c.byses i.male i.f3race i.bys34b";

/****************************************************************************************/
/*** Estimate MNL                                                                     ***/
/****************************************************************************************/
mlogit educ_attain_2000 $x_var_1, baseoutcome(1);
/****************************************************************************************/
/*** Do multiple comparisons of race effects                                          ***/
/****************************************************************************************/

margins f3race,mcompare(bon) predict(outcome(1)) contrast;
margins f3race,mcompare(bon) predict(outcome(2)) contrast;
margins f3race,mcompare(bon) predict(outcome(3)) contrast;
margins f3race,mcompare(bon) predict(outcome(4)) contrast;
margins f3race,mcompare(bon) predict(outcome(5)) contrast;
margins f3race,mcompare(bon) predict(outcome(6)) contrast;

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(1));
/****************************************************************************************/
/*** Use marginsplot command to plot esimtated probabilities as a function of         ***/
/*** eighth grade standardized math score                                             ***/
/****************************************************************************************/
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("High School Dropout", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure1a.gph",replace); 

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(2));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("High School Graduate/GED", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure1b.gph",replace); 

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(3));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("AA Degree/License", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure1c.gph",replace); 

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(4));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("Some College", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure1d.gph",replace); 


margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(5));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("BA/BS Degree", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure1e.gph",replace); 

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(6));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("MA/MS Degree or more", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure1f.gph",replace); 

/****************************************************************************************/
/*** Combine graphs on one figure                                                     ***/
/****************************************************************************************/

graph combine  "`graphout'Figure1a.gph" "`graphout'Figure1b.gph" "`graphout'Figure1c.gph" "`graphout'Figure1d.gph"
"`graphout'Figure1e.gph" "`graphout'Figure1f.gph" 
,title("Educational Attainment by Mathematics standardized score" , size(small)  color("0 0 100"))
graphregion(fcolor(white)) 
note("Source: National Education Longitudinal Study of 1988.",size(vsmall) color("`graph_color'"))
saving("`graphout'Figure1_all.gph",replace); 
graph export "`graphout'Figure1_all.pdf",replace;
/****************************************************************************************/
/*** Add nonlinear polynomial terms for math test score using #                       ***/
/****************************************************************************************/

mlogit educ_attain_2000 c.by2xmstd c.by2xmstd#c.by2xmstd c.by2xmstd#c.by2xmstd#c.by2xmstd
        c.byses i.male i.f3race i.bys34b, baseoutcome(1);

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(1));
/****************************************************************************************/
/*** Use marginsplot command to plot esimtated probabilities as a function of         ***/
/*** eighth grade standardized math score                                             ***/
/****************************************************************************************/

marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("High School Dropout", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure2a.gph",replace); 

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(2));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("High School Graduate/GED", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure2b.gph",replace); 

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(3));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("AA Degree/License", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure2c.gph",replace); 

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(4));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("Some College", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure2d.gph",replace); 


margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(5));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("BA/BS Degree", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure2e.gph",replace); 

margins , at(by2xmstd=(40(5)70)) noatlegend predict(outcome(6));
marginsplot,
xtitle("Mathematics standardized score", size(small) color("`graph_color'"))  
ytitle("Probability", size(small) color("`graph_color'"))
title("MA/MS Degree or more", size(small) color("`graph_color'"))
ylabel(0(.1)0.5,labsize(vsmall) labcolor("`graph_color'")) 
xlabel(40(5)70,labsize(vsmall) labcolor("`graph_color'")) 
saving("`graphout'Figure2f.gph",replace); 

/****************************************************************************************/
/*** Combine graphs on one figure                                                     ***/
/****************************************************************************************/

graph combine  "`graphout'Figure2a.gph" "`graphout'Figure2b.gph" "`graphout'Figure2c.gph" "`graphout'Figure2d.gph"
"`graphout'Figure2e.gph" "`graphout'Figure2f.gph" 
,title("Educational Attainment by Mathematics standardized score" , size(small)  color("0 0 100"))
graphregion(fcolor(white)) 
note("Source: National Education Longitudinal Study of 1988.",size(vsmall) color("`graph_color'"))
saving("`graphout'Figure2_all.gph",replace); 
graph export "`graphout'Figure2_all.pdf",replace;

/****************************************************************************************/
/*** Interact math score with race variable                                           ***/
/****************************************************************************************/

global x_var_2 "c.by2xmstd c.byses i.male i.f3race i.bys34b c.by2xmstd#i.f3race";

mlogit educ_attain_2000 $x_var_2, baseoutcome(1);
/****************************************************************************************/
/*** Marginal effects by race                                                         ***/
/****************************************************************************************/

margins f3race,mcompare(bon) predict(outcome(1)) contrast;
margins f3race,mcompare(bon) predict(outcome(2)) contrast;
margins f3race,mcompare(bon) predict(outcome(3)) contrast;
margins f3race,mcompare(bon) predict(outcome(4)) contrast;
margins f3race,mcompare(bon) predict(outcome(5)) contrast;
margins f3race,mcompare(bon) predict(outcome(6)) contrast;

/****************************************************************************************/
/*** Marginal effects of math score                                                   ***/
/****************************************************************************************/

margins , dydx(by2xmstd) predict(outcome(1));
margins , dydx(by2xmstd) predict(outcome(2));
margins , dydx(by2xmstd) predict(outcome(3));
margins , dydx(by2xmstd) predict(outcome(4));
margins , dydx(by2xmstd) predict(outcome(5));
margins , dydx(by2xmstd) predict(outcome(6));

/****************************************************************************************/
/*** Differences in marginal effects of math by race                                  ***/
/****************************************************************************************/

margins f3race,mcompare(bon) dydx(by2xmstd) predict(outcome(1)) contrast;
margins f3race,mcompare(bon) dydx(by2xmstd) predict(outcome(2)) contrast;
margins f3race,mcompare(bon) dydx(by2xmstd) predict(outcome(3)) contrast;
margins f3race,mcompare(bon) dydx(by2xmstd) predict(outcome(4)) contrast;
margins f3race,mcompare(bon) dydx(by2xmstd) predict(outcome(5)) contrast;
margins f3race,mcompare(bon) dydx(by2xmstd) predict(outcome(6)) contrast;

global x_var_2 "c.by2xmstd c.byses i.male i.f3race i.educ_attain_2000";

/****************************************************************************************/
/*** Estimate Ordered Probit for Job Autonomy                                         ***/
/****************************************************************************************/
oprobit f4bjaut $x_var_2;
margins f3race,mcompare(bon) predict(outcome(1)) contrast;
margins f3race,mcompare(bon) predict(outcome(2)) contrast;
margins f3race,mcompare(bon) predict(outcome(3)) contrast;
margins f3race,mcompare(bon) predict(outcome(4)) contrast;

log close;
