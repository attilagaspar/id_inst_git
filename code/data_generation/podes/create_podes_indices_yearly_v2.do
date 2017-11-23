* this code merges treatment data to the jawa podes panel and creates the
* index variables according to Anderson 2008

* set working directory - important for portability
do set_working_directory.do

use ../../data/podes_all_yearly_70p.dta, clear
local ofile="podes_panel_long_yearly_70p.dta"

drop _merge
gen id2011_1=strid11
gen bps_2011=substr(id2011_1, 1,4)
destring bps_2011, force replace

preserve
	
	* merge district proliferation crosswalk
	import excel "../../data/raw/indodapoer/District-Proliferation-Crosswalk.xlsx", sheet("Proliferation Crosswalk") firstrow clear
	drop if strpos(name_2014, "Prov.")!=0
	
	
	gen bps_2010=bps_2009
	gen bps_2011=bps_2009
	gen bps_2012=bps_2009
	gen bps_2013=bps_2009
	
	duplicates drop bps_2011, force
	tempfile treat
	save `treat'
restore

/*create moving bps_code to identify regency changes*/
merge m:1 bps_2011 using `treat'
gen bps_moving1996=bps_1996
gen bps_moving2000=bps_2000
gen bps_moving2003=bps_2003
gen bps_moving2005=bps_2005
gen bps_moving2008=bps_2008
gen bps_moving2011=bps_2011



*_merge==2 contains only Jakarta and province entries of the masterfile
*_merge==1 contains a single empty line which God only knows how got there
keep if _merge==3



* population

gen pop1996=podes1996_b4ar2a
gen pop2000=podes2000_b4ar2a
gen pop2003=podes2003_b4r402a+podes2003_b4r402b
* banten rosszul van kotve :(
*replace pop2000=(pop2003+pop1996)/2 if pop2000==.
gen pop2005=podes2005_r401a+podes2005_r401b
gen pop2008=podes2008_r401a+podes2008_r401b
gen pop2011=podes2011_r401a+podes2011_r401b


* households
rename podes1996_b4ar2c hhold1996
rename podes2000_b4ar2b hhold2000
rename podes2003_b3r307b2 hhold2003
rename podes2005_r401c hhold2005
rename podes2008_r401c hhold2008
rename podes2011_r401c hhold2011


*  desa-kelurahan status
drop status
rename podes1996_b3r2 status1996 //  1996 desa : 1 kelurahan:2
rename podes2000_b3r3 status2000 //  2000 desa : 1 kelurahan 2
rename podes2003_b3r303 status2003 //  2003
rename podes2005_r301 status2005  // 2005 (desa: 1 kelurahan:2  nagari:3 lainnya: 4)
rename podes2008_r301 status2008 // 2008 (desa: 1 kelurahan:2 nagari: 3 lannya: 4)
rename podes2011_r301 status2011 // 2011 (desa: 1, kelurahan:2 lainnya: 3)

foreach s in "1996" "2000" "2003" "2005" "2008" "2011" {
	
	gen kelurahan`s'=.
	replace kelurahan`s'=1 if status`s'==2
	replace kelurahan`s'=0 if status`s'==1

}

*  budget
gen rev_own2008=podes2008_r13011_3	
gen rev_own2011=podes2011_r1401ak3

gen rev_own1996=podes1996_b12r1a2a+podes1996_b12r1a2b	
gen rev_own2003=podes2003_b16r1602

gen rev_kab1996=podes1996_b12r1a5	
gen rev_kab2003=podes2003_b16r1603c
gen rev_prop1996=podes1996_b12r1a4	
gen rev_prop2003=podes2003_b16r1603b
gen rev_centr1996=podes1996_b12r1a3	
gen rev_centr2003=podes2003_b16r1603a

gen rev_total1996=podes1996_b12ra
gen rev_total2003=podes2003_b16r1601b
gen rev_other1996=podes1996_b12r1a6

egen rev_total1996b=rowtotal(rev_own1996 rev_kab1996 rev_prop1996 rev_centr1996 rev_other1996)
egen rev_total2003b=rowtotal(rev_own2003 rev_kab2003 rev_prop2003 rev_centr2003 )

	
gen rev_kab2008=podes2008_r13012a_3	
gen rev_kab2011=podes2011_r1401b1k3
gen rev_prop2008=podes2008_r13012b_3
gen rev_prop2011=podes2011_r1401b2k3
gen rev_centr2008=podes2008_r13012c_3	
gen rev_centr2011=podes2011_r1401b3k3
gen rev_foreign2008=podes2008_r13012d_3	
gen rev_foreign2011=podes2011_r1401b4k3
gen rev_priv2008=podes2008_r13012e_3	
gen rev_priv2011=podes2011_r1401b5k3
gen rev_other2008=podes2008_r13012f_3

foreach s in  "rev_priv1996" "rev_foreign1996"  "rev_priv2003" "rev_foreign2003"  "rev_other2003"{

	gen `s'=.
	
}


gen rev_other2011=podes2011_r1401b6k3
egen rev_total2008=rowtotal(rev_own2008 rev_kab2008 rev_prop2008 rev_centr2008 rev_foreign2008 rev_priv2008 rev_other2008)
egen rev_total2011=rowtotal(rev_own2011 rev_kab2011 rev_prop2011 rev_centr2011 rev_foreign2011 rev_priv2011 rev_other2011)

foreach s in "rev_own" "rev_kab" "rev_prop" "rev_centr" "rev_total" "rev_other" ///\
	"rev_foregn" "rev_priv" {
	
	foreach t in "2000" "2005" {
	
		gen `s'_`t'=.
	
	}
	
}

*  urban-rural status


* distances
* 2000
rename podes2000_b3r12 dist_camat2000
rename podes2000_b3r13 dist_bupati2000
rename podes2000_b3r14 dist_otherbupati2000
* 2003
rename podes2003_b3r313 dist_camat2003
rename podes2003_b3r314 dist_bupati2003
rename podes2003_b3r315  dist_otherbupati2003
* 2005
rename podes2005_r902ak21  dist_camat2005
rename podes2005_r902bk21 dist_bupati2005
rename podes2005_r902ck21  dist_otherbupati2005
* 2008
rename podes2008_r9021_2  dist_camat2008
rename podes2008_r9022_2   dist_bupati2008
rename podes2008_r9023_2   dist_otherbupati2008
* 2011
rename podes2011_r1004ak2 dist_camat2011
rename podes2011_r1004bk2 dist_bupati2011
rename podes2011_r1004ck2 dist_otherbupati2011
* the CILEGON-BANYUWANGI distance (furthermost points of Java) are 1000 kms from
* one another, so this is clearly a very dirty data
* cutoff: 120 for kabupaten, 25 for kecamatan

gen kecamatan_2011=substr(id2011_1, 1,7)
foreach v of varlist dist_camat* {

	replace `v'=. if `v'>25
	egen `v'_imputed = mean(`v'), by(kecamatan_2011)
	replace `v'=`v'_imputed if `v'==.

}

foreach v of varlist dist_bupati* {

	replace `v'=. if `v'>120
	egen `v'_imputed = mean(`v'), by(kecamatan_2011)
	replace `v'=`v'_imputed if `v'==.

}

foreach v of varlist dist_otherbupati* {

	replace `v'=. if `v'>240
	egen `v'_imputed = mean(`v'), by(kecamatan_2011)
	replace `v'=`v'_imputed if `v'==.

}




merge m:1 bps_2011 using ../../data/regulations/treatment_for_podes_1123.dta, gen(merge_treatment)
drop if merge_treatment == 2

