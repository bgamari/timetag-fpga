set_time_format -unit ns -decimal_places 3

# We create two clocks for the FX2. The use of a virtual external clock
# was suggested at http://www.alteraforum.com/forum/showthread.php?t=4921
# fx2_clk represents the FX2 clock used by the FPGA
create_clock -name {fx2_clk} -period 33.333  [get_ports {fx2_clk}]
# ext_fx2_clk represents the phase-shifted clock used by the FX2
create_clock -name {ext_fx2_clk} -period 33.333

# Crystal oscillator from which sample_clk is generated
create_clock -name {ext_clk} -period 31.250  [get_ports {ext_clk}]

create_generated_clock -name {sample_clk} -source [get_pins {b2v_inst2|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -master_clock {ext_clk} [get_pins {b2v_inst2|altpll_component|pll|clk[0]}] 


# Constrain FX2 interface ports
# These numbers are taken from the EZ-USB datasheet, chapter 9
# Section 9.7
set_output_delay -clock fx2_clk -min 0ns [get_ports {fx2_slrd}]
set_output_delay -clock fx2_clk -max 18.7ns [get_ports {fx2_slrd}]
set_input_delay -clock fx2_clk -max 9.2ns [get_ports {fx2_fd*}]
set_input_delay -clock fx2_clk -min 0ns [get_ports {fx2_fd*}]
set_input_delay -clock fx2_clk -max 9.5ns [get_ports {fx2_flags*}]
set_input_delay -clock fx2_clk -min 9.5ns [get_ports {fx2_flags*}]

# Section 9.10
set_output_delay -clock fx2_clk -min 0ns [get_ports {fx2_slwr}]
set_output_delay -clock fx2_clk -max 10.4ns [get_ports {fx2_slwr}]
set_output_delay -clock fx2_clk -max 9.2ns [get_ports {fx2_fd*}]
set_output_delay -clock fx2_clk -min 0ns [get_ports {fx2_fd*}]

# Section 9.15
set_output_delay -clock fx2_clk -min -10ns [get_ports {fx2_fifoadr*}]
set_output_delay -clock fx2_clk -max 25ns [get_ports {fx2_fifoadr*}]

# Section 9.11
set_output_delay -clock fx2_clk -max 9.5ns [get_ports {fx2_pktend*}]
set_output_delay -clock fx2_clk -min 0ns [get_ports {fx2_pktend*}]


# Constrain input ports
# Try setting a minimum delay with a maximum delay in hopes that this
# gives the fitter more flexibility
set_input_delay -clock sample_clk -min -10ns [get_ports {strobe_in*}]
set_input_delay -clock sample_clk -max 10ns [get_ports {strobe_in*}]

# LED timing doesn't matter
set_output_delay -clock fx2_clk -max -100ns [get_ports {led*}]
set_output_delay -clock fx2_clk -min 100ns [get_ports {led*}]

# Set control paths as multicycle
set_false_path -from {*|register:*|value*} -to {*}

# Pulse sequencer can have a bit of delay
#set_false_path -from {*|sequencer:*|seq_channel:*|out} -to {*|event_tagger:*|*}
#set_max_delay -from {*|sequencer:*|seq_channel:*|out} -to {*|event_tagger:*|*} 10ns

# Counters are not cycle accurate (FIXME)
set_false_path -from {*|counter_register:*|reset*} -to {*|counter_register:*|my_value*}
set_false_path -from {*|counter_register:*|my_value*} -to {*|counter_register:*|value*}

