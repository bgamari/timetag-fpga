## Generated SDC file "timetag.sdc"

## Copyright (C) 1991-2010 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 10.1 Build 153 11/29/2010 SJ Web Edition"

## DATE    "Sat Feb 12 16:03:31 2011"

##
## DEVICE  "EP2C5T144C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {fx2_clk} -period 33.333 -waveform { 0.000 16.666 } [get_ports {fx2_clk}]
create_clock -name {ext_clk} -period 50.000 -waveform { 0.000 25.000 } [get_ports {ext_clk}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {b2v_inst2|altpll_component|pll|clk[0]} -source [get_pins {b2v_inst2|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -master_clock {ext_clk} [get_pins {b2v_inst2|altpll_component|pll|clk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_d09:dffpipe20|dffe21a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_c09:dffpipe17|dffe18a*}]
set_false_path -from [get_registers {timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[0] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[1] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[2] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[3] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[4] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[5] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[6] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[7] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[0] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[1] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[2] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[3] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[4] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[5] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[6] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[7] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[0] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[1] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[2] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[3] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[4] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[5] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[6] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[7]}] -to [get_registers {timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[0] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[1] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[2] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[3] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[4] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[5] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[6] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[7] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[8] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[9] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[10] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[11] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[12] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[13] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[14] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[15] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[16] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[17] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[18] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[19] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[20] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[21] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[22] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[23] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[24] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[25] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[26] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[27] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[28] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[29] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[30] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[31] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[32] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[33] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[34] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[35] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[36] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[37] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[38] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[39] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[45] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|data[46] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|old_delta[0] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|old_delta[1] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|old_delta[2] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|old_delta[3] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|ready timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[0] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[1] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[2] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[3] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[4] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[5] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[6] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[7] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[8] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[9] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[10] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[11] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[12] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[13] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[14] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[15] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[16] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[17] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[18] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[19] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[20] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[21] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[22] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[23] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[24] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[25] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[26] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[27] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[28] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[29] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[30] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[31] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[32] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[33] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[34] timetag:tagger|apdtimer_all:apdtimer|event_tagger:tagger|timer[35] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[0] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[1] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[2] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[3] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[4] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[5] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[6] timetag:tagger|apdtimer_all:apdtimer|register:apdtimer_reg|value[7] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[0] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[1] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[2] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[3] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[4] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[5] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[6] timetag:tagger|apdtimer_all:apdtimer|register:delta_operate_reg|value[7] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[0] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[1] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[2] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[3] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[4] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[5] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[6] timetag:tagger|apdtimer_all:apdtimer|register:strobe_operate_reg|value[7] timetag:tagger|apdtimer_all:apdtimer|strobe_latch:latch0|out timetag:tagger|apdtimer_all:apdtimer|strobe_latch:latch0|state timetag:tagger|apdtimer_all:apdtimer|strobe_latch:latch1|out timetag:tagger|apdtimer_all:apdtimer|strobe_latch:latch1|state timetag:tagger|apdtimer_all:apdtimer|strobe_latch:latch2|out timetag:tagger|apdtimer_all:apdtimer|strobe_latch:latch2|state timetag:tagger|apdtimer_all:apdtimer|strobe_latch:latch3|out timetag:tagger|apdtimer_all:apdtimer|strobe_latch:latch3|state}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

