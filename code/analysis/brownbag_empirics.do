*replace unempr1=. if log_gdp_pc==.
eststo clear

local panel_col = "../../data/indodap_panel_collapsed1109.dta"
local panel_uncol = "../../data/indodap_panel_uncollapsed1109.dta" 


local treatments = " treated1 treat_event1 "
*local treatments = " treated1##c.ELF treated1##c.RF treat_event1##c.ELF  treat_event1##c.RF "

*local treatments= " treated1_elf 	treat_event1_elf 	treated1_rf 	treat_event1_tf"

*local clustvar = "bps_2000"
local sterror = " rob "
local control = "lpop log_gdp_pc"
*local control = " log_gdp_pc"

*local subsample = " keep if java == 1 "

local y0="log_gdp_pc"
*local y1="gdp_growth_win"
local y1="log_gdp_pc"
local y4="si_pov_ngap"
local y3="si_pov_napr_zs"
local y2="unempr1" 
local y5="se_jrsec_nenr_zs"
local y6="sh_morb_zs"
local y7="beating"
     


local y0name="Log(GDP PC)"
local y1name= "GDP Growth"
*local y1name="Log(GDP PC)"
local y4name="Poverty Gap"
local y3name="Poverty Rate"

local y2name="UnempRate"
local y5name="NER J2ND"
local y6name="Morbidity"
local y7name="Status of women"

local y0year1="2000"
local y1year1="2002" // ezt 2002re kell rakni vagy irrealis dolgok jonnek ki a novekedessel
local y4year1="2002"
local y3year1="2002"
local y2year1="2001"
local y5year1="2001"
local y6year1="2001"

local y7year1="2002"


local y0year2="2012"
local y1year2="2012"
local y4year2="2012"
local y3year2="2012"
local y2year2="2012"
local y5year2="2012"
local y6year2="2012"
local y7year2="2012"

local y0year_pre="2000"
local y1year_pre="2002"
*local y2year_pre="1999"
*local y3year_pre="1999"
local y4year_pre="2002"
local y3year_pre="2002"
local y2year_pre="2001"

*local y5year_pre="1998"
*local y6year_pre="1998"
local y5year_pre="2000"
local y6year_pre="2000"

local y7year_pre="2002"



/* pre-differences table */
preserve
use ../../data/indodap_panel_uncollapsed1109.dta, clear
putexcel set "../../evidence/brownbag_regional_descriptive.xls", replace sheet("t_test")
	putexcel A1=("Variable") B1=("Year observed") C1= ("N if no Sharia by 2013") D1=("N if any Sharia by 2013") ///
	E1=("Mean if no Sharia by 2013")  F1=("Mean if any Sharia by 2013") G1=("Difference (pp.) ") ///
	H1=("t-stat of diff.") I1=("p-value ")
	
	local row = 1
	forvalues n = 0/7 {
		
		local row=`row'+1
		*disp "ttest `y`n'' if year==`y`n'year_pre',by(cum_treat2013)"
		*ttest `y`n'' if year==2002,by(cum_treat2013)
		ttest `y`n'' if year==`y`n'year1',by(cum_treat2013)
		putexcel A`row' = ("`y`n'name'")
		putexcel B`row' = (`y`n'year1')
		cap putexcel C`row' = (r(N_1))
		cap putexcel D`row' = (r(N_2))
		cap putexcel E`row' = (r(mu_1))
		cap putexcel F`row' = (r(mu_2))
		cap putexcel G`row' = ((r(mu_2)-r(mu_1)))
		cap putexcel H`row' = (r(t))
		cap putexcel I`row' = (r(p))

	
	}
restore

