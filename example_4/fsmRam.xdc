## This file is a general .xdc for the ARTY Rev. B
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal

set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clock]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clock]

###Misc. ChipKit signals
#set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports i_reset]

###Switches
#set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {i_enable[0]}]
#set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {i_enable[1]}]
#set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports {i_enable[2]}]


#set_property PACKAGE_PIN K13 [get_ports o_log_ram_full]
#set_property IOSTANDARD LVCMOS18 [get_ports o_log_ram_full]
#set_property PACKAGE_PIN J13 [get_ports {o_log_data_from_ram[15]}]
#set_property PACKAGE_PIN H17 [get_ports {o_log_data_from_ram[14]}]
#set_property PACKAGE_PIN G17 [get_ports {o_log_data_from_ram[13]}]
#set_property PACKAGE_PIN J14 [get_ports {o_log_data_from_ram[12]}]
#set_property PACKAGE_PIN H15 [get_ports {o_log_data_from_ram[11]}]
#set_property PACKAGE_PIN C16 [get_ports {o_log_data_from_ram[10]}]
#set_property PACKAGE_PIN C17 [get_ports {o_log_data_from_ram[9]}]
#set_property PACKAGE_PIN E18 [get_ports {o_log_data_from_ram[8]}]
#set_property PACKAGE_PIN D18 [get_ports {o_log_data_from_ram[7]}]
#set_property PACKAGE_PIN G18 [get_ports {o_log_data_from_ram[6]}]
#set_property PACKAGE_PIN F18 [get_ports {o_log_data_from_ram[5]}]
#set_property PACKAGE_PIN J17 [get_ports {o_log_data_from_ram[4]}]
#set_property PACKAGE_PIN J18 [get_ports {o_log_data_from_ram[3]}]
#set_property PACKAGE_PIN K15 [get_ports {o_log_data_from_ram[2]}]
#set_property PACKAGE_PIN J15 [get_ports {o_log_data_from_ram[1]}]
#set_property PACKAGE_PIN K16 [get_ports {o_log_data_from_ram[0]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[15]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[14]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[13]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[12]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[11]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[10]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[9]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[8]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[7]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[6]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[5]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[4]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[3]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[2]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[1]}]
#set_property IOSTANDARD LVCMOS18 [get_ports {o_log_data_from_ram[0]}]