*stop
* treatment variables
/* THIS IS COMMENTED OUT FOR THE NEW TREATMENT VAR */
*gen ever_treated=0
*replace ever_treated=1 if any_treat2014==1
gen ever_treated=0
replace ever_treated=1 if treatedby_2011==1
*drop type_A1999 type_B1999 type_C1999 type_E1999 type_F1999 type_G1999 type_H1999 type_I1999 type_J1999 type_K1999 type_L1999 type_M1999 type_N1999 type_O1999 type_P1999 type_A2000 type_B2000 type_C2000 type_E2000 type_F2000 type_G2000 type_H2000 type_I2000 type_J2000 type_K2000 type_L2000 type_M2000 type_N2000 type_O2000 type_P2000 type_A2001 type_B2001 type_C2001 type_E2001 type_F2001 type_G2001 type_H2001 type_I2001 type_J2001 type_K2001 type_L2001 type_M2001 type_N2001 type_O2001 type_P2001 type_A2002 type_B2002 type_C2002 type_E2002 type_F2002 type_G2002 type_H2002 type_I2002 type_J2002 type_K2002 type_L2002 type_M2002 type_N2002 type_O2002 type_P2002 type_A2003 type_B2003 type_C2003 type_E2003 type_F2003 type_G2003 type_H2003 type_I2003 type_J2003 type_K2003 type_L2003 type_M2003 type_N2003 type_O2003 type_P2003 type_A2004 type_B2004 type_C2004 type_E2004 type_F2004 type_G2004 type_H2004 type_I2004 type_J2004 type_K2004 type_L2004 type_M2004 type_N2004 type_O2004 type_P2004 type_A2005 type_B2005 type_C2005 type_E2005 type_F2005 type_G2005 type_H2005 type_I2005 type_J2005 type_K2005 type_L2005 type_M2005 type_N2005 type_O2005 type_P2005 type_A2006 type_B2006 type_C2006 type_E2006 type_F2006 type_G2006 type_H2006 type_I2006 type_J2006 type_K2006 type_L2006 type_M2006 type_N2006 type_O2006 type_P2006 type_A2007 type_B2007 type_C2007 type_E2007 type_F2007 type_G2007 type_H2007 type_I2007 type_J2007 type_K2007 type_L2007 type_M2007 type_N2007 type_O2007 type_P2007 type_A2008 type_B2008 type_C2008 type_E2008 type_F2008 type_G2008 type_H2008 type_I2008 type_J2008 type_K2008 type_L2008 type_M2008 type_N2008 type_O2008 type_P2008 type_A2009 type_B2009 type_C2009 type_E2009 type_F2009 type_G2009 type_H2009 type_I2009 type_J2009 type_K2009 type_L2009 type_M2009 type_N2009 type_O2009 type_P2009 type_A2010 type_B2010 type_C2010 type_E2010 type_F2010 type_G2010 type_H2010 type_I2010 type_J2010 type_K2010 type_L2010 type_M2010 type_N2010 type_O2010 type_P2010 type_A2011 type_B2011 type_C2011 type_E2011 type_F2011 type_G2011 type_H2011 type_I2011 type_J2011 type_K2011 type_L2011 type_M2011 type_N2011 type_O2011 type_P2011 type_A2012 type_B2012 type_C2012 type_E2012 type_F2012 type_G2012 type_H2012 type_I2012 type_J2012 type_K2012 type_L2012 type_M2012 type_N2012 type_O2012 type_P2012 type_A2013 type_B2013 type_C2013 type_E2013 type_F2013 type_G2013 type_H2013 type_I2013 type_J2013 type_K2013 type_L2013 type_M2013 type_N2013 type_O2013 type_P2013 type_A2014 type_B2014 type_C2014 type_E2014 type_F2014 type_G2014 type_H2014 type_I2014 type_J2014 type_K2014 type_L2014 type_M2014 type_N2014 type_O2014 type_P2014 type_A2015 type_B2015 type_C2015 type_E2015 type_F2015 type_G2015 type_H2015 type_I2015 type_J2015 type_K2015 type_L2015 type_M2015 type_N2015 type_O2015 type_P2015 type_A2016 type_B2016 type_C2016 type_E2016 type_F2016 type_G2016 type_H2016 type_I2016 type_J2016 type_K2016 type_L2016 type_M2016 type_N2016 type_O2016 type_P2016 regency_name merge_tr_ovie type_X1999 type_X2000 type_X2001 type_X2002 type_X2003 type_X2004 type_X2005 type_X2006 type_X2007 type_X2008 type_X2009 type_X2010 type_X2011 type_X2012 type_X2013 type_X2014 type_X2015 type_X2016 bps_2010 bps_2012 bps_2013 bps_2015 bps_2016 treated1999 treat_A1999 treat_B1999 treat_C1999 treat_E1999 treat_F1999 treat_G1999 treat_H1999 treat_I1999 treat_J1999 treat_K1999 treat_L1999 treat_M1999 treat_N1999 treat_O1999 treat_P1999 treated2000 treat_A2000 treat_B2000 treat_C2000 treat_E2000 treat_F2000 treat_G2000 treat_H2000 treat_I2000 treat_J2000 treat_K2000 treat_L2000 treat_M2000 treat_N2000 treat_O2000 treat_P2000 treated2001 treat_A2001 treat_B2001 treat_C2001 treat_E2001 treat_F2001 treat_G2001 treat_H2001 treat_I2001 treat_J2001 treat_K2001 treat_L2001 treat_M2001 treat_N2001 treat_O2001 treat_P2001 treated2002 treat_A2002 treat_B2002 treat_C2002 treat_E2002 treat_F2002 treat_G2002 treat_H2002 treat_I2002 treat_J2002 treat_K2002 treat_L2002 treat_M2002 treat_N2002 treat_O2002 treat_P2002 treated2003 treat_A2003 treat_B2003 treat_C2003 treat_E2003 treat_F2003 treat_G2003 treat_H2003 treat_I2003 treat_J2003 treat_K2003 treat_L2003 treat_M2003 treat_N2003 treat_O2003 treat_P2003 treated2004 treat_A2004 treat_B2004 treat_C2004 treat_E2004 treat_F2004 treat_G2004 treat_H2004 treat_I2004 treat_J2004 treat_K2004 treat_L2004 treat_M2004 treat_N2004 treat_O2004 treat_P2004 treated2005 treat_A2005 treat_B2005 treat_C2005 treat_E2005 treat_F2005 treat_G2005 treat_H2005 treat_I2005 treat_J2005 treat_K2005 treat_L2005 treat_M2005 treat_N2005 treat_O2005 treat_P2005 treated2006 treat_A2006 treat_B2006 treat_C2006 treat_E2006 treat_F2006 treat_G2006 treat_H2006 treat_I2006 treat_J2006 treat_K2006 treat_L2006 treat_M2006 treat_N2006 treat_O2006 treat_P2006 treated2007 treat_A2007 treat_B2007 treat_C2007 treat_E2007 treat_F2007 treat_G2007 treat_H2007 treat_I2007 treat_J2007 treat_K2007 treat_L2007 treat_M2007 treat_N2007 treat_O2007 treat_P2007 treated2008 treat_A2008 treat_B2008 treat_C2008 treat_E2008 treat_F2008 treat_G2008 treat_H2008 treat_I2008 treat_J2008 treat_K2008 treat_L2008 treat_M2008 treat_N2008 treat_O2008 treat_P2008 treated2009 treat_A2009 treat_B2009 treat_C2009 treat_E2009 treat_F2009 treat_G2009 treat_H2009 treat_I2009 treat_J2009 treat_K2009 treat_L2009 treat_M2009 treat_N2009 treat_O2009 treat_P2009 treated2010 treat_A2010 treat_B2010 treat_C2010 treat_E2010 treat_F2010 treat_G2010 treat_H2010 treat_I2010 treat_J2010 treat_K2010 treat_L2010 treat_M2010 treat_N2010 treat_O2010 treat_P2010 treated2011 treat_A2011 treat_B2011 treat_C2011 treat_E2011 treat_F2011 treat_G2011 treat_H2011 treat_I2011 treat_J2011 treat_K2011 treat_L2011 treat_M2011 treat_N2011 treat_O2011 treat_P2011 treated2012 treat_A2012 treat_B2012 treat_C2012 treat_E2012 treat_F2012 treat_G2012 treat_H2012 treat_I2012 treat_J2012 treat_K2012 treat_L2012 treat_M2012 treat_N2012 treat_O2012 treat_P2012 treated2013 treat_A2013 treat_B2013 treat_C2013 treat_E2013 treat_F2013 treat_G2013 treat_H2013 treat_I2013 treat_J2013 treat_K2013 treat_L2013 treat_M2013 treat_N2013 treat_O2013 treat_P2013 treated2014 treat_A2014 treat_B2014 treat_C2014 treat_E2014 treat_F2014 treat_G2014 treat_H2014 treat_I2014 treat_J2014 treat_K2014 treat_L2014 treat_M2014 treat_N2014 treat_O2014 treat_P2014 treated2015 treat_A2015 treat_B2015 treat_C2015 treat_E2015 treat_F2015 treat_G2015 treat_H2015 treat_I2015 treat_J2015 treat_K2015 treat_L2015 treat_M2015 treat_N2015 treat_O2015 treat_P2015 treated2016 treat_A2016 treat_B2016 treat_C2016 treat_E2016 treat_F2016 treat_G2016 treat_H2016 treat_I2016 treat_J2016 treat_K2016 treat_L2016 treat_M2016 treat_N2016 treat_O2016 treat_P2016

drop type_A1999 - cum_treat2016
* create province ID
gen province_id = substr(id2011_1,1,2)
destring province_id, force replace

/*drop jakarta for 3 reasons:
 - kotas are not independent 
 - it is different - no sharia, lot of services, high levels of development 
*/
drop if province_id==31



* dummies  correction


// # dokter pria
// # dokter wanita
//
// # hospitals
// # maternity hospital
// #poliklinik
// #puskesmas
// #puskesmas pembantu
// # tempat praktek dokter

local health_dummies = "podes2000_b8r2a1 podes2000_b8r2a2 podes2000_b8r2d podes2008_r604a_2 podes2008_r604b_2 podes2008_r604c_2 podes2008_r604d_2 podes2008_r604e_2 podes2008_r604f_2 podes2008_r604l_2"
local educ_dummies = "podes1996_b5r2a podes1996_b5r2b podes1996_b5r2c podes1996_b5r2d podes1996_b5r2e podes1996_b5r2f podes1996_b5r2g podes1996_b5r2h podes1996_b5r2i podes1996_b5r2j podes1996_b5r2k podes1996_b5r2l"
/*

foreach v of varlist `health_dummies'  `educ_dummies'	 {

		sum `v'
		replace `v'=`v'-`r(max)'
		replace `v'=-1*`v'

}

*/
/* VARIABLE GROUPS OF INDICES */

