V_FLAGS=
ALTERA_ROOT=/home/bgamari
#ALTERA_ROOT=/opt/altera9.0/modelsim_ase
INCLUDES=-I${ALTERA_ROOT}/altera/verilog/src

LIB_FILES= \
	  event_tagger.v apdtimer_all.v clicklatch.v cmd_fifo.v cmd_parser.v \
	  sample_fifo.v sample_multiplexer.v strobe_bits_controller.v \
	  summator.v timetag.v fx2_timetag.v fx2_bidir.v leddriver.v \
	  ${ALTERA_ROOT}/altera/verilog/src/altera_mf.v

TIMETAG_BENCH_FILES=timetag_bench.v

FX2_TIMETAG_BENCH_FILES=fx2_fixture.v fx2_model.v fx2_timetag_bench.v


all : timetag_bench fx2_timetag_bench


timetag_bench : ${TIMETAG_BENCH_FILES} ${LIB_FILES}
	iverilog ${V_FLAGS} -o $@ ${INCLUDES} $+

fx2_timetag_bench : ${FX2_TIMETAG_BENCH_FILES} ${LIB_FILES}
	iverilog ${V_FLAGS} -o $@ ${INCLUDES} $+
