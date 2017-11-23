

/* merge podes2003 to podes2005*/

* set working directory - important for portability
do set_working_directory.do


/* load crosswalk */

local bps_master="bps_2006"

preserve
	
	* merge district proliferation crosswalk
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	drop if strpos(name_2014, "Prov.")!=0
	
	duplicates drop `bps_master', force
	keep `bps_master' bps_2002  name_2005
	replace name_2005=strtrim(lower(name_2005))
	drop if mod(`bps_master', 100)==0
	tempfile crosswlk
	save `crosswlk'
restore

/* load using file - podes 2003 */

preserve
	
	use ../../data/raw/podes/podes2003.dta, clear
	gen name=lower(strtrim(podes2003_nama))
	replace name=subinstr(name,"(","",.)
	replace name=subinstr(name,")","",.)
	egen spaces = noccur(name), string(" ")
	gen length = length(name)
	gen space_share = spaces/length
	replace name=subinstr(name," ","",.) if space_share>=.4
	drop length space_share

	replace name=subinstr(name,"1","i",.)
	replace name=subinstr(name,"2","ii",.)
	replace name=subinstr(name,"3","iii",.)
	replace name=subinstr(name,"4","iv",.)
	replace name=subinstr(name,"5","v",.)
	replace name=subinstr(name,"6","vi",.)
	replace name=subinstr(name,"7","vii",.)
	replace name=subinstr(name,"8","viii",.)
	replace name=subinstr(name,"9","ix",.)
	replace name=subinstr(name,"10","x",.)

	split name, parse(" ") gen(n)
	replace name = subinstr(name,"desa","",1) if n1=="desa"
	replace name = subinstr(name,"nagari","",1) if n1=="nagari"
	drop n1-n7
	replace name = subinstr(name,"kelurahan","",1)
	replace name = subinstr(name,"kel.","",1)
	gen consonant_key=name
	replace consonant_key=subinstr(consonant_key,"a","",.)
	replace consonant_key=subinstr(consonant_key,"e","",.)
	replace consonant_key=subinstr(consonant_key,"i","",.)
	replace consonant_key=subinstr(consonant_key,"o","",.)
	replace consonant_key=subinstr(consonant_key,"u","",.)
	replace consonant_key=subinstr(consonant_key,"j","",.)
	replace consonant_key=subinstr(consonant_key,"y","",.)
	replace consonant_key=subinstr(consonant_key," ","",.)

	*rename podes2003_kec keca
	gen  keca=podes2003_kec2002

	*gen bps_2003=100*podes2003_prop+podes2003_kab
	gen bps_2002	=100*podes2003_prop2002+podes2003_kab2002
	*some kabupaten codes are miscoded in podes
	replace bps_2002=9407 if bps_2002==9105
	tab podes2003_b3r306a if bps_2002==9207
	replace bps_2002=9407 if bps_2002==9207
	replace bps_2002=9403 if bps_2002==9304
	replace bps_2002=2072 if bps_2002==1474
	replace bps_2002=2071 if bps_2002==1472
	replace bps_2002=2003 if bps_2002==1412
	replace bps_2002=2001 if bps_2002==1411
	replace bps_2002=2002 if bps_2002==1410
	
	gen idusing=_n
	*60 villages are lost this way (they are probably true duplicates, as there
	* it is hard to believe that neighboring villages (same kecamatan) would
	* be called the same name 
	duplicates drop name bps_2002 keca, force
	
	tempfile p2003
	save `p2003'
restore

/* load 2005 data - master */

use ../../data/raw/podes/podes2005.dta, clear

gen name=lower(strtrim(podes2005_nama))
replace name=subinstr(name,"(","",.)
replace name=subinstr(name,")","",.)
egen spaces = noccur(name), string(" ")
gen length = length(name)
gen space_share = spaces/length
replace name=subinstr(name," ","",.) if space_share>=.4
drop length space_share

replace name=subinstr(name,"1","i",.)
replace name=subinstr(name,"2","ii",.)
replace name=subinstr(name,"3","iii",.)
replace name=subinstr(name,"4","iv",.)
replace name=subinstr(name,"5","v",.)
replace name=subinstr(name,"6","vi",.)
replace name=subinstr(name,"7","vii",.)
replace name=subinstr(name,"8","viii",.)
replace name=subinstr(name,"9","ix",.)
replace name=subinstr(name,"10","x",.)

split name, parse(" ") gen(n)
replace name = subinstr(name,"desa","",1) if n1=="desa"
replace name = subinstr(name,"nagari","",1) if n1=="nagari"
drop n1-n7
replace name = subinstr(name,"kelurahan","",1)
replace name = subinstr(name,"kel.","",1)
gen consonant_key=name
replace consonant_key=subinstr(consonant_key,"a","",.)
replace consonant_key=subinstr(consonant_key,"e","",.)
replace consonant_key=subinstr(consonant_key,"i","",.)
replace consonant_key=subinstr(consonant_key,"o","",.)
replace consonant_key=subinstr(consonant_key,"u","",.)
replace consonant_key=subinstr(consonant_key,"j","",.)
replace consonant_key=subinstr(consonant_key,"y","",.)
replace consonant_key=subinstr(consonant_key," ","",.)

/*podes2005_prop podes2005_kab podes2005_kec podes2005_nama podes2005_prop_old podes2005_kabu_old podes2005_keca_old podes2005_nama_old*/


*rename podes2003_kec keca
gen keca = podes2005_kec 

*gen bps_2003=100*podes2003_prop+podes2003_kab
gen `bps_master'	=100*podes2005_prop+podes2005_kab
*gen `bps_master'	=100*podes2005_prop_old+podes2005_kabu_old
*some kabupaten codes are miscoded in podes

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



merge m:1 `bps_master' using `crosswlk', gen(merge_crosswalk)
* two regencies from the using sample are not found, why?
keep if merge_crosswalk==3



drop if name==""
* 36 duplicates are dropped
duplicates drop name `bps_master' keca, force

gen idmaster=_n	
	
/* find perfect matches by name and kecamatan*/	
preserve
	/* we lose 28 villages with this duplicates drop command */
	duplicates drop name bps_2002 keca, force
	merge 1:1 name bps_2002 keca using `p2003', gen(merge_2003)
	keep if merge_2003==3
	gen perfectmatch03=1
	tempfile perfect 
	save `perfect'
restore

/* find the imperfect matches by regional statistical code, kecamatan and name*/


* ezzel mi baja?
reclink bps_2002 keca name consonant_key using `p2003', wmatch(10 5 10 2) required(bps_2002) idmaster(idmaster)  idusing(idusing) gen(mp2003) exclude(`perfect') 
append using `perfect'


drop if _merge<3

replace mp2003=1 if perfectmatch03==1
egen maxscore = max(mp2003), by(idusing)
gen bestmatch=0
replace bestmatch=1 if maxscore==mp2003
keep if bestmatch==1
drop if mp2003<`1'

/* create ids*/

duplicates tag idmaster, gen(bad_dups_2005)


local n = 0
foreach v of varlist podes2005_prop podes2005_kab  podes2005_kec  podes2005_desa    {

	
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

local n = 0
foreach v of varlist podes2003_prop podes2003_kab podes2003_kec2002 podes2003_desa  {

	
	local n = `n'+1
	cap drop i`n'
	tostring `v', gen(i`n')

}

replace i2="0"+i2 if length(i2)==1
replace i3="0"+i3 if length(i3)==2
replace i3="00"+i3 if length(i3)==1
replace i4="0"+i4 if length(i4)==2
replace i4="00"+i4 if length(i4)==1

gen strid03=i1+i2+i3+i4
drop i1 i2 i3 i4

order strid05 strid03

save ../../data/podes_matched_2003_2005.dta, replace