egen kinds_vocational96 = rowtotal(`educ_dummies')

local health_1996 = " podes1996_b8r1ik2	podes1996_b8r1ak2	podes1996_b8r1bk2	podes1996_b8r1dk2	podes1996_b8r1ek2	podes1996_b8r1fk2	podes1996_b8r1hk2	podes1996_b8r1ik2	podes1996_b8r1jk2	podes1996_b8r1kk2	podes1996_b8r2a1	podes1996_b8r2a2	podes1996_b8r2c"
local health_2000="podes2000_b8r1k2	podes2000_b8r1a2	podes2000_b8r1b2	podes2000_b8r1d2	podes2000_b8r1e2	podes2000_b8r1f2	podes2000_b8r1h2	podes2000_b8r1k2	podes2000_b8r1l2	podes2000_b8r1n2	podes2000_b8r2a1	podes2000_b8r2a2	podes2000_b8r2d "
local health_2003= "podes2003_b7r701i2	podes2003_b7r701a2	podes2003_b7r701b2	podes2003_b7r701c2	podes2003_b7r701d2	podes2003_b7r701e2	podes2003_b7r701f2	podes2003_b7r701i2	podes2003_b7r701j2	podes2003_b7r701l2	podes2003_b7r703a1	podes2003_b7r703a2	podes2003_b7r703b1 "
local health_2005 = " podes2005_r603ik2	podes2005_r603ak2	podes2005_r603bk2	podes2005_r603ck2	podes2005_r603dk2	podes2005_r603ek2	podes2005_r603fk2	podes2005_r603ik2	podes2005_r603jk2	podes2005_r603kk2	podes2005_r604a1	podes2005_r604a2	podes2005_r604c "
local health_2008 = "podes2008_r604i_3	podes2008_r604a_2	podes2008_r604b_2	podes2008_r604c_2	podes2008_r604d_2	podes2008_r604e_2	podes2008_r604f_2	podes2008_r604i_3	podes2008_r604k_3	podes2008_r604l_2	podes2008_r606a1	podes2008_r606a2	podes2008_r606c "
local health_2011 = " podes2011_r704ik3	podes2011_r704ak3	podes2011_r704bk3	podes2011_r704ck3	podes2011_r704dk3	podes2011_r704ek3	podes2011_r704fk3	podes2011_r704ik3	podes2011_r704kk3	podes2011_r704lk2	podes2011_r707a1	podes2011_r707a2	podes2011_r707c "
// kinds_vocational96 - ezt kivittem mert elviszi az egesz valtozot a picsaba
local educ_1996 = "podes1996_b5r1ak2	podes1996_b5r1ak4 podes1996_b5r1bk2 podes1996_b5r1bk4	podes1996_b5r1ck2 podes1996_b5r1ck4 podes1996_b5r1dk2 podes1996_b5r1dk3 podes1996_b5r1dk4 podes1996_b5r1dk5 podes1996_b5r1ek2 podes1996_b5r1ek3 podes1996_b5r1ek4 podes1996_b5r1ek5  "
*sum `educ_1996'
local educ_2000 = "podes2000_b5r1a2 podes2000_b5r1a3 podes2000_b5r1b2 podes2000_b5r1b3 podes2000_b5r1c2 podes2000_b5r1c3 podes2000_b5r1d2 podes2000_b5r1d3 podes2000_b5r1e2 podes2000_b5r1e3 podes2000_b5r1f2 podes2000_b5r1f3 podes2000_b5r2a podes2000_b5r2b podes2000_b5r2c podes2000_b5r2d podes2000_b5r2e podes2000_b5r2f podes2000_b5r2g podes2000_b5r2h podes2000_b5r2i podes2000_b5r2j podes2000_b5r2k podes2000_b5r2l "
local educ_2003 = "podes2003_b6r601a2 podes2003_b6r601a3 podes2003_b6r601b2 	podes2003_b6r601b3 podes2003_b6r601c2 podes2003_b6r601c3 podes2003_b6r601d2 podes2003_b6r601d3 podes2003_b6r601e2 podes2003_b6r601e3 podes2003_b6r601e4 podes2003_b6r601f2 podes2003_b6r601f3 podes2003_b6r601g2 podes2003_b6r601g3 podes2003_b6r604g3 podes2003_b6r604h3 podes2003_b6r604a3 podes2003_b6r604b3 podes2003_b6r604d3 podes2003_b6r604e3 podes2003_b6r604c3"
local educ_2005 = "podes2005_r601ak2 podes2005_r601ak3 podes2005_r601bk2 podes2005_r601bk3 podes2005_r601ck2 podes2005_r601ck3 podes2005_r601dk2 podes2005_r601dk3 podes2005_r601ek2 podes2005_r601ek3 podes2005_r601ek41 podes2005_r601ek42 podes2005_r601fk2 podes2005_r601fk3 podes2005_r601gk2 podes2005_r601gk3 podes2005_r602gk3 podes2005_r602hk3 podes2005_r602ak3 podes2005_r602bk3 podes2005_r602dk3 podes2005_r602ek3 podes2005_r602ck3 podes2005_r602fk3 podes2005_r602ik3 "
local educ_2008 = "podes2008_r601a_2 podes2008_r601a_3 podes2008_r601b_2 podes2008_r601b_3 podes2008_r601c_2 podes2008_r601c_3 podes2008_r601d_2 podes2008_r601d_3 podes2008_r601e_2 podes2008_r601e_3 podes2008_r601e_4 podes2008_r601f_2 podes2008_r601f_3 podes2008_r601g_2 podes2008_r601g_3 podes2008_r602e_3 podes2008_r602f_3 podes2008_r602a_3 podes2008_r602c_3 podes2008_r602b_3 podes2008_r602d_3 podes2008_r602g_3 "
local educ_2011 = "podes2011_r701ak2 	podes2011_r701ak3 podes2011_r701bk2 podes2011_r701bk3 podes2011_r701ck2 podes2011_r701ck3 podes2011_r701dk2 podes2011_r701dk3 podes2011_r701ek2 podes2011_r701ek3 podes2011_r701ek4 podes2011_r701fk2 podes2011_r701fk3 podes2011_r701gk2 podes2011_r701gk3 podes2011_r702e podes2011_r702f podes2011_r702a podes2011_r702c podes2011_r702b podes2011_r702d podes2011_r702g "


local sick_1996 = "podes1996_b8r3a	podes1996_b8r3b	podes1996_b8r3c"

local sick_2000 = "podes2000_b8r7a3	podes2000_b8r7b3	podes2000_b8r7c3	podes2000_b8r7d3	podes2000_b8r7e3	podes2000_b8r7f3	"									
local sick_2003 = "podes2003_b7r706a3	podes2003_b7r706b3	podes2003_b7r706c3	podes2003_b7r706d3	podes2003_b7r706e3	podes2003_b7r706f3 "										
local sick_2005 = "podes2005_r607ak3	podes2005_r607bk3	podes2005_r607dk3	podes2005_r607ck3	podes2005_r607ek3	podes2005_r607fk3	"									
local sick_2008 = "podes2008_r607a_4	podes2008_r607a_3	podes2008_r607b_4	podes2008_r607b_3	podes2008_r607d_4	podes2008_r607d_3	podes2008_r607c_4	podes2008_r607c_3	podes2008_r607e_4	podes2008_r607e_3	podes2008_r607h_4	podes2008_r607h_3	podes2008_r607f_3	podes2008_r607f_4	podes2008_r607g_3	podes2008_r607g_4"
local sick_2011 = "podes2011_r708ak4	podes2011_r708ak3	podes2011_r708bk4	podes2011_r708bk3	podes2011_r708dk4	podes2011_r708dk3	podes2011_r708ck4	podes2011_r708ck3	podes2011_r708ek4	podes2011_r708ek3	podes2011_r708hk4	podes2011_r708hk3	podes2011_r708fk4	podes2011_r708fk3	podes2011_r708gk4	podes2011_r708gk3"
			
foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {

	egen total_sick`t'=rowtotal(`sick_`t'')

}

		
			
local services_1996= "podes1996_b11ar13	podes1996_b11ar14	podes1996_b9br3a	podes1996_b9br4	podes1996_b11ar1a	podes1996_b11ar2a	podes1996_b11ar3	podes1996_b11ar4	podes1996_b11ar18a	podes1996_b11ar19	podes1996_b11cr1a	podes1996_b11cr5a	podes1996_b7r1a	podes1996_b11br12	podes1996_b11cr5b	podes1996_b11cr7a	podes1996_b7r9		"

local services_2000= "podes2000_b11ar12a	podes2000_b11ar12b	podes2000_b11ar12c	podes2000_b11ar12d	podes2000_b9br3a	podes2000_b9br4	podes2000_b11ar1a	podes2000_b11ar2a	podes2000_b11ar3	podes2000_b11ar4	podes2000_b11ar5	podes2000_b11br1	podes2000_b11br3a	podes2000_b7r3a	podes2000_b11ar10	podes2000_b11br3b	podes2000_b7r6a	 "	
local services_2003= "podes2003_b15r1512a4	podes2003_b15r1512b4	podes2003_b15r1512c4	podes2003_b11r1105a	podes2003_b11r1106	podes2003_b15r1502a	podes2003_b15r1503a	podes2003_b15r1504	podes2003_b15r1505	podes2003_b15r1506	podes2003_b15r1501	podes2003_b15r1513	podes2003_b9r903a	podes2003_b15r1511	podes2003_b15r1515b2	podes2003_b9r906a "			
local services_2005= "podes2005_r1108a	podes2005_r1108b	podes2005_r1108c	podes2005_r908a	podes2005_r909	podes2005_r1110a	podes2005_r1111a	podes2005_r1112	podes2005_r1113	podes2005_r1114	podes2005_r1115	podes2005_r1119	podes2005_r1121a	podes2005_r802a	podes2005_r1117	podes2005_r1121b	podes2005_r1118	podes2005_r1124b	podes2005_r803a "
local services_2008= "podes2008_r1102a	podes2008_r1102b	podes2008_r1102c	podes2008_r907a	podes2008_r908	podes2008_r1103a	podes2008_r1104a	podes2008_r1105	podes2008_r1106	podes2008_r1107	podes2008_r1108	podes2008_r1112a	podes2008_r801a	podes2008_r1110	podes2008_r1112b	podes2008_r1111	podes2008_r1113b	podes2008_r802a	 "
local services_2011= "podes2011_r1202a	podes2011_r1202b	podes2011_r1202c	podes2011_r1010a	podes2011_r1011	podes2011_r1203a	podes2011_r1205a	podes2011_r1206	podes2011_r1207	podes2011_r1210	podes2011_r1209	podes2011_r1215ak3	podes2011_r1213a	podes2011_r901a	podes2011_r1211	podes2011_r1213b	podes2011_r1212	podes2011_r902a	 "

local religion_1996= "podes1996_b6ar1	podes1996_b6ar2					"
local religion_2000= "ers2000 podes2000_b6r1a2	podes2000_b6r1b2	podes2000_b6r2a5k2	podes2000_b6r2a5k3	podes2000_b5r1g3	podes2000_b5r1h3	"
local religion_2003= "ers2003	podes2003_b8r801b	podes2003_b8r802a4	podes2003_b6r601h3		"	
local religion_2005= "ers2005 	podes2005_r703b	podes2005_r704b1k2	podes2005_r601hk3			"
local religion_2008= "ers2008 	podes2008_r703b	podes2008_r7041_2	podes2008_r601h	podes2008_r601i		"
local religion_2011= "ers2011	podes2011_r803b	podes2011_r701hk3	podes2011_r701ik3			"

egen allsecular1996=rowtotal(podes1996_b5r1bk2	podes1996_b5r1bk3	podes1996_b5r1bk4	podes1996_b5r1bk5	podes1996_b5r1ck2	podes1996_b5r1ck3	podes1996_b5r1ck4	podes1996_b5r1ck5	podes1996_b5r1dk2 )
egen allsecular2000=rowtotal(podes2000_b5r1b2	podes2000_b5r1b3	podes2000_b5r1c2	podes2000_b5r1c3	podes2000_b5r1d2	podes2000_b5r1d3	)		
egen allsecular2003=rowtotal(podes2003_b6r601b2	podes2003_b6r601b3	podes2003_b6r601c2	podes2003_b6r601c3	podes2003_b6r601d2	podes2003_b6r601d3	)		
egen allsecular2005=rowtotal(podes2005_r601bk2	podes2005_r601bk3	podes2005_r601ck2	podes2005_r601ck3	podes2005_r601dk2	podes2005_r601dk3	)		
egen allsecular2008=rowtotal(podes2008_r601d_2	podes2008_r601d_3	podes2008_r601b_2	podes2008_r601b_3	podes2008_r601c_2	podes2008_r601c_3	)		
egen allsecular2011=rowtotal(podes2011_r701bk2	podes2011_r701bk3	podes2011_r701ck2	podes2011_r701ck3	podes2011_r701dk2	podes2011_r701dk3	)		

egen religious2000=rowtotal(podes2000_b5r1g3	podes2000_b5r1h3)
gen religious2003=podes2003_b6r601h3	
gen religious2005=podes2005_r601hk3	
egen religious2008=rowtotal(podes2008_r601h	podes2008_r601i)
egen religious2011=rowtotal(podes2011_r701hk3	podes2011_r701ik3)


foreach t in "2000" "2003" "2005" "2008" "2011" {
	replace allsecular`t'=0 if allsecular`t'==.
	replace religious`t'=0 if religious`t'==.
	gen educ_relig_share`t'=religious`t'/(religious`t'+allsecular`t')
	replace educ_relig_share`t'=0 if religious`t'==0&allsecular`t'==0
	* the following step is important so that the main religious education share
	* indicator is not standardized
	gen ers`t'=educ_relig_share`t'
}

local development_1996="electr1996 podes1996_poor	podes1996_b4br1	podes1996_b4br2	podes1996_b4br3	podes1996_b4br9c	podes1996_b4br14b2	podes1996_b11er8b1	podes1996_b11er8b2	podes1996_b9br1	podes1996_b11cr2b1		 "
local development_2000="electr2000 podes2000_b4br2b	podes2000_b4br3	podes2000_b4br4	podes2000_b4br5	podes2000_b4br8b	podes2000_b4br11b3	podes2000_b4ar3	podes2000_b8r5	podes2000_b9br1			"
local development_2003="electr2003 	podes2003_b5r502a	podes2003_b5r503	podes2003_b5r504	podes2003_b5r505	podes2003_b5r507b	podes2003_b5r511b4	podes2003_b4r403a1	podes2003_b7r704a	podes2003_b11r1101	podes2003_b15r1514	podes2003_b15r1514	"
local development_2005="electr2005	podes2005_r502b	podes2005_r503	podes2005_r504	podes2005_r505	podes2005_r509c3	podes2005_r401e	podes2005_r606	podes2005_r904	podes2005_r1120a			"
local development_2008="electr2008 	podes2008_r502b	podes2008_r503	podes2008_r504a	podes2008_r504b	podes2008_r10c	podes2008_r509b3	podes2008_r610	podes2008_r903				"
local development_2011="electr2011 podes2011_r502b	podes2011_r503	podes2011_r505a	podes2011_r504	podes2011_r510b3	podes2011_r712	podes2011_r1005b	podes2011_r1215bk3		"		

gen podes1996_poor = podes1996_b11er8b1+podes1996_b11er8b2

gen electr1996=(podes1996_b11er3a+podes1996_b11er3b)/hhold1996
gen electr2000=(podes2000_b4br1a+podes2000_b4br1b)/hhold2000
gen electr2003=(podes2003_b5r501b1+podes2003_b5r501b2)/hhold2003
gen electr2005=(podes2005_r501b1+podes2005_r501b2)/hhold2005
gen electr2008=(podes2008_r501b1+podes2008_r501b2)/hhold2008
gen electr2011=(podes2011_r501a+podes2011_r501b)/hhold2011





/*
foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {

	foreach v of varlist `development_`t'' {
	
		reg `v' ever_treated pop`t', cluster(bps_1996)
		outreg2 using devs.xls
	
	}

}
*/
/* infra and prosperity are parts from the development index, so they need not be standardized twice */
local infra_1996="electr1996 podes1996_b11er3b	podes1996_b11er4b	podes1996_b4br1	podes1996_b4br2	podes1996_b4br3 podes1996_b9br1"
local infra_2000="electr2000 podes2000_b4br1b	podes2000_b4br2b	podes2000_b4br3	podes2000_b4br4	podes2000_b4br5	podes2000_b9br1"
local infra_2003="electr2003 podes2003_b5r501b1	podes2003_b5r502a	podes2003_b5r503	podes2003_b5r504	podes2003_b5r505	podes2003_b11r1101"
local infra_2005="electr2005 podes2005_r502b	podes2005_r503	podes2005_r504	podes2005_r505	podes2005_r904"
local infra_2008="electr2008 podes2008_r502b	podes2008_r503	podes2008_r504a	podes2008_r504b	podes2008_r903"
local infra_2011="electr2011 podes2011_r502b	podes2011_r503	podes2011_r505a	podes2011_r504	podes2011_r1005b"

local prosp_1996="podes1996_b4br9c	podes1996_b4br14b2	podes1996_poor	"
local prosp_2000="podes2000_b4br8b	podes2000_b4br11b3	podes2000_b4ar3	podes2000_b8r5	"
local prosp_2003="podes2003_b5r507b	podes2003_b5r511b4	podes2003_b4r403a1	podes2003_b7r704a	"
local prosp_2005="podes2005_r509c3	podes2005_r401e	podes2005_r606	"
local prosp_2008="podes2008_r10c	podes2008_r509b3	podes2008_r610"
local prosp_2011="podes2011_r510b3	podes2011_r712"




/* el vannak csuszva a sorok a leirasban	
local crime_1996="podes1996_b12r1a2	podes1996_b12r1a3	podes1996_b12r1b2	podes1996_b12r1b3	podes1996_b12r1c2	podes1996_b12r1c3	podes1996_b12r1d2	podes1996_b12r1d3	podes1996_b12r1e2	podes1996_b12r1e3	podes1996_b12r1f2	podes1996_b12r1f3	podes1996_b12r1g2	podes1996_b12r1g3	podes1996_b12r1h2	podes1996_b12r1h3													"
local crime_2000="podes2000_b17r1704c1	podes2000_b17r1704c2	podes2000_b17r1704c3	podes2000_b17r170522	podes2000_b17r170523	podes2000_b17r170532	podes2000_b17r170533	podes2000_b17r170582	podes2000_b17r170583	podes2000_b17r170542	podes2000_b17r170543	podes2000_b17r170552	podes2000_b17r170553	podes2000_b17r170562	podes2000_b17r170563	podes2000_b17r170572	podes2000_b17r170573	podes2000_b17r170592											"
local crime_2003="podes2003_r1202b1	podes2003_r1202b2	podes2003_r1202b3	podes2003_r1204a2k2	podes2003_r1204a2k3	podes2003_r1204a3k2	podes2003_r1204a3k3	podes2003_r1204a9k2	podes2003_r1204a9k3	podes2003_r1204a4k2	podes2003_r1204a4k3	podes2003_r1204a5k2	podes2003_r1204a5k3	podes2003_r1204a6k2	podes2003_r1204a6k3	podes2003_r1204a7k2	podes2003_r1204a7k3	podes2003_r1204a8k2	podes2003_r1204a8k3	podes2003_r1204a10k2	podes2003_r1204a10k3	podes2003_r1204a11k2	podes2003_r1204a11k3						"
local crime_2005="podes2005_r1201ba_4	podes2005_r1201ba_5	podes2005_r1203a01	podes2005_r1203a1	podes2005_r1203a02	podes2005_r1203a2	podes2005_r1203a03	podes2005_r1203a3	podes2005_r1203a09	podes2005_r1203a9	podes2005_r1203a04	podes2005_r1203a4	podes2005_r1203a05	podes2005_r1203a5	podes2005_r1203a06	podes2005_r1203a6	podes2005_r1203a07	podes2005_r1203a7	podes2005_r1203a08	podes2005_r1203a8	podes2005_r1203a10	podes2005_r1203a11	podes2005_r1203a12	podes2005_r1203a13	podes2005_r1207a	podes2005_r1207b_2	podes2005_r1208b	podes2005_r1208c	podes2005_r1208a"
local crime_2008="podes2008_r1201ba_4	podes2008_r1201ba_5	podes2008_r1203a01_2	podes2008_r1203a02_2	podes2008_r1203a03_2	podes2008_r1203a04_2	podes2008_r1203a05_2	podes2008_r1203a06_2	podes2008_r1203a07_2	podes2008_r1203a08_2	podes2008_r1203a10_2	podes2008_r1203a11_2																	"
local crime_2011="podes2011_r1301b1k4	podes2011_r1301b1k5	podes2011_r130301k2	podes2011_r130301k3	podes2011_r130302k2	podes2011_r130302k3	podes2011_r130308k2	podes2011_r130308k3	podes2011_r130303k2	podes2011_r130303k3	podes2011_r130309k2	podes2011_r130309k3	podes2011_r130304k2	podes2011_r130304k3	podes2011_r130305k2	podes2011_r130305k3	podes2011_r130306k2	podes2011_r130306k3	podes2011_r130307k2	podes2011_r130307k3	podes2011_r130310k2	podes2011_r130310k3							"
*/
local crime_1996= "podes1996_b3r12a podes1996_b3r12b"
local crimef_1996 = "podes1996_b3r13a	podes1996_b3r13b	podes1996_b3r13c"
local crime_2000="podes2000_b12r1a2	podes2000_b12r1a3	podes2000_b12r1b2	podes2000_b12r1b3	podes2000_b12r1	podes2000_b12r1c3	podes2000_b12r1d2	podes2000_b12r1d3	podes2000_b12r1e2	podes2000_b12r1e3	podes2000_b12r1f2	podes2000_b12r1f3	podes2000_b12r1g2	podes2000_b12r1g3	podes2000_b12r1h2	podes2000_b12r1h3	"																	
local crimef_2000="podes2000_b12r3a2	podes2000_b12r3b2	podes2000_b12r3	"																														
local crime_2003="podes2003_b17r1704c1	podes2003_b17r1704c2	podes2003_b17r1704c3	podes2003_b17r170522	podes2003_b17r170532	podes2003_b17r170582		podes2003_b17r170542	podes2003_b17r170552	podes2003_b17r170562	podes2003_b17r170572	podes2003_b17r170592	"															

local crimef_2003="podes2003_b17r1708a2	podes2003_b17r1708b2	podes2003_b17r1708b4	podes2003_b17r1709	podes2003_b17r1709	"																												
local crime_2005="podes2005_r1202b1	podes2005_r1202b2	podes2005_r1202b3	podes2005_r1204a2k2	podes2005_r1204a2k3	podes2005_r1204a3k2	podes2005_r1204a3k3	podes2005_r1204a9k2	podes2005_r1204a9k3	podes2005_r1204a4k2	podes2005_r1204a4k3	podes2005_r1204a5k2	podes2005_r1204a5k3	podes2005_r1204a6k2	podes2005_r1204a6k3	podes2005_r1204a7k2	podes2005_r1204a7k3	podes2005_r1204a8k2	podes2005_r1204a8k3	podes2005_r1204a10k2	podes2005_r1204a10k3	podes2005_r1204a11k2	podes2005_r1204a11k3 "											


local crimef_2005="podes2005_r1206e	podes2005_r1207ak2	podes2005_r1208	podes2005_r1207bk4		"																												
local crime_2008="podes2008_r1201ba_4	podes2008_r1201ba_5	podes2008_r1201bb_4	podes2008_r1201bb_5	podes2008_r1201bc_4	podes2008_r1201bc_5	podes2008_r1201bd_4	podes2008_r1201be_4	podes2008_r1201be_5	podes2008_r1201bf_4	podes2008_r1201bf_5	podes2008_r1203a01*		podes2008_r1203a02*	podes2008_r1203a03*		podes2008_r1203a09*	podes2008_r1203a04*		podes2008_r1203a05*	podes2008_r1203a06*	podes2008_r1203a07*		podes2008_r1203a08*		podes2008_r1203a10*	podes2008_r1203a11*	 "

local crimef_2008="podes2008_r1207a	podes2008_r1207b_2	podes2008_r1208a	podes2008_r1208b	podes2008_r1208c	"																												
local crime_2011="podes2011_r1301b1k4	podes2011_r1301b1k5	podes2011_r130301k2	podes2011_r130301k3	podes2011_r130302k2	podes2011_r130302k3	podes2011_r130308k2	podes2011_r130308k3	podes2011_r130303k2	podes2011_r130303k3	podes2011_r130309k2	podes2011_r130309k3	podes2011_r130304k2	podes2011_r130304k3	podes2011_r130305k2	podes2011_r130305k3	podes2011_r130306k2	podes2011_r130306k3	podes2011_r130307k2	podes2011_r130307k3	podes2011_r130310k2	podes2011_r130310k3		"										
local crimef_2011="podes2011_r1310	podes2011_r1309ak2	podes2011_r1309bk2	"																														


local cost_1996="podes1996_b3r10"
local cost_2000="podes2000_b3r12	podes2000_b3r13	podes2000_b3r14	podes2000_b4br15a	podes2000_b4br15b1	podes2000_b4br15b2	podes2000_b4br15b3	podes2000_b4br15b4	podes2000_b4br15b5	podes2000_b4br15b6	podes2000_b4br15b7	podes2000_b4br15b8	podes2000_b4br15b9	podes2000_b4br1510																																	"
local cost_2003="podes2003_b3r313	podes2003_b3r314	podes2003_b3r315	podes2003_b5r514a2	podes2003_b5r514a3	podes2003_b5r514	podes2003_b5r514c3	podes2003_b5r514b2	podes2003_b5r514b3	"
local cost_2005="podes2005_r902ak21	podes2005_r902bk21	podes2005_r902ck21	podes2005_r512dk2	podes2005_r512dk3	podes2005_r513d	podes2005_r513f	podes2005_r513g	podes2005_r512bk2	podes2005_r512bk3	podes2005_r513b	podes2005_r513c	podes2005_r512ak2	podes2005_r512ak3	podes2005_r513a	podes2005_r512ek2	podes2005_r512ek3	podes2005_r513e"
local cost_2008="podes2008_r9021_2	podes2008_r9022_2	podes2008_r9023_2	podes2008_r513d_2	podes2008_r513d_3	podes2008_r513d_5	podes2008_r513d_6	podes2008_r513h_2	podes2008_r513h_3	podes2008_r513h_5	podes2008_r513h_6	podes2008_r513i_2	podes2008_r513i_3	podes2008_r513i_5	podes2008_r513i_6	podes2008_r513b_2	podes2008_r513b_3	podes2008_r513b_5	podes2008_r513b_6	podes2008_r513c_2	podes2008_r513c_3	podes2008_r513c_5	podes2008_r513c_6	podes2008_r513a_2	podes2008_r513a_3	podes2008_r513a_5	podes2008_r513a_6	podes2008_r513e_2	podes2008_r513e_3	podes2008_r513e_5	podes2008_r513e_6	podes2008_r513f_2	podes2008_r513f_3	podes2008_r513f_5	podes2008_r513f_6	podes2008_r513g_2	podes2008_r513g_3	podes2008_r513g_5	podes2008_r513g_6"
local cost_2011="podes2011_r1004ak2	podes2011_r1004bk2	podes2011_r1004ck2	podes2011_r305b		podes2011_r60104k2	podes2011_r60104k3	podes2011_r60104k4	podes2011_r60104k5	podes2011_r60108k2	podes2011_r60108k3	podes2011_r60108k4	podes2011_r60108k5	podes2011_r60109k2	podes2011_r60109k3		podes2011_r60109k5	podes2011_r60102k2	podes2011_r60102k3	podes2011_r60102k4	podes2011_r60102k5	podes2011_r60103k2	podes2011_r60103k3	podes2011_r60103k4	podes2011_r60103k5	podes2011_r60101k2	podes2011_r60101k3	podes2011_r60101k4	podes2011_r60101k5		podes2011_r60106k2	podes2011_r60106k3	podes2011_r60106k4	podes2011_r60106k5	podes2011_r60107k2	podes2011_r60107k3	podes2011_r60107k4	podes2011_r60107k5	podes2011_r60110k2	podes2011_r60110k3	podes2011_r60110k4	podes2011_r60110k5	"


/* this next step is a check thet all variables exist */
disp "checking variable existence"
foreach s in  "development" "services"   "health" "educ"  "religion" "crime" "sick" "prosp" "infra" {
	foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {
		foreach v of varlist ``s'_`t'' {
			qui sum `v'
		}
	}
}

/* RECODING SIGNS OF VARIABLES */
/*     with this variables the bigger number means a worse condition (ie. number of poor households), so they need to be recoded   */

foreach v of varlist podes1996_b4br9c podes1996_b4br14b2 podes1996_poor {
	replace `v'=1-(`v'/hhold1996)
}
foreach v of varlist podes2000_b4br8b podes2000_b4br11b3 podes2000_b4ar3 podes2000_b8r5 {
	replace `v'=1-(`v'/hhold2000)
}
foreach v of varlist podes2003_b5r507b podes2003_b5r511b4 podes2003_b4r403a1 podes2003_b7r704a {
	replace `v'=1-(`v'/hhold2003)
}

foreach v of varlist podes2005_r509c3 podes2005_r401e podes2005_r606 {
	replace `v'=1-(`v'/hhold2005)
}

foreach v of varlist podes2008_r10c podes2008_r610 {
	replace `v'=1-(`v'/hhold2008)
}

foreach v of varlist podes2011_r712 podes2011_r510b3 {
	replace `v'=1-(`v'/hhold2011)
}
/* with these variables the best outcome is 1 while the worse is 4, it has to be the other way around */

foreach v of varlist 	podes1996_b11er4b ///
						podes2000_b4br2b ///
						podes2003_b5r502a /// 
						podes2005_r502b ///
						podes2008_r502b ///
						podes2011_r502b ///
						podes1996_b4br1 ///
						podes2000_b4br3 ///
						podes2003_b5r503 ///
						podes2005_r503 /// 
						podes2008_r503 ///
						podes2011_r503 ///
						podes1996_b4br2 ///
						podes2000_b4br4 ///
						podes2003_b5r504 ///
						podes2005_r504 ///
						podes2008_r504a ///
						podes2011_r505a ///
						podes1996_b4br3  ///
						podes2000_b4br5 ///
						podes2003_b5r505 ///
						podes2005_r505 ///
						podes2008_r504b ///
						podes2011_r505a ///
						podes2011_r504 {
						

						recode `v' (1=4) (2=3) 
						
}




/* RECODING DUMMIES */


gen problem_obs=0
* dummy check - dummies are miscoded (the lower number means "yes" and they are often
* not coded as 0 and 1 
*"cost" "sick"
*
foreach idx in "educ"  "development" "religion" "services"  "health"  "crime" "crimef"    {
	foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {
		gen `idx'_dummy`t'=0
		foreach v of varlist ``idx'_`t'' {
		
			qui sum `v' if `v'!=.
			if (`r(max)'==`r(min)'+1)&(`r(max)'!=1) {
				*disp "variable `idx' - `t' - `v' , min `r(min)' max `r(max)' )"
				qui replace `v'=`v'-`r(max)'
				qui replace `v'=-1*`v'
				qui sum `v' if `v'!=.
				*disp "replaced `idx' - `t' -  `v'  to  min `r(min)' max `r(max)' )"
				qui replace `idx'_dummy`t'=`idx'_dummy`t'+`v'
			}
			else {
				*disp "replaced `idx' - `t' -  `v'  to  population share as it is not a dummy"
				*qui replace `v'=`v'/pop`t'
				*qui sum `v', det
				/*
				qui sum `v', det
				qui count if `r(kurtosis)'>1000&`v'>`r(p99)'&`v'!=.
				*disp "`r(N)' problem observations"
				if (`r(N)'>	0) {
					qui sum `v', det
					*qui replace problem_obs = 1 if `r(kurtosis)'>1000&`v'>`r(p99)'&`v'!=.
					local kur_pre = `r(kurtosis)'
					*if (`kur_pre'>30) {
					*	* winsorize
					qui winsor `v', gen(`v'_w) p(0.01) highonly
					qui sum `v'_w, det
					if (`r(kurtosis)'!=.){
						qui drop `v'
						qui rename `v'_w `v'
						qui sum `v', det
						*local kur_post = `r(kurtosis)'
						*disp "kurtosis reduced from `kur_pre' to `kur_post'"
						
					}

				}
				*/
			}
		}	
	}
}


