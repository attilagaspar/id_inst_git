
* matching geo2_idx vars
use "../../data/raw/gg/govandgrowth_distribution.dta", clear


gen name = subinstr(name09, "Kab. ", "Kabupaten ",.)

egen i = group(name)

preserve
		import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
		*keep bps_1993	bps_2001	bps_2009	bps_2014	name_2001	name_2014 databank_name_old
		drop if strpos(name_2014, "Prov.")!=0
		gen name = name_2000
		duplicates drop name, force
		keep bps_1993-bps_2000 name_1993-name_2000 name_2005 name
		replace name = subinstr(name, "Kab. ", "Kabupaten ",.)	
		*rename name name_kabupaten
		
		

		/* growth and government names is not consistent with crosswalk 2000 names */
		replace name = "Kabupaten Aceh Pidie" if name=="Kabupaten Pidie"
		replace name = "Kabupaten Jakarta Utara" if name=="Kabupaten Adm. Kepulauan Seribu"
		replace name = "Kabupaten Batanghari" if name=="Kabupaten Batang Hari"
		replace name = "Kabupaten Bintan" if name=="Kabupaten Kepulauan Riau"
		replace name = "Kabupaten Bolaang Mongondow" if name=="Kabupaten Bolaang Mengondow"
		replace name = "Kabupaten Bulungan" if name=="Kabupaten Bulongan"
		replace name = "Kabupaten Halmahera Barat" if name=="Kabupaten Maluku Utara"
		replace name = "Kabupaten Kepulauan Sangihe" if name=="Kabupaten Sangihe Talaud"
		replace name = "Kabupaten Konawe" if name=="Kabupaten Kendari"
		replace name = "Kabupaten Kota Baru" if name=="Kota Baru"
		replace name = "Kabupaten Kuantan Singingi" if name=="Kabupaten Kuantan Sengingi"
		replace name = "Kabupaten Kutai Kartanegara" if name=="Kabupaten Kutai"
		replace name = "Kabupaten Limapuluh Kota" if name=="Kabupaten Lima Puluh Koto"
		replace name = "Kabupaten Musi Banyuasin" if name=="Kabupaten Musi Banyu Asin"
		replace name = "Kabupaten Polewali Mandar" if name=="Kabupaten Polewali Mamasa"
		replace name = "Kabupaten Sawahlunto Sijunjung" if name=="Kabupaten Sawahlunto/Sijunjung"
		replace name = "Kabupaten Tanah Karo" if name=="Kabupaten Karo"
		replace name = "Kabupaten Tulang Bawang" if name=="Kabupaten Tulangbawang"
		replace name = "Kota Dumai" if name=="Kota D U M A I"
		replace name = "Kota Jakarta Barat" if name=="Kodya Jakarta Barat"
		replace name = "Kota Jakarta Pusat" if name=="Kodya Jakarta Pusat"
		replace name = "Kota Jakarta Selatan" if name=="Kodya Jakarta Selatan"
		replace name = "Kota Jakarta Timur" if name=="Kodya Jakarta Timur"
		replace name = "Kota Jakarta Utara" if name=="Kodya Jakarta Utara"
		replace name = "Kota Madiun" if name_2005=="Kota Madiun"
		replace name = "Kota Makassar" if name=="Kota Ujung Pandang"
		replace name = "Kota Mojokerto" if name_2005=="Kota Mojokerto"
		replace name = "Kota Palangkaraya" if name=="Kota Palangka Raya"
		replace name = "Kota Sawahlunto" if name=="Kota Sawah Lunto"


		
		tempfile codes
		save `codes'
restore




drop y0706 - ary_pcexp0701
drop pop0706 - gpop0501
drop gy_rpcexp0701
drop pop* merge_SI
drop GAW0107 - GAUnypcexp0105

*rename *2000 *00
rename *2001 *01
rename *2002 *02
rename *2003 *03
rename *2004 *04
rename *2005 *05
rename *2006 *06
rename *2007 *07
*rename *2008 *08
*rename *2009 *09

rename *00 *2000
rename *01 *2001 
rename *02 *2002 
rename *03 *2003 
rename *04 *2004 
rename *05 *2005 
rename *06 *2006 
rename *07 *2007 
rename *08 *2008 
rename *09 *2009 

merge 1:1 name using `codes', gen(merge_codes) // perfect match except for jakarta
drop if strpos(name,"Jakarta")!=0 // jakarta needs to be dropped
drop if strpos(name,"Seribu")!=0 // jakarta 


