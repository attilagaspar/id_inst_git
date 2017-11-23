
clear

* set working directory - important for portability
do set_working_directory.do

* merge podes data to form panel
do podes/merge_podes_by_waves.do

* create index variables from podes panel
do podes/create_podes_indices_yearly_v2.do