/* CREATING SUPPLEMENTARY HEALTH VARS */

* create health infrastructure score based on current market prices 
* of constructing such an institution

/*
item_type	mean_value
polindes	3.19
rumah_sakit	8.15
rumah_sakit_bersalin	7.6
poliklinik	3.31
puskesmas	2.27
puskesmas_pembantu	1.33
farmasi	2.79
*/


foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {

	gen health_infra`t'=0
}

local polindes_score=3.19
local rs_score=8.15
local rsb_score=7.6
local polikl_score=3.31
local puskes_score=2.27
local puskes_pem_score=1.33
local farmasi_score=2.79

* # polindes
replace health_infra1996=health_infra1996+podes1996_b8r1ik2*`polindes_score' if podes1996_b8r1ik2!=.
replace health_infra2000=health_infra2000+podes2000_b8r1k2*`polindes_score' if podes2000_b8r1k2!=.
replace health_infra2003=health_infra2003+podes2003_b7r701i2*`polindes_score' if podes2003_b7r701i2!=.
replace health_infra2005=health_infra2005+podes2005_r603ik2*`polindes_score' if podes2005_r603ik2!=.
replace health_infra2008=health_infra2008+podes2008_r604i_3*`polindes_score' if podes2008_r604i_3!=.
replace health_infra2011=health_infra2011+podes2011_r704ik3*`polindes_score' if podes2011_r704ik3!=.
* # hospitals
replace health_infra1996=health_infra1996+podes1996_b8r1ak2*`rs_score' if podes1996_b8r1ak2!=.
replace health_infra2000=health_infra2000+podes2000_b8r1a2*`rs_score' if podes2000_b8r1a2!=.
replace health_infra2003=health_infra2003+podes2003_b7r701a2*`rs_score' if podes2003_b7r701a2!=.
replace health_infra2005=health_infra2005+podes2005_r603ak2*`rs_score' if podes2005_r603ak2!=.
replace health_infra2008=health_infra2008+podes2008_r604a_2*`rs_score' if podes2008_r604a_2!=. // dummy
replace health_infra2011=health_infra2011+podes2011_r704ak3*`rs_score' if podes2011_r704ak3!=.
* # maternity hospital
replace health_infra1996=health_infra1996+podes1996_b8r1bk2*`rsb_score' if podes1996_b8r1bk2!=.
replace health_infra2000=health_infra2000+podes2000_b8r1b2*`rsb_score' if podes2000_b8r1b2!=.
replace health_infra2003=health_infra2003+podes2003_b7r701b2*`rsb_score' if podes2003_b7r701b2!=.
replace health_infra2005=health_infra2005+podes2005_r603bk2*`rsb_score' if podes2005_r603bk2!=.
replace health_infra2008=health_infra2008+podes2008_r604b_2*`rsb_score' if  podes2008_r604b_2!=.  	 // dummy
replace health_infra2011=health_infra2011+podes2011_r704bk3*`rsb_score' if podes2011_r704bk3!=.
* # poliklinik
replace health_infra1996=health_infra1996+podes1996_b8r1dk2*`polikl_score' if podes1996_b8r1dk2!=.
replace health_infra2000=health_infra2000+podes2000_b8r1d2*`polikl_score' if podes2000_b8r1d2!=.
replace health_infra2003=health_infra2003+podes2003_b7r701c2*`polikl_score' if podes2003_b7r701c2!=.
replace health_infra2005=health_infra2005+podes2005_r603ck2*`polikl_score' if podes2005_r603ck2!=.
replace health_infra2008=health_infra2008+podes2008_r604c_2*`polikl_score' if podes2008_r604c_2!=.
*r604c_2
replace health_infra2011=health_infra2011+podes2011_r704ck3*`polikl_score' if podes2011_r704ck3!=.
* #puskesmas
replace health_infra1996=health_infra1996+podes1996_b8r1ek2*`puskes_score' if podes1996_b8r1ek2!=.
replace health_infra2000=health_infra2000+podes2000_b8r1e2*`puskes_score' if podes2000_b8r1e2!=.
replace health_infra2003=health_infra2003+podes2003_b7r701d2*`puskes_score' if podes2003_b7r701d2!=.
replace health_infra2005=health_infra2005+podes2005_r603dk2*`puskes_score' if podes2005_r603dk2!=.
replace health_infra2008=health_infra2008+podes2008_r604d_2*`puskes_score' if podes2008_r604d_2!=.
replace health_infra2011=health_infra2011+podes2011_r704dk3*`puskes_score' if podes2011_r704dk3!=.
* #puskesmas pembantu
replace health_infra1996=health_infra1996+podes1996_b8r1fk2*`puskes_pem_score' if podes1996_b8r1fk2!=.
replace health_infra2000=health_infra2000+podes2000_b8r1f2*`puskes_pem_score' if podes2000_b8r1f2!=.
replace health_infra2003=health_infra2003+podes2003_b7r701e2*`puskes_pem_score' if podes2003_b7r701e2!=.
replace health_infra2005=health_infra2005+podes2005_r603ek2*`puskes_pem_score' if podes2005_r603ek2!=.
replace health_infra2008=health_infra2008+podes2008_r604e_2*`puskes_pem_score' if podes2008_r604e_2!=.
replace health_infra2011=health_infra2011+podes2011_r704ek3*`puskes_pem_score' if podes2011_r704ek3!=.
* #farmasi/apotek
replace health_infra1996=health_infra1996+podes1996_b8r1jk2*`farmasi_score' if	podes1996_b8r1jk2!=.
replace health_infra2000=health_infra1996+podes2000_b8r1l2*`farmasi_score' if	podes2000_b8r1l2!=.
replace health_infra2003=health_infra1996+podes2003_b7r701j2*`farmasi_score' if	podes2003_b7r701j2!=.
replace health_infra2005=health_infra1996+podes2005_r603jk2*`farmasi_score' if	podes2005_r603jk2!=.
replace health_infra2008=health_infra1996+podes2008_r604k_3*`farmasi_score' if	podes2008_r604k_3!=.
replace health_infra2011=health_infra1996+podes2011_r704kk3*`farmasi_score' if	podes2011_r704kk3!=.

/* demeaning and standardizing */
foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {
	qui gen health_infra_std`t'=health_infra`t'
	qui sum health_infra_std`t' if ever_treated==0
	qui local control_sd=`r(sd)'
	qui sum health_infra_std`t'
	qui local mn=`r(mean)'
	qui replace health_infra_std`t'=(health_infra_std`t'-`mn')/`control_sd'
	
}

/*
https://www.salaryexpert.com/salary/job/doctor/indonesia : 721215180
https://www.salaryexpert.com/salary/job/nurse-midwife/indonesia :377893542
 - October  13 2017,  2:30 PM
 
 Doctor = Midwife * 1.9
 

	# dokter pria		# dokter wanita		# bidan		*/
egen personnel1996=rowtotal(	podes1996_b8r2a1		podes1996_b8r2a2		podes1996_b8r2c		)
egen personnel2000=rowtotal(	podes2000_b8r2a1		podes2000_b8r2a2		podes2000_b8r2d		)
egen personnel2003=rowtotal(	podes2003_b7r703a1		podes2003_b7r703a2		podes2003_b7r703b1	)
egen personnel2005=rowtotal(	podes2005_r604a1		podes2005_r604a2		podes2005_r604c		)
egen personnel2008=rowtotal(	podes2008_r606a1		podes2008_r606a2		podes2008_r606c		)
egen personnel2011=rowtotal(	podes2011_r707a1		podes2011_r707a2		podes2011_r707c		)

egen doctor1996=rowtotal(	podes1996_b8r2a1		podes1996_b8r2a2			)
egen doctor2000=rowtotal(	podes2000_b8r2a1		podes2000_b8r2a2			)
egen doctor2003=rowtotal(	podes2003_b7r703a1		podes2003_b7r703a2			)
egen doctor2005=rowtotal(	podes2005_r604a1		podes2005_r604a2			)
egen doctor2008=rowtotal(	podes2008_r606a1		podes2008_r606a2			)
egen doctor2011=rowtotal(	podes2011_r707a1		podes2011_r707a2			)

foreach v of varlist doctor* personnel* {

	replace `v'=0 if `v'==.

}

foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {

	gen personnel_imputed`t'=1.9*doctor`t' + personnel`t'-doctor`t' // 1.9*doctors + midwives

}


/* STANDARDIZING AND CREATING THE INDEX */

foreach idx in "development" "educ" "health"  "religion" "services" "sick"  "crime" "crimef"  {
	foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {
		* this will identify indices which are bogus
		gen missingtag_`idx'_`t'=0
		local totalvars = 0
			
		/* demean variables */
		foreach v of varlist ``idx'_`t'' {
			disp "demeaning `idx' - `t' -  `v'"
			qui sum `v'
			local totalvars = `totalvars'+1 
			replace missingtag_`idx'_`t'=missingtag_`idx'_`t'+1 if `v'==.
		}
		* the maximum value of this variable will identify missing observations
		replace missingtag_`idx'_`t'=missingtag_`idx'_`t'/`totalvars'
		
		
		foreach v of varlist ``idx'_`t'' {
			*disp "demeaning `idx' - `t' -  `v'"
			qui sum `v'
			* only those observations need to be replaced to zero which correspond
			* to an actual observation (ie. if a village has no hospiatal,
			* the number of hospitals will be missing (and in reality it is zero)
			*, but if the village is not linked, than the number of everything 
			* will be missing which in turn cannot be treated as zeroes.
			* Development is a good indicator of overall missing data.
			qui replace `v'=0 if `v'==.&missingtag_development_`t'<.9

			qui sum `v' if ever_treated==0
			qui local control_sd=`r(sd)'
			qui sum `v'
			qui local mn=`r(mean)'
			qui replace `v'=(`v'-`mn')/`control_sd'
			qui sum `v' if ever_treated==0
			qui local sdc=`r(sd)'
			qui sum `v' if ever_treated==1
			qui local sdt=`r(sd)'	
			disp "standardized means for ctr: `sdc' and for tr: `sdt'"
			*disp "kurtosis of `v' (`idx' - `t'): `r(kurtosis)'"
		}
		
		/* create weights and index vars */
		disp "creating weights for `idx' `t' " // itt romlik el, a winsorizálással vmelyik változó elbaszódik
		qui corr ``idx'_`t''	, cov
		qui matrix invm = syminv(r(C))
		qui matrix ones=J(rowsof(invm),1,1)
		qui matrix onesT=ones'
		qui matrix denom = onesT*invm*ones
		qui matrix weights = invm*ones/denom[1,1]
		mat li weights
		*putexcel A1=matrix(weights, names) using "weights/`idx'`t'" , replace
		
		qui gen `idx'`t'=0

		local n = 0
		
		/* reweighting variables */
		
		foreach v of varlist ``idx'_`t''	{
			disp "weighting `v' "
			qui local n = `n'+1
			*qui replace `idx'`t'=`idx'`t'+(weights[`n',1]*`v')/denom[1,1]
			qui replace `idx'`t'=`idx'`t'+weights[`n',1]*`v'
		}
		*cap pca ``idx'_`t''
		*cap rotate
		*cap predict `idx'_pca`t'
	}
}

