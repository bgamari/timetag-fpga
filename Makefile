SIM_FILES= \
	  allclickreg.v apdtimer_all.v clicklatch.v cmd_fifo_bb.v \
	  cmd_parser.v cntrl_pulse_sequencer.v \
	  pulseseq.v \
	  sample_fifo_bb.v sample_multiplexer.v strobe_bits_controller.v \
	  summator.v timetag.v timetag_bench.v

timetag_bench : ${SIM_FILES}
	iverilog -o $@ $+


test : test.v cmd_fifo_bb.v
	iverilog -o $@ $+
