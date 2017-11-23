/* this script creates the election database and merges 
	- calendar data
	- treatment data
	- outcomes based on electoral cycles
	*/

* set working directory - important for portability
do set_working_directory.do


foreach s in "java" "kalimantan" "maluku" "nusa_tenggara" "papua" "riau" "sulawesi" "sumatra" {


	import excel "../../data/raw/elections/elections_`s'.xlsx", sheet("Munka1") firstrow clear
	gen island="`s'"
	drop if election_year==.
	tempfile `s'
	save ``s''


}


foreach s in "java" "kalimantan" "maluku" "nusa_tenggara" "papua" "riau" "sulawesi" {


	
	append using ``s''


}

/*clean party names*/

split nominating_parties, parse ("," "&") gen(prt)

foreach p of varlist prt* {

	replace `p' = strtrim(`p')

}


gen party_aceh=0
gen party_dem=0
gen party_gerindra=0
gen party_golkar=0
gen party_hanura=0
gen party_nasdem=0
gen party_pbb =0
gen party_pbr =0
gen party_pdip =0
gen party_pgb =0
gen party_pkb =0
gen party_pkd =0
gen party_pkpi =0
gen party_pknu =0
gen party_pkp =0
gen party_pks =0
gen party_pnbk =0
gen party_pni =0
gen party_ppdi =0
gen party_ppib =0
gen party_ppp =0
gen party_psip =0
gen party_pan =0

gen count_parties=0