*drop *199*

order name* bps_*

/*save labels*/
foreach v of varlist povhc_200*	cy200*	RGDPnoil_200*	y200*	GDPnoil200*	agr_200*	min_200*	man_200*	///
	enr_200*	con_200*	trd_200*	trs_200*	fin_200*	ser_200*	POPUR200*		age_prim200* ///
	age_secj200*	age_sech200*	enrolp200*	enroly200*	enrols200*	scl_sd200*	scl_smp200*	scl_sma200*	none_scl200* ///
	scl200*	prim200*	secj200*	sech200*	NER_sd200*	NER_smp200*	NER_sma200*	enPRIM200*	enSECJ200*	enSECH200* ///
	enSECT200*	PRIM200*	SECJ200*	SECH200*	lf_200*	employ200*	unempl200*	POPEMP200*	AGR200*	MIN200*	MAN200*	ENR200* ///
	CON200*	TRD200*	TRS200*	FIN200*	SER200*	OTHER_SECTOR200*	SH_AGR200*	SH_MIN200*	SH_MAN200*	SH_ENR200*	SH_CON200*	///
	SH_TRD200*	SH_TRS200*	SH_FIN200*	SH_SER200*	SH_OTHER_SECTOR200*	sh_urban200*	hh_200*	NVIL_200*	///
	TELP_200*	TELPHH200*	coastal200*	valey200*	hill200*	plainland200*	LLOCK_200*	ROAD_200*	///
	road_asphalt200*	road_rocks200*	road_soil200*	road_other200*	SHCRIME_200*	///
	s_fight200*	s_thieving200*	s_robbery200*	s_plundery200*	s_mistreat200*	s_burn200*	s_murder200*	///
	s_suicide200*	s_othercrime200*	s_raping200*	s_drugabuse200*	s_drugtraf200*	///
	s_childtraf200*	fight200*	thieving200*	robbery200*	plundery200*	murder200*	mistreat200*	///
	burn200*	suicide200*	othercrime200*	SH_road_asphalt200*	SH_road_rocks200*	SH_road_soil200* ///
	SH_road_other200*	SH_coastal200*	SH_valey200*	SH_hill200*	SH_plainland200*	raping200* ///
	drugabuse200*	drugtraf200*	childtraf200*	earthquake200*	volcanic200*	dryness200*	forestfire200* ///
	flood200*	fog200*	mudslides200*	abrasi200*	tsunami200*	disother200*	freq_earthquake200*	///
	freq_mudslides200*	freq_flood200*	flashflood200*	gempatsunami200*	fire200*	///
	typhoon200*	freq_flashflood200*	freq_gempatsunami200*	freq_tsunami200*	freq_typhoon200*	///
	freq_volcanic200*	freq_forestfire200*	vic_mudslides200*	vic_flood200*	vic_flashflood200*	///
	vic_earthquake200*	vic_gempatsunami200*	vic_tsunami200*	vic_typhoon200*	vic_volcanic200*	///
	vic_forestfire200*	loss_mudslides200*	loss_flood200*	loss_flashflood200*	loss_earthquake200* /// 
	loss_gempatsunami200*	loss_tsunami200*	loss_typhoon200*	loss_volcanic200*	///
	loss_forestfire200*	pcexp200*		PCY_200*	PCYnoil_200*	PLY_200*	lnPLY_200*	lnPCY_200*	///
	lnPCYnoil_200*		 ///	
	nm_bup200*	type_bup200*	party_bup200*	neword_200*	demind_200*	demdir_200*	caretaker_200*	izin_pma200* ///
	pma200*	izin_pmdn200*	pmdn200*	IT_200*	IB_200*	NTP_200*	NEW200*	gini_sectsus200*	gini_sector200*	rev200*	 ///
	dev200*	rtn200*	shagr200*	shmin200*	shman200*	shenr200*	shcon200*	shtrd200*	 ///
	shtrs200*	shfin200*	shser200*	Dmigas200*	migas200*	LOGpop200*	LOGpopsus200*	LOGpopeduc200*	LOGlf_200* ///
	SQRlnPCY_200*	firm_200*	YPRVCU_200*	LTLNOU_200*	VTLVCU_200*	FTTLCU_200*	HHI_YPRVCU200*	///
	HHI_LTLNOU200*	HHI_VTLVCU200*	HHI_FTTLCU200*	top1_YPRVCU200*	top1_LTLNOU200*	top1_VTLVCU200*	///
	top1_FTTLCU200*	top5_YPRVCU200*	top5_LTLNOU200*	top5_VTLVCU200*	top5_FTTLCU200*		///
	manuf_200*	sh_vamanuf200*	cpi200*	 {
	
	
	local varname = substr("`v'",1,length("`v'")-4)
	*disp "`varname'"
	disp "`v'"
	local lab_`varname' : variable label `v'
	
	
	
}


