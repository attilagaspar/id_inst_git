

set more off

* set working directory - important for portability
do set_working_directory.do



import excel "../../data/raw/indodapoer/indo-dapoer_master_file-05_26_2015-imh-oh-rdr.xlsx", sheet("Data") firstrow clear

* create data from INDO-DAPOER raw data

rename A kab_name_dapoer
rename B kab_code_dapoer
rename C series_code
rename D series_name

* destringing


drop YR1976-YR1993

forvalues n=1994/2013 {
	cap replace YR`n'=subinstr(YR`n',",","",.)
	*destring 	YR`n', force gen(YR`n'_num)
	destring 	YR`n', force replace
	*gen YR`n'_tag=0
	*cap replace YR`n'_tag=1 if YR`n'!="" & YR`n'_num==.
	*replace first_year=`n' if first_year==. & YR`n'!=.
	*replace last_year=`n' if YR`n'!=.
}

* # of years
egen no_years = rownonmiss(YR1994-YR2013)



* drop provincial data, only regencies are needed
drop if strpos(kab_name_dapoer,"Prop.")!=0


* create kabupaten names for matching

*replace kab_name_dapoer="Selayar, Kab." if kab_name_dapoer== "Kepulauan Selayar"


split kab_name_dapoer, parse(", ") gen(kb)
gen name_kabupaten=strtrim(kb1)
replace name_kabupaten="Kabupaten "+kb1 if kb2!="Kota"
replace name_kabupaten="Kota "+kb1 if kb2=="Kota"

replace name_kabupaten="Kabupaten Kepulauan Seribu" if name_kabupaten=="Kabupaten Adm. Kepulauan Seribu"
replace name_kabupaten="Kabupaten Banyu Asin" if name_kabupaten=="Kabupaten Banyuasin"
replace name_kabupaten="Kabupaten Batang Hari" if name_kabupaten=="Kabupaten Batanghari"
replace name_kabupaten="Kabupaten Fakfak" if name_kabupaten=="Kabupaten Fak-Fak"
replace name_kabupaten="Kabupaten Siau Tagulandang Biaro" if name_kabupaten=="Kabupaten Kep. Siau Tagulandang Biaro"
replace name_kabupaten="Kabupaten Kotabaru" if name_kabupaten=="Kabupaten Kota Baru"
replace name_kabupaten="Kabupaten Lima Puluh Kota" if name_kabupaten=="Kabupaten Limapuluh Kota"
replace name_kabupaten="Kabupaten Pangkajene Dan Kepulauan" if name_kabupaten=="Kabupaten Pangkajene Kepulauan"
replace name_kabupaten="Kabupaten Paser" if name_kabupaten=="Kabupaten Pasir"
replace name_kabupaten="Kabupaten Kepulauan Selayar" if name_kabupaten=="Kabupaten Selayar"
replace name_kabupaten="Kabupaten Tulangbawang" if name_kabupaten=="Kabupaten Tulang Bawang"
replace name_kabupaten="Kabupaten Tulangbawang Barat" if name_kabupaten=="Kabupaten Tulang Bawang Barat"
replace name_kabupaten="Kota Banjarbaru" if name_kabupaten=="Kota Banjar Baru"
replace name_kabupaten="Kota Bau-Bau" if name_kabupaten=="Kota Bau-bau"
replace name_kabupaten="Kota Gunungsitoli" if name_kabupaten=="Kota Gunung Sitoli"
replace name_kabupaten="Kodya Jakarta Barat" if name_kabupaten=="Kota Jakarta Barat"
replace name_kabupaten="Kodya Jakarta Pusat" if name_kabupaten=="Kota Jakarta Pusat"
replace name_kabupaten="Kodya Jakarta Selatan" if name_kabupaten=="Kota Jakarta Selatan"
replace name_kabupaten="Kodya Jakarta Timur" if name_kabupaten=="Kota Jakarta Timur"
replace name_kabupaten="Kodya Jakarta Utara" if name_kabupaten=="Kota Jakarta Utara"
replace name_kabupaten="Kota Tidore Kepulauan" if name_kabupaten=="Kota Kepulauan Tidore"
replace name_kabupaten="Kota Padangsidimpuan" if name_kabupaten=="Kota Padang Sidempuan"
replace name_kabupaten="Kota Palangka Raya" if name_kabupaten=="Kota Palangkaraya"
replace name_kabupaten="Prabumulih Municipality" if name_kabupaten=="Kota Prabumulih"
replace name_kabupaten="Kota Sawah Lunto" if name_kabupaten=="Kota Sawahlunto"





