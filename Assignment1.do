****Assignment 1 *****
**Created by Peilin Qiu**
**Date: 09/11/2019**

set maxvar 32000
use "D:\EDUC 771\Data\NELS\NELS_88_00_BYF4STU_V1_0.dta"
rename *,lower;

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

