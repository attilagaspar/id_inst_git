* this code creates variables that describe the place of women in society from the DHS

* set working directory - important for portability
do set_working_directory.do

use "../../data/raw/DHS/2012/IDIR63FL.DTA" , clear
keep v739 v743a v743b v743c v743d v743e v743f v744a v744b v744c v744d v744e v745a v745b v746  v024 v005 sregmun

gen bps_2012= 100*v024+sregmun
gen beating = 0
foreach v of varlist v744* {

	replace beating = beating + 1 if `v'==1
	replace beating = beating + 0.5 if `v'==8

}


foreach v of varlist v743* {

	replace beating = beating + 1 if `v'==4 //has no say in...
	
}


rename v005 weight

replace beating = beating*weight

collapse (sum) beating weight, by(bps_2012)
replace beating = beating / weight
gen year=2012

save "../../data/DHS/2012.dta", replace

use "../../data/raw/DHS/2002/individual recode/IDIR42FL.DTA" , clear

keep v739 v742 v743a v743b v743c v743d v743e v744a v744b v744c v744d v744e  v024 sregmun ssubd svillag v741 v005


gen bps_2001= 100*v024+sregmun  // kep. riau is featured on 2001 statistical codes (ie. before becoming independent)
gen beating = 0
foreach v of varlist v744* {

	replace beating = beating + 1 if `v'==1
	replace beating = beating + 0.5 if `v'==8

}

foreach v of varlist v743* {

	replace beating = beating + 1 if `v'==4 //has no say in...
	
}


rename v005 weight

replace beating = beating*weight

collapse (sum) beating weight, by(bps_2001)
replace beating = beating / weight

gen year=2002

save "../../data/DHS/2002.dta", replace


/*
v739 who decides how to spend woman's earnings - ha nincs valasz, nincs earning?

final say on...
v743a  own healthcare
v743b  large purchases
v743d  visit to family or relatives

beating justified if...
v744a  goes out without telling
v744b  neglects children
v744c  argues
v744d  refuses to have sex
v744e  burns food


v133  education in years 
v155  literacy
v157  freq. of reading newsp
v158  freq. of listening to radio
v159  freq. of watching tv

v714  is employed
v741  work is paid / not paid 



gen beating = 0
foreach v of varlist v744* {

	replace beating = beating + 1 if `v'==1
	replace beating = beating + 0.5 if `v'==8

}

egen decision = rowmean(v743*)
*/