preserve
		import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
		*use ../data/crosswalk_with_treatment.dta, clear
		*use ../data/regulations/crosswalk_with_treatment_1106.dta, clear
		*keep bps_*	name_*	databank_name_old treated* any_treat*
		drop if strpos(name_2014, "Prov.")!=0
		*replace name = subinstr(name_2014, "Kab. ", "Kabupaten ",.)	
		*rename name name_kabupaten
		
		rename databank_name_old kab_name_dapoer
		*rename bps_2009 geo2_idx
		rename bps_2014 geo2_idx
		
		replace kab_name_dapoer=strtrim(kab_name_dapoer)
		
		replace kab_name_dapoer="Boven Digoel, Kab." if kab_name_dapoer=="Boven Digoel, Kab"
		replace kab_name_dapoer="Cianjur, Kab." if kab_name_dapoer=="Cianjur, Kab"
		replace kab_name_dapoer="Karo, Kab." if kab_name_dapoer=="Tanah Karo, Kab."
		replace kab_name_dapoer="Kep. Siau Tagulandang Biaro, Kab." if kab_name_dapoer=="Kep. Siau Tagulandang Biaro (Sitaro), Kab."
		replace kab_name_dapoer="Kepulauan Selayar" if kab_name_dapoer=="Selayar, Kab."
		replace kab_name_dapoer="Kepulauan Tidore, Kota" if kab_name_dapoer=="Tidore Kepulauan, Kota"
		replace kab_name_dapoer="Kepulauan Yapen, Kab." if kab_name_dapoer=="Yapen Waropen, Kab."
		replace kab_name_dapoer="Limapuluh Kota, Kab" if kab_name_dapoer=="Limapuluh Kota, Kab."
		replace kab_name_dapoer="Lubuklinggau, Kota" if kab_name_dapoer=="Lubuk Linggau, Kota"
		replace kab_name_dapoer="Mahakam Hulu, Kab." if kab_name_dapoer=="Mahakam Ulu, Kab."
		replace kab_name_dapoer="Mandailing Natal, Kab" if kab_name_dapoer=="Mandailing Natal, Kab."
		replace kab_name_dapoer="Minahasa Tenggara, Kab." if kab_name_dapoer=="Minahasa Tenggara (Mitra), Kab."
		replace kab_name_dapoer="Pasaman, Kab" if kab_name_dapoer=="Pasaman, Kab."
		replace kab_name_dapoer="Pekanbaru, Kota" if kab_name_dapoer=="Pekan Baru, Kota"
		replace kab_name_dapoer="Pidie, Kab." if kab_name_dapoer=="Aceh Pidie, Kab."
		replace kab_name_dapoer="Pulau Morotai, Kab." if kab_name_dapoer=="Morotai, Kab."
		replace kab_name_dapoer="Sijunjung, Kab." if kab_name_dapoer=="Sawahlunto Sijunjung, Kab."
		replace kab_name_dapoer="Tambrauw, Kab" if kab_name_dapoer=="Tambrauw, Kab."
		replace kab_name_dapoer="Tambrauw, Kab" if kab_name_dapoer=="Tambrauw, Kab."

		
		tempfile codes
		save `codes'
restore

replace kab_name_dapoer=strtrim(kab_name_dapoer)
merge m:1 kab_name_dapoer using `codes'
* this is a perfect merge
keep if _merge==3 // 1 observation is dropped, which is the header
drop _merge

// group var generation
egen variable = group(series_code)
order variable