/*


stop
estpost ttest price mpg headroom trunk, by(cum_treat2013)
esttab, wide nonumber mtitle("diff.")

Variable	Year observed	N if no Sharia by 2013	N if any Sharia by 2013	Mean if no Sharia by 2013	Mean if any Sharia by 2013	Difference (pp.) 	t-stat of diff.	p-value 
Log(GDP PC)	2000	138	131	1.13	1.33	0.20	-2.78	0.01
GDP Growth	2001	133	127	0.08	0.06	-0.02	1.14	0.26
Poverty Gap	1999	160	146	4.95	3.88	-1.07	3.01	0.00
Poverty Rate	1999	160	146	25.28	21.83	-3.45	2.17	0.03
UnempRate	2001	167	149	0.04	0.05	0.01	-3.42	0.00
NER J2ND	1998	136	130	55.94	55.84	-0.09	0.05	0.96
Morbdity	1998	136	130	25.76	26.72	0.97	-1.02	0.31
*/



* TABLE 10: LONG DIFFERENCE
* unempr1 unempr2
* "panel_uncol"


eststo clear
foreach data in "panel_col" {

	use ``data'', clear
	`subsample'

	forvalues n = 1/4 {
		local dif = `y`n'year2'-`y`n'year1'
		gen pop_growth=s`dif'.lpop
		gen gdp_initial=l`dif'.log_gdp_pc
		*local dcontrol = "s`dif'.lpop  l`dif'.log_gdp_pc  RF ELF  "
		la var pop_growth "Pop. growth"
		la var gdp_initial "2000 GDP "
		la var treated1 "Has any Sharia"
		local dcontrol = "pop_growth gdp_initial  RF  "
		disp "reg s`dif'.`y`n'' treated1 `dcontrol' if year==`y`n'year2' , `sterror'"
		reg s`dif'.`y`n'' treated1 `dcontrol' if year==`y`n'year2' , `sterror'
		local ols`n'=_b[treated1]
		qui sum s`dif'.`y`n''
		local meandep = `r(mean)'
		disp `meandep'
		eststo  ,title("OLS") addscalar(MeanY `meandep' FirstYear `y`n'year1' LastYear `y`n'year2')
		*drop dx dy
		drop pop_growth gdp_initial
		
	}

	esttab using ../../evidence/`data'_longd_ols_1.tex  ///
	, star(* 0.10 ** 0.05 *** 0.01) scalars(MeanY FirstYear LastYear) label replace mtitles("`y1name'" "`y2name'" "`y3name'" "`y4name'"   )  ///
	keep(treated1  ) compress nonotes ///
	addnotes("Robust t-stats in parentheses. Additional controls: " " Population growth, initial GDP, religious fractionalization index " "  * p<0.10, ** p<0.05, *** p<0.01 ")
	
	eststo clear

	use ``data'', clear
	`subsample'

	forvalues n = 5/7 {
		local dif = `y`n'year2'-`y`n'year1'
		gen pop_growth=s`dif'.lpop
		gen gdp_initial=l`dif'.log_gdp_pc
		*local dcontrol = "s`dif'.lpop  l`dif'.log_gdp_pc  RF ELF  "
		la var pop_growth "Pop. growth"
		la var gdp_initial "2000 GDP "
		la var treated1 "Has any Sharia"
		local dcontrol = "pop_growth gdp_initial  RF  "
		disp "reg s`dif'.`y`n'' treated1 `dcontrol' if year==`y`n'year2' , `sterror'"
		reg s`dif'.`y`n'' treated1 `dcontrol' if year==`y`n'year2' , `sterror'
		local ols`n'=_b[treated1]
		qui sum s`dif'.`y`n''
		local meandep = `r(mean)'
		disp `meandep'
		eststo  ,title("OLS") addscalar(MeanY `meandep' FirstYear `y`n'year1' LastYear `y`n'year2')
		*drop dx dy
		drop pop_growth gdp_initial
		
	}

	esttab using ../../evidence/`data'_longd_ols_2.tex  ///
	, star(* 0.10 ** 0.05 *** 0.01) scalars(MeanY FirstYear LastYear) label replace mtitles( "`y5name'" "`y6name'" "`y7name'"   )  ///
	keep(treated1  ) compress nonotes ///
	addnotes("Robust t-stats in parentheses. Additional controls: " " Population growth, initial GDP, religious fractionalization index " " * p<0.10, ** p<0.05, *** p<0.01 ")
	
	eststo clear


}

* TABLE 11-12-13-14: LONG DIFFERENCE - IV
*"panel_uncol"

*local clustvar = "bps_1999"
local sterror = " rob "
local control = "lpop log_gdp_pc "
local panel_col = "../../data/indodap_panel_collapsed1109.dta"
local panel_uncol = "../../data/indodap_panel_uncollapsed1109.dta" 

foreach data in "panel_col"  {

	use ``data'', clear
	`subsample'
	*iv3-iv3
	foreach v of varlist iv3 masyumi_before_communists  {
		forvalues n = 1/4 {
			
			local dif = `y`n'year2'-`y`n'year1'

			disp "`y`n'name' `y`n'year2'-`y`n'year1'"
			gen pop_growth=s`dif'.lpop
			gen gdp_initial=l`dif'.log_gdp_pc
			la var pop_growth "Pop. growth"
			la var gdp_initial "2000 GDP"
		
			local dcontrol = "pop_growth gdp_initial  RF  "
			
			cap gen dtreated=s`dif'.treated1
			la var dtreated "Has any Sharia"
			ivregress gmm s`dif'.`y`n'' (dtreated=c.`v') `dcontrol'  if year==`y`n'year2' ,  rob first 
			eststo  ,title("IV") addscalar(OLSCoeff `ols`n'') 
			*stop
			*drop dy dx
			*drop dtreated
			drop pop_growth gdp_initial
		}

		esttab using ../../evidence/`data'_`v'_longd_iv_1.tex  ///
		, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("`y1name'" "`y2name'" "`y3name'" "`y4name'" )     keep(dtreated ) scalars(OLSCoeff) nonotes
*				, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("`y1name'" "`y2name'" "`y3name'" "`y4name'" "`y5name'" "`y6name'"  "`y7name'"  )     keep(treated1 )
		eststo clear

		forvalues n = 5/7 {
			
			local dif = `y`n'year2'-`y`n'year1'

			disp "`y`n'name' `y`n'year2'-`y`n'year1'"
			gen pop_growth=s`dif'.lpop
			gen gdp_initial=l`dif'.log_gdp_pc
			la var pop_growth "Pop. growth"
			la var gdp_initial "2000 GDP"
		
			local dcontrol = "pop_growth gdp_initial  RF  "
			
			cap gen dtreated=s`dif'.treated1
			la var dtreated "Has any Sharia"
			ivregress gmm s`dif'.`y`n'' (dtreated=c.`v') `dcontrol'  if year==`y`n'year2' ,  rob first
			eststo  ,title("IV")	 addscalar(OLSCoeff `ols`n'') 
			*stop
			*drop dy dx
			*drop dtreated
			drop pop_growth gdp_initial
		}

		esttab using ../../evidence/`data'_`v'_longd_iv_2.tex  ///
		, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles( "`y5name'" "`y6name'"  "`y7name'"  )     keep(dtreated   )  scalars(OLSCoeff) nonotes
*				, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("`y1name'" "`y2name'" "`y3name'" "`y4name'" "`y5name'" "`y6name'"  "`y7name'"  )     keep(treated1 )
		eststo clear
		

		
		
	}
	
	


}

