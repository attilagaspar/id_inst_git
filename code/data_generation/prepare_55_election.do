
/* this script merges historical election dates to the district proliferation
crosswalk */


* set working directory - important for portability
do set_working_directory.do

/* load election results from excel */

foreach s in "JAWA" "KALIMANTAN" "MALUKU" "NUSATENGGARA" "SULAWESI" "SUMATERA" {

	import excel "../../data/raw/elections_1955/elections_1955.xls", sheet("`s'") firstrow clear
	gen region="`s'"
	order region
	tempfile prov_`s'
	save `prov_`s''
	clear
}

foreach s in "JAWA" "KALIMANTAN" "MALUKU" "NUSATENGGARA" "SULAWESI" "SUMATERA" {

	append using `prov_`s''

}


/* clean region names */
rename kabupaten kabu_original
gen kabupaten=kabu_original

drop if strpos(kabupaten,"Jakarta")!=0
drop if kabupaten=="TOTAL"
drop if kabupaten==""

/* name corrections come here only */

replace kabupaten="Kab. Aceh Barat" if kabupaten=="Kab Aceh Barat"
replace kabupaten="Kab. Asahan" if kabupaten=="Kab Asahan"
replace kabupaten="Kab. Lima Puluh Koto" if kabupaten=="Kab. Limapuluh Kota"
replace kabupaten="Kab. Pesisir Selatan" if kabupaten=="Kab. Pesisir Sel/Kerinci"
replace kabupaten="Kab. Sawahlunto/Sijunjung" if kabupaten=="Kab. Sawahlunto Sijunjung"
replace kabupaten="Kab. Indragiri Hulu" if kabupaten=="Kab. Indragiri"
replace kabupaten="Kab. Musi Banyu Asin" if kabupaten=="Kab. Pal/Banyu Asin"
replace kabupaten="Kab. Musi Rawas" if kabupaten=="Kab. Musi Ulu/Rawas"
replace kabupaten="Kab. Pemalang" if kabupaten=="Kab. (?) Pemelang"
replace kabupaten="Kab. Rembang" if kabupaten=="Kab. Remang"
replace kabupaten="Kab. Gunung Kidul" if kabupaten=="Kab. Gunungkidul"
replace kabupaten="Kab. Kulon Progo" if kabupaten=="Kab. Kulonprogo"
replace kabupaten="Kab. Pamekasan" if kabupaten=="Kab Pamekasan"
replace kabupaten="Kab. Barito Utara" if kabupaten=="Kab. Barito"
replace kabupaten="Kab. Kotawaringin Barat" if kabupaten=="Kab. Kotawaringin"
replace kabupaten="Kab. Kotawaringin Timur" if kabupaten=="Kab. Kotawaringin"
replace kabupaten="Kab. Barito Kuala" if kabupaten=="Kab. Barito"
replace kabupaten="Kab. Hulu Sungai Utara" if kabupaten=="Hulu Sungai Utara"
replace kabupaten="Kab. Tanah Laut" if kabupaten=="Kab. Tanah Karo"
replace kabupaten="Kab. Berau" if kabupaten=="Kab. D.I. Berau"
replace kabupaten="Kab. Kutai" if kabupaten=="Kab. D. I. Kutai"
replace kabupaten="Kab. Bolaang Mengondow" if kabupaten=="Bolaang Mongondow"
replace kabupaten="Kab. Donggala" if kabupaten=="Kab Donggala"
replace kabupaten="Kab. Karang Asem" if kabupaten=="Kab. Karangasem"
replace kabupaten="Kab. Flores Timur" if kabupaten=="Kab. Flores Timur / Pulau eler"
replace kabupaten="Kab. Timor Tengah Selatan" if kabupaten=="Kab. Timur Tengah Selatan"
replace kabupaten="Kab. Timor Tengah Utara" if kabupaten=="Kab. Timur Tengah Utara"
replace kabupaten="Kab. Rote Ndao/Sawu" if kabupaten=="Kab. Roti/Sawu"
replace kabupaten="Kab. Pandeglang" if kabupaten=="Kab. Pandenglang"
replace kabupaten="Kab. Kepulauan Riau" if kabupaten=="Kab. Kep. Riau"
replace kabupaten="Kab. Bulongan" if kabupaten=="Kab. D.I. Bulongan"


/* load crosswalk */


preserve
	/* reshape province data to regencies */
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	gen kabupaten=name_1993
	drop if strpos(kabupaten,"Jakarta")!=0
	keep if strpos(kabupaten,"Prov.")!=0
	duplicates drop bps_2014, force
	gen prov_code = floor(bps_2014/100)
	gen island = floor(prov_code/10)
	rename name_2014 prov_name
	keep prov_code prov_name island
	tempfile prov
	save `prov'
restore, preserve
	/* clean crosswalk data for merging */
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	gen kabupaten=name_1993
	la var kabupaten "Regency name for 1955 election matching"
	// jakarta is not self-governing on the kota level
	drop if strpos(kabupaten,"Jakarta")!=0
	drop if strpos(kabupaten,"Prov.")!=0
	gen prov_code = floor(bps_2014/100) 
	merge m:1 prov_code using `prov', gen(merge_prov)
	// west papua was annexed in 1969
	drop if strpos(prov_name,"Papua")!=0
	/* proliferations */
	

	gen border_imputed = 0
	replace border_imputed = 1 if kabupaten=="Kota Blitar"
	replace border_imputed = 1 if kabupaten=="Kota Magelang"
	replace border_imputed = 1 if kabupaten=="Kota Pasuruan"
	replace border_imputed = 1 if kabupaten=="Kota Probolinggo"
	replace border_imputed = 1 if kabupaten=="Kab. Sarolangun Bangko"
	replace border_imputed = 1 if kabupaten=="Kota Ujung Pandang"
	replace border_imputed = 1 if name_2000=="Kota Madiun"
	replace border_imputed = 1 if name_2002=="Kab. Rote Ndao"
	replace border_imputed = 1 if kabupaten =="Kab. Bantaeng"
	replace border_imputed = 1 if kabupaten =="Kota Pare-Pare"
	replace border_imputed = 1 if kabupaten =="Kab. Gowa"
	replace border_imputed = 1 if kabupaten =="Kab. Maros"
	replace border_imputed = 1 if kabupaten =="Kota Baru"
	replace border_imputed = 1 if kabupaten=="Kab. Aceh Tenggara"
	replace border_imputed = 1 if kabupaten=="Kota Sabang"
	replace border_imputed = 1 if kabupaten=="Kota Banda Aceh" // this is important because masyumi support levels in Aceh are otherwise unrealistic
	replace border_imputed = 1 if kabupaten=="Kab. Dairi"
	replace border_imputed = 1 if kabupaten=="Kab. Indragiri Hilir"
	replace border_imputed = 1 if kabupaten=="Kota Batam"
	replace border_imputed = 1 if kabupaten=="Kab. Lampung Barat"
	replace border_imputed = 1 if kabupaten=="Kab. Subang"
	replace border_imputed = 1 if kabupaten=="Kota Tangerang"
	replace border_imputed = 1 if kabupaten=="Kab. Batang"
	replace border_imputed = 1 if kabupaten=="Kab. Situbondo"
	replace border_imputed = 1 if kabupaten=="Kota Denpasar"
	replace border_imputed = 1 if kabupaten=="Kota Mataram"
	replace border_imputed = 1 if kabupaten=="Kota Palangka Raya"
	replace border_imputed = 1 if kabupaten=="Kab. Tapin"
	replace border_imputed = 1 if kabupaten=="Kab. Tabalong"
	replace border_imputed = 1 if kabupaten=="Kota Bitung"
	replace border_imputed = 1 if kabupaten=="Kab. Halmahera Tengah"
	replace border_imputed = 1 if kabupaten=="Kab. Buton"
	replace border_imputed = 1 if kabupaten=="Kab. Muna"
	replace border_imputed = 1 if kabupaten=="Kab. Kendari"
	replace border_imputed = 1 if kabupaten=="Kab. Kolaka"
	replace border_imputed = 1 if kabupaten=="Kota Gorontalo"
	
	*jawa*
	
	replace kabupaten = "Kab. Blitar" if kabupaten=="Kota Blitar"
	replace kabupaten = "Kab. Magelang" if kabupaten=="Kota Magelang"
	replace kabupaten = "Kab. Pasuruan" if kabupaten=="Kota Pasuruan"
	replace kabupaten = "Kab. Probolinggo" if kabupaten=="Kota Probolinggo"

	*not jawa*
	replace kabupaten = "Kab. Merangin" if kabupaten=="Kab. Sarolangun Bangko"
	replace kabupaten = "Kota Makasar" if kabupaten=="Kota Ujung Pandang"
	replace kabupaten = "Kota Madiun" if name_2000=="Kota Madiun"
	replace kabupaten = "Kab. Rote Ndao/Sawu"	   if name_2002=="Kab. Rote Ndao"
	replace kabupaten = "Kab. Bonthain" if kabupaten =="Kab. Bantaeng"
	replace kabupaten = "Kab. Pare-Pare" if kabupaten =="Kota Pare-Pare"
	*replace kabupaten = "Kab. Makasar (1)" if kabupaten =="Kab. Gowa"
	*replace kabupaten = "Kab. Makasar (2)" if kabupaten =="Kab. Maros"
	replace kabupaten = "Kab. Makasar" if kabupaten =="Kab. Gowa"
	replace kabupaten = "Kab. Makasar" if kabupaten =="Kab. Maros"	
	replace kabupaten = "Kab. Kotabaru" if kabupaten =="Kota Baru"
	replace kabupaten="Kab. Aceh Tengah" if kabupaten=="Kab. Aceh Tenggara"
	replace kabupaten="Kab. Aceh Besar" if kabupaten=="Kota Sabang"
	replace kabupaten="Kab. Aceh Besar" if kabupaten=="Kota Banda Aceh" // this is important because masyumi support levels in Aceh are otherwise unrealistic
	replace kabupaten="Kab. Tapanuli Utara" if kabupaten=="Kab. Dairi"
	replace kabupaten="Kab. Indragiri Hulu" if kabupaten=="Kab. Indragiri Hilir"
	replace kabupaten="Kab. Bintan" if kabupaten=="Kota Batam"
	replace kabupaten="Kab. Lampung Barat" if kabupaten=="Kab. Lampung Barat"
	replace kabupaten="Kab. Cianjur" if kabupaten=="Kab. Subang"
	replace kabupaten="Kab. Tangerang" if kabupaten=="Kota Tangerang"
	replace kabupaten="Kab. Pekalongan" if kabupaten=="Kab. Batang"
	replace kabupaten="Kab. Panarukan" if kabupaten=="Kab. Situbondo"
	replace kabupaten="Kab. Badung" if kabupaten=="Kota Denpasar"
	replace kabupaten="Kab. Lombok Barat" if kabupaten=="Kota Mataram"
	replace kabupaten="Kab. Kapuas" if kabupaten=="Kota Palangka Raya"
	replace kabupaten="Kab. Hulu Sungai Selatan" if kabupaten=="Kab. Tapin"
	replace kabupaten="Kab. Hulu Sungai Utara" if kabupaten=="Kab. Tabalong"
	replace kabupaten="Kab. Minahasa" if kabupaten=="Kota Bitung"
	replace kabupaten="Kab. Halmahera Barat" if kabupaten=="Kab. Halmahera Tengah"
	
	/* southeast sulawesi proliferations */
	replace kabupaten="Kab. Sulawesi Tenggara"  if kabupaten=="Kab. Buton"
	replace kabupaten="Kab. Sulawesi Tenggara"  if kabupaten=="Kab. Muna"
	replace kabupaten="Kab. Sulawesi Tenggara"  if kabupaten=="Kab. Kendari"
	replace kabupaten="Kab. Sulawesi Tenggara"  if kabupaten=="Kab. Kolaka"

	/* info coming from separate document */
	replace kabupaten="Kab. Gorontalo" if kabupaten=="Kota Gorontalo"
	
	
	/* Salatiga imputed from on first 3 vote count 
	
	PKI 11898
	PNI 2237
	NU 1247
	I then assumed that the relative vote share of NU/Masyumi is the same as 
	the average in the Semarang region (5x) from which I imputed that it had
	200 votes or 1.2%

	*/
	
	
	/* all other regions will be imputed based on regional averages (Feith 1955) */
	
	*duplicates drop kabupaten, force
	
	gen idusing=_n
	tempfile crosswalk
	save `crosswalk'
restore

gen elec55_id=_n


/* merge 1955 data to 1993 ids */
*reclink kabupaten using `crosswalk', idmaster(elec55_id) idusing(idusing) gen(merge_crosswalk)
merge 1:m kabupaten using `crosswalk',  gen(merge_crosswalk)


*browse kabupaten Ukabupaten if merge_crosswalk<1



/* merge IMPUTED VOTE SHARES from 1955 */
preserve
	import excel "../../data/raw/elections_1955/Feith_1955_imputations.xlsx", sheet("Sheet1") firstrow clear
	keep Province Party DPR Konst
	drop if Party==""
	egen allvotes_DPR=total(DPR), by(Province)
	egen allvotes_Konst=total(Konst), by(Province)
	gen DPR_share=DPR/allvotes_DPR
	gen Konst_share=Konst/allvotes_Konst
	replace Konst_share=Konst_share*100
	replace DPR_share=DPR_share*100
	replace Province=strtrim(Province)

	gen partyid=.
	replace partyid=1 if Party=="PNI"
	replace partyid=2 if Party=="Masjumi"
	replace partyid=3 if Party=="NU"
	replace partyid=4 if Party=="PKI"
	keep if partyid!=.

	egen i = group(Province)
	drop Party DPR Konst allvotes*
	reshape wide DPR_share Konst_share, i(i) j(partyid)

	rename DPR_share1 PNI_DPR_imp
	rename Konst_share1 PNI_Konst_imp 
	rename DPR_share2 Masyumi_DPR_imp
	rename Konst_share2 Masyumi_Konst_imp
	rename DPR_share3 NU_DPR_imp
	rename Konst_share3 NU_Konst_imp
	rename DPR_share4 PKI_DPR_imp
	rename Konst_share4 PKI_Konst_imp
	tempfile prov1955
	save `prov1955'
restore


gen Province1955=""
replace Province1955="NORTH SUMATRA" if prov_name=="Prov. Nanggroe Aceh Darussalam"
replace Province1955="CENTRAL SUMATRA" if prov_name=="Prov. Sumatera Barat"
replace Province1955="NORTH SUMATRA" if prov_name=="Prov. Sumatera Utara"
replace Province1955="WEST NUSATENGGARA" if prov_name=="Prov. Bali"
replace Province1955="WEST JAVA" if prov_name=="Prov. Jawa Barat"
replace Province1955="SOUTH SUMATRA" if prov_name=="Prov. Kep. Bangka Belitung"
replace Province1955="EAST JAVA" if prov_name=="Prov. Jawa Timur"
replace Province1955="SOUTH KALIMANTAN" if prov_name=="Prov. Kalimantan Selatan"
replace Province1955="CENTRAL JAVA" if prov_name=="Prov. Jawa Tengah"
replace Province1955="CENTRAL JAVA" if prov_name=="Prov. D I Yogyakarta"
replace Province1955="SOUTH KALIMANTAN" if prov_name=="Prov. Kalimantan Tengah"
replace Province1955="CENTRAL SUMATRA" if prov_name=="Prov. Jambi"
replace Province1955="EAST NUSATENGGARA" if prov_name=="Prov. Nusa Tenggara Timur"
replace Province1955="CENTRAL SUMATRA" if prov_name=="Prov. Riau"
replace Province1955="SOUTH SUMATRA" if prov_name=="Prov. Bengkulu"
replace Province1955="EAST KALIMANTAN" if prov_name=="Prov. Kalimantan Timur"
replace Province1955="WEST NUSATENGGARA" if prov_name=="Prov. Nusa Tenggara Barat"
replace Province1955="NORTH SULAWESI" if prov_name=="Prov. Sulawesi Utara"
replace Province1955="SOUTH SULAWESI" if prov_name=="Prov. Sulawesi Selatan"
replace Province1955="EAST KALIMANTAN" if prov_name=="Prov. Kalimantan Utara"
replace Province1955="NORTH SULAWESI" if prov_name=="Prov. Sulawesi Tengah"
replace Province1955="NORTH SULAWESI" if prov_name=="Prov. Gorontalo"
replace Province1955="WEST KALIMANTAN" if prov_name=="Prov. Kalimantan Barat"
replace Province1955="CENTRAL SUMATRA" if prov_name=="Prov. Kepulauan Riau"
replace Province1955="SOUTH SUMATRA" if prov_name=="Prov. Sumatera Selatan"
replace Province1955="SOUTH SUMATRA" if prov_name=="Prov. Lampung"
replace Province1955="WEST JAVA" if prov_name=="Prov. Banten"
replace Province1955="MALUKU" if prov_name=="Prov. Maluku"
replace Province1955="MALUKU" if prov_name=="Prov. Maluku  Utara"
replace Province1955="SOUTH SULAWESI" if prov_name=="Prov. Sulawesi Tenggara"
replace Province1955="SOUTH SULAWESI" if prov_name=="Prov. Sulawesi Barat"

merge m:1 Province1955 using `prov1955', gen(merge_prov55)


* Roti/Sawu and Kupang were different regency in 1955 but the same in 1993 -
* However, election results are similar
*duplicates drop bps_1993, force
*drop if kabupaten=="Kab. Rote Ndao/Sawu"

/* clean variables */

egen party_masyumi55 = rowmean(Masyumi_DPR Masyumi_Konst)
egen party_nu55 = rowmean(NU_DPR NU_Konst)
egen party_pni55 = rowmean(PNI_DPR PNI_Konst)
egen party_pki55 = rowmean(PKI_DPR PKI_Konst)

/*minor muslim parties:
PPTI
AKUI // close to masyumi
Perti
PSII
*/
egen other_islamic_DPR = rowtotal(PPII_PPTI_DPR Akui_DPR Perti_DPR PSII_DPR)

gen masyumi_imp = Masyumi_DPR
replace masyumi_imp = Masyumi_DPR_imp if masyumi_imp==.


gen bps_2011=bps_2009

*keep bps_2011 Masyumi_* NU_*

save ../../data/crosswalk_with_masyumi.dta, replace


/*

import excel "C:\Users\Administrator\Desktop\sharia\data\elections\election1999.xlsx", sheet("Munka1") firstrow clear

preserve
	import excel "../data/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	gen regency=name_1999
	drop if strpos(regency,"Jakarta")!=0
	replace regency = "Kota Madiun" if name_2000=="Kota Madiun"
	replace regency = "Kota Mojokerto" if name_2000=="Kota Mojokerto"
	replace regency = "Kota Makasar" if regency=="Kota Ujung Pandang"
	/*replace kabupaten = "Kab. Merangin" if kabupaten=="Kab. Sarolangun Bangko"
	replace kabupaten = "Kota Makasar" if kabupaten=="Kota Ujung Pandang"
	
	replace kabupaten = "Kab. Rote Ndao/Sawu"	   if name_2002=="Kab. Rote Ndao"
	replace kabupaten = "Kab. Bonthain" if kabupaten =="Kab. Bantaeng"
	replace kabupaten = "Kab. Pare-Pare" if kabupaten =="Kota Pare-Pare"
	replace kabupaten = "Kab. Makasar (1)" if kabupaten =="Kab. Gowa"
	replace kabupaten = "Kab. Makasar (2)" if kabupaten =="Kab. Maros"
	replace kabupaten = "Kab. Kotabaru" if kabupaten =="Kota Baru"
	*/

	duplicates drop regency, force
	
	gen idusing=_n
	tempfile crosswalk
	save `crosswalk'
restore

drop if PDIP=="x"
gen idmaster=_n
reclink regency using `crosswalk', idmaster(idmaster) idusing(idusing) gen(merge_crosswalk)




gen bps_2011=bps_2009
foreach v of varlist PDIP - Lain {
	destring `v', force replace
	replace `v' = 0 if `v'==.
	

}
merge 1:1 bps_2011 using ../data/masyumi_1955.dta, gen(merge_1955_1999)
gen islamist = PBB + PPP + PK
