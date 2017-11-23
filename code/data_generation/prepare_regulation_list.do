/* this script cleans the sharia regulation lists */

cd "C:\Users\Administrator\Desktop\sharia\code"

import excel "../data/regulations/buehler list with names and dates.xlsx", sheet("List_by_Content_(updated)")  clear

keep A-Q

* rename vars
rename A content_code
rename D province_eng
rename E province_ind
rename F kota
rename G regency_name
rename I bid
rename J prov_id
rename K kab_id

rename L regulation_code
rename M description
rename O nodocument
rename C year
rename B ovie_added
rename N url
*rename Column1 BupatiName
rename P BupatiName
rename Q DayPassed
*empty column
drop H 

destring year, force replace
*destring kota, force replace
drop kota

/* data cleaning */

* Sragen, Jawa Tengah kotára van kódolva, pedig olyan nincs
replace regency_name = "Kabupaten Sragen" if regency_name =="Kota Sragen"

* Buehler id 57 valójában Kabupaten Mojokerto és nem Kota
replace regency_name = "Kabupaten Mojokerto" if bid=="57"
replace BupatiName="SUWANDI" if bid=="57"

* bid 277 egy olyan linkre mutat, amelyik nem önálló regulation, hanem a bid 279-et emliti - mashol verifikalhato, oke
* Kota Cirebon URL javitasok
replace url="http://hukum.cirebonkota.go.id/pdf_files/PERDA12010.pdf" if regulation_code=="No 1 Year 2001" & regency_name=="Kota Cirebon"
replace url="hukum.cirebonkota.go.id/pdf_files/PERDA102013.pdf" if regulation_code=="No 10 Year 2013" & regency_name=="Kota Cirebon"
replace url="hukum.cirebonkota.go.id/pdf_files/PERDA42013.pdf" if regulation_code=="No 4 Year 2013" & regency_name=="Kota Cirebon"
replace url="hukum.cirebonkota.go.id/get_file.php?id=820" if regulation_code=="No 3 Year 2015" & regency_name=="Kota Cirebon"

** mindent, aminek a neve KOTA le kell ellenorizni hogy nem a KABUPETEN ID-re mutat

destring kab_id, force replace
destring prov_id, force replace
replace kab_id =71 if regency_name=="Kota Tangerang"

replace kab_id =74 if regency_name=="Kota Semarang"

replace kab_id =73 if regency_name=="Kota Malang"

replace kab_id =76 if regency_name=="Kota Mojokerto"

replace kab_id =74 if regency_name=="Kota Probolinggo"

replace kab_id =73 if regency_name=="Kota Bandung"
replace kab_id =75 if regency_name=="Kota Bekasi"

replace kab_id =71 if regency_name=="Kota Bogor"
replace kab_id =74 if regency_name=="Kota Cirebon"
replace kab_id =72  if regency_name=="Kota Sukabumi"
replace kab_id =78  if regency_name=="Kota Tasikmalaya"
replace kab_id = 71 if regency_name=="Kota Sorong"
replace kab_id = 71 if regency_name=="Kota Kupang"


* merge back province ids to missing 

preserve
	drop if kab_id==.
	drop if prov_id==.
	duplicates drop regency_name , force
	keep regency_name prov_id kab_id 
	tempfile codes
	save `codes'
restore


drop kab_id prov_id

merge m:1 regency_name using `codes', update

gen bps_2009=100*prov_id+kab_id

/* clean regency codes*/

replace bps_2009=7472		  if regency_name=="Bau Bau"&bps_2009==.
replace bps_2009=7311            if regency_name=="Bone"&bps_2009==. 
replace bps_2009=7401           if regency_name=="Buton"&bps_2009==.
replace bps_2009=9101          if regency_name=="Fakfak"&bps_2009==. 
replace bps_2009=7408    if regency_name=="Kaloka Utara"&bps_2009==. 
replace regency_name="Kolaka Utara" if regency_name=="Kaloka Utara"
replace bps_2009=2101         if regency_name=="Karimun"&bps_2009==. 
replace bps_2009=7403          if regency_name=="Konawe"&bps_2009==. 
replace bps_2009=1672 if regency_name=="Kota Prabumulih"&bps_2009==. 
replace bps_2009=9110         if regency_name=="Maybrat"&bps_2009==. 
replace bps_2009=1603      if regency_name=="Muara Enim"&bps_2009==. 
replace bps_2009=1609       if regency_name=="Oku Timur"&bps_2009==. 
replace regency_name="Ogan Komering Ulu Timur" if regency_name=="Oku Timur"
*replace bps_2009=1472 if year==2001&regency_name=="Kota Batam"	
replace bps_2009=2171 if year==2002&regency_name=="Kota Batam"
/*kota solok, not kabupaten solok*/
replace bps_2009=1372 if bid=="302"