* TABLE 11-12-13-14: FIRST STAGE & RF - IV
*"panel_uncol"

*local clustvar = "bps_1999"
local sterror = " rob "
local control = "lpop log_gdp_pc RF ELF"
local panel_col = "../../data/indodap_panel_collapsed1109.dta"
local panel_uncol = "../../data/indodap_panel_uncollapsed1109.dta" 

foreach data in "panel_col"  {

	use ``data'', clear
	`subsample'
	
	eststo clear
	*iv3-iv3
	foreach v of varlist iv3 masyumi_before_communists {
		la var `v' "Masyumi pp."
		disp "reg treated1 `v' `dcontrol'  if year==2012 ,  rob "
		gen pop_growth=s`dif'.lpop
		gen gdp_initial=l`dif'.log_gdp_pc
		*la var pop_growth "Pop. growth"
		*la var gdp_initial "2000 GDP"
		reg treated1 `v' `dcontrol'  if year==2012 ,  rob 
		eststo  ,title("FS")
		forvalues n = 1/3 {
			
			local dif = `y`n'year2'-`y`n'year1'

			local dcontrol = "pop_growth gdp_initial  RF  "
			disp "`y`n'name' `y`n'year2'-`y`n'year1'"


			reg s`dif'.`y`n'' `v' `dcontrol'  if year==`y`n'year2' ,  rob 
			eststo  ,title("RF")	

			
		}
		
		esttab using ../../evidence/`data'_`v'_longd_RF_1.tex  ///
				, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles( "P(Sharia)" "`y1name'" "`y2name'" "`y3name'"   )   keep( `v'  )   nonotes
*				, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles( "First stage" "`y1name'" "`y2name'" "`y3name'" "`y4name'" "`y5name'" "`y6name'"  "`y7name'"  )     keep(`v' )
		eststo clear
		
		
		forvalues n = 4/7 {
			
			local dif = `y`n'year2'-`y`n'year1'

			local dcontrol = "pop_growth gdp_initial  RF  "
			disp "`y`n'name' `y`n'year2'-`y`n'year1'"


			reg s`dif'.`y`n'' `v' `dcontrol'  if year==`y`n'year2' ,  rob 
			eststo  ,title("RF")	

			
		}
		
		esttab using ../../evidence/`data'_`v'_longd_RF_2.tex  ///
				, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles( "`y4name'" "`y5name'" "`y6name'"  "`y7name'"  )   keep( `v'   )   nonotes
*				, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles( "First stage" "`y1name'" "`y2name'" "`y3name'" "`y4name'" "`y5name'" "`y6name'"  "`y7name'"  )     keep(`v' )
		eststo clear
		drop pop_growth gdp_initial
	}


}