/*******************************************************************************
gen tokeep = 0 // these are the variables that were used in the previous Indodapoer-GG limnkage


foreach s in  	"NA.GDP.EXC.OG.CR"	"NA.GDP.EXC.OG.KR"	"NA.GDP.INC.OG.CR"	"NA.GDP.INC.OG.KR"		 ///
	"NA.GDP.AGR.CR"	"NA.GDP.CNST.CR"	"NA.GDP.FINS.CR"	"NA.GDP.MINQ.CR"	 ///
	"NA.GDP.MNF.CR"	"NA.GDP.SRV.OTHR.CR"	"NA.GDP.TRAN.COMM.CR"	"NA.GDP.TRD.HTL.CR"	"NA.GDP.UTL.CR" ///
	"SE.JRSEC.NENR.ZS" "SE.PRM.NENR.ZS" "SE.SRSEC.NENR.ZS" ///
	"SL.UEM.TOTL" "SL.EMP.TOTL" "SL.EMP.UNDR" "SL.TLF" "SI.POV.BPL" ///
	"HOU.ELC.ACSN.ZS" "HOU.H2O.ACSN.ZS"  "HOU.MLT.MAIN.ZS"  "HOU.STA.ACSN.ZS" "HOU.MLT.MAIN.ZS" ///
	"SL.EMP.AGR.FRST.FSH" "SL.EMP.CNST" "SL.EMP.ELC" "SL.EMP.FINS" "SL.EMP.IND"  ///
	"EP.CPI.1996" "EP.CPI.2002" "EP.CPI.2007" ///
	"SL.EMP.MINQ" "SL.EMP.SOCL" "SL.EMP.TOTL" "SL.EMP.TRAD" "SL.EMP.TRAN" ///
	"SP.POP.TOTL" "SP.RUR.TOTL.ZS" "SP.URB.TOTL.ZS"  "SP.POP.1564.TO" ///
	"HOU.XPD.EDU.PC.CR" "HOU.XPD.HE.PC.CR" "HOU.XPD.PC.CR" /// 
	"REV.NRRV.SHR.CR" "REV.DAU.CR" "REV.DAK.CR" "REV.OSRV.CR" "REV.TOTL.CR" "REV.TXRV.SHR.CR" ///
	"FC.XPD.ADMN.CR" "FC.XPD.AGR.CR" "FC.XPD.ECON.CR" "FC.XPD.ENVR.CR" "FC.XPD.HE.CR" "FC.XPD.HOUS.CR" ///
	"FC.XPD.INFR.CR" "FC.XPD.PROT.CR" "FC.XPD.PUBL.CR" "FC.XPD.RELG.CR" "FC.XPD.TOUR.CR" ///
	"SH.HOSP.TOTL" "SH.PUSKESMAS.TOTL" "SI.POV.NGAP" "SI.POV.NAPR.ZS" "SH.MORB.ZS" {

	
	replace tokeep=1 if series_code=="`s'"

}



* only the vars we want
*keep if tokeep ==1 

*******************************************************************************/


rename variable old_variable
egen variable=group(old_variable)
drop old_variable

cap drop year

gen mock_id = _n //
drop AR-BE


/* RESHAPE 1 : 
	BEFORE it each line observation corresponds to a region X variable pair
	* the variables correspond to years
	AFTER it each line corresponds to a variable 
	*/
reshape long YR , i(mock_id) j(year)


* then to WIDE again
rename mock_id var_id
egen mock_id=group(geo2_idx year)

// this variable has the actual data
rename YR vars


/*******************************************************************************

PART NEEDED FOR DEDUPLICATION WHEN 2014 IDS ARE USED

egen x = min(vars), by(mock_id variable)
egen y = max(vars), by(mock_id variable)
*drop if x==0&y!=0&vars==0&t>0 // some non-proliferated districts have 0 imputed instead of missing
drop x y t
* remaining duplicates are all from the year 2013, I take average (2x9 obs)
duplicates tag mock_id variable, gen(t)
egen x = mean(vars) if t>0, by(mock_id variable)
replace vars=x if t>0&x!=.
duplicates drop mock_id variable, force
drop t
*******************************************************************************/


