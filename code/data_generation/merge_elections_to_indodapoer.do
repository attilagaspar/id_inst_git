use ../data/PANEL_indodapoer_102717_bps_moving.dta, clear
merge 1:1 bps_2014 year using ../data/elections/election_cycle_data, gen(merge_elections_and_sharia)
drop if merge_elections_and_sharia==3

* create averages for non-election years

