* this script sets up the PODES panel


* set working directory - important for portability
do set_working_directory.do

local ofile="podes_all_yearly_70p.dta"

do podes/merge_podes_by_waves_1996_2000.do .7
do podes/merge_podes_by_waves_2000_2003.do .7
do podes/merge_podes_by_waves_2003_2005.do .7
do podes/merge_podes_by_waves_2005_2008.do .7
do podes/merge_podes_by_waves_2008_2011.do .7

/*
do podes/merge_podes_by_waves_1996_2000.do .8
do podes/merge_podes_by_waves_2000_2003.do .7
do podes/merge_podes_by_waves_2003_2005.do .63
do podes/merge_podes_by_waves_2005_2008.do 0.001
do podes/merge_podes_by_waves_2008_2011.do .6340
*/


use ../../data/podes_matched_2008_2011.dta, clear

keep strid11 strid08
duplicates drop strid11, force 

preserve
	use ../../data/podes_matched_2005_2008.dta, clear
	keep strid08 strid05
	duplicates drop strid08, force 
	tempfile ids08
	save `ids08'
restore

merge m:1 strid08 using `ids08', gen(merge08) 


preserve
	use ../../data/podes_matched_2003_2005.dta, clear
	keep strid05 strid03
	duplicates drop strid05, force 
	tempfile ids05
	save `ids05'
restore

merge m:1 strid05 using `ids05', gen(merge05)


preserve
	use ../../data/podes_matched_2000_2003.dta, clear
	keep strid03 strid00
	duplicates drop strid03, force 
	tempfile ids03
	save `ids03'
restore

merge m:1 strid03 using `ids03', gen(merge03)



preserve
	use ../../data/podes_matched_1996_2000.dta, clear
	keep strid00 strid96
	duplicates drop strid00, force 
	tempfile ids00
	save `ids00'
restore

merge m:1 strid00 using `ids00', gen(merge00) 


gen merge_share=0
foreach v of varlist merge08 merge05 merge03 merge00 {

	replace merge_share=merge_share+1 if `v'==3

}

* 96/00 file kötése a bottleneck, az nagyon el van baszva
keep if merge_share==4
drop merge08 merge05 merge03 merge00 merge_share
*strid11 strid05 strid00

preserve
	use ../../data/podes_matched_2008_2011.dta, clear
	*keep strid05 strid03
	duplicates drop strid11, force 
	tempfile wave3
	save `wave3'
restore

preserve
	use ../../data/podes_matched_2003_2005.dta, clear
	*keep strid05 strid03
	duplicates drop strid05, force 
	tempfile wave2
	save `wave2'
restore

preserve
	use ../../data/podes_matched_1996_2000.dta, clear
	*keep strid05 strid03
	duplicates drop strid00, force 
	tempfile wave1
	save `wave1'
restore

merge 1:1 strid11 using `wave3', gen(w3)
merge m:1 strid05 using `wave2', gen(w2)
merge m:1 strid00 using `wave1', gen(w1)

keep if w1==3

save ../../data/`ofile'