foreach p of varlist prt* {

replace party_aceh=1 if `p'=="Aceh"

replace party_dem=1 if `p'=="Demokart"
replace party_dem=1 if `p'=="Demokrat"
replace party_dem=1 if `p'=="Demorkat"
replace party_dem=1 if `p'=="Denokrat"

replace party_gerindra=1 if `p'=="Derindra"
replace party_gerindra=1 if `p'=="Gerindra"
replace party_gerindra=1 if `p'=="Greindra"

replace party_golkar=1 if `p'=="Golkar"
replace party_golkar=1 if `p'=="PGK"


replace party_hanura=1 if `p'=="Hanur"
replace party_hanura=1 if `p'=="Hanura"

replace party_nasdem=1 if `p'=="Nasdem"

replace party_pbb =1 if `p'=="PBB"
replace party_pbr =1 if `p'=="PBR"
replace party_pdip =1 if `p'=="PDIP"
replace party_pgb =1 if `p'=="PGB"

replace party_pkb =1 if `p'=="PKB"
replace party_pkd =1 if `p'=="PKD"

replace party_pkpi =1 if `p'=="PKIP"
replace party_pkpi =1 if `p'=="PKPI"

replace party_pknu =1 if `p'=="PKNU"
replace party_pkp =1 if `p'=="PKP"

replace party_pks =1 if `p'=="PKS"
replace party_pnbk =1 if `p'=="PNBK"
replace party_pni =1 if `p'=="PNI Marhaenis"
replace party_ppdi =1 if `p'=="PPDI"
replace party_ppib =1 if `p'=="PPIB"
replace party_ppp =1 if `p'=="PPP"
replace party_psip =1 if `p'=="PSIP"

replace party_pan =1 if `p'=="Pan"
replace party_pan =1 if `p'=="PAN"

replace count_parties=count_parties+1 if `p'!=""
}


/* clean date */

replace election_date = "10/15/2010" if election_date =="15/10/2010"
replace election_date="8/3/2010" if election_date =="8/3/20110"
/* RA mistypings : election years don't match - hand-cleaned*/
replace election_date = "10/23/2013" if election_date=="10/23/2010" & kabupaten_name=="Kabupaten Langkat"
replace election_date = "2/28/2006" if election_date=="2/28/2005" & kabupaten_name=="Kabupaten Nias"
replace election_date = "2/2/2010" if election_date=="2/2/2011" & kabupaten_name=="Kota Gunung Sitoli"
replace election_date = "10/10/2011" if election_date=="10/10/2010" & kabupaten_name=="Kabupaten Kepulauan Mentawai"
replace election_date = "6/17/2013" if election_date=="6/17/2003" & kabupaten_name=="Kabupaten Indragiri Hilir"
replace election_date = "10/11/2011" if election_date=="10/11/2010" & kabupaten_name=="Kabupaten Kampar"
* Kabupaten Tanggamus	9/27/2012 is right, the a priori info on election year was not
replace election_date = "6/28/2005" if election_date=="6/28/2015" & kabupaten_name=="Kabupaten Purbalingga" //?
replace election_date = "12/9/2015" if election_date=="12/9/2005" & kabupaten_name=="Kabupaten Kebumen" //?
replace election_date = "7/24/2005" if election_date=="7/24/2015" & kabupaten_name=="Kabupaten Semarang" 
replace election_date = "10/30/2008" if election_date=="10/30/2010" & kabupaten_name=="Kota Probolinggo" 
replace election_date = "2/27/2011" if election_date=="2/27/2010" & kabupaten_name=="Kota Tangerang Selatan" 
* Kota Bontang	12/2/2010 is right, the a priori info on election year was not
* Kabupaten Tana Tidung	11/29/2009  is right, the a priori info on election year was not
/* kota bima is completely wrong 
2008	Kota Bima	6/27/2005	Zainul Majdi	PKS, PBB & PDIP, Golkar	NO	NO	http://bola.kompas.com/read/2008/07/07/2056342/Zainul.Majdi.Badrul.Masih.Unggul.	33%	29%	NO	5272	2002
2013	Kota Bima	5/13/2010	H. Qurais H. Abidin	Demokrat, PDIP & Golkar, Gerindra	NO	NO	http://ronamase.blogspot.hu/2013/05/inilah-hasil-pilkada-walikota-bima.html	33%	22%	NO	5272	2002
*/
replace source="https://nasional.tempo.co/read/472413/kakak-beradik-jadi-pasangan-calon-wali-kota-bima" if kabupaten_name=="Kota Bima" & election_year==2008
replace winner_pct=. if kabupaten_name=="Kota Bima" & election_year==2008
replace runnerup_pct=. if kabupaten_name=="Kota Bima" & election_year==2008
replace election_date = "5/19/2008" if kabupaten_name=="Kota Bima" & election_year==2008
replace nominating_p="" if kabupaten_name=="Kota Bima" & election_year==2008
replace new="NO" if kabupaten_name=="Kota Bima"
replace incumbent="YES" if kabupaten_name=="Kota Bima" & election_year==2013
* Kabupaten Nabire	2/9/2010 OK
* Kota Jayapura 2/15/2017 OK
replace election_date = "3/3/2011" if election_date=="3/3/2010" & kabupaten_name=="Kabupaten Yalimo" 
replace election_date = "4/29/2010" if election_date=="4/29/2007" & kabupaten_name=="Kabupaten Buton Utara" 


gen day = date(election_date, "MDY")
format day %td
order day


/* merge_calendar */

merge m:1 day using ../../data/islamic_calendar.dta, gen(merge_calendar)
drop if merge_calendar==2
drop merge_calendar

gen dayofmonth=day(day)
gen month=month(day)
egen day_of_year = group(month dayo)




/* merge crosswalk */

replace kabupaten_name=subinstr(kabupaten_name, "Kabupaten", "Kab.", 1)
replace kabupaten_name=subinstr(kabupaten_name, "Kapubaten", "Kab.", 1)
replace kabupaten_name=strtrim(kabupaten_name)
replace kabupaten_name="Kab. Fak-Fak" if kabupaten_name=="Kab. Fakfak"
replace kabupaten_name="Kab. Karang Asem" if kabupaten_name=="Kab. Karangasem"
replace kabupaten_name="Kab. Tanah Karo" if kabupaten_name=="Kab. Karo"
replace kabupaten_name="Kab. Selayar" if kabupaten_name=="Kab. Kepulauan Selayar"
replace kabupaten_name="Kab. Kep. Siau Tagulandang Biaro (Sitaro)" if kabupaten_name=="Kab. Kepulauan Siau Tagulandang Biaro"
replace kabupaten_name="Kab. Yapen Waropen" if kabupaten_name=="Kab. Kepulauan Yapen"
replace kabupaten_name="Kab. Limapuluh Kota" if kabupaten_name=="Kab. Lima Puluh Kota"
replace kabupaten_name="Kab. Mahakam Hulu" if kabupaten_name=="Kab. Mahakam Ulu"
replace kabupaten_name="Kab. Minahasa Tenggara (Mitra)" if kabupaten_name=="Kab. Minahasa Tenggara"
replace kabupaten_name="Kab. Ponorogo" if kabupaten_name=="Kab. Ponogoro"
replace kabupaten_name="Kab. Morotai" if kabupaten_name=="Kab. Pulau Morotai"
replace kabupaten_name="Kab. Sawahlunto Sijunjung" if kabupaten_name=="Kab. Sijunjung"
replace kabupaten_name="Kab. Yahukimo" if kabupaten_name=="Kab. Yakuhimo"
replace kabupaten_name="Kota Bau-bau" if kabupaten_name=="Kota Baubau"
replace kabupaten_name="Kota Tidore Kepulauan" if kabupaten_name=="Kota Kepulauan Tidore"
replace kabupaten_name="Kota Lubuk Linggau" if kabupaten_name=="Kota Lubuklinggau"
replace kabupaten_name="Kota Pekan Baru" if kabupaten_name=="Kota Pekanbaru"
replace kabupaten_name="Kab. Aceh Pidie" if kabupaten_name=="Kab. Pidie"



preserve 
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	rename name_2014 kabupaten_name
	drop if strpos(kabupaten_name, "Prov")!=0
	tempfile crossw
	save `crossw'
restore

merge m:1 kabupaten_name using `crossw', gen(merge_crosswalk)
drop if merge_crosswalk==2
drop merge_crosswalk

gen year = election_year
order FAO year

save ../../data/election_events.dta, replace

/*

/* we have to inflate the data to non-election years as well */

gen year=year(day)
sort bps_2014 year
bysort bps_2014: gen cycle=_n
gen election_id = 10*bps_2014+cycle
gen true_obs=1
tsset bps_2014 year
tsfill, full
replace true_obs=0 if true_obs==.
replace election_id = l.election_id if election_id==.
drop if election_id ==. // observations before first elections


/* merge elected bupati names */
preserve
	keep if elected_bupati!=""
	*keep if election_id!=.
	keep election_id election_year - holidays30
	*keep election_id elected_bupati
	*duplicates drop election_id elected_bupati, force
	tempfile names
	save `names'
restore
merge m:1 election_id using `names', gen(merge_names) update

/*
preserve
	/* save cycle data */
	keep bps_2014 year cycle election_id
	save ../data/elections/cycles.dta, replace
restore	
*/


*gen bupati = strtrim(lower(elected_bupati))

/* merge regulations */
merge 1:m bps_2014 year election_id using ../data/regulations/treatment_with_bupati_yearly.dta, gen(merge_regulations)
//merge==1 means that there is no sharia in that year
//merge==2 means that the regulation was made by sitting bupati before first direct election
tab election_id if merge_regulations==2


drop if merge_regulations==2 // 



// THIS DECIDES IF IT IS AN ELECTION PANEL OR A YEARLY PANEL
collapse (firstnm) day - cycle (max) treated_* treated (sum) regulation_count=treated (first) name_2014 (max) cum_treat* (max) election_changed, by( election_id)

*replace year=year-1

*merge 1:1 bps_2014 year using  ../data/elections/running_sum_of_regulations_by_distr.dta, gen(merge_running_sum)
// merge_running_sum=1 : those regions which never had sharia but had an election in that year --> replace to zero
// merge_running_sum=2 : those regions which had sharia but did not had an election in this year-region observation -- > to drop
*drop if merge_running_sum==2
*replace cum_treated = 0 if cum_treated == .
*replace cum_treated_previous = 0 if cum_treated_previous == .


// no regulation has 0 not .
foreach v of varlist treated* regulation_count {

	replace `v'=0 if `v'==.

}


