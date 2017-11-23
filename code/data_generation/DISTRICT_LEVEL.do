* set working directory - important for portability
clear

do set_working_directory.do

/* prepare auxiliary variables and data sources */
do prepare_dhs_variables.do
do generate_calendar.do
do election_clean.do
do create_consistent_regulation_list_revised110317.do
do prepare_55_election.do

do create_panel_from_growthandgovernment.do

do indodapoer/create_panel_from_indodapoer.do

do indodapoer/indodapoer_pre_analysis.do