/* variable names have to be dropped because of the mechanics of reshape, we 
save these for later */
preserve
	duplicates drop variable, force 
	keep series_code series_name variable
	order variable series*
	sort variable
	gen variable_exists=_n
	tempfile varnames 
	save `varnames'
	export excel using ../../data/indodapoer_variables.xls, replace
restore

/* drop variables that block reshape */
drop var_id kab_name_dapoer kab_code_dapoer series_code series_name Time no_years kb1 name_*  name_2014


/* RESHAPE 2 : 

REGION 1 VAR1 YEAR1 |			REGION1 YEAR1 VAR1 VAR2 VAR3
REGION 1 VAR1 YEAR2 |			REGION1 YEAR2 VAR1 VAR2 VAR3
REGION 1 VAR1 YEAR3 | 			REGION1 YEAR3 VAR1 VAR2 VAR3
------------------- |--->		------------- --------------
REGION 1 VAR2 YEAR1 |			REGION2	YEAR1 VAR1 VAR2 VAR3 
REGION 1 VAR2 YEAR2 |			REGION2	YEAR2 VAR1 VAR2 VAR3
REGION 1 VAR2 YEAR3 |			REGION2	YEAR3 VAR1 VAR2 VAR3

currently I use 2009 IDs as the basis of the reshape which makes it not work
because some districts were created between 2009 and 2013 


                      |    year
         FAO_Adm_Name |      2013 |     Total
----------------------+-----------+----------
   Kolaka Timur, Kab. |         7 |         7 
         Kolaka, Kab. |       141 |       141 
Konawe Kepulauan, K.. |         4 |         4 
         Konawe, Kab. |       144 |       144 
Musi Rawas Utara, K.. |         6 |         6 
     Musi Rawas, Kab. |       142 |       142 
----------------------+-----------+----------



*/
reshape wide vars, i(mock_id) j(variable)

/* apply variable names and labes from original indodapoer */
gen variable = _n 
merge 1:1 variable using `varnames', gen(merge_var_names)

replace series_code=lower(series_code)
replace series_code=subinstr(series_code,".","_",.)
replace series_code=subinstr(series_code," ","",.)

qui sum variable_exists
forvalues n = 1/`r(max)' {

	local vlab = series_name[`n']
	local vname = series_code[`n']
	cap la var vars`n' "`vlab'"
	cap rename vars`n' `vname'
}

/* merge back regency names */
merge m:1 geo2_idx using `codes', update gen(merge_dist_names)

rename geo2_idx bps_2014
order kab_name_dapoer  year fc_xpd_edu_cr - sp_urb_totl_zs  bps_1993 bps_1994 ///
	bps_1995 bps_1996 bps_1997 bps_1998  bps_1999 bps_2000 bps_2001 bps_2002 ///
	bps_2003 bps_2004 bps_2005 bps_2006 bps_2007 bps_2008 bps_2009 bps_2014 ///
	name* year merge*

sort bps_1993 bps_2014 year
drop variable series_code series_name variable_exists
drop kb2


order kab_name_dapoer

save ../../data/PANEL_indodapoer_110817.dta, replace 
use ../../data/PANEL_indodapoer_110817.dta, clear


/*MERGE HISTORICAL ELECTION DATA*/
merge m:1 FAO using ../../data/crosswalk_with_masyumi.dta, gen(merge_masyumi) // missing: papua, jakarta
merge m:1 FAO using ../../data/regulations/crosswalk_with_treatment_1123.dta, gen(merge_treatment) // jakarta

gen treated1 = 0
gen treated2 = 0
gen treat_event1 = 0
gen treat_event2 = 0
forvalues t=1999/2013 {

	*replace treated1 = 1 if cum_treat`t'==1 & year>=`t'
	*replace treated2 = 1 if cum_trt`t'==1 & year>=`t'
	replace treated1 = 1 if treated`t'==1 & year>=`t'
	replace treated2 = 1 if trt`t'==1 & year>=`t'
	replace treat_event1 = 1 if treated`t'==1 & year==`t'
	replace treat_event2 = 1 if trt`t'==1 & year==`t'

}



/* CREATE PANEL DATA THAT IS CONSISTENT WITH CHANGING BORDERS */


