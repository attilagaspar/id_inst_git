* set working directory - important for portability
do set_working_directory.do



clear
local n = td(31dec2017)-td(23feb1990)+1
set obs `n'
gen day = _n
replace day = _n+td(23feb1990)-1
format day %td

preserve
	import excel "../../data/raw/calendar/calendar_dates.xls", sheet("Sheet1") firstrow clear
	keep calendar_year - Independenceday
	destring calendar_year , force replace
	drop if calen==.
	*calendar_year Ramadanstarts EidAlFitr EidAlAdha Newyear Mawlid IsraMiraj Independenceday
	tempfile cal
	save `cal'
restore

foreach s in "Ramadanstarts" "EidAlFitr" "EidAlAdha" "Newyear" "Mawlid" "IsraMiraj" "Independenceday" {

	preserve
		disp "loading `s'"
		use `cal', clear
		keep `s'
		rename `s' day
		drop if d==.
		tempfile cal2
		save `cal2'
	restore
	disp "merging `s'"
	merge 1:1 day using `cal2', gen(merge_`s')
	rename merge_`s' `s'
	replace `s'=0 if `s'==1
	tab day if `s'==2
	drop if `s'==2
	replace `s'=1 if `s'==3

}

*
tsset day

foreach s in "Ramadanstarts" "EidAlFitr" "EidAlAdha" "Newyear" "Mawlid" "IsraMiraj" "Independenceday" {
	cap drop after_`s'=0
	cap gen after_`s'=0
	replace after_`s'=l.after_`s'+1 if `s'!=1
	/*
	forvalues n = `start'/`end' {
		if (`s'[`n']!=1) {	
			replace after_`s'=l.after_`s'+1 if 
		}
		
	}
	*/
}

gen minday=-day
tsset minday

foreach s in "Ramadanstarts" "EidAlFitr" "EidAlAdha" "Newyear" "Mawlid" "IsraMiraj" "Independenceday" {
	cap drop before_`s'=0
	cap gen before_`s'=0
	replace before_`s'=l.before_`s'+1 if `s'!=1
	/*
	forvalues n = `start'/`end' {
		if (`s'[`n']!=1) {	
			replace after_`s'=l.after_`s'+1 if 
		}
		
	}
	*/
}
drop minday
tsset day


foreach s in "Ramadanstarts" "EidAlFitr" "EidAlAdha" "Newyear" "Mawlid" "IsraMiraj" "Independenceday" {

	order day before_`s' after_`s' `s'

}
*order before_ after_ Ra


/* derived dates */
gen ramadan=0
replace ramadan=1 if after_Ramadanstarts>=0&after_Ramadanstarts<=30&before_EidAlFitr<=30&EidAlFitr!=1

/* Eid-Al-Adha is 3 days feast and it is the last 3 days of the 4 days of the Hajj */
gen hajj=0
replace hajj=1 if EidAlAdha==1
replace hajj=1 if before_EidAlAdha==1
replace hajj=1 if after_EidAlAdha==1
replace hajj=1 if after_EidAlAdha==2
replace EidAlAdha=1 if after_EidAlAdha==1
replace EidAlAdha=1 if after_EidAlAdha==2
*replace hajj=1 if after_EidAlAdha==3




foreach s in "Ramadanstarts" "EidAlFitr" "EidAlAdha" "Newyear" "Mawlid" "IsraMiraj" "Independenceday" {

	egen absdays_`s'=rowmin(before_`s' after_`s')
	
}
gen monthly = mofd(day)
egen is_holiday = rowtotal(IsraMiraj Mawlid Newyear EidAlFitr ramadan hajj)
*egen holidays = total(is_holiday), by(monthly)
tsset day
gen holidays1=0
replace holidays1=is_holiday in 1
replace holidays1=holidays1[_n-1]+is_holiday if _n>1
gen holidays2=l30.holidays1
gen holidays30=holidays1-holidays2
drop holidays1 holidays2

save ../../data/islamic_calendar.dta, replace
