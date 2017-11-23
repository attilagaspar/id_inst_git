
* set working directory - important for portability
do set_working_directory.do

use ../../data/indodap_panel_uncollapsed1109.dta, clear




/**************************/
/* create collapsed panel */
/**************************/


/* weighting */
local toweight = " se_jrsec_nenr_zs si_pov_napr_zs sh_morb_zs iv* si_pov_ngap beating "
foreach v of varlist `toweight' 	 {


	replace `v'=`v'*pop_ipol


}

collapse (sum) `toweight'    ///     		weighted average			
			   na_gdp_exc_og_kr sl_emp_totl	sl_emp_undr sl_uem_totl ///
			   pop_ipol ///
			   (max) treated1 treated2 treat_event1 treat_event2 ///
			   province_reg province_id cum_treat* bad_audit masyumi_before_communists ///
			   (first) name_2000 (mean) mean_mbc=masyumi_before_communists, by(bps_2000 year) 
			   

			   
tsset bps_2000 year  // success
replace beating=. if year!=2002&year!=2012
			 
foreach v of varlist `toweight' {

	replace `v'=`v'/pop_ipol

}


gen log_gdp = log(na_gdp_exc_og_kr)
gen log_gdp_pc = log(na_gdp_exc_og_kr/pop_ipol)
gen lpop=log(pop_ipol)

gen unempr1=(sl_uem_totl)/(sl_uem_totl+sl_emp_totl)
gen unempr2=(sl_emp_undr+sl_uem_totl)/(sl_uem_totl+sl_emp_totl)
gen gdp_growth = d.log_gdp_pc 
*gen gdp_growth = s10.log_gdp_pc 
winsor gdp_growth, gen(gdp_growth_win) p(0.01)

la var iv1 "Masyumi (exact matches)"
la var iv2 "Masyumi (border-adjusted)"
la var iv3 "Masyumi (exact for Java, average for others)"
la var iv4 "Masyumi (average rates)"
la var unempr1 "Unemployment rate"
la var unempr2 "Percentage unemployed or underemployed"
la var se_jrsec_nenr_zs "Net Enrolment Ratio (Junior Secondary)"
la var si_pov_napr_zs  "Poverty rate"
la var si_pov_napr_zs  "Poverty gap"
la var sh_morb_zs "Morbidity rate"
la var log_gdp_pc "Log of real GDP/cap, constant prices, Oil&Gas excluded"
la var gdp_growth_win "Growth rate of GDP"


	gen island = floor(bps_2000/1000)
	gen java = 0
	replace java=1 if island==3

/* replace zeroes that come from collapse to missing */
foreach v of varlist  se_jrsec_nenr_zs si_pov_napr_zs sh_morb_zs {

	replace `v'=. if `v'==0

}

/* merge unemployment from growth and government data */

preserve
	use  ../../data/gg_panel1110.dta, clear
	keep bps_1999 bps_2000 year unemp1 name
	keep if unemp1!=.
	tempfile unemp
	save `unemp'
restore

*append using `unemp'
merge 1:1 bps_2000 year using `unemp', gen (merge_gg)
merge m:1 bps_2000 using ../../data/gg_corruption_and_fract2000.dta, gen(merge_fract)
replace unempr1 = unemp1 if unempr1==.	




tsset bps_2000 year

la var ELF "Ethno-ling. IDX"
la var RF "Relig. IDX"


save ../../data/indodap_panel_collapsed1109.dta, replace


*do brownbag_empirics.do

*use ../../data/indodap_panel_uncollapsed1109.dta, clear