cap gen bps_2010=bps_2009
cap gen bps_2011=bps_2009
cap gen bps_2012=bps_2009
cap drop bps_2013
gen bps_2013=bps_2014 // many regencies were created in 2013 which
	// would show up as duplicates if this was not recoded to 2013
	
preserve
	keep if year==2005
	gen border1993=1
	gen moving_id1993=string(bps_1993)

	forvalues t=1993/2014 {
		local tmo=`t'-1  // " t minus one" 
		*cap gen bps_`t'=bps_`tmo' // to interpolate for years without a specific BPS identifier
		egen c`t' = count(bps_`t'), by(bps_`t')
		if (`t'>1993) {
			gen split`t'=0
			replace split`t'=1 if c`t'!=c`tmo' // identify border changing episodes
			gen border`t'=border`tmo'  // create border change identifier
			replace border`t'=border`t'+split`t'
			gen moving_id`t'=moving_id`tmo'
			replace moving_id`t'=moving_id`tmo'+"_"+string(bps_`t') if split`t'==1 // change id if border changes
			
			
		}
	}
	keep FAO split* border* moving* 
	tempfile moving_id
	save `moving_id'
restore


merge m:1 FAO using `moving_id', update 

gen moving_id=""

forvalues t=1993/2014 {
	replace moving_id=moving_id`t' if year==`t'
}

egen id_moving = group(moving_id)
la var id_moving "Region ID which is unique for each border"

gen id_collapsed = bps_2000
la var id_collapsed "Region ID collapsed to borders in 2000"

egen missings = rowmiss(fc_xpd_edu_cr - sp_urb_totl_zs) // count how many of the variables are missing per observation. 
														// missings==151 indicates that the variable is an observation for
														// a district which did not form yet

drop if missings==151


/* this codepart compares observation numbers to actual number of districts */

forvalues t=1994/2013{

	qui distinct bps_`t'
	local max_obs =  `r(ndistinct)'
	qui count if year==`t'
	local act_obs = `r(N)'
	local flag = " " 
	if (`act_obs'>`max_obs') {
		
		local flag = "!!!"
	
	}
	disp "Year `t': `act_obs' observations for `max_obs' regions  `flag'"
	
	/*	
	Year 2000: 456 observations for 341 regions  !!!
	Year 2001: 445 observations for 354 regions  !!!
	Year 2002: 449 observations for 391 regions  !!!
	WTF
	*/


}

