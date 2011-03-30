set_time_format -unit ns -decimal_places 3

create_clock -name {fx2_clk} -period 33.333 -waveform { 0.000 16.666 } [get_ports {fx2_clk}]
create_clock -name {ext_clk} -period 31.250 -waveform { 0.000 16.000 } [get_ports {ext_clk}]

create_generated_clock -name {sample_clk} -source [get_pins {b2v_inst2|altpll_component|pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 5 -master_clock {ext_clk} [get_pins {b2v_inst2|altpll_component|pll|clk[0]}] 

# Constrain FX2 interface ports
set_input_delay -clock fx2_clk -max 9ns [get_ports {fx2_fd*}]
set_input_delay -clock fx2_clk -min 0ns [get_ports {fx2_fd*}]
set_output_delay -clock fx2_clk -max 9ns [get_ports {fx2_fd*}]
set_output_delay -clock fx2_clk -min 0ns [get_ports {fx2_fd*}]

set_input_delay -clock fx2_clk -max 9ns [get_ports {fx2_flags*}]
set_input_delay -clock fx2_clk -min 0ns [get_ports {fx2_flags*}]

set_output_delay -clock fx2_clk -max 9ns [get_ports {fx2_sl*}]
set_output_delay -clock fx2_clk -min 0ns [get_ports {fx2_sl*}]

set_output_delay -clock fx2_clk -max 9ns [get_ports {fx2_fifoadr*}]
set_output_delay -clock fx2_clk -min 0ns [get_ports {fx2_fifoadr*}]

set_output_delay -clock fx2_clk -max 9ns [get_ports {fx2_pktend*}]
set_output_delay -clock fx2_clk -min 0ns [get_ports {fx2_pktend*}]

# Constrain input ports
# Try setting a minimum delay with a maximum delay in hopes that this
# gives the fitter more flexibility
set_input_delay -clock sample_clk -max 5ns [get_ports {strobe_in*}]
set_input_delay -clock sample_clk -min 2ns [get_ports {strobe_in*}]

# LED timing doesn't matter
set_output_delay -clock fx2_clk -max 0ns [get_ports {led*}]
set_output_delay -clock fx2_clk -min 1ns [get_ports {led*}]

# Set control paths as multicycle
set_false_path -from {*|register:*|value*} -to {*}

# Pulse sequencer can have a bit of delay
set_false_path -from {*|sequencer:*|seq_channel:*|out} -to {*|event_tagger:*|*}
set_max_delay -from {*|sequencer:*|seq_channel:*|out} -to {*|event_tagger:*|*} 10

# Counters are not cycle accurate (FIXME)
set_false_path -from {*|counter_register:*|reset*} -to {*|counter_register:*|my_value*}
set_false_path -from {*|counter_register:*|my_value*} -to {*|counter_register:*|value*}

