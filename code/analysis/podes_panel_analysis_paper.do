
use ../../data/podes_panel_long_yearly_70p.dta, clear

la var log_dist_bupati "Log(dist) to center"
la var treated "Has any Sharia"
la var lpop "Log(population"

eststo clear

*local interactions = "##c.log_dist_bupati" 
local interactions = "##c.mean_dist_bupati_raw" 


local prefix = "../../evidence/baseline_"
*local sample_suffix="&mean_dist_bupati_raw<=55"
*local sample_suffix="&revenue_years==1&kelurahan==0"
local covariates = "lpop "
*local covariates = "lpop log_rev_total"

forvalues n=1/1 {

	if (`n'==1) {
		local type="`prefix'all"
		*local sample = "if merged_share>.95"
		local sample = "if year!=.`sample_suffix'"
		local mean_tr_col = "B"
		local se_tr_col = "C"
		local mean_utr_col = "D"
		local se_utr_col = "E"
		local p_col = "F"		
	}
	if (`n'==2) {
		local type="`prefix'jawa"
		*local sample = "if merged_share>.95&island==3"
		local sample = "if island==3`sample_suffix'"
		local mean_tr_col = "G"
		local se_tr_col = "H"
		local mean_utr_col = "I"
		local se_utr_col = "J"
		local p_col = "K"
	}
	if (`n'==3) {

		local type="`prefix'outer"
		*local sample = "if merged_share>.95&island!=3"
		local sample = "if island!=3&islamic_majority==1&province_id!=11`sample_suffix'"
		local mean_tr_col = "L"
		local se_tr_col = "M"
		local mean_utr_col = "N"
		local se_utr_col = "O"
		local p_col = "P"
		
	}
	
	
	*local reg_types = "typeB typeC typeE typeF typeG typeH typeI typeK typeM typeN typeO typeP"
	local trt = "treated"
	*"log_health_infra"
	*"sick"
	*"religion"
	la var `trt' "Sharia"
	foreach s in    "development" "infra" "services"  "educ"  "health"    {
		local s = "`s'"
		qui sum `s', det
		local iqr = floor((`r(p75)'-`r(p25)')*100)/100  

		*`trt'##java
		xtreg `s' `trt'  `covariates' `sample', fe vce(cluster bps_1996) 
		eststo  ,title("`s'") 
	

	}
	
	esttab using `type'_fe.tex  ///
				, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("Development" "Infrastructure" "Services" "Education" "Healthcare" "Religion" )   drop(lpop _cons )
				eststo clear
	
	la var `trt' "Has any Sharia"
	
	*************
	*"religion"
	foreach s in    "development" "infra" "services"  "educ"  "health"    {
		local s = "`s'"
		qui sum `s', det
		local iqr = floor((`r(p75)'-`r(p25)')*100)/100  

		*`interactions'##java
		xtreg `s' `trt'`interactions'  `covariates' `sample' , fe vce(cluster bps_1996) 
		local dist_where_zero=abs(_b[1.treated]/_b[1.treated#c.mean_dist_bupati_raw])
		disp `dist_where_zero'
		eststo  ,title("`s'")  addscalar(distance `dist_where_zero')


	}
	la var mean_dist_bupati_raw "Km"
	esttab using `type'_fe_inter.tex  ///
		, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("Development" "Infrastructure"  "Services" "Education" "Healthcare" "Religion" ) ///
		drop(lpop _cons 0.treated  mean_dist_bupati_raw 0.treated#c.mean_dist_bupati_raw) scalars(distance) ///
		nonotes addnotes("Standard errors are clustered at 2000 borders." "Control: log(population)")
		eststo clear
	***************
	* pre-differences

	
	/*
	local trt = "ever_treated"
	la var ever_treated "Would-be treated"
	la var mean_dist_bupati_raw "Km"
	local sample = "`sample'&year==1996&dist_bupati!=.`sample_suffix'"
	

	foreach s in "development"  "services"  "educ"  "health"  "religion"   {
		local s = "`s'"
		qui sum `s', det
		local iqr = floor((`r(p75)'-`r(p25)')*100)/100  
		*##java
		reg `s' `trt' `covariates' `sample',  vce(cluster bps_1996) 
		eststo  ,title("`s'")



	}
	esttab using `type'_prediff.tex  ///
		, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("Development" "Services" "Education" "Healthcare" "Religion" )  drop(lpop _cons)
		eststo clear
	
	foreach s in "development" "services"  "educ"  "health"  "religion"   {
		local s = "`s'"
		qui sum `s', det
		local iqr = floor((`r(p75)'-`r(p25)')*100)/100  
		*`trt'`interactions'##java
		reg `s' `trt'`interactions'  `covariates' `sample' ,  vce(cluster bps_1996) 	
		eststo  ,title("`s'")

	}
	esttab using `type'_prediff_inter.tex  ///
	, star(* 0.10 ** 0.05 *** 0.01) label replace mtitles("Development"  "Services" "Education" "Healthcare" "Religion" )    drop(lpop _cons 0.ever_treated mean_dist_bupati_raw 0.ever_treated#c.mean_dist_bupati_raw)
	eststo clear
	*/
}
/*
tab year, gen(yd)

*replace rev_own_pc = 0 if rev_own_pc == . & revenue_years==1
*replace rev_kab_pc = 0 if rev_kab_pc == . & revenue_years==1

gen same_sample=0
replace same_sample=1 if rev_own_pc!=.&rev_kab_pc!=.

la var treated "Has any Sharia"
la var mean_dist_bupati_raw "Km"
eststo clear
xtreg rev_own_pc treated lpop   yd* if revenue_years==1&mean_dist_bupati_raw!=.&same_sample==1, vce(cluster bps_1996) fe
eststo  ,title("Own revenue pc")
xtreg rev_own_pc treated##c.mean_dist_bupati_raw lpop    yd* if revenue_years==1&same_sample==1, vce(cluster bps_1996) fe
eststo  ,title("Own revenue pc")
xtreg rev_kab_pc treated lpop   yd* if revenue_years==1&mean_dist_bupati_raw!=.&same_sample==1, vce(cluster bps_1996) fe
eststo  ,title("Regency aid pc")
xtreg rev_kab_pc treated##c.mean_dist_bupati_raw lpop    yd* if revenue_years==1&same_sample==1, vce(cluster bps_1996) fe
eststo  ,title("Regency aid pc")

	esttab using ../evidence/revenues.tex  ///
		, star(* 0.10 ** 0.05 *** 0.01) label replace noomitted  drop(lpop _cons yd* 0.treated) ///
		nonotes addnotes("Standard errors are clustered at 1996 borders") ///
		mtitles("Own Rev." "Own Rev." "Aid fr. Region" "Aid fr. Region")  
		eststo clear 