/* this code part shows which variables generate duplicates */
/* most duplicates are in GDP and population */
foreach v of varlist fc_xpd_edu_cr - sp_urb_totl_zs {
	local n = `n'+1
	
	egen t_`v' = count(`v'), by(moving_id year)
	qui sum t_`v', det
	if (`r(max)'!=1) {
	
		disp "`v'"
		tab t_`v'
		tab year if t_`v'>1
	
	}
	drop  t_`v'

}

/* deduplication wrt to district bortders */

egen min_missing = min(missing), by(moving_id year)
sum fc_xpd_edu_cr - sp_urb_totl_zs if min_missing != missings   // this shows that these are duplicate observations that are only present for population and gdp mostly

drop if min_missing!=missing
egen c = count(_n), by(moving_id year)
drop if FAO=="Minahasa Tenggara, Kab."&moving_id=="7103_7105"   // this is a data error, it has observation 
drop c


tsset id_moving year  // success


/* create panels for analysis */


ipolate sp_pop_totl year, by(id_moving) gen(pop_ipol) // only 4 observations are involved, the others are present

*sl_tlf =  sl_emp_totl + sl_uem_totl
*labor force = employed + unemployed

/* main variables */

* to sum
*	na_gdp_exc_og_kr // gdp excluding oil and gas
*	sl_emp_totl  // employed
*	sl_emp_undr // underemployed 
*	sl_emp_uem // unemployed 
*	sl_tlf sl_uem_totl  // labor force

* to take avg
*	se_jrsec_nenr_zs // net enrolment, junior secondary
*	si_pov_napr_zs // poverty rate
*	sh_morb_zs	 // morbidity rate

gen iv1 = Masyumi_DPR if border_imputed!=1
gen iv2 = Masyumi_DPR
gen iv3 = Masyumi_DPR if island==3
replace iv3 = Masyumi_DPR_imp if island!=3
gen iv4 = Masyumi_DPR_imp

gen masyumi_before_communists=0&Masyumi_DPR!=.
replace masyumi_before_communists=1 if Masyumi_DPR>PKI_DPR&Masyumi_DPR!=.
gen masyumi_before_communists_imp=masyumi_before_communists
replace masyumi_before_communists_imp=1 if Masyumi_DPR_imp>PKI_DPR_imp&Masyumi_DPR_imp!=.&masyumi_before_communists==.


gen log_gdp = log(na_gdp_exc_og_kr)
gen log_gdp_pc = log(na_gdp_exc_og_kr/pop_ipol)
gen lpop=log(pop_ipol)
gen unempr1=(sl_uem_totl)/(sl_uem_totl+sl_emp_totl)
gen unempr2=(sl_emp_undr+sl_uem_totl)/(sl_uem_totl+sl_emp_totl)
gen gdp_growth = d.log_gdp_pc 
winsor gdp_growth, gen(gdp_growth_win) p(0.01)

la var iv1 "Masyumi (exact matches)"
la var iv2 "Masyumi (border-adjusted)"
la var iv3 "Masyumi (exact for Java, average for others)"
la var iv4 "Masyumi (average rates)"

la var se_jrsec_nenr_zs "Net Enrolment Ratio (Junior Secondary)"
la var si_pov_napr_zs  "Poverty rate"
la var sh_morb_zs "Morbidity rate"
la var log_gdp_pc "Log of real GDP/cap, constant prices, Oil&Gas excluded"
la var gdp_growth_win "Growth rate of GDP"
la var unempr1  "Unemployment rate"
la var unempr2  "Percentage unemployed or underemployed"



	*gen island = floor(bps_1999/1000)
	gen java = 0
	replace java=1 if island==3

merge m:1 bps_2000 using ../../data/gg_corruption_and_fract2000.dta, gen(merge_fract)

/* province level regulations & restricting sample */
gen province_id = floor(bps_2014/100)
drop if province_id==11 //aceh
drop if province_id==82 //papua
drop if province_id==94 //papua
drop if province_id==91 //papua

gen province_reg = 0
replace province_reg=1 if year==	1999	&province_id==	11
replace province_reg=1 if year==	2000	&province_id==	11
replace province_reg=1 if year==	2001	&province_id==	11
replace province_reg=1 if year==	2002	&province_id==	11
replace province_reg=1 if year==	2003	&province_id==	11
replace province_reg=1 if year==	2004	&province_id==	11
replace province_reg=1 if year==	2007	&province_id==	11
replace province_reg=1 if year==	2009	&province_id==	11
replace province_reg=1 if year==	2003	&province_id==	51
replace province_reg=1 if year==	2012	&province_id==	51
replace province_reg=1 if year==	2004	&province_id==	36
replace province_reg=1 if year==	2009	&province_id==	72
replace province_reg=1 if year==	2011	&province_id==	35
replace province_reg=1 if year==	2003	&province_id==	75
replace province_reg=1 if year==	2005	&province_id==	75
replace province_reg=1 if year==	2006	&province_id==	19
replace province_reg=1 if year==	2009	&province_id==	19
replace province_reg=1 if year==	2000	&province_id==	63
replace province_reg=1 if year==	2008	&province_id==	63
replace province_reg=1 if year==	2006	&province_id==	73
replace province_reg=1 if year==	2002	&province_id==	16
replace province_reg=1 if year==	2009	&province_id==	61
replace province_reg=1 if year==	2001	&province_id==	13
replace province_reg=1 if year==	2007	&province_id==	13


/* merge unemployment from growth and government data */

preserve
	use  ../../data/gg_panel1110.dta, clear
	keep bps_1999 bps_2000 year unemp1 name
	keep if unemp1!=.
	tempfile unemp
	save `unemp'