/* creating PROSPERITY and INFRASTRUCTURE indices, which are part of 
DEVELOPMENT index, and they thus the variables within need not be 
standardized again */


foreach idx in "infra" "prosp"  {
	foreach t in "1996" "2000" "2003" "2005" "2008" "2011" {
		foreach v of varlist ``idx'_`t'' {
			*disp "demeaning `idx' - `t' -  `v'"
			qui sum `v'
			* only those observations need to be replaced to zero which correspond
			* to an actual observation (ie. if a village has no hospiatal,
			* the number of hospitals will be missing (and in reality it is zero)
			*, but if the village is not linked, than the number of everything 
			* will be missing which in turn cannot be treated as zeroes.
			* Development is a good indicator of overall missing data.
			qui replace `v'=0 if `v'==.&missingtag_development_`t'<.9

			qui sum `v' if ever_treated==0
			qui local control_sd=`r(sd)'
			qui sum `v'
			qui local mn=`r(mean)'
			qui replace `v'=(`v'-`mn')/`control_sd'
			qui sum `v' if ever_treated==0
			qui local sdc=`r(sd)'
			qui sum `v' if ever_treated==1
			qui local sdt=`r(sd)'	
			disp "standardized means for ctr: `sdc' and for tr: `sdt'"
			*disp "kurtosis of `v' (`idx' - `t'): `r(kurtosis)'"
		}
		
		/* create weights and index vars */
		disp "creating weights for `idx' `t' " 
		qui corr ``idx'_`t''	, cov
		qui matrix invm = syminv(r(C))
		qui matrix ones=J(rowsof(invm),1,1)
		qui matrix onesT=ones'
		qui matrix denom = onesT*invm*ones
		qui matrix weights = invm*ones/denom[1,1]
		mat li weights
		*putexcel A1=matrix(weights, names) using "weights/`idx'`t'" , replace
		
		qui gen `idx'`t'=0

		local n = 0
		
		/* reweighting variables */
		
		foreach v of varlist ``idx'_`t''	{
			disp "weighting `v' "
			qui local n = `n'+1
			qui replace `idx'`t'=`idx'`t'+weights[`n',1]*`v'
		}

	}
}


/* RESHAPE */

keep id2011_1 podes2011_r1401* podes2003_b16r1603c crime*  development* ///
 religion* services* sick* health* educ* prosp* infra* pop* ///
 treatedby_*  bps_1999 bps_1996 bps_2011 ever_treated ///
 dist_camat* dist_bupati2000 dist_bupati2003 dist_bupati2005 dist_bupati2008 ///
dist_bupati2011 dist_otherbupati* merge_* missingtag* strid* ///
bps_moving* province_id educ_relig_share* health_infra* total_sick* personnel* ///
doctor* status* kelurahan* podes2008_r130*  podes2011_r140*  podes2003_b16r160* ///
podes1996_b12r* rev* 
*podes2011_1
/*
keep id2011_1 podes2011_r1401* podes2003_b16r1603c crime*  development* ///
 religion* services* sick* health* educ* prosp* infra* pop* ///
 treated*  bps_1999 bps_1996 bps_2011 treatedby* ///
 dist_camat* dist_bupati2000 dist_bupati2003 dist_bupati2005 dist_bupati2008 ///
dist_bupati2011 dist_otherbupati* merge_* missingtag* strid* ///
bps_moving* province_id educ_relig_share* health_infra* total_sick* personnel* ///
doctor* status* kelurahan* podes2008_r130*  podes2011_r140*  podes2003_b16r160* ///
podes1996_b12r* rev* 
*/



* island dummy
gen island = substr(id2011_1, 1, 1)
destring island, force replace


/* we find a nearest neighbor for which we can*/
*teffects nnmatch (development2011 development1996 religion1996 services1996 health1996 educ1996 pop1996 island) (ever_treated), ematch(island) osample(y) gen(matchA)
*gen obsno = _n
/*preserve
	keep id2011_1 matchA1
	duplicates drop matchA1, force
	rename matchA1 obsno
	rename id2011_1 first_neighbor
	tempfile matched_ids
	save `matched_ids'
