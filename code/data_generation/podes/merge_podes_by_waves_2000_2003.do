
/* merge podes1996 to podes2000*/

* set working directory - important for portability
do set_working_directory.do

/* load crosswalk */
preserve
	* merge district proliferation crosswalk
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	drop if strpos(name_2014, "Prov.")!=0
	
	duplicates drop bps_2002, force
	keep bps_1998 bps_2002 bps_2000
	drop if mod(bps_1998, 100)==0
	tempfile crosswlk
	save `crosswlk'
restore


preserve
	use ../../data/raw/podes/podes2000.dta, clear
	local n = 0
	foreach v of varlist podes2000_prop podes2000_kab podes2000_kec podes2000_desa    {

		
		local n = `n'+1
		cap drop i`n'
		tostring `v', gen(i`n')

	}

	replace i2="0"+i2 if length(i2)==1
	replace i3="0"+i3 if length(i3)==2
	replace i3="00"+i3 if length(i3)==1
	replace i4="0"+i4 if length(i4)==2
	replace i4="00"+i4 if length(i4)==1


	gen strid00=i1+i2+i3+i4
	drop i1 i2 i3 i4

	gen name=lower(strtrim(podes2000_nama))
	replace name=subinstr(name,"(","",.)
	replace name=subinstr(name,")","",.)
	drop if name==""
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
	
	
	gen keca=podes2000_kec98

	gen bps_1998= podes2000_prop98*100 + podes2000_kab98
	gen bps_2000= podes2000_prop*100 + podes2000_kab
	* there are a couple of hundred villages with bogus region codes
	drop if bps_1998<1000 
	
	duplicates drop name keca, force
	
	rename strid00 strid_using00
	gen idusing = _n
	tempfile p2000
	save `p2000'

	
restore

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
gen keca=podes2003_kec2002

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

merge m:1 bps_2002 using `crosswlk', gen(merge_crosswalk)
* all podes vars are merged

keep if merge_crosswalk==3
drop merge_crosswalk

drop if name==""
* 45 duplicates are dropped
duplicates drop name bps_2002 keca, force

gen idmaster=_n	
	
/* find perfect matches by name and kecamatan*/	
preserve
	/* we lose 3 villages with this duplicates drop command */
	duplicates drop name bps_1998 bps_2000 keca, force
	merge 1:1 name bps_1998 bps_2000 keca using `p2000', gen(merge_2000)
	keep if merge_2000==3
	gen perfectmatch00=1
	tempfile perfect 
	save `perfect'
restore


/* find the imperfect matches by regional statistical code, kecamatan and name*/


* ezzel mi baja?
reclink bps_1998 keca name consonant_key using `p2000', wmatch(10 5 10 2) required(bps_1998) idmaster(idmaster)  idusing(idusing) gen(mp2000) exclude(`perfect') 
append using `perfect'


/* drop mismatches */
drop if _merge<3

replace mp2000=1 if perfectmatch00==1
egen maxscore = max(mp2000), by(idusing)
gen bestmatch=0
replace bestmatch=1 if maxscore==mp2000
keep if bestmatch==1
drop if mp2000<`1'


duplicates tag idmaster, gen(bad_dups_2003)


/* create village ids*/

local n = 0
foreach v of varlist podes2003_prop2002 podes2003_kab2002 podes2003_kec2002 podes2003_desa2002  {

	
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

local n = 0
*foreach v of varlist podes2000_prop98 podes2000_kab98 podes2000_kec98 podes2000_desa98    {
foreach v of varlist  podes2000_prop podes2000_kab podes2000_kec podes2000_desa {
	
	local n = `n'+1
	cap drop i`n'
	tostring `v', gen(i`n')

}

replace i2="0"+i2 if length(i2)==1
replace i3="0"+i3 if length(i3)==2
replace i3="00"+i3 if length(i3)==1
replace i4="0"+i4 if length(i4)==2
replace i4="00"+i4 if length(i4)==1


gen strid00=i1+i2+i3+i4
drop i1 i2 i3 i4

order strid03 strid00

save ../../data/podes_matched_2000_2003.dta, replace
