
* set working directory - important for portability
do set_working_directory.do

use ../../data/indodap_panel_uncollapsed1109.dta, clear

tsset id_moving year

cap drop election_year
gen election_year_direct=0
gen election_year_indirect=0
replace election_year_indirect=1 if year==1999
replace election_year_indirect=1 if year==2004
replace election_year_indirect=1 if year==2009
replace election_year_direct=1 if merge_election==3

gen year_in_cycle=1 if election_year_direct==1
replace year_in_cycle=2 if l.year_in_cycle==1
replace year_in_cycle=3 if l.year_in_cycle==2
replace year_in_cycle=4 if l.year_in_cycle==3
replace year_in_cycle=5 if l.year_in_cycle==4

gen incumbent = 0
replace incumbent = 1 if incumbent_reelected=="YES"

gen year_in_cycle_incumbent=.
replace year_in_cycle_incumbent=1 if election_year_direct==1&incumbent==1
replace year_in_cycle_incumbent=2 if l.year_in_cycle_incumbent==1
replace year_in_cycle_incumbent=3 if l.year_in_cycle_incumbent==2
replace year_in_cycle_incumbent=4 if l.year_in_cycle_incumbent==3
replace year_in_cycle_incumbent=5 if l.year_in_cycle_incumbent==4

gen indirect = 0
replace indirect=1 if year_in_cycle==.&year<2008

/* gdp changes */

*gen gdp_growth = d.log_gdp_pc
gen gdp_growth_ma = (gdp_growth+l.gdp_growth+l2.gdp_growth)/3
gen recession=0
replace recession=1 if gdp_growth<0
gen cumulative_recession= recession+l.recession+l2.recession+l3.recession+l4.recession



/* election figure 
	- no reputational concerns for 	incumbents
	- unfortunately the differences are not significant

*/
gen treat_incumbent = 0
replace treat_incumbent = 1 if treat_event1==1&year_in_cycle_inc!=.
gen treat_nonincumbent = 0
replace treat_nonincumbent = 1 if treat_event1==1&year_in_cycle_inc==.
binscatter treat_noni treat_inc year_in_cycle , linetype(connect) savedata(../../evidence/elections)  replace
 

***************************************************************

gen log_spending_change = log( hou_xpd_pc_cr ) - log(l.hou_xpd_pc_cr )
gen log_poor_spending_change = log( hou_xpd_totl_20poor_cr ) - log(l.hou_xpd_totl_20poor_cr )
/* is the economy driving the results */
**********************************************************************
*reg treat_event1   gdp_growth iv3 if year>=1998&year<2013, rob

la var gdp_growth "Dlog(GDP) over year"
la var treat_event1 "Sharia regulation in a year"
la var iv3 "Masyumi votes in 1955 (pp)"
eststo clear
reg treat_event1  l.unempr1  l.gdp_growth c.iv3  if year>=1998&year<2013 , cluster(bps_2000)
qui sum treat_event1 if year>=1998&year<2013
local meandep = `r(mean)' 
eststo ,title("ShariaDeterminants") addscalar(MeanY `meandep')


esttab using ../../evidence/determinants.tex  ///
	, star(* 0.10 ** 0.05 *** 0.01) scalars(MeanY) label replace mtitles("P(Sharia reg. in a year)"   )  ///
	compress nonotes ///
	addnotes("Standard errors clustered on 2000 borders. * p<0.10, ** p<0.05, *** p<0.01 ")
	

// median Sharia-support is 34.7 --> 4.1% each year
// amounts to a loss of 64% of the GDP according to this regression
// unemployment is important but it is idiosincratic, on the long run there
// are no differences in unemployment

// --> unemployment changes institutions
**********************************************************************


/* why is education and health worse */
gen educ = fc_xpd_edu_cr/ (na_gdp_inc_og_cr*1000000)
gen health = fc_xpd_he_cr/ (na_gdp_inc_og_cr*1000000)
gen staff = ec_xpd_staf_cr  / (na_gdp_inc_og_cr*1000000)
gen budget_size = ec_xpd_totl_cr/(na_gdp_exc_og_cr*1000000)

local ed  "Educ. exp./RGDP"
la var educ "`ed'"
local he "Health. exp./RGDP"
la var health  "`he'"
local st "Personnel exp./RGDP"
la var staff "`st'"
la var log_gdp_pc "Log GDP pc"
la var budget_size "Incomes/RGDP"
eststo clear
la var treated1 "Has any Sharia"