restore

merge m:1 obsno using `matched_ids', gen(first_neighbor_match)*/


local reshape_vars1 = "dist_camat* dist_bupati* dist_otherbupati* crime*  crimef*  development* religion*  health* health_infra* total_sick* educ* prosp* infra* pop* sick* personnel* doctor* merge_* services*  treated*  status* kelurahan* rev*"
*local reshape_vars1 = "dist_camat* dist_bupati* dist_otherbupati* crime*  crimef*  development* religion*  health* health_infra* total_sick* educ* prosp* infra* pop* sick* personnel* doctor* merge_* services*  treatedby*  status* kelurahan* rev*"

local reshape_vars2 = "bps_moving missingtag_educ_ missingtag_health_ missingtag_development_ missingtag_crime_ missingtag_services_ missingtag_religion_ dist_camat dist_bupati dist_otherbupati crime  crimef development religion health health_infra health_infra_std total_sick personnel personnel_imputed doctor educ prosp infra pop   sick merge_ services services_pca treatedby_ educ_relig_share status kelurahan rev_own rev_kab rev_prop rev_centr rev_total rev_other rev_foregn rev_priv"
*local reshape_vars2 = "bps_moving missingtag_educ_ missingtag_health_ missingtag_development_ missingtag_crime_ missingtag_services_ missingtag_religion_ treatedby dist_camat dist_bupati dist_otherbupati crime  crimef development religion health health_infra health_infra_std total_sick personnel personnel_imputed doctor educ prosp infra pop   sick merge_ services services_pca treated educ_relig_share status kelurahan rev_own rev_kab rev_prop rev_centr rev_total rev_other rev_foregn rev_priv"

foreach v of varlist `reshape_vars1' {

	cap drop `v'1997
	cap drop `v'1998
	cap drop `v'1999
	cap drop `v'2001
	cap drop `v'2002
	cap drop `v'2004
	cap drop `v'2006
	cap drop `v'2007
	cap drop `v'2009
	cap drop `v'2010
	cap drop `v'2012
	cap drop `v'2013
	cap drop `v'2014

}

* insert index name here
reshape long `reshape_vars2', i(id2011_1) j(year)
drop if year==1997
drop if year==1998
drop if year==1999
drop if year==2001
drop if year==2002
drop if year==2004
drop if year==2006
drop if year==2007
drop if year==2009
drop if year==2010
drop if year==2012
drop if year==2013
drop if year==2014
drop if year<1996


egen id = group(id2011_1)
egen t = group(year)


* no data for crime in 1996
replace crime=. if year==1996


* generate log population
gen lpop = log(pop)

* generate treatment length


* population dummies
egen pop_mean = mean(pop), by(year)
gen below_mean = 0
replace below_mean = 1 if pop<pop_mean
egen pop_median = median(pop), by(year)
gen above_median = 0
replace above_median = 1 if pop>pop_median&pop!=.


* weight
drop pop_mean
egen pop_mean = mean(pop), by(id2011_1)

gen religious=0
replace religious=1 if religion>0

* re-standardize

foreach s in  "development" "services"   "health" "educ"  "religion" "crime" "sick" "prosp" "infra" {

	egen `s'_sd = sd(`s'), by(year)
	replace `s'=`s'/`s'_sd

}


* sharia index
/*
		qui corr typeB typeC typeE typeF typeG ///
			typeH typeI typeK typeM typeN typeO typeP	if treated==1, cov
		qui matrix invm = syminv(r(C))
		qui matrix ones=J(rowsof(invm),1,1)
		qui matrix onesT=ones'
		qui matrix denom = onesT*invm*ones
		qui matrix weights = invm*ones/denom[1,1]
		mat li weights
		
		qui gen sharia_index=0

		local n = 0
		
		/* reweighting variables */
		
		foreach v of varlist typeB typeC typeE typeF typeG ///
			typeH typeI typeK typeM typeN typeO typeP	{
			disp "weighting `v' "
			qui local n = `n'+1
			*qui replace `idx'`t'=`idx'`t'+(weights[`n',1]*`v')/denom[1,1]
			qui replace sharia_index=sharia_index+weights[`n',1]*`v' if treated==1
		}
*/


* set distances for 1996
tsset id t

