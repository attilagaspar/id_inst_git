* set working directory - important for portability
do set_working_directory.do


/* merge podes1996 to podes2000*/

/* load crosswalk */
preserve
	* merge district proliferation crosswalk
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	drop if strpos(name_2014, "Prov.")!=0

	duplicates drop bps_1998, force
	keep bps_1998 bps_1996
	drop if mod(bps_1998, 100)==0
	tempfile crosswlk
	save `crosswlk'
restore


preserve
	use ../../data/raw/podes/podes1996b.dta, clear
	gen name=lower(strtrim(podes1996_nama))
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
	
	
	gen keca=podes1996_kec
	
	gen bps_1996=100*podes1996_prop+podes1996_kab
	
	rename strid strid_using96
	* 416 villages have missing names
	* after that there are 3 duplicate pairs, all from aceh
	drop if name==""
	duplicates drop name bps_1996 keca, force
	gen idusing = _n
	tempfile p1996
	save `p1996'	

restore


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

gen keca=podes2000_kec98

gen bps_1998= podes2000_prop98*100 + podes2000_kab98

merge m:1 bps_1998 using `crosswlk', gen(merge_crosswalk)
* 66k villages successfully matched
keep if merge_crosswalk==3
drop merge_crosswalk

duplicates drop name keca, force

rename strid00 strid_using00
gen idmaster = _n
	
/* find perfect matches by name and kecamatan*/	
preserve
	merge 1:1 name bps_1996 keca using `p1996', gen(merge_1996)
	keep if merge_1996==3
	gen perfectmatch96=1
	tempfile perfect 
	save `perfect'
restore

/* find the imperfect matches by regional statistical code, kecamatan and name*/
reclink bps_1996 keca name using `p1996', wmatch(10 5 10) required(bps_1996) idmaster(idmaster) idusing(idusing) gen(mp1996) exclude(`perfect')
append using `perfect'

/* drop mismatches */
drop if _merge<3

replace mp1996=1 if perfectmatch96==1
egen maxscore = max(mp1996), by(idusing)
gen bestmatch=0
replace bestmatch=1 if maxscore==mp1996
keep if bestmatch==1

drop if mp1996<`1'



duplicates tag idmaster, gen(bad_dups_2000)

/* create village ids*/


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

rename strid_using96 strid96

order strid00 strid96


save ../../data/podes_matched_1996_2000.dta, replace



