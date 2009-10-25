module fx2_timetag(
	fx2_clk,
	fx2_flags,
	fx2_SLWR,
	fx2_SLRD,
	fx2_SLOE,
	fx2_WU2,
	fx2_PKTEND,
	fx2_FD,
	fx2_FIFOADR,

	ext_clk,
	laser_en,
	detectors,
	led,
	running,

	debug
);
output [3:0] debug;

input	fx2_clk;
input	[2:0] fx2_flags;
output	fx2_SLWR;
output	fx2_SLRD;
output	fx2_SLOE;
output	fx2_WU2;
output	fx2_PKTEND;
inout	[7:0] fx2_FD;
output	[1:0] fx2_FIFOADR;

input	ext_clk;
input	[3:0] detectors;
output	[3:0] laser_en;
output	[1:0] led;
output  running;

wire    clk;
wire	[7:0] data;
wire	data_available;
wire	[15:0] length;
wire	PKTEND;
wire	request_length;
wire	cmd_avail;
wire	[7:0] cmd;
wire	data_accepted;


/*
altpll0 b2v_inst2(
	//.inclk0(ext_clk),
	.inclk0(fx2_clk),
	.c0(clk)
);*/
assign clk = fx2_clk;

timetag b2v_inst(
	.fx2_clk(fx2_clk),
	.cmd_wr(cmd_avail),
	.cmd_in(cmd),

	.clk(clk),
	.detectors(detectors),
	//.detectors({3'b0, detectors[0]}),
	.laser_en(laser_en),
	.running(running),

	.data_avail(data_available),
	.data(data),
	.data_accepted(data_accepted),
	
	.request_length(request_length),
	.length(length)
);


FX2_bidir b2v_inst1(
	.FX2_CLK(fx2_clk),
	.FX2_FD(fx2_FD),
	.FX2_flags(fx2_flags),
	.FX2_SLRD(fx2_SLRD),
	.FX2_SLWR(fx2_SLWR),
	.FX2_SLOE(fx2_SLOE),
	.FX2_WU2(fx2_WU2),
	.FX2_PKTEND(fx2_PKTEND),
	
	.FPGA_WORD_AVAILABLE(data_available),
	.FPGA_WORD(data),
	.FPGA_WORD_ACCEPTED(data_accepted),
	
	.CMD(cmd),
	.CMD_WR(cmd_avail),
	.REQUEST_LENGTH(request_length),
	.LENGTH(length),
	.FX2_FIFOADR(fx2_FIFOADR),
	.state(debug)
);

wire all_detectors = detectors[0] | detectors[1] | detectors[2] | detectors[3];
leddriver b2v_inst4(
	.clk(fx2_clk),
	.in(all_detectors),
	.out(led[1]));

leddriver b2v_inst6(
	.clk(fx2_clk),
	.in(cmd_avail),
	.out(led[0]));

//assign debug[3:0] = { data_available, data_accepted, cmd_avail, request_length };

/*
leddriver	b2v_inst7(
	.clk(fx2_clk),
	.in(data_available),
	.out(LED[1]));
*/

endmodule