*preserve 
*keep if year>=2005
xtreg educ treated1  budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
qui sum educ if year>=1998&year<2013
local meandep = `r(mean)' 
eststo, title("ed") addscalar(MeanY `meandep')
xtreg health treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
qui sum health if year>=1998&year<2013
local meandep = `r(mean)' 
eststo, title("he") addscalar(MeanY `meandep')
xtreg staff treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
qui sum staff if year>=1998&year<2013
local meandep = `r(mean)' 
eststo, title("st") addscalar(MeanY `meandep')

/*

xtreg bureaucracy treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
xtreg business treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
xtreg infra treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
xtreg totalbudget treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
xtreg lawandor treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
xtreg lain treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
*xtreg loglain treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 

foreach v of varlist ec_xpd_cap_cr ec_xpd_gsr_cr ec_xpd_othr_cr ec_xpd_staf_cr ec_xpd_totl_cr {


	gen log_`v'=log(`v')
	
	xtreg log_`v' treated1 budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe 
	
	drop log_`v'

}
*/

esttab using ../../evidence/expenditures.tex  ///
	, star(* 0.10 ** 0.05 *** 0.01) scalars(MeanY) label replace mtitles("`ed'" "`he'" "`st'" )  ///
	compress nonotes ///
	addnotes("Standard errors clustered on 2000 borders." "Time and Region FE included." "* p<0.10, ** p<0.05, *** p<0.01 ") ///
	keep(treated1  budget_size log_gdp_pc)
*restore	

/*


*reg treat_event1   cumulative_recession iv3 if year>=1998&year<2013, rob



**********************************************************************
*total revenue: 
rev_totl_cr


*expenditure
ec_xpd_totl_cr

fc_xpd_edu_cr //educ
fc_xpd_he_cr //healt

* share of educ & health spending to gdp

gen environ = fc_xpd_envr_cr / (na_gdp_inc_og_cr*1000000)

gen budget_size = ec_xpd_totl_cr/(na_gdp_exc_og_cr*1000000)
gen bureaucracy = fc_xpd_admn_cr / (na_gdp_inc_og_cr*1000000)
gen business = fc_xpd_econ_cr / (na_gdp_inc_og_cr*1000000)
gen infra = fc_xpd_infr_cr / (na_gdp_inc_og_cr*1000000)

gen totalbudget = ec_xpd_totl_cr  / (na_gdp_inc_og_cr*1000000)
gen lawandorder = fc_xpd_publ_cr  / (na_gdp_inc_og_cr*1000000)

gen goods = ec_xpd_gsr_cr  /  (na_gdp_inc_og_cr*1000000)
gen lain = ec_xpd_othr_cr  /  (na_gdp_inc_og_cr*1000000)



foreach v of varlist hou_xpd_edu_pc_cr hou_xpd_he_pc_cr hou_xpd_pc_cr hou_xpd_totl_20poor_cr {

	cap drop log_`v' 
	gen log_`v' = log(1+`v')
	xtreg `v' treated1  budget_size log_gdp_pc i.year if year>=1998&year<2013, cluster(bps_2000) fe
	


}




foreach s in "1996" "2002" "2007" {
	gen defl_`s'=ep_cpi_`s'/100
	replace defl_`s'=l.defl_`s' if defl_`s'==.
	replace defl_`s'=f.defl_`s' if defl_`s'==.
	replace defl_`s'=f.defl_`s' if defl_`s'==.
}




ep_cpi_1996 ep_cpi_2002 ep_cpi_2007






gen surplus_wo=((rev_totl_cr-ec_xpd_totl_cr)/(na_gdp_inc_og_cr*1000000))
gen surplus_woo=((rev_totl_cr-ec_xpd_totl_cr)/(na_gdp_exc_og_cr*1000000))

gen natrev = rev_txrv_shr_cr
gen lnatrev = log(natrev) - log(l.natrev)
replace lnatrev = 0 if lnatrev==.

winsor surplus_woo, gen(surplus_win) p(0.01)

gen exp_percapita = ec_xpd_totl_cr/pop_ipol

// total income - total expenditure over non-oil revenue 






