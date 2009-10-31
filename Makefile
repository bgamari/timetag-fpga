LIB_FILES= \
	  allclickreg.v apdtimer_all.v clicklatch.v cmd_fifo_bb.v \
	  cmd_parser.v cntrl_pulse_sequencer.v \
	  pulseseq.v \
	  sample_fifo_bb.v sample_multiplexer.v strobe_bits_controller.v \
	  summator.v timetag.v fx2_timetag.v FX2_bidir.v leddriver.v

TIMETAG_BENCH_FILES=timetag_bench.v

FX2_TIMETAG_BENCH_FILES=fx2_fixture.v fx2_model.v fx2_timetag_bench.v


all : timetag_bench fx2_timetag_bench test


timetag_bench : ${TIMETAG_BENCH_FILES} ${LIB_FILES}
	iverilog -o $@ $+

fx2_timetag_bench : ${FX2_TIMETAG_BENCH_FILES} ${LIB_FILES}
	iverilog -o $@ $+

test : test.v cmd_fifo_bb.v
	iverilog -o $@ $+