* TABLE 11-12-13-14: - IV PLACEBO

*"panel_uncol"

*local clustvar = "bps_2000"
local sterror = " rob "
*local control = "lpop log_gdp_pc RF "
local control = " " 
local panel_col = "../../data/indodap_panel_collapsed1109.dta"
local panel_uncol = "../../data/indodap_panel_uncollapsed1109.dta" 

foreach data in "panel_col"  {

	use ``data'', clear
	`subsample'
	gen cum_treat1998=0
	
	foreach v of varlist iv3-iv3 {
		forvalues n = 1/4 {
			
			la var `v' "Masyumi pp."
			disp "`y`n'name'"
			disp "reg `y`n'' `v' `control'  if year==`y`n'year_pre'&cum_treat`y`n'year_pre'==0 , rob first"
			reg `y`n'' `v' `control'  if year==`y`n'year_pre'&cum_treat`y`n'year_pre'==0 , rob 
			eststo  ,title("Placebo")	addscalar(Year `y`n'year_pre')
			

			
		}
	
		esttab using ../../evidence/`data'_`v'_placebo_1.tex  ///
			, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("Log(GDP)" "`y2name'" "`y3name'" "`y4name'" )    keep(iv3  ) nonotes scalars(Year)
			*	, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("Log(GDP)" "`y2name'" "`y3name'" "`y4name'" "`y5name'" "`y6name'" "`y7name'" )    keep(`v')
		eststo clear
		
		
		forvalues n = 5/7 {
			
			la var `v' "Masyumi pp."
			disp "`y`n'name'"
			disp "reg `y`n'' `v' `control'  if year==`y`n'year_pre'&cum_treat`y`n'year_pre'==0 , rob first"
			reg `y`n'' `v' `control'  if year==`y`n'year_pre'&cum_treat`y`n'year_pre'==0 , rob 
			eststo  ,title("Placebo")	 addscalar(Year `y`n'year_pre')
			

			
		}
	
		esttab using ../../evidence/`data'_`v'_placebo_2.tex  ///
			, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles( "`y5name'" "`y6name'" "`y7name'" )    keep(iv3  ) nonotes ///
			addnotes("") scalars(Year)
			*	, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("Log(GDP)" "`y2name'" "`y3name'" "`y4name'" "`y5name'" "`y6name'" "`y7name'" )    keep(`v')
		eststo clear

	}


}

/*
/*    			 heterogeneity analysis 				*/

foreach data in "panel_col" {

	use ``data'', clear
	`subsample'

	gen treat_elf = treated1*ELF
	gen treat_rf = treated1*RF
	forvalues n = 1/7 {
		local dif = `y`n'year2'-`y`n'year1'
		*local dcontrol = "s`dif'.lpop s`dif'.log_gdp_pc RF  "
		*local dcontrol = " s`dif'.log_gdp_pc RF  "
		*local dcontrol = " s`dif'.log_gdp_pc  "
		local dcontrol = "s`dif'.lpop  l`dif'.log_gdp_pc  "
		disp "`y`n'name'  `dif'   `y`n''-l`dif'.`y`n'' if year == `y`n'year2'"
		disp "reg s`dif'.`y`n'' treated1 treat_elf ELF `dcontrol' if year==`y`n'year2' , `sterror'"
		reg s`dif'.`y`n'' treated1 treat_elf ELF `dcontrol' if year==`y`n'year2' ,  rob
		qui sum s`dif'.`y`n''
		local meandep = `r(mean)'
		disp `meandep'
		eststo  ,title("OLS") addscalar(MeanY `meandep')
		*drop dx dy
		
	}

	esttab using ../evidence/hetero1.tex  ///
			, star(* 0.10 ** 0.05 *** 0.01) scalars(MeanY) label replace mtitles("`y1name'" "`y2name'" "`y3name'" "`y4name'" "`y5name'" "`y6name'" "`y7name'"   )   keep(treated1 treat_elf ELF )
			eststo clear
	eststo clear

	forvalues n = 1/7 {
		local dif = `y`n'year2'-`y`n'year1'
		*local dcontrol = "s`dif'.lpop s`dif'.log_gdp_pc RF  "
		*local dcontrol = " s`dif'.log_gdp_pc RF  "
		*local dcontrol = " s`dif'.log_gdp_pc  "
		local dcontrol = "s`dif'.lpop  l`dif'.log_gdp_pc  "
		disp "`y`n'name'  `dif'   `y`n''-l`dif'.`y`n'' if year == `y`n'year2'"
		*gen dy = `y`n''-l`dif'.`y`n'' if year == `y`n'year2'
		*gen dx = `control'-l`dif'.`control' if year == `y`n'year2'
		disp "reg s`dif'.`y`n'' treated1 treat_rf RF `dcontrol' if year==`y`n'year2' , `sterror'"
		reg s`dif'.`y`n'' treated1 treat_rf RF `dcontrol' if year==`y`n'year2' , rob
		qui sum s`dif'.`y`n''
		local meandep = `r(mean)'
		disp `meandep'
		eststo  ,title("OLS") addscalar(MeanY `meandep')
		*drop dx dy
		
	}

	esttab using ../evidence/hetero2.tex  ///
			, star(* 0.10 ** 0.05 *** 0.01) scalars(MeanY) label replace mtitles("`y1name'" "`y2name'" "`y3name'" "`y4name'" "`y5name'" "`y6name'" "`y7name'"   )   keep(treated1 treat_rf RF )
			eststo clear
	eststo clear
	
}