/* these were missing in the previous version ! */
replace bps_2009 = 1611		if regency_name=="Empat Lawang"
replace bps_2009 = 3403		if regency_name=="Gunung Kidul"
replace bps_2009 = 1218		if regency_name=="Serdang Bedagai"
replace bps_2009 = 1405		if regency_name=="Siak"
replace bps_2009 = 3404		if regency_name=="Sleman"
replace bps_2009 = 1204		if regency_name=="Tapanuli Tengah"
replace bps_2009 = 7313		if regency_name=="Wajo"
replace bps_2009 = 7407		if regency_name=="Wakatobi"
replace bps_2009 = 1372		if regency_name=="Kota Solok"


/* what is left are empty lines from the excel */
drop if bps_2009==.

gen bps_2014=bps_2009


/* this file contains the list of regulations in themselves*/
save ../data/regulations/treatment_ovie.dta, replace

foreach s in "A" "B" "C" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" {
	gen type_`s'=0
	replace type_`s'=1 if content_code=="`s'"
}


/* collapse to panel */
collapse (firstnm) regency_name (sum) type_* , by(bps_2014 year)
	   
/* reshape to 1 line - 1 region format */
reshape wide type_A-type_P, i(bps_2014) j(year)

tempfile treatment_ovie
save `treatment_ovie'

/* load crosswalk */

import excel "../data/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear

merge 1:1 bps_2014 using `treatment_ovie', gen(merge_tr_ovie)


/* fill missings with zeroes */
forvalues t=1999/2016 {
	/* generate extra category for regulations not found by RA */
	gen type_X`t'=0
	
	
	foreach s in "A" "B" "C" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" {
		replace type_`s'`t'=0 if type_`s'`t'==.
	}

}

/* fill in extra category for regulations not found by RA */
replace type_X2003 =1 if bps_2014==1372
replace type_X2006 =1 if bps_2014==1671
replace type_X2010 =1 if bps_2014==3214
replace type_X2009 =1 if bps_2014==3217
replace type_X2006 =2 if bps_2014==3376
replace type_X2006 =1 if bps_2014==3514
replace type_X2011 =1 if bps_2014==6202
replace type_X2006 =1 if bps_2014==6206
replace type_X2002 =1 if bps_2014==6271
replace type_X2009 =1 if bps_2014==7203
replace type_X2004 =1 if bps_2014==7271
replace type_X2006 =1 if bps_2014==7271

*
gen bps_2010=bps_2009
gen bps_2011=bps_2009
gen bps_2012=bps_2009
gen bps_2013=bps_2009
gen bps_2015=bps_2014
gen bps_2016=bps_2014


/* if a region is indicated for treatment in year T, then if in year T there
are more regions with that name then that region split later and all former
parts must be indicated as treated */
forvalues t=1999/2016 {
	*gen treated`t'=0
	gen trt`t'=0
	/* generating treatment variable that is robust to border changes */
	foreach s in "A" "B" "C" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P"  "X"{
		
		replace trt`t'=1 if type_`s'`t'==1
		
		/*
		egen treat_`s'`t'=max(type_`s'`t'), by(bps_`t')
		qui corr treat_`s'`t' type_`s'`t'
		if (`r(rho)')!=1&(`r(rho)')!=. {
		
			disp "`s' `t' `r(rho)'"
		
		}
		
		replace treated`t'=1 if treat_`s'`t'!=0&treat_`s'`t'!=.*/
		
	}
	egen treated`t'=max(trt`t'), by(bps_`t')
}

/* create cumulative treatments */

gen cum_trt1999=0
gen cum_treat1999=0
replace cum_trt1999=1 if trt1999==1
replace cum_treat1999=1 if treated1999==1

