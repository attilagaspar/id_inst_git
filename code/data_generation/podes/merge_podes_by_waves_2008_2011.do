
* set working directory - important for portability
do set_working_directory.do

/* load crosswalk */

local bps_master="bps_2009"

preserve
	* merge district proliferation crosswalk
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	drop if strpos(name_2014, "Prov.")!=0
	
	
	duplicates drop `bps_master', force
	keep `bps_master' bps_2008 name_2009
	drop if mod(`bps_master', 100)==0
	tempfile crosswlk
	save `crosswlk'
restore


preserve

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
	
	gen keca=podes2008_kec

	gen bps_2008=100*podes2008_prop+ podes2008_kab
	
	gen idusing=_n
	
	* 8 villages lost
	duplicates drop bps_2008 keca name, force
	tempfile p2008
	save `p2008'
	
restore



/* load master data (2011) */
use ../../data/raw/podes/podes2011.dta, clear

 
gen name=podes2011_nama_desa
gen name_kec=podes2011_nama_kec

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


/* merge proliferation codes*/

gen keca=podes2011_kec

gen `bps_master'	=100*podes2011_prop+  podes2011_kab
merge m:1 `bps_master' using `crosswlk', gen(merge_crosswalk)

* merge is OK, 10 regions were created later, they need to be dropped
drop if merge_crosswalk==2
/*
gen name_kabupaten=lower(strtrim(podes2011_nama_kab))
gen name_crosswalk=lower(strtrim(name_2009))
replace name_crosswalk=subinstr(name_crosswalk, "kab. ", "", .)
replace name_crosswalk=subinstr(name_crosswalk, "kota ", "", .)
strdist name_kabupaten name_crosswalk, gen(name_crosscheck)
replace name_crosscheck=2*name_crosscheck/(length(name_crosswalk)+length(name_kabupaten))
* kabupaten matching is checked and 100% */

duplicates drop name `bps_master' keca, force

gen idmaster=_n	

/* find perfect matches by name and kecamatan*/	
preserve
	/* we lose 28 villages with this duplicates drop command */
	duplicates drop name name_kec bps_2008 keca, force
	merge 1:1 name name_kec bps_2008 keca using `p2008', gen(merge_2008)
	keep if merge_2008==3
	gen perfectmatch08=1
	tempfile perfect 
	save `perfect'
restore

/* find the imperfect matches by regional statistical code, kecamatan and name*/

reclink bps_2008 keca name name_kec name_consonant_key using `p2008', wmatch(10 2 12 5 2) required(bps_2008) idmaster(idmaster)  idusing(idusing) gen(mp2008) exclude(`perfect') 
append using `perfect'

drop if _merge<3

replace mp2008=1 if perfectmatch08==1
egen maxscore = max(mp2008), by(idusing)
gen bestmatch=0
replace bestmatch=1 if maxscore==mp2008
keep if bestmatch==1
drop if mp2008<`1'

duplicates tag idmaster, gen(bad_dups_2011)

/* create village ids*/
foreach v of varlist podes2011_prop podes2011_kab podes2011_kec  podes2011_desa    {

	
	local n = `n'+1
	cap drop i`n'
	tostring `v', gen(i`n')

}

replace i2="0"+i2 if length(i2)==1
replace i3="0"+i3 if length(i3)==2
replace i3="00"+i3 if length(i3)==1
replace i4="0"+i4 if length(i4)==2
replace i4="00"+i4 if length(i4)==1

gen strid11=i1+i2+i3+i4
drop i1 i2 i3 i4



local n = 0
foreach v of varlist podes2008_prop podes2008_kab  podes2008_kec  podes2008_desa    {

	
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

order strid11 strid08

save ../../data/podes_matched_2008_2011.dta, replace