*tsset election_id year
tsset bps_2014 year

// variable creations

gen margin_pc = winner_pctage - runnerup_pctage

gen province_id = floor(bps_2014/100)
drop island
gen island = floor(bps_2014/1000)
drop if province_id==11 //aceh is different

replace island = 1 if island== 2 // Riau Islands to Sumatra
replace island = 4 if province_id==52 // NTB is predominantly Islamic, while 
	// the remainder the Lesser Sunda Islands, NTT and Bali are either Christian
	// or Hindu, so NTB gets is own "Island Code"
replace island = 9 if province_id==82 // Maluku and Papua were under the same
	// island code earlier on
	
label define islands 1 "Sumatra and Riau" 3 "Java" 4 "West Nusa Tenggara" ///
	5 "Bali and East Nusa Tenggara" 6 "Kalimantan" 7 "Sulawesi" 8 "Maluku" ///
	9 "Papua"

la val island islands

gen islamic_majority=0
replace islamic_majority=1 if island==1
replace islamic_majority=1 if island==3
replace islamic_majority=1 if island==6	
replace islamic_majority=1 if island==7 & province_id!=75 // Sulawesi Utara province of Sulawesi is not Islamic majority
replace islamic_majority=1 if province_id==52 // NTB is Islamic
replace islamic_majority=1 if island==8 & province_id!=82 // Maluku Utara province of Maluku is not Islamic majority (roughly ~50%)