/* time invariant variables */
foreach v of varlist * {

if strpos("`v'","200")==0 {

	disp "`v'"

}

}



preserve
	keep bps_2000 CORN1 CORN2 CORNBUR CORN3 CORV1 CORV2 CORVBUR CORV3 COREX1 COREX2 ELF RF 
	save ../../data/gg_corruption_and_fract2000.dta, replace
restore



reshape long	povhc_	cy	RGDPnoil_	y	GDPnoil	agr_	min_	man_	///
	enr_	con_	trd_	trs_	fin_	ser_	POPUR		age_prim ///
	age_secj	age_sech	enrolp	enroly	enrols	scl_sd	scl_smp	scl_sma	none_scl ///
	scl	prim	secj	sech	NER_sd	NER_smp	NER_sma	enPRIM	enSECJ	enSECH ///
	enSECT	PRIM	SECJ	SECH	lf_	employ	unempl	POPEMP	AGR	MIN	MAN	ENR ///
	CON	TRD	TRS	FIN	SER	OTHER_SECTOR	SH_AGR	SH_MIN	SH_MAN	SH_ENR	SH_CON	///
	SH_TRD	SH_TRS	SH_FIN	SH_SER	SH_OTHER_SECTOR	sh_urban	hh_	NVIL_	///
	TELP_	TELPHH	coastal	valey	hill	plainland	LLOCK_	ROAD_	///
	road_asphalt	road_rocks	road_soil	road_other	SHCRIME_	///
	s_fight	s_thieving	s_robbery	s_plundery	s_mistreat	s_burn	s_murder	///
	s_suicide	s_othercrime	s_raping	s_drugabuse	s_drugtraf	///
	s_childtraf	fight	thieving	robbery	plundery	murder	mistreat	///
	burn	suicide	othercrime	SH_road_asphalt	SH_road_rocks	SH_road_soil ///
	SH_road_other	SH_coastal	SH_valey	SH_hill	SH_plainland	raping ///
	drugabuse	drugtraf	childtraf	earthquake	volcanic	dryness	forestfire ///
	flood	fog	mudslides	abrasi	tsunami	disother	freq_earthquake	///
	freq_mudslides	freq_flood	flashflood	gempatsunami	fire	///
	typhoon	freq_flashflood	freq_gempatsunami	freq_tsunami	freq_typhoon	///
	freq_volcanic	freq_forestfire	vic_mudslides	vic_flood	vic_flashflood	///
	vic_earthquake	vic_gempatsunami	vic_tsunami	vic_typhoon	vic_volcanic	///
	vic_forestfire	loss_mudslides	loss_flood	loss_flashflood	loss_earthquake /// 
	loss_gempatsunami	loss_tsunami	loss_typhoon	loss_volcanic	///
	loss_forestfire	pcexp		PCY_	PCYnoil_	PLY_	lnPLY_	lnPCY_	///
	lnPCYnoil_	y_noil	yl	gy	gy_noil	gyl	lny	avy	ary	lnypcexp	ypcexp ///
	gy_pcexp	lny_pcexp	avy_pcexp	ary_pcexp		 ///	
	nm_bup	type_bup	party_bup	neword_	demind_	demdir_	caretaker_	izin_pma ///
	pma	izin_pmdn	pmdn	IT_	IB_	NTP_	NEW	gini_sectsus	gini_sector	rev	 ///
	dev	rtn	GAW	GAUn	GAUnypcexp	shagr	shmin	shman	shenr	shcon	shtrd	 ///
	shtrs	shfin	shser	Dmigas	migas	LOGpop	LOGpopsus	LOGpopeduc	LOGlf_ ///
	SQRlnPCY_	gpop	firm_	YPRVCU_	LTLNOU_	VTLVCU_	FTTLCU_	HHI_YPRVCU	///
	HHI_LTLNOU	HHI_VTLVCU	HHI_FTTLCU	top1_YPRVCU	top1_LTLNOU	top1_VTLVCU	///
	top1_FTTLCU	top5_YPRVCU	top5_LTLNOU	top5_VTLVCU	top5_FTTLCU		///
	manuf_	sh_vamanuf	cpi	rpcexp	rypcexp	gy_rpcexp	lnrpcexp_ , i(i) j(year)


