module fx2_timetag(
	fx2_clk,
	fx2_flags,
	fx2_slwr,
	fx2_slrd,
	fx2_sloe,
	fx2_wu2,
	fx2_pktend,
	fx2_fd,
	fx2_fifoadr,

	ext_clk,
	laser_en,
	detectors,
	led,

	debug
);
output [3:0] debug;

input	fx2_clk;
input	[2:0] fx2_flags;
output	fx2_slwr;
output	fx2_slrd;
output	fx2_sloe;
output	fx2_wu2;
output	fx2_pktend;
inout	[7:0] fx2_fd;
output	[1:0] fx2_fifoadr;

input	ext_clk;
input	[3:0] detectors;
output	[3:0] laser_en;
output	[1:0] led;

wire    clk;
wire	cmd_rdy;
wire	[7:0] cmd;

wire	sample_rdy;
wire	[7:0] sample;
wire	sample_ack;

wire	[7:0] reply;
wire	reply_rdy;
wire	reply_ack;
wire	reply_end;


/*altpll0 b2v_inst2(
	//.inclk0(ext_clk),
	.inclk0(fx2_clk),
	.c0(clk)
);*/
assign clk = fx2_clk;

wire [3:0] pulse_seq_operate;
assign led[1] = (pulse_seq_operate != 0);
timetag b2v_inst(
	.fx2_clk(fx2_clk),
	.cmd_wr(cmd_rdy),
	.cmd_in(cmd),

	.clk(clk),
	.detectors(detectors),
	//.detectors({3'b0, detectors[0]}),
	.laser_en(laser_en),

	.data_rdy(sample_rdy),
	.data(sample),
	.data_ack(sample_ack),

	.capture_operate(led[0]),
	.pulse_seq_operate(pulse_seq_operate)
);


fx2_bidir fx2_if(
	.fx2_clk(fx2_clk),
	.fx2_fd(fx2_fd),
	.fx2_flags(fx2_flags),
	.fx2_slrd(fx2_slrd),
	.fx2_slwr(fx2_slwr),
	.fx2_sloe(fx2_sloe),
	.fx2_wu2(fx2_wu2),
	.fx2_pktend(fx2_pktend),
	.fx2_fifoadr(fx2_fifoadr),
	
	.sample(sample),
	.sample_rdy(sample_rdy),
	.sample_ack(sample_ack),
	
	.cmd(cmd),
	.cmd_wr(cmd_rdy),
	
	.reply_rdy(reply_rdy),
	.reply(reply),
	.reply_ack(reply_ack),
	.reply_end(reply_end)
);

//`define DETECTORS_LED
`ifdef DETECTORS_LED
wire all_detectors = detectors[0] | detectors[1] | detectors[2] | detectors[3];
leddriver b2v_inst4(
	.clk(fx2_clk),
	.in(all_detectors),
	.out(led[1])
);
`endif

//`define CMD_RDY_LED
`ifdef CMD_RDY_LED
leddriver b2v_inst6(
	.clk(fx2_clk),
	.in(cmd_rdy),
	.out(led[0])
);
`endif

endmodule