gen ramadan2=ramadan
replace ramadan2=1 if before_Ramadanstarts<30
replace ramadan2=1 if after_Ramadanstarts<60

gen ramadan3=ramadan
replace ramadan3=1 if before_Ramadanstarts<10
replace ramadan3=1 if after_Ramadanstarts<40

gen ramadan4=ramadan
replace ramadan4=1 if after_Ramadanstarts<60
*Newyear Mawlid Isra
egen islamic_holiday = rowmax(ramadan hajj Eid*  )

foreach n in 1 3 5 7 10 14 {
foreach s in "absdays" "before" "after" {
		gen islamic_holiday_`s'_`n'=islamic_holiday
		foreach h of varlist Eid*  {
			replace islamic_holiday_`s'_`n'=1 if `s'_`h'<=`n'
		
		}
		/*
		replace islamic_holiday = 1 if absdays_Mawlid<=3
		replace islamic_holiday = 1 if absdays_EidAlAdha<=3
		replace islamic_holiday = 1 if absdays_EidAlFitr<=3
		replace islamic_holiday = 1 if absdays_Isra<=3
		replace islamic_holiday = 1 if absdays_Ramad<=3
		replace islamic_holiday = 1 if absdays_Newye<=3*/

	}

}


// Merge Masyumi
gen bps_2011=bps_2009
merge m:1 bps_2011 using ../data/masyumi_1955.dta, gen (merge_election55)


save ../data/elections/election_cycle_data.dta, replace

/*
gen match=1
/* newly elected and outgoing bupatis are wrongly matched */

replace match=0 if elected_bupati=="Drs. H. Nasrul Abit" & BupatiName=="H. Darizal Basir"
replace match=0 if elected_bupati=="Drs. H . Irdinansyah Tarmizi" & BupatiName=="M.SHADIQ PASADIGOE"
replace match=0 if elected_bupati=="Drs . Syamsu Rahim" & BupatiName=="ACHMAD YUNIS"
replace match=0 if elected_bupati=="Drs. H. Burhanuddin Husin, M.M." & BupatiName=="H. Jefri Noer"
replace match=0 if elected_bupati=="H. Erzaldi Rosman, SE, MM" & BupatiName=="ABU HANIFAH"
replace match=0 if elected_bupati=="Sukmawijaya" & BupatiName=="?"
replace match=0 if elected_bupati=="H. Aceng HM Fikri , S.Ag." & BupatiName=="AGUS SUPRIADI"
replace match=0 if elected_bupati=="H. Yoyok Riyo Sudibyo" & BupatiName=="Bambang Bintoro, SE"
replace match=0 if elected_bupati=="Prof. Dr. Ir. H Sumpeno Putro" & BupatiName=="SUHARTO"
replace match=0 if elected_bupati=="Ir. H. Gusti Khairul Saleh, M.M." & BupatiName=="H. M. MUCHLIS GAFURI"
replace match=0 if elected_bupati=="H. Muhidin, M.Si" & BupatiName=="H. A. YUDHI WAHYUNI"
replace match=0 if elected_bupati=="A. M. Sukri A. Sappewali" & BupatiName=="H. A. Patabai Pabokori"

replace match=0 if elected_bupati=="Drs. A.S. Tamrin, M.H." & BupatiName=="MZ. AMIRUL TAMIM"

replace BupatiName=strtrim(BupatiName)
replace match=0 if elected_bupati=="Rusda Mahmud" & BupatiName=="ANDI KAHARUDDIN"

gen election_id2 = election_id
replace election_id2 = election_id2-1 if match==0

* drop pre 2005 treatemtn


preserve 
	keep bps_2014 year election_id-election_id2 elected_bupati
	keep if treated==1
	sort election_id2
	gen t = 0
	replace t = 1 if election_id2!=election_id
	order election_id* year t BupatiName elected_bupati 
	sort election_id2
	drop election_id
	rename election_id2 election_id
	tempfile corrected_cycles
	save `corrected_cycles'
restore

drop merge_names - election_id2

merge 1:1 election_id2 year using `corrected_cycles'
