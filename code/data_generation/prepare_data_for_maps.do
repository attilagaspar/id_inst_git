/* this script creates the data which will be joined to the maps in QGIS for the
   brownbag talk */
cd "C:/Users/Administrator/Desktop/sharia/code"


/* MAP 1 : regional level regulations */
import excel "../data/maps/idn_adm2_simplified.xlsx", sheet("idn_adm2_simplified") firstrow clear

destring id , force replace

preserve
	use ../data/indodap_panel_uncollapsed1109.dta, clear
	keep if year==2009
	keep treat* Mas* iv* bps_2009 name cum*
	rename name name_indodapoer
	rename bps_2009 id
	tempfile indap
	save `indap'
restore
	

merge 1:1 id using  `indap', gen(merge_map)


export delimited using "C:\Users\Administrator\Desktop\sharia\data\maps\treatment_map_data.csv", replace

/*

/* MAP 1 : villages */
import excel "../data/maps/DesaIndonesia.xlsx", sheet("DesaIndonesia") firstrow clear

replace KABUPATEN=strtrim(KABUPATEN)
gen kota=0
replace kota=1 if strpos(KABU, "Kdy.")!=0
replace kota=1 if strpos(KABU, "Kodya")!=0
gen name_1999=subinstr(KABU, "Kdy.", "Kota",.)
replace name_1999=subinstr(name_1999, "Kodya", "Kota",.)
replace name_1999=subinstr(name_1999, "Kdy. ", "Kota ",.)
replace name_1999 = "Kab. "+name_1999 if kota==0

drop if strpos(PROP, "Aceh")!=0
drop if strpos(PROP, "Irian")!=0
drop if strpos(PROP, "Jakarta")!=0

preserve
	use ../data/indodap_panel_uncollapsed1109.dta, clear
	keep if year==1999
	keep bps_1999 bps_1998 name_1999 province
	*keep treat* Mas* iv* bps_2009 name
	*rename name name_indodapoer
	*drop if bps_1999==3577
	*drop if bps_1999==3576
	replace name="Kota Mojokerto" if bps_1999==3576
	replace name="Kota Madiun" if bps_1999==3577
	replace name="Kab. Kota Baru" if name=="Kota Baru"
	replace name = strtrim(name)
	*rename bps_2009 id
	tempfile indap
	save `indap'
restore

egen g = group(KABUPATEN)
preserve

	duplicates drop g, force
	reclink name_1999 using `indap', gen(merge_map) idusing(bps_1999) idmaster(g)
	duplicates drop g, force
	keep g name_1999 bps_1999 bps_1998
	tempfile regency
	save `regency'
restore

merge m:1 g using `regency', gen(merge_regency)

/* merge this to podes village names */
preserve
	use "../data/podes_all_yearly_70p.dta" , clear
	keep strid11 strid08 strid05 strid03 strid00 strid96 podes2000_nama podes2000_nama_kec podes1996_nama_kec podes1996_nama_kab bps*
	rename podes2000_nama village_name
	rename podes2000_nama_kec subdist_name
	replace village_name=strtrim(village_name)
	replace subdist_name=strtrim(subdist_name)
	save "../data/maps/podes_matched_ids.dta",replace
restore

gen village_name=upper(strtrim(DESA))
gen subdist_name=upper(strtrim(KECAMATAN))


duplicates drop bps_1998 village_name subdist_name, force
// egy falu tobb polygon is lehet, pl viz miatt, es ez ott para, vissza kell mergelni majd.
egen idmaster = group(MI_PRINX)

replace village_name=subinstr(village_name,"(","",.)
replace village_name=subinstr(village_name,")","",.)

preserve
	use "../data/maps/podes_matched_ids.dta", clear
	duplicates drop strid00, force // szetvalasok miatt nem lesz unique
	duplicates drop bps_1998 village_name subdist_name , force // 6 observations only
	replace village_name=subinstr(village_name,"(","",.)
	replace village_name=subinstr(village_name,")","",.)
	tempfile masterf
	save `masterf'
restore, preserve
	merge 1:1 bps_1998 village_name subdist_name using `masterf', gen(merge_perfect)
	keep if merge_perfect==3
	gen perfectmatch=1
	tempfile perfect 
	save `perfect'
restore



reclink bps_1998 village_name subdist_name using `masterf', wmatch(10 10 5) required(bps_1998) idmaster(idmaster) idusing(strid11) gen(mp1996)   exclude(`perfect')
append using `perfect'

drop if _merge<3

egen bestmatch= max(mp1996), by(strid11)
drop if bestmatch!=mp1996

duplicates drop strid11, force

/* merge back to panel data */
keep if strid11!=""

merge 1:m strid11 using ../data/podes_panel_long_yearly_70p.dta, gen(merge_podes_panel)
keep if merge_podes_panel==3


keep id2011 year strid11 DESA  MI_PRINX village_name Uvillage_name development  services  educ  health  religion infra prosp treated

reshape wide   development  services  educ  health  religion infra prosp treated, i(id2011) j(year)

foreach v in "development"  "services"  "educ"  "health"  "religion" "infra" "prosp" {

	gen longdiff_`v' = `v'2011-`v'1996

}

export delimited using "C:\Users\Administrator\Desktop\sharia\data\maps\village_map_data.csv", replace 
