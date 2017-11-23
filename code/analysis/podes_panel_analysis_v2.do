cap rm indices.xls
cap rm indices.txt

cap rm indices_diff.xls
cap rm indices_diff.txt



local weights=" [aweight=pop_mean] "




putexcel set index_means.xls, replace
putexcel B1=("Whole Country Treated Mean")  C1=("Whole Country Treated SE") ///
	D1=("Whole Country Untreated Mean") E1=("Whole Country Untreated SE") ///
	F1=("Whole Country p-value of Diff.") G1=("Java Treated Mean") ///
	H1=("Java Treated SE") I1=("Java Untreated Mean") J1=("Java Untreated SE") ///
	K1=("Java p-value of Diff.") L1=("Outer Provinces Treated Mean") ///
	M1=("Outer Provinces Treated SE") M1=("Outer Provinces Unreated Mean") ///
	N1=("Outer Provinces Untreated Mean") O1=("Outer Provinces Untreated SE") ///
	O1=("Outer Provinces p-vale of Diff.") A2=("Development (1996)") ///
	A3=("Services (1996)") A4=("Healthcare (1996)") A5=("Education (1996)") ///
	A6=("Religion (1996)") A7=("Development (2011)") ///
	A8=("Services (2011)") A9=("Healthcare (2011)") A10=("Education (2011)") ///
	A11=("Religion (2011)")

putexcel B2:P11=nformat("number_d2")
*local interactions = "##i.below_mean"
*local interactions = "##above_median"
*local interactions = "##i.religious"

*local interactions = "##c.dist_bupati"
local interactions = "##c.log_dist_bupati" 
*local interactions = "##(i.kelurahan_2000 c.log_dist_bupati)" 
*local interactions = "##i.kelurahan_2000##i.remote" 
*local interactions = "##c.religion"
*local interactions = "##i.island"
*"crime" "crimef"

*local prefix = "devrevised_noja_yearlypanel70p_"
local prefix = "kelu_"
*local sample_suffix="&mean_dist_bupati_raw<=55"
local sample_suffix="&revenue_years==1&kelurahan==0"
*local covariates = "lpop"
local covariates = "lpop log_rev_total"

forvalues n=1/3 {

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
		local sample = "if island!=3`sample_suffix'"
		local mean_tr_col = "L"
		local se_tr_col = "M"
		local mean_utr_col = "N"
		local se_utr_col = "O"
		local p_col = "P"
		
	}
	
	cap rm `type'_indices_diff.xls
	cap rm `type'_indices.xls
	cap rm `type'_pre_diffs.xls
	cap rm `type'_indices_diff.txt
	cap rm `type'_indices.txt
	cap rm `type'_pre_diffs
	
	/*
	local excel_row = 2
	foreach s in  "development" "services"   "health" "educ"  "religion"  {
		local trt = "treated"
		local s = "`s'_w"
		local covariates = "lpop"
		ttest `s' `sample'&year==1996, by(ever_treated)
		putexcel `mean_tr_col'`excel_row'=(`r(mu_1)')
		putexcel `se_tr_col'`excel_row'=(`r(sd_1)')
		putexcel `mean_utr_col'`excel_row'=(`r(mu_2)')
		putexcel `se_utr_col'`excel_row'=(`r(sd_2)')
		putexcel `p_col'`excel_row'=(`r(p)')
		local excel_row=`excel_row'+1
		
		local second_row=`excel_row'+4
		ttest `s' `sample'&year==2011, by(ever_treated)		
		putexcel `mean_tr_col'`second_row'=(`r(mu_1)')
		putexcel `se_tr_col'`second_row'=(`r(sd_1)')
		putexcel `mean_utr_col'`second_row'=(`r(mu_2)')
		putexcel `se_utr_col'`second_row'=(`r(sd_2)')
		putexcel `p_col'`second_row'=(`r(p)')
		qui sum `s', det
		local iqr = floor((`r(p75)'-`r(p25)')*100)/100  


		reg d5.`s' d5.`trt' d.`covariates' `sample',  vce(cluster bps_1996) 
		outreg2 using `type'_indices_longdiff.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions)


		*reg d.`s' event`interactions' d.`covariates' `sample' ,  vce(cluster bps_1996) 
		*outreg2 using `type'_indices_diff.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions )



	}
	*/
	*local reg_types = "typeB typeC typeE typeF typeG typeH typeI typeK typeM typeN typeO typeP"
	local trt = "treated"
	*local trt = "i.masy_treat"
	
	*"sick"
	foreach s in  "log_health_infra"  "development"  "infra" "prosp" "services"  "educ"   "religion"  {
		local s = "`s'"
		qui sum `s', det
		local iqr = floor((`r(p75)'-`r(p25)')*100)/100  

		/*
		xtreg `s'_good_md `trt' `covariates' `sample', fe vce(cluster bps_1996) 
		outreg2 using `type'_indices_bin.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions)
		xtreg `s'_good_mn `trt' `covariates' `sample', fe vce(cluster bps_1996) 
		outreg2 using `type'_indices_bin.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions)
		*/
		xtreg `s' `trt' `covariates' `sample', fe vce(cluster bps_1996) 
		outreg2 using `type'_indices.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions)

		/*	
		xtreg `s'_good_md `trt'`interactions' `covariates' `sample' , fe vce(cluster bps_1996) 
		outreg2 using `type'_indices_bin.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions )
		xtreg `s'_good_mn `trt'`interactions' `covariates' `sample' , fe vce(cluster bps_1996) 
		outreg2 using `type'_indices_bin.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions)
		*/
		xtreg `s' `trt'`interactions' `covariates' `sample' , fe vce(cluster bps_1996) 
		outreg2 using `type'_indices.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions )



	}
	
	* pre-differences
	local sample = "`sample'&year==1996&dist_bupati!=.`sample_suffix'"
	
	local trt = "ever_treated"
	*local trt = "i.masy_treat"

	cap rm pre_diffs.xls
	cap rm pre_diffs.txt

	foreach s in "log_health_infra" "development"   "infra" "prosp"  "services"    "educ"  "religion"   {
		local s = "`s'"
		qui sum `s', det
		local iqr = floor((`r(p75)'-`r(p25)')*100)/100  
		/*
		reg `s'_good_md `trt' `covariates' `sample',  vce(cluster bps_1996) 
		outreg2 using `type'_pre_diffs_bin.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions)
		reg `s'_good_mn `trt' `covariates' `sample',  vce(cluster bps_1996) 
		outreg2 using `type'_pre_diffs_bin.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions)
		*/
		reg `s' `trt' `covariates' `sample',  vce(cluster bps_1996) 
		outreg2 using `type'_pre_diffs.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions)

		/*
		reg `s'_good_md `trt'`interactions' `covariates' `sample' ,  vce(cluster bps_1996) 
		outreg2 using `type'_pre_diffs_bin.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions )
		reg `s'_good_mn `trt'`interactions' `covariates' `sample' ,  vce(cluster bps_1996) 
		outreg2 using `type'_pre_diffs_bin.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions )
		*/
		reg `s' `trt'`interactions' `covariates' `sample' ,  vce(cluster bps_1996) 
		outreg2 using `type'_pre_diffs.xls , addtext(Interquantile range, `iqr', Model, FE,Clusters, 1996 Regions )
		


	}
	
}