forvalues t=2000/2016 {
	gen cum_trt`t'=0
	gen cum_treat`t'=0
	local l=`t'-1
	replace cum_trt`t'=1 if cum_trt`l'==1
	replace cum_treat`t'=1 if cum_treat`l'==1
	replace cum_trt`t'=1 if trt`l'==1
	replace cum_treat`t'=1 if treated`l'==1
}

drop if floor(bps_2014/100)==31 //drop jakarta
drop if strpos(FAO,"Prop.")!=0

save ../data/regulations/crosswalk_with_treatment_1106.dta, replace

stop
/*
/*create treatment vars explicitly for PODES matching */

foreach py in 2000 2003 2005 2008 2011 {

	gen treatedby_`py'=0
	gen treatedby_`py'b=0
	local lastyear = `py'-1
	forvalues t=1999/`lastyear' {
	
		replace treatedby_`py'=1 if treated`t'==1
		replace treatedby_`py'b=1 if treated`t'==1
		replace treatedby_`py'b=1 if treated`py'==1
		
	}


}

save ../data/regulations/treatment_for_podes_1106.dta, replace
stop

/* FROM HERE ONLY REGULATIONS FROM DIRECTLY ELECTED BUPATIS ARE CONSIDERED */


merge m:1 bps_2014 year using ../data/elections/cycles.dta, gen(merge_cycles)
order regulation_id bps_2014 year election_id BupatiName
sort regulation_id bps_2014 year election_id BupatiName

* merge_cycles = 1: regulation before first direct election
* merge_cycles = 2: year without regulation
keep if merge_cycles==3

/* the earlier regulation will be recoded to previous election if there are multiple names */
split regulation_code, gen(r)
destring r2 r4, force replace

// regulation code missing but there is buehler id - ovie elbaszta?
//drop if r2==.
rename r2 reg_no
rename r4 reg_year
sort bps_2014 reg_year reg_no
// drop if bupati unknown
//drop if BupatiName=="?"

replace BupatiN=strtrim(BupatiN)
replace BupatiName="H. MUHIDIN" if BupatiName=="H.A.YUDHI WAHYUNI" // walikota of the same person
replace BupatiName="H. M. Aunul Hadi" if BupatiName=="H. FAKHRUDDIN" // died in office
replace BupatiName="H. M. Aunul Hadi" if BupatiName=="H.M. AUNUL HADI" // died in office

egen t = tag(election_id BupatiName)
egen c= total(t), by(election_id)



// hand-coded cases when regulation was made in election year but no by winning bupati
// 226 224: Ano Sutrisno was walikota of Cirebon who died in office, that is not an error

gen election_changed=0

foreach n in 171 166 328 349 422 479 22 82 152 83 152 355 124 {
	replace election_changed=1 if regulation_id==`n'
	replace election_id=election_id-1 if regulation_id==`n'

}


// ez azert kell, mert az adott evre nincs megfelelo election id megfigyeles
replace year=year-1 if election_changed==1

*drop if ovie=="*"
*drop if nodocument=="*"
drop if nodocument=="*"&ovie=="*"

replace nodocument="1" if nodocument=="*"
replace ovie="1" if ovie=="*"
destring nodocument ovie, force replace
replace nodocument=0 if nodocument==.
replace ovie=0 if ovie==.




collapse (max) treated_* treated (sum) regulation_count=treated (first)  name_2014 BupatiName cum_treated*  (max) election_changed, by(bps_2014 year election_id)
	


save ../data/regulations/treatment_with_bupati_yearly.dta, replace
/* DISTRICTS WHERE BPS_2014!=BPS_2009
none of these had treatment in the given years 
Banggai Laut, Kab.	7211
Bulungan, Kab.	6502
Kalimantan Utara, Prop.	6500
Kolaka Timur, Kab.	7411
Konawe Kepulauan, Kab.	7412
Mahakam Hulu, Kab.	6411
Malaka, Kab.	5321
Malinau, Kab.	6501
Mamuju Tengah, Kab.	7606
Manokwari Selatan, Kab.	9111
Morowali Utara, Kab.	7212
Musi Rawas Utara, Kab.	1613
Nunukan, Kab.	6504
Pangandaran, Kab.	3218
Pegunungan Arfak, Kab.	9112
Penukal Abab Lematang Ilir, Kab.	1612
Pesisir Barat, Kab.	1813
Pulau Taliabu, Kab.	8208
Tana Tidung, Kab.	6503
Tarakan, Kota	6571
	 */