restore
merge m:1 bps_2000 year using `unemp', gen (merge_gg)

replace unempr1 = unemp1 if unempr1==.	
drop if merge_gg==2
tsset id_moving year

replace unempr1=unempr1*100

merge m:1 bps_2012 year using ../../data/DHS/2012.dta, gen(merge_dhs_2012)
drop if merge_dhs_2012==2 //papua aceh jakarta
merge m:1 bps_2001 year using ../../data/DHS/2002.dta, gen(merge_dhs_2002) update

gen bad_audit = 0
replace bad_audit=1 if bpk_aud_subn==3
replace bad_audit=.5 if bpk_aud_subn==2


merge 1:1 FAO year using ../../data/election_events.dta, gen(merge_election) force
drop if merge_election == 2 //papua aceh jakarta + later years

save ../../data/indodap_panel_uncollapsed1109.dta, replace




			   
/*
/*MERGE HISTORICAL ELECTION DATA*/
merge m:1 FAO using ../data/crosswalk_with_masyumi.dta, gen(merge_masyumi) // missing: papua, jakarta
merge m:1 FAO using ../data/regulations/crosswalk_with_treatment_1106.dta, gen(merge_treatment) // jakarta

gen treated1 = 0
gen treated2 = 0
gen treat_event1 = 0
gen treat_event2 = 0
forvalues t=1999/2013 {

	replace treated1 = 1 if cum_treat`t'==1 & year>=`t'
	replace treated2 = 1 if cum_trt`t'==1 & year>=`t'
	replace treat_event1 = 1 if treated`t'==1 & year==`t'
	replace treat_event2 = 1 if trt`t'==1 & year==`t'

}


/* population has to be interpolated because that will be the basis of 
weighting */ 

ipolate sp_pop_totl year, by(bps_2009) gen(pop_ipol) // only 4 observations are involved, the others are present

/* create dummies & weights*/
qui tab bps_2009, gen(kab_dum)

tsset bps_2009 year
gen next_group=f.bps_moving

forvalues n = 2008(-1)1993 {

	disp `n'
	qui foreach v of varlist kab_dum* {
		cap drop maxdum
		egen maxdum = max(f.`v') if year==`n',by(next_group) 
		replace `v'=1 if year==`n'&maxdum==1
	
	}


}

qui tab bps_2009, gen(popdum)

foreach v of varlist popdum* {

	local n = `n'+1 

	qui egen latent_pop`n'=mean(pop_ipol) if `v'==1
	qui replace latent_pop`n'=0 if latent_pop`n'==.


}

drop popdum*

forvalues n=1/497 {

	qui gen effective_pop`n'=latent_pop`n'*kab_dum`n'
	qui egen total_pop`n'=rowtotal(effective_pop*)
	qui gen weight`n'=effective_pop`n'/total_pop`n'
	qui replace weight`n'=0 if weight`n'==.


}

foreach v of varlist kab_dum* {

	*replace `v'=`v'*pop_ipol

}


/* gen moving id to correctly track proliferations */
gen bps_moving = .
gen no_dists = .
forvalues n = 1994/2009 {

	replace bps_moving=bps_`n' if year==`n'
	egen t = tag(bps_`n')
	egen bps_`n'_n=total(t)
	drop t
	replace no_dists = bps_`n'_n if year==`n'
}

tsset bps_2009 year
forvalues n = 2010/2014 {

	replace bps_moving = l.bps_moving if year==`n'
	replace no_dists= l.no_dists if year==`n'
}


/* see how unique is each variable */ 
foreach v of varlist fc_xpd_edu_cr - sp_urb_totl_zs {
	cap drop `v'_c
	egen `v'_c = count(`v'), by(bps_moving year)


}

/*
foreach v of varlist fc_xpd_edu_cr_c - sp_urb_totl_zs_c {
	
	qui sum `v'
	if (`r(max)'!=1) {
		codebook `v'
	}
	
}
*/