* budget evidence

* in sharia regions a smaller share of revenue is coming from the regional government
* they have less own source revenue as well 	
xtreg rev_own_pc treated##c.mean_dist_bupati_raw  i.year if revenue_years==1&kelurahan==0, vce(cluster bps_1996) fe
xtreg rev_own_pc treated##c.mean_dist_bupati_raw lpop i.year if revenue_years==1&kelurahan==0, vce(cluster bps_1996) fe


xtreg rev_own_pc treated lpop log_rev_percap  i.year if revenue_years==1, vce(cluster bps_1996) fe
eststo  ,title("Own revenue pc")
xtreg rev_own_pc treated##c.mean_dist_bupati_raw lpop  log_rev_percap  i.year if revenue_years==1&kelurahan==0, vce(cluster bps_1996) fe
eststo  ,title("Own revenue pc")
xtreg rev_kab_pc treated lpop  log_rev_percap  i.year if revenue_years==1, vce(cluster bps_1996) fe
eststo  ,title("Regency aid pc")
xtreg rev_kab_pc treated##c.mean_dist_bupati_raw lpop  log_rev_percap  i.year if revenue_years==1&kelurahan==0, vce(cluster bps_1996) fe
eststo  ,title("Regency aid pc")

	esttab using ../evidence/revenues.tex  ///
		, star(* 0.10 ** 0.05 *** 0.01) label replace noomitted  drop(lpop _cons)
		eststo clear

xtreg rev_share_kab treated lpop i.year if revenue_years==1&kelurahan==0, vce(cluster bps_1996) fe



xtreg rev_prop_pc treated i.year if revenue_years==1&kelurahan==0, vce(cluster bps_1996) fe
xtreg rev_centr_pc treated i.year if revenue_years==1&kelurahan==0, vce(cluster bps_1996) fe


/*
* development dummies

 

foreach v of varlist development_transp  development_educ development_infrastr development_econ {

	*reg `v' treated log_rev_total lpop if year==2011&kelurahan==0, vce(cluster bps_2011) 
	* ezt azert nagyon nem hiszem el
	ivregress gmm `v' (treated=masyumi)  if year==2011&kelurahan==0&island==3, vce(cluster bps_2011) first


}