replace dist_camat = f.dist_camat if year==1996
replace dist_bupati = f.dist_bupati if year==1996
replace dist_otherbupati = f.dist_otherbupati if year==1996
egen mean_dist_bupati_raw = mean(dist_bupati), by(id)
egen mean_dist_bupati = mean(dist_bupati), by(id bps_moving)
replace mean_dist_bupati = mean_dist_bupati_raw if mean_dist_bupati==.
gen remote=0
sum mean_dist_bupati, det
replace remote=1 if mean_dist_bupati>`r(p50)'


gen remote_raw=0
sum mean_dist_bupati_raw, det
replace remote_raw=1 if mean_dist_bupati_raw>`r(p50)'
la var remote "village is farther than median distance from regent's office"
gen log_dist_bupati = log(mean_dist_bupati)

egen local_median_dist_bupati=median(mean_dist_bupati), by(bps_moving)
gen locally_remote = 0
replace locally_remote = 1 if mean_dist_bupati>local_median_dist_bupati 

* jawa vs outer provinces
gen outer=0
replace outer=1 if island!=3

* splitting
gen split_event=0
replace split_event=1 if l.bps_moving!=bps_moving

/* treatment after revision 
replace treated=0
replace treated=1 if year==2000&treatedby_2000
replace treated=1 if year==2003&treatedby_2003
replace treated=1 if year==2005&treatedby_2005
replace treated=1 if year==2008&treatedby_2008
replace treated=1 if year==2011&treatedby_2011

gen treated2=treated
replace treated=1 if year==2000&treatedby_2000b==1
replace treated=1 if year==2003&treatedby_2003b==1
replace treated=1 if year==2005&treatedby_2005b==1
replace treated=1 if year==2008&treatedby_2008b==1
replace treated=1 if year==2011&treatedby_2011b==1*/


*treatment intensity
rename treatedby_ treated
egen first_treated = min(year) if treated==1, by(id2011_1)
gen treated_years = year-first_treated
tab treated_years
replace treated_years=0 if treated_years==.

*event study sample
gen event = 0
replace event = 1 if d.treated==1

gen event_window = 0 if event==1
replace event_window  = 1 if l.event==1
replace event_window  = 2 if l2.event==1
replace event_window  = 3 if l3.event==1
replace event_window  = 4 if l4.event==1
replace event_window  = 5 if l5.event==1
replace event_window  = -1 if f.event==1
replace event_window  = -2 if f2.event==1
replace event_window  = -3 if f3.event==1
replace event_window  = -4 if f4.event==1
replace event_window  = -5 if f5.event==1

cap gen e_sample = 0
replace e_sample = 1 if event==1 & year==2003
replace e_sample = 1 if event==1 & year==2005
egen event_sample = max(e_sample), by(id)

gen ew = event_window if abs(event_window)<=2
tab ew, gen(yr)

la var yr1 "-2 wave"
la var yr2 "-1 wave"
la var yr3 "Treatment wave"
la var yr4 "+1 wave"
la var yr5 "+2 wave"
la var yr1 "1996 wave"
la var yr2 "2000 wave"
la var yr3 "2003 wave"
la var yr4 "2005 wave"
la var yr5 "2008 wave"
replace ew = ew+3

foreach v of varlist yr1-yr5 {

	replace `v'=. if event_sample!=1

}

gen c_sample = 0
replace c_sample = 1 if event==1 & year==2011
egen control_sample = max(c_sample), by(id)

foreach v of varlist yr1-yr5 {

	replace `v'=0 if control_sample==1

}

replace yr1 =1 if control_sample==1 & year==1996
replace yr2 =1 if control_sample==1 & year==2000
replace yr3 =1 if control_sample==1 & year==2003
replace yr4 =1 if control_sample==1 & year==2005
replace yr5 =1 if control_sample==1 & year==2008


gen remote_quartiles=.
*sum mean_dist_bupati if event_sample==1, det

egen pctile33=pctile(mean_dist_bupati_raw) , by(bps_1996) p(33)
egen pctile66=pctile(mean_dist_bupati_raw) , by(bps_1996) p(66)
egen pctile25=pctile(mean_dist_bupati_raw) , by(bps_1996) p(25)
egen pctile75=pctile(mean_dist_bupati_raw) , by(bps_1996) p(75)
replace remote_quartiles = 1 if mean_dist_bupati>=pctile75&mean_dist_bupati!=.&event_sample==1
replace remote_quartiles = 0 if mean_dist_bupati<=pctile25&mean_dist_bupati!=.&event_sample==1

*bysort bps_moving year: replace remote_q=1 if mean_dist_bupati>=`r(p75)'&event_sample==1
*bysort bps_moving year: replace remote_q=0 if mean_dist_bupati<=`r(p25)'&event_sample==1


* control: those that had sharia AFTER the event study sample had sharia
/*
gen c_sample=0
replace c_sample=1 if event==1 & year==2011
egen control_sample = max(c_sample), by(id)
gen control_window=-2 if year==1996 & control_sample==1
replace control_window= -1 if year==2000 & control_sample==1
replace control_window= 0 if year==2003 & control_sample==1
replace control_window= 1 if year==2005 & control_sample==1
replace control_window= 2 if year==2008 & control_sample==1

gen treated_control_window=.
replace treated_control_window=event_window if event_sample==1&abs(event_window)<3
replace treated_control_window=control_window if control_sample==1

gen treatment_eventstudy=.
replace treatment_eventstudy=0 if control_sample==1
replace treatment_eventstudy=1 if event_sample==1

gen tcw =treated_control_window if abs(treated_control_window)<=2
tab tcw, gen(cyr)
la var cyr1 "-2 wave"
la var cyr2 "-1 wave"
la var cyr3 "Treatment wave"
la var cyr4 "+1 wave"
la var cyr5 "+2 wave"
replace tcw = tcw+3
*/
tsset id t

/* recode island dummy */ 
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

/*create winsored versions and dummy outcomes */
foreach s in  "development" "services"   "health" "health_infra" "health_infra_std" "educ"   "religion" "prosp" "infra" "sick" {

	winsor `s' , gen(`s'_w) p(0.01) 
	egen `s'_yearly_mean=mean(`s'), by(year)
	egen `s'_yearly_median=median(`s'), by(year)
	gen `s'_good_md = 0
	gen `s'_good_mn = 0
	replace `s'_good_md = 1 if `s'>`s'_yearly_median
	replace `s'_good_mn = 1 if `s'>`s'_yearly_mean
}

gen log_health_infra=log(1+health_infra)


* kelurahan

gen kh2000=1 if year==2000&kelurahan==1
egen kelurahan_2000=min(kh2000), by(id)
replace kelurahan_2000=0 if kelurahan_2000==.
drop kh2000


* merge masyumi
preserve
	use ../../data/crosswalk_with_masyumi.dta, clear
	duplicates drop bps_2011, force
	tempfile elec55
	save `elec55'
restore

merge m:1 bps_2011 using `elec55', gen (merge_election55)

egen masyumi = rowmean(Masyumi_DPR Masyumi_Konst)
replace masyumi=. if Masyumi_DPR==.&Masyumi_Konst==.

sum masyumi, det
gen masyumi_quart=.
replace masyumi_quart=1 if masyumi<=`r(p25)'
replace masyumi_quart=2 if masyumi>`r(p25)'&masyumi<=`r(p50)'
replace masyumi_quart=3 if masyumi>`r(p50)'&masyumi<=`r(p75)'
replace masyumi_quart=4 if masyumi>`r(p75)'&masyumi!=.
gen masy_treat = masyumi_quart*treated
tab year masy_treat

/* correct revenes by inflafion
http://www.inflation.eu/inflation-rates/indonesia/historic-inflation/cpi-inflation-indonesia.aspx
2011	5.061221707
2008	4.435778407
2005	3.541574387
2003	2.8413419
2000	
1996	1

*/

foreach v of varlist rev_own rev_kab rev_prop rev_centr rev_total rev_other rev_foregn rev_priv {
	
	replace `v'=`v'/5.061221707 if year==2011
	replace `v'=`v'/4.435778407 if year==2008
	replace `v'=`v'/3.541574387 if year==2005
	replace `v'=`v'/2.8413419 if year==2003
	replace `v'=`v'/2.183782607 if year==2000
	/* the data is in millions after 2003, but thousands before*/
	replace `v'=`v'*1000 if year>2003


}

gen revenue_years = 0
replace revenue_years = 1 if year==1996|year==2003|year==2008|year==2011
gen log_rev_total = log(rev_total)
gen log_rev_total_pc = log(rev_total/pop)


gen log_rev_kab = log(rev_kab)
gen log_rev_centr= log(rev_centr)
gen log_rev_own = log(rev_own)
*local ofile="podes_panel_long_yearly_70p.dta"

gen rev_share_kab = rev_kab/rev_total
gen rev_kab_pc = rev_kab/pop
gen rev_own_pc = rev_own/pop
gen rev_total_pc = rev_total / pop
gen rev_prop_pc = rev_prop/pop
gen rev_centr_pc = rev_centr/pop


foreach v of varlist podes2011_r1402a2k2 podes2011_r1402a1k2 podes2011_r1402a3k2 podes2011_r1402a4k2 {
	* recode dummies
	replace `v'=2-`v'


}
rename podes2011_r1402a2k2 development_transp
rename podes2011_r1402a1k2 development_educ
rename podes2011_r1402a3k2 development_infrastr
rename podes2011_r1402a4k2 development_econ

gen java=0
replace java=1 if island==3


save ../../data/`ofile', replace

stop
merge m:1 bps_moving year using ../../data/PANEL_indodapoer_102717_bps_moving_podes.dta, gen(merge_indodapoer)
keep if merge_indodapoer==3


/* create district financial statistics */

gen rev_percap = rev_totl_cr / sp_pop_totl
gen nat_rev_share = rev_nrrv_shr_cr / rev_totl_cr

foreach v of varlist rev_percap {
	
	replace `v'=`v'/5.061221707 if year==2011
	replace `v'=`v'/4.435778407 if year==2008
	replace `v'=`v'/3.541574387 if year==2005
	replace `v'=`v'/2.8413419 if year==2003
	replace `v'=`v'/2.183782607 if year==2000
	/* the data is in millions after 2003, but thousands before*/


}


gen log_rev_percap = log(rev_percap)
gen log_rev_kab_pc = log(rev_kab_pc)

rev_dak_cr rev_dau_cr rev_nrrv_shr_cr rev_osrv_cr rev_othr_cr rev_totl_cr rev_txrv_shr_cr sp_pop_totl
