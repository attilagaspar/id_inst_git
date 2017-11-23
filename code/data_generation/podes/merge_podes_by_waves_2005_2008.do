
/* merge podes2005 to podes2008*/

* set working directory - important for portability
do set_working_directory.do

/* load crosswalk */

local bps_master="bps_2008"

preserve
	* merge district proliferation crosswalk
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	drop if strpos(name_2014, "Prov.")!=0
	
	
	duplicates drop `bps_master', force
	keep `bps_master' bps_2006  name_2006
	drop if mod(`bps_master', 100)==0
	tempfile crosswlk
	save `crosswlk'
restore


preserve
	
	use ../../data/raw/podes/podes2005.dta, clear

	
	gen name=podes2005_nama
	gen name_kec=podes2005_nama_kec

	foreach v of varlist name name_kec {
		replace `v'=lower(strtrim(`v'))
		replace `v'=subinstr(`v',"(","",.)
		replace `v'=subinstr(`v',")","",.)
		egen spaces = noccur(`v'), string(" ")
		gen length = length(`v')
		gen space_share = spaces/length
		replace `v'=subinstr(`v'," ","",.) if space_share>=.4
		drop length space_share spaces

		replace `v'=subinstr(`v',"1","i",.)
		replace `v'=subinstr(`v',"2","ii",.)
		replace `v'=subinstr(`v',"3","iii",.)
		replace `v'=subinstr(`v',"4","iv",.)
		replace `v'=subinstr(`v',"5","v",.)
		replace `v'=subinstr(`v',"6","vi",.)
		replace `v'=subinstr(`v',"7","vii",.)
		replace `v'=subinstr(`v',"8","viii",.)
		replace `v'=subinstr(`v',"9","ix",.)
		replace `v'=subinstr(`v',"10","x",.)

		split `v', parse(" ") gen(n)
		replace `v' = subinstr(`v',"desa","",1) if n1=="desa"
		replace `v' = subinstr(`v',"nagari","",1) if n1=="nagari"
		replace `v' = subinstr(`v',"dusun","",1) if n1=="dusun"
		replace `v' = subinstr(`v',"gampong","",1) if n1=="gampong"
		replace `v' = subinstr(`v',"kampong","",1) if n1=="kampong"
		replace `v' = subinstr(`v',"kampung","",1) if n1=="kampung"

		drop n1-n5
		cap drop n6
		cap drop n7
		replace `v' = subinstr(`v',"kelurahan","",1)
		replace `v' = subinstr(`v',"kel.","",1)
		gen `v'_consonant_key=`v'
		replace `v'_consonant_key=subinstr(`v'_consonant_key,"a","",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key,"e","",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key,"i","",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key,"o","",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key,"u","",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key,"j","",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key,"y","",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key," ","",.)

		* special characters kill reclink, so they need to be removed
		forvalues x=33/39 {
			replace `v'=subinstr(`v',char(`x'),"",.)
			replace `v'_consonant_key=subinstr(`v'_consonant_key,char(`x'),"",.)
		}
		foreach x in 40 41 42 43 44 45 46 47 96 {
			replace `v'=subinstr(`v',char(`x'),"",.)
			replace `v'_consonant_key=subinstr(`v'_consonant_key,char(`x'),"",.)
		}
	}

	/*podes2005_prop podes2005_kab podes2005_kec podes2005_nama podes2005_prop_old podes2005_kabu_old podes2005_keca_old podes2005_nama_old*/


	*rename podes2003_kec keca
	gen keca= podes2005_kec 

	*gen bps_2003=100*podes2003_prop+podes2003_kab
	gen bps_2006	=100*podes2005_prop+podes2005_kab
	*gen bps_2006	=100*podes2005_prop_old+podes2005_kabu_old
	*some kabupaten codes are miscoded in podes

	replace bps_2006=7602	if bps_2006==7319
	replace bps_2006=7601	if bps_2006==7320
	replace bps_2006=7603	if bps_2006==7323
	replace bps_2006=7604	if bps_2006==7321
	replace bps_2006=7605	if bps_2006==7324
	replace bps_2006=9101	if bps_2006==9405
	replace bps_2006=9107	if bps_2006==9406
	replace bps_2006=9105	if bps_2006==9407

	replace bps_2006=9171 if bps_2006==9472	
	replace bps_2006=9102 if bps_2006==9421
	replace bps_2006=9103 if bps_2006==9425
	replace bps_2006=9104 if bps_2006==9424
	replace bps_2006=9106	if bps_2006==9422
	replace bps_2006=9108	if bps_2006==9423
	
	gen idusing=_n
	duplicates drop  bps_2006 keca name podes2005_nama_kec, force
	
	tempfile p2005
	save `p2005'

restore

	
	

use ../../data/raw/podes/podes2008.dta, clear

gen name=podes2008_nama
gen name_kec=podes2008_nama_kec

foreach v of varlist name name_kec {
	replace `v'=lower(strtrim(`v'))
	replace `v'=subinstr(`v',"(","",.)
	replace `v'=subinstr(`v',")","",.)
	egen spaces = noccur(`v'), string(" ")
	gen length = length(`v')
	gen space_share = spaces/length
	replace `v'=subinstr(`v'," ","",.) if space_share>=.4
	drop length space_share spaces

	replace `v'=subinstr(`v',"1","i",.)
	replace `v'=subinstr(`v',"2","ii",.)
	replace `v'=subinstr(`v',"3","iii",.)
	replace `v'=subinstr(`v',"4","iv",.)
	replace `v'=subinstr(`v',"5","v",.)
	replace `v'=subinstr(`v',"6","vi",.)
	replace `v'=subinstr(`v',"7","vii",.)
	replace `v'=subinstr(`v',"8","viii",.)
	replace `v'=subinstr(`v',"9","ix",.)
	replace `v'=subinstr(`v',"10","x",.)

	split `v', parse(" ") gen(n)
	replace `v' = subinstr(`v',"desa","",1) if n1=="desa"
	replace `v' = subinstr(`v',"nagari","",1) if n1=="nagari"
	replace `v' = subinstr(`v',"dusun","",1) if n1=="dusun"
	replace `v' = subinstr(`v',"gampong","",1) if n1=="gampong"
	replace `v' = subinstr(`v',"kampong","",1) if n1=="kampong"
	replace `v' = subinstr(`v',"kampung","",1) if n1=="kampung"

	drop n1-n5
	cap drop n6
	cap drop n7
	replace `v' = subinstr(`v',"kelurahan","",1)
	replace `v' = subinstr(`v',"kel.","",1)
	gen `v'_consonant_key=`v'
	replace `v'_consonant_key=subinstr(`v'_consonant_key,"a","",.)
	replace `v'_consonant_key=subinstr(`v'_consonant_key,"e","",.)
	replace `v'_consonant_key=subinstr(`v'_consonant_key,"i","",.)
	replace `v'_consonant_key=subinstr(`v'_consonant_key,"o","",.)
	replace `v'_consonant_key=subinstr(`v'_consonant_key,"u","",.)
	replace `v'_consonant_key=subinstr(`v'_consonant_key,"j","",.)
	replace `v'_consonant_key=subinstr(`v'_consonant_key,"y","",.)
	replace `v'_consonant_key=subinstr(`v'_consonant_key," ","",.)

	* special characters kill reclink, so they need to be removed
	forvalues x=33/39 {
		replace `v'=subinstr(`v',char(`x'),"",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key,char(`x'),"",.)
	}
	foreach x in 40 41 42 43 44 45 46 47 96 {
		replace `v'=subinstr(`v',char(`x'),"",.)
		replace `v'_consonant_key=subinstr(`v'_consonant_key,char(`x'),"",.)
	}
}

/*podes2005_prop podes2005_kab podes2005_kec podes2005_nama podes2005_prop_old podes2005_kabu_old podes2005_keca_old podes2005_nama_old*/


*rename podes2003_kec keca
gen keca = podes2008_kec
 
*gen bps_2003=100*podes2003_prop+podes2003_kab
gen `bps_master'	=100*podes2008_prop+ podes2008_kab
*gen `bps_master'	=100*podes2005_prop_old+podes2005_kabu_old
*some kabupaten codes are miscoded in podes
/*
replace `bps_master'=7602	if `bps_master'==7319
replace `bps_master'=7601	if `bps_master'==7320
replace `bps_master'=7603	if `bps_master'==7323
replace `bps_master'=7604	if `bps_master'==7321
replace `bps_master'=7605	if `bps_master'==7324
replace `bps_master'=9101	if `bps_master'==9405
replace `bps_master'=9107	if `bps_master'==9406
replace `bps_master'=9105	if `bps_master'==9407

replace `bps_master'=9171 if `bps_master'==9472	
replace `bps_master'=9102 if `bps_master'==9421
replace `bps_master'=9103 if `bps_master'==9425
replace `bps_master'=9104 if `bps_master'==9424
replace `bps_master'=9106	if `bps_master'==9422
replace `bps_master'=9108	if `bps_master'==9423
*/


merge m:1 `bps_master' using `crosswlk', gen(merge_crosswalk)
* new regions are not recoded, so there are some unused codes 
drop if merge_crosswalk==2




drop if name==""
* 36 duplicates are dropped
duplicates drop name `bps_master' keca, force

gen idmaster=_n	
	
/* find perfect matches by name and kecamatan*/	
preserve
	/* we lose 28 villages with this duplicates drop command */
	duplicates drop name name_kec bps_2006 keca, force
	merge 1:1 name name_kec bps_2006 keca using `p2005', gen(merge_2005)
	keep if merge_2005==3
	gen perfectmatch05=1
	tempfile perfect 
	save `perfect'
restore

/* find the imperfect matches by regional statistical code, kecamatan and name*/


* ezzel mi baja?
reclink bps_2006 keca name name_kec name_consonant_key using `p2005', wmatch(10 2 12 5 2) required(bps_2006) idmaster(idmaster)  idusing(idusing) gen(mp2005) exclude(`perfect') 
append using `perfect'


drop if _merge<3

replace mp2005=1 if perfectmatch05==1
egen maxscore = max(mp2005), by(idusing)
gen bestmatch=0
replace bestmatch=1 if maxscore==mp2005
keep if bestmatch==1


drop if mp2005<`1'
* all matches seem ok

/* create village ids*/
local n = 0
foreach v of varlist podes2008_prop podes2008_kab podes2008_kec  podes2008_desa    {

	
	local n = `n'+1
	cap drop i`n'
	tostring `v', gen(i`n')

}

replace i2="0"+i2 if length(i2)==1
replace i3="0"+i3 if length(i3)==2
replace i3="00"+i3 if length(i3)==1
replace i4="0"+i4 if length(i4)==2
replace i4="00"+i4 if length(i4)==1

gen strid08=i1+i2+i3+i4
drop i1 i2 i3 i4

local n = 0
foreach v of varlist podes2005_prop podes2005_kab podes2005_kec  podes2005_desa    {

	
	local n = `n'+1
	cap drop i`n'
	tostring `v', gen(i`n')

}

replace i2="0"+i2 if length(i2)==1
replace i3="0"+i3 if length(i3)==2
replace i3="00"+i3 if length(i3)==1
replace i4="0"+i4 if length(i4)==2
replace i4="00"+i4 if length(i4)==1

gen strid05=i1+i2+i3+i4

drop i1 i2 i3 i4
order strid08 strid05


duplicates tag idmaster, gen(bad_dups_2008)

save ../../data/podes_matched_2005_2008.dta, replace