* variables which need to be averaged instead of summed over proliferation
order hou_elc_acsn_zs hou_h2o_acsn_zs hou_mlt_main_zs hou_sta_acsn_zs hou_xpd_edu_pc_cr hou_xpd_he_pc_cr hou_xpd_pc_cr hou_xpd_totl_20poor_cr ///
	idx_hdi rod_vilg_asph_zs rod_vilg_dirt_zs rod_vilg_gravl_zs rod_vilg_othr_zs  ///
	se_jrsec_nenr_zs se_litr_15up_zs se_nexm_scr_jrsec se_nexm_scr_prm se_nexm_scr_srsec se_prm_nenr_zs se_srsec_nenr_zs ///
	sh_imm_chld_zs sh_morb_zs sh_sta_brtc_zs si_pov_napl si_pov_napr_zs si_pov_ngap sp_rur_totl_zs sp_urb_totl_zs ///
	palm_yld_prvt palm_yld_smhd palm_yld_soe 
order ep_cpi_*
* variables that have to be maxed (?) // 
order bpk_aud_subn
replace bpk_aud_subn=. if bpk_aud_subn==9 // only not unique data is actually has no info


/* save labels before collapse */
 foreach v of var * {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
  	}
  }

/* generate an indicator for sums which are all missing */
foreach v of varlist fc_xpd_edu_cr - sp_pop_totl {

	bysort bps_moving year: gen allmiss_`v'=missing(`v')

}
  
collapse (mean)any_treat hou_elc_acsn_zs-palm_yld_soe ep_cpi_* bpk_aud_subn allmiss_* (sum) fc_xpd_edu_cr - sp_pop_totl kab_dum* pop_ipol (firstnm) name_* bps_1993-bps_2014, by(bps_moving year) 

foreach v of varlist fc_xpd_edu_cr - sp_pop_totl {

	replace `v'=. if allmiss_`v'==1

}


/* restore labels after collapse */
  foreach v of var * {
 	label var `v' "`l`v''"
  }

 drop allmiss*

 /* set weights */
foreach v of varlist kab_dum* {

	replace `v'=`v'/pop_ipol

}

foreach v of varlist kab_dum* {

	qui count if `v'>0&`v'<1
	if (`r(N)'>1) {
	
		codebook `v'
	
	}

}
 
 
 save ../data/PANEL_indodapoer_102717_bps_moving.dta, replace
 
 
 /*
 /* create data according to podes waves*/
 
 gen podes_wave = year
 replace podes_wave=1996 if podes_wave==1995
 replace podes_wave=1996 if podes_wave==1994
 replace podes_wave=2000 if podes_wave==1997
 replace podes_wave=2000 if podes_wave==1998
 replace podes_wave=2000 if podes_wave==1999
 replace podes_wave=2003 if podes_wave==2001
 replace podes_wave=2003 if podes_wave==2002
 replace podes_wave=2005 if podes_wave==2004
 replace podes_wave=2008 if podes_wave==2006
 replace podes_wave=2008 if podes_wave==2007
 replace podes_wave=2011 if podes_wave==2009
 replace podes_wave=2011 if podes_wave==2010
 replace podes_wave=. if podes_wave>2011
 
 gen podes_id = bps_moving if year==podes_wave
 
 
	egen unique_obs=count(_n) if year<2012, by(bps_moving podes_wave )
	replace unique_obs = unique_obs/3 if podes_wave==1996
	replace unique_obs = unique_obs/4 if podes_wave==2000
	replace unique_obs = unique_obs/3 if podes_wave==2003
	replace unique_obs = unique_obs/2 if podes_wave==2005
	replace unique_obs = unique_obs/3 if podes_wave==2008
	replace unique_obs = unique_obs/3 if podes_wave==2011
	
drop if year>2011


/* collapse to podes waves */
/* save labels before collapse */
 foreach v of var * {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
  	}
  }

  
collapse (mean)hou_elc_acsn_zs-palm_yld_soe ep_cpi_* bpk_aud_subn  fc_xpd_edu_cr - sp_pop_totl (firstnm) name_* bps_1993-bps_2014, by(bps_moving podes_wave) 

/* restore labels after collapse */
  foreach v of var * {
 	label var `v' "`l`v''"
  }
  
 rename podes_wave year
 
  save ../data/PANEL_indodapoer_102717_bps_moving_podes.dta, replace

  merge 1:1 bps_2014 year using ../data/elections/election_cycle_data, gen(merge_elections_and_sharia)