foreach v of varlist povhc_	cy	RGDPnoil_	y	GDPnoil	agr_	min_	man_	///
	enr_	con_	trd_	trs_	fin_	ser_	POPUR		age_prim ///
	age_secj	age_sech	enrolp	enroly	enrols	scl_sd	scl_smp	scl_sma	none_scl ///
	scl	prim	secj	sech	NER_sd	NER_smp	NER_sma	enPRIM	enSECJ	enSECH ///
	enSECT	PRIM	SECJ	SECH	lf_	employ	unempl	POPEMP	AGR	MIN	MAN	ENR ///
	CON	TRD	TRS	FIN	SER	OTHER_SECTOR	SH_AGR	SH_MIN	SH_MAN	SH_ENR	SH_CON	///
	SH_TRD	SH_TRS	SH_FIN	SH_SER	SH_OTHER_SECTOR	sh_urban	hh_	NVIL_	///
	TELP_	TELPHH	coastal	valey	hill	plainland	LLOCK_	ROAD_	///
	road_asphalt	road_rocks	road_soil	road_other	SHCRIME_	///
	s_fight	s_thieving	s_robbery	s_plundery	s_mistreat	s_burn	s_murder	///
	s_suicide	s_othercrime	s_raping	s_drugabuse	s_drugtraf	///
	s_childtraf	fight	thieving	robbery	plundery	murder	mistreat	///
	burn	suicide	othercrime	SH_road_asphalt	SH_road_rocks	SH_road_soil ///
	SH_road_other	SH_coastal	SH_valey	SH_hill	SH_plainland	raping ///
	drugabuse	drugtraf	childtraf	earthquake	volcanic	dryness	forestfire ///
	flood	fog	mudslides	abrasi	tsunami	disother	freq_earthquake	///
	freq_mudslides	freq_flood	flashflood	gempatsunami	fire	///
	typhoon	freq_flashflood	freq_gempatsunami	freq_tsunami	freq_typhoon	///
	freq_volcanic	freq_forestfire	vic_mudslides	vic_flood	vic_flashflood	///
	vic_earthquake	vic_gempatsunami	vic_tsunami	vic_typhoon	vic_volcanic	///
	vic_forestfire	loss_mudslides	loss_flood	loss_flashflood	loss_earthquake /// 
	loss_gempatsunami	loss_tsunami	loss_typhoon	loss_volcanic	///
	loss_forestfire	pcexp		PCY_	PCYnoil_	PLY_	lnPLY_	lnPCY_	///
	lnPCYnoil_	y_noil	yl	gy	gy_noil	gyl	lny	avy	ary	lnypcexp	ypcexp ///
	gy_pcexp	lny_pcexp	avy_pcexp	ary_pcexp		 ///	
	nm_bup	type_bup	party_bup	neword_	demind_	demdir_	caretaker_	izin_pma ///
	pma	izin_pmdn	pmdn	IT_	IB_	NTP_	NEW	gini_sectsus	gini_sector	rev	 ///
	dev	rtn	GAW	GAUn	GAUnypcexp	shagr	shmin	shman	shenr	shcon	shtrd	 ///
	shtrs	shfin	shser	Dmigas	migas	LOGpop	LOGpopsus	LOGpopeduc	LOGlf_ ///
	SQRlnPCY_	gpop	firm_	YPRVCU_	LTLNOU_	VTLVCU_	FTTLCU_	HHI_YPRVCU	///
	HHI_LTLNOU	HHI_VTLVCU	HHI_FTTLCU	top1_YPRVCU	top1_LTLNOU	top1_VTLVCU	///
	top1_FTTLCU	top5_YPRVCU	top5_LTLNOU	top5_VTLVCU	top5_FTTLCU		///
	manuf_	sh_vamanuf	cpi	rpcexp	rypcexp	gy_rpcexp	lnrpcexp_ {
	
	
	la var `v' "`lab_`v''"
	
	}
	



drop y_noil -  ary_pcexp ///
 GAW GAUn GAUnypcexp ///
 LOGpop LOGpopsus LOGpopeduc LOGlf_ SQRlnPCY_ ///
 gpop ///
 rpcexp rypcexp gy_rpcexp lnrpcexp_ ///
 merge_codes 

gen unemp1 = unemp / (unemp + employ)

save ../../data/gg_panel1110.dta, replace





