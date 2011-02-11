V_FLAGS=
ALTERA_ROOT=/home/bgamari
#ALTERA_ROOT=/opt/altera9.0/modelsim_ase
INCLUDES=-I${ALTERA_ROOT}/altera/verilog/src

LIB_FILES= \
	  event_tagger.v apdtimer_all.v clicklatch.v \
	  reg_manager.v register.v \
	  sample_fifo.v sample_multiplexer.v \
	  timetag.v fx2_timetag.v fx2_bidir.v \
	  ${ALTERA_ROOT}/altera/verilog/src/altera_mf.v

TIMETAG_BENCH_FILES=timetag_bench.v

FX2_TIMETAG_BENCH_FILES=fx2_test_fixture.v fx2_timetag_bench.v

PROGS=timetag_bench fx2_timetag_bench
all : ${PROGS}
clean :
	rm -f ${PROGS}

timetag_bench : ${TIMETAG_BENCH_FILES} ${LIB_FILES}
	iverilog ${V_FLAGS} -o $@ ${INCLUDES} $+

fx2_timetag_bench : ${FX2_TIMETAG_BENCH_FILES} ${LIB_FILES}
	iverilog ${V_FLAGS} -o $@ ${INCLUDES} $+

