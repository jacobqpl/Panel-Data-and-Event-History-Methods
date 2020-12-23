/* Decision points:
   year0: before entering college 
   year1: before returning for the 2nd year 
   year2: before returning for the 3rd year 
   year3: before returning for the 4th year */

/* sequence: 
   enrollment decision
   course taking pattern
   graduation check */

*cd "/Users/yiranchen/Desktop"

capture mkdir "C:\Users\Yiran\Desktop\771 simulation"
cd "C:\Users\Yiran\Desktop\771 simulation"

clear
global DIV 3
global N_TERM = 4*$DIV

//---------------------------------------------
// Program for making enrollment decisions
//---------------------------------------------

capture program drop ENROLL
program ENROLL
	args y

	use "students", clear
	capture gen cum_cr_com = 0
	
	if `y' >= 1 {
		local y0 = `y' - 1
		merge 1:1 stu_id using "graduated, year `y'", nogen keep(3) keepusing(graduated)
		drop if graduated == 1
		merge 1:1 stu_id using "stay decision at time `y0'", nogen keepusing(chance) update replace
		merge 1:1 stu_id using "year`y' stu", nogen keep(1 3) keepusing(qp_coef cr_com)
		replace chance = chance * qp_coef
		replace cum_cr_com = cum_cr_com + cr_com
		drop qp_coef cr_com
	}

	replace chance = 0.9999 if chance > 0.9999 & !missing(chance)
	replace chance = 0 if chance < 0

	// benefit if leave
	gen sum_benefit_leave = HS_wage*(55*$DIV-`y')

	// benefit if stay
	gen sum_wage_BA = BA_wage*((55-4)*$DIV-`y') * chance
	gen sum_cost =   -437.5*(120-cum_cr_com)
	gen sum_benefit_stay = sum_wage_BA + sum_cost

	// stay decision
	gen stay_y`y' = sum_benefit_stay > sum_benefit_leave & !missing(sum_benefit_stay)
	save "stay decision at time `y'", replace
end

//---------------------------------------------
// Program for determining course taking pattern
//---------------------------------------------
capture program drop COURSE
program COURSE
	args y

	use stu_id ability* using "students", clear
	
	local y0 = `y'-1
	merge 1:1 stu_id using "stay decision at time `y0'", nogen keepusing(stay_y`y0')
	keep if stay_y`y0' == 1
	drop stay_y`y0'

	gen target_cr = floor(runiform(3,55/$DIV))
	expand 10
	sort stu_id
	bysort stu_id: gen course_id = _n
	gen credits = floor(runiform(2,6))

	bysort stu_id: gen tot_cr = credits[1]
	bysort stu_id: replace tot_cr = credits[_n] + tot_cr[_n-1] if _n>1
	replace credits = credits - (tot_cr - target_cr) if tot_cr > target_cr
	drop if credits <= 0

	// determine the grade of each course
	gen grade = rbinomial(4, ability_logit)
	label define grade 4 "A" 3 "B" 2 "C" 1 "D" 0 "F"
	label value grade grade
	gen year = `y'
	gen cr_att = credits
	gen cr_com = cr_att * (grade > 0)
	gen qp = credits * grade
	drop credits tot_cr target_cr ability*
	save "year`y' course", replace

	// collapse: course-term lv -> student-term level
	use "year`y' course", clear
	collapse (sum) cr_att cr_com qp, by(stu_id year)
	gen qp_coef = qp/(30/$DIV*2)   // goal: 30 credits * 2.0 GPA
	save "year`y' stu", replace
	
end

//---------------------------------------------
// Program for determine whether one graduated
//---------------------------------------------
capture program drop GRADUATE
program GRADUATE
	args y
	
	clear
	quietly forvalues i = 1/`y' {
		append using "year`i' course.dta"
	}

	collapse (sum) cr_com cr_att qp, by(stu_id)
	gen gpa = qp / cr_att

	gen graduated = (cr_com >= 120 & gpa >= 2.0)
	save "graduated, year `y'", replace
end


//---------------------------------------------
// create individuals
//---------------------------------------------
set seed 191121
set obs 10000
gen stu_id = _n

// generate ability indicator
gen ability = exp(rnormal())
gen ability_logit = ability / (1+ability)

// wage is determined by ability (712 & 1173 = weekly median wage)
sum ability
gen HS_wage = (ability/r(mean) * rnormal(1,0.3)) *  712*52/$DIV 
gen BA_wage = (ability/r(mean) * rnormal(1,0.3)) * 1173*52/$DIV
replace HS_wage = 0 if HS_wage < 0
replace BA_wage = 0 if BA_wage < 0


// self-percived chance before enrollment
gen chance = ability_logit * rnormal(2,0.5)

save "students", replace

//---------------------------------------------
// Run the simulation
//---------------------------------------------
ENROLL 0

forvalues i = 1/$N_TERM {
	COURSE `i'
	GRADUATE `i'
	ENROLL `i'
}

//---------------------------------------------
// Assemble the results 
//---------------------------------------------

// transcript
clear
quietly forvalue i = 1/$N_TERM {
	append using "year`i' course.dta"
	erase "year`i' course.dta"
}
order stu_id year course_id, first
sort stu_id year course_id
save "transcript", replace

// cumulative quality points
use "transcript", clear
collapse (sum) qp cr_att cr_com, by(stu_id year)
gen gpa = qp / cr_att

foreach x of varlist qp cr_att cr_com {
	gen cum_`x' = `x'
	bysort stu_id (year): replace cum_`x' = cum_`x' + cum_`x'[_n-1] if _n>1
}
gen cum_gpa = cum_qp / cum_cr_att

gen graduated = (cum_cr_com >= 120) & (cum_gpa >= 2.0)
save "student by term outcome", replace

use "students", clear
expand $N_TERM
bysort stu_id: gen year = _n
merge 1:1 stu_id year using "student by term outcome", nogen

bysort stu_id: egen cr_att_tot = sum(cr_att)
drop if cr_att_tot == 0
drop cr_att_tot
codebook, compact
save "analytical sample", replace

//---------------------------------------------
// Survival Analysis
//---------------------------------------------
use "analytical sample", clear
drop ability ability_logit HS_wage BA_wage chance

gen event = 1
replace event = 3 if missing(qp[_n+1])
replace event = 2 if graduated == 1

label define event 1 "in college" 2 "graduated" 3 "dropout"
label value event event

stset year, id(stu_id) failure(event == 3) exit(event == 2 3)
stdescribe
list in 1/30, sepby(stu_id)
sts graph, saving(time)

stset cum_qp, id(stu_id) failure(event == 3) exit(event == 2 3)
stdescribe
list in 1/30, sepby(stu_id)
sts graph, saving(qp)

graph combine time.gph qp.gph, xsize(20) ysize(10)
